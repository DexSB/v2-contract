// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IBetTypeHandler } from "./IBetTypeHandler.sol";
import { TicketStatus } from "../constant/Status.sol";
import { IOracleV1 } from "../OracleV1.sol";
import { SingleBetTicket } from "../model/Ticket.sol";
import { ResultStatus } from "../constant/Status.sol";
import { BetType } from "../constant/BetType.sol";
import { SportType } from "../constant/SportType.sol";
import { KeyHash } from "../constant/KeyHash.sol";
import { RefundChecker } from "../lib/RefundChecker.sol";

contract HTMoneylineHandler is IBetTypeHandler {
    function settleTicket(address oracle, bytes memory ticketBytes) external view returns (TicketStatus status, uint256 deadHeat) {
        SingleBetTicket memory ticket = abi.decode(ticketBytes, (SingleBetTicket));
        ResultStatus resultStatus = IOracleV1(oracle).getEventStatus(ticket.eventId, BetType.HTMoneyline, 0);
        bool isRefund = RefundChecker.getIsRefund(BetType.HTMoneyline, resultStatus, ticket.resource1);
        if (isRefund) {
            return (TicketStatus.Refund, 1);
        }

        (uint256 homeScore, uint256 awayScore) = IOracleV1(oracle).getScore(
            ticket.eventId,
            ticket.sportType,
            BetType.HTMoneyline,
            0
        );

        homeScore *= 100;
        awayScore *= 100;

        int256 ticketResult = int256(homeScore) - int256(awayScore);
        bytes32 resultHash;
        if (ticketResult > 0) {
            resultHash = KeyHash.LowerCaseH;
        } else if (ticketResult < 0) {
            resultHash = KeyHash.LowerCaseA;
        } else {
            return (TicketStatus.Draw, 1);
        }

        if (ticket.keyHash == resultHash) {
            return (TicketStatus.Won, 1);
        } else {
            return (TicketStatus.Lost, 1);
        }
    }
}
