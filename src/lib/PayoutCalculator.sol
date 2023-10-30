// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { SignedMath } from "../../lib/openzeppelin-contracts/contracts/utils/math/SignedMath.sol";
import { OddsType } from "../constant/OddsType.sol";
import { TicketStatus } from "../constant/Status.sol";

library PayoutCalculator {
    using SignedMath for int256;

    function covertFromDisplayForm(
        OddsType oddsType,
        int256 displayPrice,
        uint256 displayStake
    ) internal pure returns (uint256 payout, uint256 stake) {
        uint256 priceFactor = 100;
        if (oddsType == OddsType.Decimal) {
            payout = (uint256(displayPrice) * displayStake) / priceFactor;
            stake = displayStake;
        } else if (oddsType == OddsType.HongKong) {
            uint256 price = uint256(displayPrice) + (1 * priceFactor);
            payout = (price * displayStake) / priceFactor;
            stake = displayStake;
        } else if (oddsType == OddsType.Indo) {
            payout = 0;
            stake = 0;
        } else if (oddsType == OddsType.Malay) {
            if (displayPrice > 0) {
                uint256 price = uint256(displayPrice) + (1 * priceFactor);
                payout = (price * displayStake) / priceFactor;
                stake = displayStake;
            } else {
                uint256 priceAbs = displayPrice.abs();
                payout = ((priceAbs * displayStake) / priceFactor) + displayStake;
                stake = (priceAbs * displayStake) / priceFactor;
            }
        } else if (oddsType == OddsType.American) {
            payout = 0;
            stake = 0;
        }
    }

    function getPayoutByTicketStatus(
        TicketStatus ticketStatus,
        uint256 payout,
        uint256 stake,
        uint256 deadHeat,
        bool isFreeBet,
        bool isPayoutInludeStake
    ) internal pure returns (uint256 amountToPayout, uint256 amountToCustomer) {
        if (ticketStatus == TicketStatus.Won) {
            amountToCustomer = (payout - stake) / deadHeat;
            amountToPayout = payout - stake - amountToCustomer;
            if (!isFreeBet || isPayoutInludeStake) {
                amountToCustomer += stake;
            }
        } else if (ticketStatus == TicketStatus.HalfWon) {
            amountToCustomer = (payout - stake) / 2;
            amountToPayout = (payout - stake) / 2;
            if (!isFreeBet) {
                amountToCustomer += stake;
            }
        } else if (
            ticketStatus == TicketStatus.Draw ||
            ticketStatus == TicketStatus.Refund
        ) {
            amountToCustomer = stake;
            amountToPayout = payout - stake;
        } else if (ticketStatus == TicketStatus.HalfLost) {
            amountToCustomer = stake / 2;
            amountToPayout = payout - stake;
            if (!isFreeBet) {
                amountToPayout += stake / 2;
            }
        } else if (ticketStatus == TicketStatus.Lost) {
            amountToPayout = payout;
            if (isFreeBet) {
                amountToPayout -= stake;
            }
        }
    }
}
