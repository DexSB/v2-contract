// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { PayoutCalculator } from "../../src/lib/PayoutCalculator.sol";
import { OddsType } from "../../src/constant/OddsType.sol";
import { OracleV1 } from "../../src/OracleV1.sol";
import { SingleBetTicket } from "../../src/model/Ticket.sol";
import { SportType } from "../../src/constant/SportType.sol";
import { FT1x2Handler } from "../../src/handler/FT1x2Handler.sol";
import { TicketStatus, ResultStatus } from "../../src/constant/Status.sol";

contract FT1x2HandlerTest is Test {
    FT1x2Handler private handler;

    address private oracle = makeAddr("oracle");

    function setUp() public {
        handler = new FT1x2Handler();
    }

    function test_settleTicket_with_static_case() public {
        TicketStatus ticketStatus;
        uint256 deadHeat;

        _mock_OracleV1_getEventStatus_completed();
        _given_OracleV1_getScore(1, 0);
        (ticketStatus, deadHeat) = handler.settleTicket(address(oracle), _given_SingleBetTicketBytes("1"));
        assertEq(uint256(ticketStatus), uint256(TicketStatus.Won));
        assertEq(deadHeat, 1);
        (ticketStatus, deadHeat) = handler.settleTicket(address(oracle), _given_SingleBetTicketBytes("x"));
        assertEq(uint256(ticketStatus), uint256(TicketStatus.Lost));
        assertEq(deadHeat, 1);
        (ticketStatus, deadHeat) = handler.settleTicket(address(oracle), _given_SingleBetTicketBytes("2"));
        assertEq(uint256(ticketStatus), uint256(TicketStatus.Lost));
        assertEq(deadHeat, 1);

        _given_OracleV1_getScore(0, 0);
        (ticketStatus, deadHeat) = handler.settleTicket(address(oracle), _given_SingleBetTicketBytes("1"));
        assertEq(uint256(ticketStatus), uint256(TicketStatus.Lost));
        assertEq(deadHeat, 1);
        (ticketStatus, deadHeat) = handler.settleTicket(address(oracle), _given_SingleBetTicketBytes("x"));
        assertEq(uint256(ticketStatus), uint256(TicketStatus.Won));
        assertEq(deadHeat, 1);
        (ticketStatus, deadHeat) = handler.settleTicket(address(oracle), _given_SingleBetTicketBytes("2"));
        assertEq(uint256(ticketStatus), uint256(TicketStatus.Lost));
        assertEq(deadHeat, 1);

        _given_OracleV1_getScore(0, 1);
        (ticketStatus, deadHeat) = handler.settleTicket(address(oracle), _given_SingleBetTicketBytes("1"));
        assertEq(uint256(ticketStatus), uint256(TicketStatus.Lost));
        assertEq(deadHeat, 1);
        (ticketStatus, deadHeat) = handler.settleTicket(address(oracle), _given_SingleBetTicketBytes("x"));
        assertEq(uint256(ticketStatus), uint256(TicketStatus.Lost));
        assertEq(deadHeat, 1);
        (ticketStatus, deadHeat) = handler.settleTicket(address(oracle), _given_SingleBetTicketBytes("2"));
        assertEq(uint256(ticketStatus), uint256(TicketStatus.Won));
        assertEq(deadHeat, 1);
    }

    function test_settleTicket_with_refund() public {
        TicketStatus ticketStatus;
        uint256 deadHeat;

        _mock_OracleV1_getEventStatus_refund();
        _given_OracleV1_getScore(1, 0);
        (ticketStatus, deadHeat) = handler.settleTicket(address(oracle), _given_SingleBetTicketBytes("1"));
        assertEq(uint256(ticketStatus), uint256(TicketStatus.Refund));
        assertEq(deadHeat, 1);
        (ticketStatus, deadHeat) = handler.settleTicket(address(oracle), _given_SingleBetTicketBytes("x"));
        assertEq(uint256(ticketStatus), uint256(TicketStatus.Refund));
        assertEq(deadHeat, 1);
        (ticketStatus, deadHeat) = handler.settleTicket(address(oracle), _given_SingleBetTicketBytes("2"));
        assertEq(uint256(ticketStatus), uint256(TicketStatus.Refund));
        assertEq(deadHeat, 1);
    }

    function _given_OracleV1_getScore(
        uint256 homeScore,
        uint256 awayScore
    ) internal {
        vm.mockCall(address(oracle), abi.encodeWithSelector(OracleV1.getScore.selector), abi.encodePacked(homeScore, awayScore));
    }

    function _mock_OracleV1_getEventStatus_completed() internal {
        vm.mockCall(address(oracle), abi.encodeWithSelector(OracleV1.getEventStatus.selector), abi.encode(ResultStatus.Completed));
    }

    function _mock_OracleV1_getEventStatus_refund() internal {
        vm.mockCall(address(oracle), abi.encodeWithSelector(OracleV1.getEventStatus.selector), abi.encode(ResultStatus.Refund));
    }

    function _given_SingleBetTicketBytes(string memory key) public pure returns (bytes memory) {
        return abi.encode(
            SingleBetTicket(
                1, 1, keccak256(abi.encode(key)), 0, 0, 0, 0, SportType.Soccer, 0, 0
            )
        );
    }
}
