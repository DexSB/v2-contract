// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IERC20 } from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {
    IPaymentV1,
    PaymentRequestDto,
    PaymentDetail,
    TransferRequestDto
} from "./PaymentV1.sol";
import {
    Ticket,
    PlaceSingleBetDto,
    SingleBetTicket,
    PlaceOutrightBetDto,
    OutrightBetTicket
} from "./model/Ticket.sol";
import { PayoutCalculator } from "./lib/PayoutCalculator.sol";
import { TicketStatus } from "./constant/Status.sol";
import { IBetTypeHandler } from "./handler/IBetTypeHandler.sol";
import { Ownable } from "./proxy/Ownable.sol";
import { PausableUpgradeable } from "lib/openzeppelin-contracts-upgradeable/contracts/security/PausableUpgradeable.sol";

struct BetToken {
    bool isFreeBetToken;
    address payoutToken;
    bool isIncludeStake;
}

struct SettleBetDto {
    uint256 referenceId;
    uint256[] transIds;
}

struct RejectBetDto {
    uint256[] transIds;
}

struct CentralWalletTransferRequestDto {
    address token;
    address from;
    address to;
    uint256 amount;
}

interface IBettingV2 {
    event BetPlaced(uint256 transId);
    event TicketSettled(uint256 transId, uint256 amountToCustomer, TicketStatus status);
    event TicketRejected(uint256 transId);
    function placeSingleBet(PlaceSingleBetDto calldata dto) external;
    function placeOutrightBet(PlaceOutrightBetDto calldata dto) external;
    function settle(uint256[] calldata transIds) external;
    function reject(uint256[] calldata transIds) external;
    function setPayment(address newPayment) external;
    function setTransferer(address newTransferer) external;
    function setSettler(address newSettler) external;
    function setRejecter(address newRejecter) external;
    function validateBroker(address broker, bool isVaidate) external;
    function setSettleEngine(uint256 betType, address settleEngine) external;
}

contract BettingV2 is IBettingV2, Ownable, PausableUpgradeable {
    address private oracle;
    address private payment;
    address private transferer;
    address private settler;
    address private rejecter;
    mapping(address => bool) private validatedBrokers;
    mapping(address => BetToken) private tokens;
    mapping(uint256 => Ticket) private tickets;
    mapping(uint256 => address) private settleEngines;

    function initialize(address _oracle, address _payment, address _rejecter, address _settler) public initializer {
        Ownable.initialize();
        oracle = _oracle;
        payment = _payment;
        rejecter = _rejecter;
        settler = _settler;
    }

    function placeSingleBet(PlaceSingleBetDto calldata dto) external {
        require(validatedBrokers[msg.sender], "CustomErrors: sender is not a validated broker");
        if (tickets[dto.transId].isExist) {
            return;
        }

        (uint256 payout, uint256 stake) = PayoutCalculator.covertFromDisplayForm(dto.oddsType, dto.displayPrice, dto.displayStake);
        require(
            IPaymentV1(payment).collect(_createCollectRequestDto(dto.token, dto.payoutAddress, payout, dto.customer, stake)),
            "CustomErrors: collect token failed"
        );

        SingleBetTicket memory singleBetTicket = SingleBetTicket(
            dto.transId,
            dto.eventId,
            dto.keyHash,
            dto.liveHomeScore,
            dto.liveAwayScore,
            dto.hdp1,
            dto.hdp2,
            dto.sportType,
            dto.resource1,
            dto.resource2
        );

        tickets[dto.transId] = Ticket(dto.betType, dto.payoutAddress, payout, dto.customer, stake, dto.token, true, 1, abi.encode(singleBetTicket));
        emit BetPlaced(dto.transId);
    }

    function placeOutrightBet(PlaceOutrightBetDto calldata dto) external {
        require(validatedBrokers[msg.sender], "CustomErrors: sender is not a validated broker");
        if (tickets[dto.transId].isExist) {
            return;
        }

        (uint256 payout, uint256 stake) = PayoutCalculator.covertFromDisplayForm(dto.oddsType, dto.displayPrice, dto.displayStake);
        require(
            IPaymentV1(payment).collect(_createCollectRequestDto(dto.token, dto.payoutAddress, payout, dto.customer, stake)),
            "CustomErrors: collect token failed"
        );

        OutrightBetTicket memory outrightBetTicket = OutrightBetTicket(dto.leagueId, dto.teamId);
        tickets[dto.transId] = Ticket(10, dto.payoutAddress, payout, dto.customer, stake, dto.token, true, 1, abi.encode(outrightBetTicket));
        emit BetPlaced(dto.transId);
    }

    function settle(uint256[] calldata transIds) external override {
        require(msg.sender == settler, "CustomErrors: sender is not settler");
        for (uint256 i = 0; i < transIds.length; ++i) {
            Ticket memory ticket = tickets[transIds[i]];
            if (!ticket.isExist) {
                continue;
            }

            (TicketStatus ticketStatus, uint256 deadHeat) =
                IBetTypeHandler(settleEngines[ticket.betType]).settleTicket(address(oracle), ticket.betDetail);

            (uint256 amountToPayout, uint256 amountToCustomer) =
                PayoutCalculator.getPayoutByTicketStatus(
                    ticketStatus,
                    ticket.payout,
                    ticket.stake,
                    deadHeat,
                    tokens[ticket.token].isFreeBetToken,
                    tokens[ticket.token].isIncludeStake
                );
            
            require(
                IPaymentV1(payment).payout(_createSettlePaymentRequestDto(ticket, ticketStatus, amountToPayout, amountToCustomer)),
                "CustomErrors: payout failed"
            );
            delete tickets[transIds[i]];
            emit TicketSettled(transIds[i], amountToCustomer, ticketStatus);
        }
    }

    function reject(uint256[] calldata transIds) external override {
        require(msg.sender == rejecter, "CustomErrors: sender is not rejecter");
        for (uint256 i = 0; i < transIds.length; ++i) {
            Ticket memory ticket = tickets[transIds[i]];

            if (!ticket.isExist) {
                continue;
            }

            require(
                IPaymentV1(payment).payout(_createRejectPaymentRequestDto(ticket)),
                "CustomErrors: payout failed"
            );
            delete tickets[transIds[i]];
            emit TicketRejected(transIds[i]);
        }
    }

    function setPayment(address newPayment) external onlyOwner {
        payment = newPayment;
    }

    function setTransferer(address newTransferer) external onlyOwner {
        transferer = newTransferer;
    }

    function setSettler(address newSettler) external onlyOwner {
        settler = newSettler;
    }

    function setRejecter(address newRejecter) external onlyOwner {
        rejecter = newRejecter;
    }


    function validateBroker(address broker, bool isVaidate) external onlyOwner {
        validatedBrokers[broker] = isVaidate;
    }

    function setSettleEngine(uint256 betType, address settleEngine) external onlyOwner {
        settleEngines[betType] = settleEngine;
    }

    function _createCollectRequestDto(
        address token,
        address payoutAddress,
        uint256 payout,
        address customerAddress,
        uint256 stake
    ) internal view returns (PaymentRequestDto memory) {
        PaymentDetail[] memory paymentDetails = new PaymentDetail[](2);
        paymentDetails[0] = PaymentDetail(
            token,
            customerAddress,
            stake
        );

        BetToken memory betToken = tokens[token];
        if (betToken.isFreeBetToken) {
            uint256 amountFromPayout = payout;
            if (!betToken.isIncludeStake) {
                amountFromPayout -= stake;
            }

            paymentDetails[1] = PaymentDetail(
                betToken.payoutToken,
                payoutAddress,
                amountFromPayout
            );
        } else {
            paymentDetails[1] = PaymentDetail(
                token,
                payoutAddress,
                payout - stake
            );
        }

        return PaymentRequestDto(paymentDetails);
    }

    function _createRejectPaymentRequestDto(Ticket memory ticket) internal view returns (PaymentRequestDto memory) {
        PaymentDetail[] memory paymentDetails = new PaymentDetail[](2);
        paymentDetails[0] = PaymentDetail(
            ticket.token,
            ticket.customer,
            ticket.stake
        );

        BetToken memory betToken = tokens[ticket.token];
        if (betToken.isFreeBetToken) {
            uint256 amountToPayout = ticket.payout;
            if (!betToken.isIncludeStake) {
                amountToPayout -= ticket.stake;
            }

            paymentDetails[1] = PaymentDetail(
                betToken.payoutToken,
                ticket.payoutAddress,
                amountToPayout
            );
        } else {
            paymentDetails[1] = PaymentDetail(
                ticket.token,
                ticket.payoutAddress,
                ticket.payout - ticket.stake
            );
        }

        return PaymentRequestDto(paymentDetails);
    }

    function _createSettlePaymentRequestDto(Ticket memory ticket, TicketStatus ticketStatus, uint256 amountToPayout, uint256 amountToCustomer) internal view returns (PaymentRequestDto memory) {
        address tokenToCustomer;
        address tokenToPayout;
        BetToken memory betToken = tokens[ticket.token];
        if (
            betToken.isFreeBetToken &&
            (ticketStatus == TicketStatus.Won && ticketStatus == TicketStatus.HalfWon)) {
            tokenToCustomer = betToken.payoutToken;
        } else if (betToken.isFreeBetToken && amountToCustomer < ticket.stake) {
            tokenToCustomer = ticket.token;
            tokenToPayout = betToken.payoutToken;
        } else {
            tokenToCustomer = ticket.token;
            tokenToPayout = ticket.token;
        }

        PaymentDetail[] memory paymentDetails ;
        if (amountToPayout > 0 && amountToCustomer > 0) {
            paymentDetails = new PaymentDetail[](2);
            paymentDetails[0] = PaymentDetail(
                tokenToCustomer,
                ticket.customer,
                amountToCustomer
            );
            paymentDetails[1] = PaymentDetail(
                tokenToPayout,
                ticket.payoutAddress,
                amountToPayout
            );
        } else {
            paymentDetails = new PaymentDetail[](1);
            if (amountToCustomer > 0) {
                paymentDetails[0] = PaymentDetail(
                    tokenToCustomer,
                    ticket.customer,
                    amountToCustomer
                );
            } else {
                paymentDetails[0] = PaymentDetail(
                    tokenToPayout,
                    ticket.payoutAddress,
                    amountToPayout
                );
            }
        }

        return PaymentRequestDto(paymentDetails);
    }
}
