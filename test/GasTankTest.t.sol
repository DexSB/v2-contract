// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "src/GasTank.sol";
import "forge-std/Test.sol";


contract GasTankTest is Test{
    GasTank internal gasTank;

    address owner = address(0x54917758c42E90BA5bDCF655C7D2F361615e2A31);
    address sender = address(0x7b25c2d67a4b123de38F858b33b915ff1A5C5E66);

    function setUp() public {
        vm.startPrank(owner);
        gasTank = new GasTank();

//        deal(address(gasTank), 10000 * 1e18);
        vm.stopPrank();
    }

    function testDepositNativeTokenToContract() public {
        address alice = makeAddr("alice");
        deal(alice, 1000 * 1e18);

        vm.prank(alice);
        gasTank.deposit{value: 10*1e18}();

        assertEq(address(gasTank).balance, 10 * 1e18);
    }

    function testSendTokenToCustomers() public {
        address alice = makeAddr("alice");
        address bob = makeAddr("bob");
        address clark = makeAddr("clark");

        address[] memory customers = new address[](2);
        customers[0] = alice;
        customers[1] = bob;

        address[] memory newCustomer = new address[](1);
        newCustomer[0] = clark;

        deal(alice, 1000 * 1e18);

        vm.prank(alice);
        gasTank.deposit{value: 1000*1e18}();

        vm.prank(owner);
        gasTank.setTokenSender(sender);
        vm.prank(owner);
        vm.expectRevert("CustomErrors: caller is not the sender");
        gasTank.sendTokens(customers, 5 * 1e18);

        vm.prank(sender);
        gasTank.sendTokens(customers, 5 * 1e18);

        assertEq(address(alice).balance, 5 * 1e18);
        assertEq(address(bob).balance, 5 * 1e18);

        vm.prank(sender);
        gasTank.sendTokens(newCustomer, 123456);

        assertEq(address(clark).balance, 123456);
    }

}
