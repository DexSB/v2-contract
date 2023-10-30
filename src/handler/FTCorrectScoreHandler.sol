// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IBetTypeHandler } from "./IBetTypeHandler.sol";
import { TicketStatus } from "../constant/Status.sol";
import { IOracleV1 } from "../OracleV1.sol";
import { SingleBetTicket } from "../model/Ticket.sol";
import { ResultStatus } from "../constant/Status.sol";
import { BetType } from "../constant/BetType.sol";
import { RefundChecker } from "../lib/RefundChecker.sol";

contract FTCorrectScoreHandler is IBetTypeHandler {
    function settleTicket(address oracle, bytes memory ticketBytes) external view returns (TicketStatus status, uint256 deadHeat) {
        SingleBetTicket memory ticket = abi.decode(ticketBytes, (SingleBetTicket));
        ResultStatus resultStatus = IOracleV1(oracle).getEventStatus(ticket.eventId, BetType.FTCorrectScore, ticket.resource1);
        bool isRefund = RefundChecker.getIsRefund(BetType.FTCorrectScore, resultStatus, ticket.resource1);
        if (isRefund) {
            return (TicketStatus.Refund, 1);
        }

        bytes32 resultHash = IOracleV1(oracle).getResultHash(
            ticket.eventId,
            ticket.sportType,
            BetType.FTCorrectScore,
            ticket.resource1
        );

        if (ticket.keyHash == resultHash) {
            return (TicketStatus.Won, 1);
        } else {
            return (TicketStatus.Lost, 1);
        }
    }
}
