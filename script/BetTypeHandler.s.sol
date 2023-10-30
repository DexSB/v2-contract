// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script, console2 } from "forge-std/Script.sol";
import { FTHandicapHandler } from "../src/handler/FTHandicapHandler.sol";
import { FTOddEvenHandler } from "../src/handler/FTOddEvenHandler.sol";
import { IBettingV2 } from "../src/BettingV2.sol";

contract CounterScript is Script {
    address private betting;
    uint256 deployPrivateKey;

    function setUp() public {
        betting = 0x8fad49012d8264E73C5Ef0E954A0f05Eb04f6D92;
        deployPrivateKey = vm.envUint("DEPLOYER_KEY");
    }

    function deploy_all() public {
        deploy_FTHandicapHandler();
    }

    function deploy_FTHandicapHandler() public {
        vm.startBroadcast(deployPrivateKey);
        FTHandicapHandler fTHandicapHandler = new FTHandicapHandler();
        IBettingV2(betting).setSettleEngine(1, address(fTHandicapHandler));
        vm.stopBroadcast();
    }
    function deploy_FTOddEvenHandler() public {
        vm.startBroadcast(deployPrivateKey);
        FTOddEvenHandler fTOddEvenHandler = new FTOddEvenHandler();
        IBettingV2(betting).setSettleEngine(2, address(fTOddEvenHandler));
        vm.stopBroadcast();
    }
}
