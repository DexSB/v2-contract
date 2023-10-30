// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { PayoutCalculator } from "../../src/lib/PayoutCalculator.sol";
import { OddsType } from "../../src/constant/OddsType.sol";
import { OracleV1 } from "../../src/OracleV1.sol";
import { SingleBetTicket } from "../../src/model/Ticket.sol";
import { SportType } from "../../src/constant/SportType.sol";
import { FTCorrectScoreHandler } from "../../src/handler/FTCorrectScoreHandler.sol";
import { TicketStatus, ResultStatus } from "../../src/constant/Status.sol";

contract FTCorrectScoreHandlerTest is Test {
    FTCorrectScoreHandler private handler;

    address private oracle = makeAddr("oracle");

    function setUp() public {
        handler = new FTCorrectScoreHandler();
    }

    function test_settleTicket_with_static_case() public {
        string memory result = "0:0";
        TicketStatus ticketStatus;
        uint256 deadHeat;

        _mock_OracleV1_getEventStatus_completed();
        vm.mockCall(oracle, abi.encodeWithSelector(OracleV1.getResultHash.selector), abi.encode(keccak256(abi.encode(result))));

        (ticketStatus, deadHeat) = handler.settleTicket(address(oracle), _given_SingleBetTicketBytes("0:0"));
        assertEq(uint256(ticketStatus), uint256(TicketStatus.Won));
        assertEq(deadHeat, 1);

        (ticketStatus, deadHeat) = handler.settleTicket(address(oracle), _given_SingleBetTicketBytes("0:1"));
        assertEq(uint256(ticketStatus), uint256(TicketStatus.Lost));
        assertEq(deadHeat, 1);
    }

    function test_settleTicket_with_refund() public {
        string memory result = "0:0";
        TicketStatus ticketStatus;
        uint256 deadHeat;

        _mock_OracleV1_getEventStatus_refund();
        vm.mockCall(oracle, abi.encodeWithSelector(OracleV1.getResultHash.selector), abi.encode(keccak256(abi.encode(result))));

        (ticketStatus, deadHeat) = handler.settleTicket(address(oracle), _given_SingleBetTicketBytes("0:0"));
        assertEq(uint256(ticketStatus), uint256(TicketStatus.Refund));
        assertEq(deadHeat, 1);

        (ticketStatus, deadHeat) = handler.settleTicket(address(oracle), _given_SingleBetTicketBytes("0:1"));
        assertEq(uint256(ticketStatus), uint256(TicketStatus.Refund));
        assertEq(deadHeat, 1);
    }

    function test_settleTicket_with_abandoned_q3() public {
        string memory result = "0:0";
        TicketStatus ticketStatus;
        uint256 deadHeat;

        _mock_OracleV1_getEventStatus_abandon_q3();
        vm.mockCall(oracle, abi.encodeWithSelector(OracleV1.getResultHash.selector), abi.encode(keccak256(abi.encode(result))));

        (ticketStatus, deadHeat) = handler.settleTicket(address(oracle), _given_SingleBetTicketBytes("0:0"));
        assertEq(uint256(ticketStatus), uint256(TicketStatus.Refund));
        assertEq(deadHeat, 1);

        (ticketStatus, deadHeat) = handler.settleTicket(address(oracle), _given_SingleBetTicketBytes("0:1"));
        assertEq(uint256(ticketStatus), uint256(TicketStatus.Refund));
        assertEq(deadHeat, 1);
    }

    function _mock_OracleV1_getEventStatus_completed() internal {
        vm.mockCall(address(oracle), abi.encodeWithSelector(OracleV1.getEventStatus.selector), abi.encode(ResultStatus.Completed));
    }

    function _mock_OracleV1_getEventStatus_refund() internal {
        vm.mockCall(address(oracle), abi.encodeWithSelector(OracleV1.getEventStatus.selector), abi.encode(ResultStatus.Refund));
    }

    function _mock_OracleV1_getEventStatus_abandon_q3() internal {
        vm.mockCall(address(oracle), abi.encodeWithSelector(OracleV1.getEventStatus.selector), abi.encode(ResultStatus.AbandonedQ3));
    }

    function _given_SingleBetTicketBytes(string memory key) public pure returns (bytes memory) {
        return abi.encode(
            SingleBetTicket(
                1, 1, keccak256(abi.encode(key)), 0, 0, 0, 0, SportType.Soccer, 0, 0
            )
        );
    }
}
