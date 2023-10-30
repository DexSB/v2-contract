// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { PayoutCalculator } from "../../src/lib/PayoutCalculator.sol";
import { OddsType } from "../../src/constant/OddsType.sol";
import { OracleV1 } from "../../src/OracleV1.sol";
import { SingleBetTicket } from "../../src/model/Ticket.sol";
import { SportType } from "../../src/constant/SportType.sol";
import { MatchPointHandicapHandler } from "../../src/handler/MatchPointHandicapHandler.sol";
import { TicketStatus, ResultStatus } from "../../src/constant/Status.sol";

contract MatchPointHandicapHandlerTest is Test {
    MatchPointHandicapHandler private handler;

    address private oracle = makeAddr("oracle");

    function setUp() public {
        handler = new MatchPointHandicapHandler();
    }

    function test_settleTicket_with_static_case() public {
        TicketStatus ticketStatus;
        uint256 deadHeat;
        _mock_OracleV1_getEventStatus_completed();

        _given_OracleV1_getScore(1, 1);
        (ticketStatus, deadHeat) = handler.settleTicket(address(oracle), _given_SingleBetTicketBytes("h", 0, 0));
        assertEq(uint256(ticketStatus), uint256(TicketStatus.Draw));
        assertEq(deadHeat, 1);
        (ticketStatus, deadHeat) = handler.settleTicket(address(oracle), _given_SingleBetTicketBytes("a", 0, 0));
        assertEq(uint256(ticketStatus), uint256(TicketStatus.Draw));
        assertEq(deadHeat, 1);

        _given_OracleV1_getScore(1, 0);
        (ticketStatus, deadHeat) = handler.settleTicket(address(oracle), _given_SingleBetTicketBytes("h", 0, 0));
        assertEq(uint256(ticketStatus), uint256(TicketStatus.Won));
        assertEq(deadHeat, 1);
        (ticketStatus, deadHeat) = handler.settleTicket(address(oracle), _given_SingleBetTicketBytes("a", 0, 0));
        assertEq(uint256(ticketStatus), uint256(TicketStatus.Lost));
        assertEq(deadHeat, 1);

        _given_OracleV1_getScore(0, 1);
        (ticketStatus, deadHeat) = handler.settleTicket(address(oracle), _given_SingleBetTicketBytes("h", 0, 0));
        assertEq(uint256(ticketStatus), uint256(TicketStatus.Lost));
        assertEq(deadHeat, 1);
        (ticketStatus, deadHeat) = handler.settleTicket(address(oracle), _given_SingleBetTicketBytes("a", 0, 0));
        assertEq(uint256(ticketStatus), uint256(TicketStatus.Won));
        assertEq(deadHeat, 1);
    }

    function test_settleTicket_half_won_lost_with_static_case() public {
        TicketStatus ticketStatus;
        uint256 deadHeat;
        uint256 homeScore = 1;
        uint256 awayScore = 1;

        _mock_OracleV1_getEventStatus_completed();
        _given_OracleV1_getScore(homeScore, awayScore);
        vm.mockCall(oracle, abi.encodeWithSelector(OracleV1.getResultHash.selector), abi.encodePacked(homeScore, awayScore));

        (ticketStatus, deadHeat) = handler.settleTicket(address(oracle), _given_SingleBetTicketBytes("h", 0, 25));
        assertEq(uint256(ticketStatus), uint256(TicketStatus.HalfWon));
        assertEq(deadHeat, 1);

        (ticketStatus, deadHeat) = handler.settleTicket(address(oracle), _given_SingleBetTicketBytes("a", 0, 25));
        assertEq(uint256(ticketStatus), uint256(TicketStatus.HalfLost));
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

    function _given_SingleBetTicketBytes(
        string memory key,
        uint256 hdp1,
        uint256 hdp2
    ) public pure returns (bytes memory) {
        return abi.encode(
            SingleBetTicket(
                1, 1, keccak256(abi.encode(key)), 0, 0, hdp1, hdp2, SportType.Soccer, 1, 0
            )
        );
    }
}
