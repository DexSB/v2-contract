// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import {
    PaymentV1,
    PaymentRequestDto,
    PaymentDetail,
    TransferBatchRequestDto,
    TransferRequestDto
} from "../src/PaymentV1.sol";
import { TransferEventType } from "../src/constant/Transfer.sol";
import { ERC1967Proxy } from "../src/proxy/ERC1967Proxy.sol";
import { TestERC20 } from "./token/TestERC20.sol";

contract PaymentV1Test is Test {
    address private owner = makeAddr("owner");
    address private licensee = makeAddr("licensee");
    address private customer = makeAddr("customer");

    PaymentV1 private paymentImpl;
    ERC1967Proxy private payment; 
    TestERC20 private erc20;

    uint256 private constant totalSupply =
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint256 private constant amountForTesting =
        0x00000000000000000000000000000000000000000fffffffffffffffffffffff;

    function setUp() public {
        vm.startPrank(owner);
        paymentImpl = new PaymentV1();
        payment = new ERC1967Proxy(address(paymentImpl), "");
        PaymentV1(address(payment)).initialize(1);
        erc20 = new TestERC20(totalSupply);

        erc20.transfer(licensee, amountForTesting);
        erc20.transfer(customer, amountForTesting);
        erc20.transfer(address(payment), amountForTesting);
        vm.stopPrank();
    }

    /**
     * forge-config: default.fuzz.runs = 4096
     * forge-config: default.fuzz.max-test-rejects = 500
     */
    function test_collect_with_normal_erc20_fuzz(
        uint256 payout,
        uint256 stake
    ) public {
        _markOwnerAsValidatedContract();
        _setApproveForUsers();

        payout = bound(payout, 0, amountForTesting);
        stake = bound(stake, 0, amountForTesting);

        vm.prank(owner);
        PaymentV1(address(payment)).collect(_givenPaymentRequestDto(
            address(erc20), payout, address(erc20), stake
        ));

        assertEq(erc20.balanceOf(licensee), amountForTesting - payout);
        assertEq(erc20.balanceOf(customer), amountForTesting - stake);
    }

    function test_collect_with_unvalidated_contract() public {
        _setApproveForUsers();

        uint256 payout = 100;
        uint256 stake = 100;

        vm.expectRevert("CustomErrors: sender is not a validated contract");
        vm.prank(owner);
        PaymentV1(address(payment)).collect(_givenPaymentRequestDto(
            address(erc20), payout, address(erc20), stake
        ));

        assertEq(erc20.balanceOf(licensee), amountForTesting);
        assertEq(erc20.balanceOf(customer), amountForTesting);
    }

    function test_collect_without_approve() public {
        _markOwnerAsValidatedContract();

        uint256 payout = 100;
        uint256 stake = 100;

        vm.prank(owner);
        vm.expectRevert("ERC20: insufficient allowance");
        PaymentV1(address(payment)).collect(_givenPaymentRequestDto(
            address(erc20), payout, address(erc20), stake
        ));

        assertEq(erc20.balanceOf(licensee), amountForTesting);
        assertEq(erc20.balanceOf(customer), amountForTesting);
    }

    /**
     * forge-config: default.fuzz.runs = 4096
     * forge-config: default.fuzz.max-test-rejects = 500
     */
    function test_payout_with_normal_erc20_fuzz(
        uint256 payout,
        uint256 stake
    ) public {
        _markOwnerAsValidatedContract();
        _setApproveForUsers();

        payout = bound(payout, 0, amountForTesting / 2);
        stake = bound(stake, 0, amountForTesting / 2);

        vm.prank(owner);
        PaymentV1(address(payment)).payout(_givenPaymentRequestDto(
            address(erc20), payout, address(erc20), stake
        ));

        assertEq(erc20.balanceOf(licensee), amountForTesting + payout);
        assertEq(erc20.balanceOf(customer), amountForTesting + stake);
    }

    function test_payout_with_unvalidated_contract() public {
        _setApproveForUsers();

        uint256 payout = 100;
        uint256 stake = 100;

        vm.expectRevert("CustomErrors: sender is not a validated contract");
        vm.prank(owner);
        PaymentV1(address(payment)).collect(_givenPaymentRequestDto(
            address(erc20), payout, address(erc20), stake
        ));

        assertEq(erc20.balanceOf(licensee), amountForTesting);
        assertEq(erc20.balanceOf(customer), amountForTesting);
    }

    /**
     * forge-config: default.fuzz.runs = 4096
     * forge-config: default.fuzz.max-test-rejects = 500
     */
    function test_validateContract_add_contract(
        string memory addrIndex
    ) public {
        _setApproveForUsers();

        uint256 payout = 100;
        uint256 stake = 100;

        address contractAddr = makeAddr(addrIndex);
        vm.prank(owner);
        PaymentV1(address(payment)).validateContract(contractAddr, true);

        vm.prank(contractAddr);
        PaymentV1(address(payment)).collect(_givenPaymentRequestDto(
            address(erc20), payout, address(erc20), stake
        ));

        assertEq(erc20.balanceOf(licensee), amountForTesting - 100);
        assertEq(erc20.balanceOf(customer), amountForTesting - 100);
    }

    function test_validateContract_remove_contract() public {
        _markOwnerAsValidatedContract();
        _setApproveForUsers();

        uint256 payout = 100;
        uint256 stake = 100;

        vm.prank(owner);
        PaymentV1(address(payment)).collect(_givenPaymentRequestDto(
            address(erc20), payout, address(erc20), stake
        ));

        assertEq(erc20.balanceOf(licensee), amountForTesting - 100);
        assertEq(erc20.balanceOf(customer), amountForTesting - 100);

        vm.prank(owner);
        PaymentV1(address(payment)).validateContract(owner, false);

        vm.expectRevert("CustomErrors: sender is not a validated contract");
        vm.prank(owner);
        PaymentV1(address(payment)).collect(_givenPaymentRequestDto(
            address(erc20), payout, address(erc20), stake
        ));

        assertEq(erc20.balanceOf(licensee), amountForTesting - 100);
        assertEq(erc20.balanceOf(customer), amountForTesting - 100);
    }

    function test_transfer_with_nomal_erc20_static_value() public {
        _markOwnerAsValidatedTransferer();
        _setApproveForUsers();
        _setApproveForOwner();

        uint256 amount = 1_000_000;
        uint256 balanceOfTokenOwner = erc20.balanceOf(owner);

        vm.prank(owner);
        PaymentV1(address(payment)).transfer(_givenTransferRequestDto(
            address(erc20), owner, amount, amount
        ));

        assertEq(erc20.balanceOf(owner), balanceOfTokenOwner - (2 * amount));
        assertEq(erc20.balanceOf(licensee), amountForTesting + amount);
        assertEq(erc20.balanceOf(customer), amountForTesting + amount);
    }

    function test_transfer_with_same_referenceId() public {
        _markOwnerAsValidatedTransferer();
        _setApproveForUsers();
        _setApproveForOwner();

        uint256 amount = 1_000_000;
        uint256 balanceOfTokenOwner = erc20.balanceOf(owner);

        vm.prank(owner);
        PaymentV1(address(payment)).transfer(_givenTransferRequestDto(
            address(erc20), owner, amount, amount
        ));

        assertEq(erc20.balanceOf(owner), balanceOfTokenOwner - (2 * amount));
        assertEq(erc20.balanceOf(licensee), amountForTesting + amount);
        assertEq(erc20.balanceOf(customer), amountForTesting + amount);

        vm.prank(owner);
        PaymentV1(address(payment)).transfer(_givenTransferRequestDto(
            address(erc20), owner, amount, amount
        ));

        assertEq(erc20.balanceOf(owner), balanceOfTokenOwner - (2 * amount));
        assertEq(erc20.balanceOf(licensee), amountForTesting + amount);
        assertEq(erc20.balanceOf(customer), amountForTesting + amount);
    }

    /**
     * forge-config: default.fuzz.runs = 4096
     * forge-config: default.fuzz.max-test-rejects = 500
     */
    function test_transfer_with_normal_erc20_fuzz(
        uint256 amountToLicensee,
        uint256 amountToCustomer
    ) public {
        _markOwnerAsValidatedTransferer();
        _setApproveForUsers();
        _setApproveForOwner();

        amountToLicensee = bound(amountToLicensee, 0, amountForTesting / 2);
        amountToCustomer = bound(amountToCustomer, 0, amountForTesting / 2);

        uint256 balanceOfTokenOwner = erc20.balanceOf(owner);

        vm.prank(owner);
        PaymentV1(address(payment)).transfer(_givenTransferRequestDto(
            address(erc20), owner, amountToLicensee, amountToCustomer
        ));

        assertEq(erc20.balanceOf(owner), balanceOfTokenOwner - (amountToLicensee + amountToCustomer));
        assertEq(erc20.balanceOf(licensee), amountForTesting + amountToLicensee);
        assertEq(erc20.balanceOf(customer), amountForTesting + amountToCustomer);
    }

    function _markOwnerAsValidatedContract() internal {
        vm.prank(owner);
        PaymentV1(address(payment)).validateContract(owner, true);
    }

    function _markOwnerAsValidatedTransferer() internal {
        vm.prank(owner);
        PaymentV1(address(payment)).validateTransferer(owner, true);
    }

    function _setApproveForUsers() internal {
        vm.prank(licensee);
        erc20.approve(address(payment), totalSupply);
        vm.prank(customer);
        erc20.approve(address(payment), totalSupply);
    }

    function _setApproveForOwner() internal {
        vm.prank(owner);
        erc20.approve(address(payment), totalSupply);
    }

    function _givenPaymentRequestDto(
        address payoutToken,
        uint256 payout,
        address betToken,
        uint256 stake
    ) internal view returns (PaymentRequestDto memory dto) {
        PaymentDetail[] memory details = new PaymentDetail[](2);
        details[0] = PaymentDetail(payoutToken, licensee, payout);
        details[1] = PaymentDetail(betToken, customer, stake);
        dto.paymentDetails = details;
        return dto;
    }

    function _givenTransferRequestDto(
        address token,
        address from,
        uint256 amountToLicensee,
        uint256 amountToCustomer
    ) internal view returns (TransferBatchRequestDto memory dto) {
        TransferRequestDto[] memory transferRequests = new TransferRequestDto[](2);
        transferRequests[0] = TransferRequestDto(from, licensee, token, amountToLicensee);
        transferRequests[1] = TransferRequestDto(from, customer, token, amountToCustomer);
        dto.referenceId = 1;
        dto.transferEventType = TransferEventType.WithdrawToPolygon;
        dto.transferRequestDtos = transferRequests;
        return dto;
    }
}
