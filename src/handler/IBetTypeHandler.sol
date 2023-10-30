// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { TicketStatus } from "../constant/Status.sol";

interface IBetTypeHandler {
    function settleTicket(address oracle, bytes memory ticketBytes) external returns (TicketStatus, uint256);
}
