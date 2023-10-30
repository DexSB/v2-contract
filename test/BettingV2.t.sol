// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { BettingV2 } from "../src/BettingV2.sol";
import { PaymentV1 } from "../src/PaymentV1.sol";
import { TestERC20 } from "./token/TestERC20.sol";
import { PlaceSingleBetDto } from "../src/model/Ticket.sol";
import { OddsType } from "../src/constant/OddsType.sol";
import { ERC1967Proxy } from "../src/proxy/ERC1967Proxy.sol";

contract BettingV2Test is Test {
    PaymentV1 public paymentImpl;
    BettingV2 public bettingImpl;
    TestERC20 public testERC20;
    ERC1967Proxy public payment;
    ERC1967Proxy public betting;

    address private owner = makeAddr("owner");
    address private licensee = makeAddr("licensee");
    address private player = makeAddr("player");

    function setUp() public {
        vm.startPrank(owner);
        paymentImpl = new PaymentV1();
        payment = new ERC1967Proxy(address(paymentImpl), "");
        PaymentV1(address(payment)).initialize(1);

        bettingImpl = new BettingV2();
        betting = new ERC1967Proxy(address(bettingImpl), "");
        BettingV2(address(betting)).initialize(address(0), address(payment), address(0), address(0));
        BettingV2(address(betting)).validateBroker(owner, true);

        testERC20 = new TestERC20(100_000_000_000);
        testERC20.approve(address(payment), 100_000_000);
        testERC20.transfer(player, 100_000_000);
        PaymentV1(address(payment)).validateContract(address(betting), true);
        vm.stopPrank();

        vm.startPrank(player);
        testERC20.approve(address(payment), 100_000_000);
        vm.stopPrank();
    }

    function test_placeSingleBet() public {
        vm.prank(owner);
        PaymentV1(address(payment)).validateContract(address(betting), true);

        vm.prank(owner);
        BettingV2(address(betting)).placeSingleBet(PlaceSingleBetDto(
            1, 1, 1, 1, bytes32("h"), 0, 0, OddsType.Decimal, 200, 1_000_000, player, owner, address(testERC20), 0, 0, 0, 0
        ));

        assertEq(testERC20.balanceOf(owner), 100_000_000_000 - 1_000_000 - 100_000_000);
        assertEq(testERC20.balanceOf(player), 100_000_000 - 1_000_000);
    }

    function test_placeSingleBet_with_invalid_broker() public {
        vm.prank(owner);
        PaymentV1(address(payment)).validateContract(address(betting), true);

        vm.expectRevert("CustomErrors: sender is not a validated broker");
        BettingV2(address(betting)).placeSingleBet(PlaceSingleBetDto(
            1, 1, 1, 1, bytes32("h"), 0, 0, OddsType.Decimal, 200, 1_000_000, player, owner, address(testERC20), 0, 0, 0, 0
        ));

        assertEq(testERC20.balanceOf(owner), 100_000_000_000- 100_000_000);
        assertEq(testERC20.balanceOf(player), 100_000_000);
    }
}
