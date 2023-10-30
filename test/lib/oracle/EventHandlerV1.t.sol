// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { EventHandlerV1 } from "../../../src/lib/oracle/EventHandlerV1.sol";
import {
    EventResultV1,
    Score
} from "../../../src/model/EventResult.sol";
import { ResultStatus } from "../../../src/constant/Status.sol";

contract EventHandlerV1Test is Test {
    event hashedKey(string key, bytes32 hashed);
    function test_getScore_with_betType_FTHandicap_get_full_time_home_score() public pure {
        // emit hashedKey("h", keccak256(abi.encode("h")));
        // emit hashedKey("a", keccak256(abi.encode("a")));
        // emit hashedKey("o", keccak256(abi.encode("o")));
        // emit hashedKey("u", keccak256(abi.encode("u")));
        // emit hashedKey("e", keccak256(abi.encode("e")));
        // emit hashedKey("1", keccak256(abi.encode("1")));
        // emit hashedKey("x", keccak256(abi.encode("x")));
        // emit hashedKey("2", keccak256(abi.encode("2")));
        // emit hashedKey("0:0", keccak256(abi.encode("0:0")));
        // emit hashedKey("0:1", keccak256(abi.encode("0:1")));
        // emit hashedKey("0:2", keccak256(abi.encode("0:2")));
        // emit hashedKey("0:3", keccak256(abi.encode("0:3")));
        // emit hashedKey("0:4", keccak256(abi.encode("0:4")));
        // emit hashedKey("1:0", keccak256(abi.encode("1:0")));
        // emit hashedKey("1:1", keccak256(abi.encode("1:1")));
        // emit hashedKey("1:2", keccak256(abi.encode("1:2")));
        // emit hashedKey("1:3", keccak256(abi.encode("1:3")));
        // emit hashedKey("1:4", keccak256(abi.encode("1:4")));
        // emit hashedKey("2:0", keccak256(abi.encode("2:0")));
        // emit hashedKey("2:1", keccak256(abi.encode("2:1")));
        // emit hashedKey("2:2", keccak256(abi.encode("2:2")));
        // emit hashedKey("2:3", keccak256(abi.encode("2:3")));
        // emit hashedKey("2:4", keccak256(abi.encode("2:4")));
        // emit hashedKey("3:0", keccak256(abi.encode("3:0")));
        // emit hashedKey("3:1", keccak256(abi.encode("3:1")));
        // emit hashedKey("3:2", keccak256(abi.encode("3:2")));
        // emit hashedKey("3:3", keccak256(abi.encode("3:3")));
        // emit hashedKey("3:4", keccak256(abi.encode("3:4")));
        // emit hashedKey("4:0", keccak256(abi.encode("4:0")));
        // emit hashedKey("4:1", keccak256(abi.encode("4:1")));
        // emit hashedKey("4:2", keccak256(abi.encode("4:2")));
        // emit hashedKey("4:3", keccak256(abi.encode("4:3")));
        // emit hashedKey("4:4", keccak256(abi.encode("4:4")));
    }

    function _given_EventResultV1_bytes_with_full_time_score() internal pure returns (bytes memory) {
        return abi.encode(
        );
    }
}
