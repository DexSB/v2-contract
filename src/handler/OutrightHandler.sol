// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IBetTypeHandler } from "./IBetTypeHandler.sol";
import { TicketStatus } from "../constant/Status.sol";
import { IOracleV1 } from "../OracleV1.sol";
import { OutrightBetTicket } from "../model/Ticket.sol";
import { OutrightTeamStatus } from "../constant/Status.sol";
import { BetType } from "../constant/BetType.sol";
import { SportType } from "../constant/SportType.sol";
import { KeyHash } from "../constant/KeyHash.sol";
import { RefundChecker } from "../lib/RefundChecker.sol";

contract OutrightHandler is IBetTypeHandler {
    function settleTicket(address oracle, bytes memory ticketBytes) external view returns (TicketStatus status, uint256 deadHeat) {
        OutrightBetTicket memory ticket = abi.decode(ticketBytes, (OutrightBetTicket));
        (OutrightTeamStatus teamStatus, uint256 outrightDeadHeat) =
            IOracleV1(oracle).getOutrightResult(ticket.leagueId, ticket.teamId);
        
        if (teamStatus == OutrightTeamStatus.Won) {
            return (TicketStatus.Won, outrightDeadHeat);
        } else if (teamStatus == OutrightTeamStatus.Refund) {
            return (TicketStatus.Refund, outrightDeadHeat);
        } else {
            return (TicketStatus.Lost, outrightDeadHeat);
        }
    }
}
