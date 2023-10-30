// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { IERC20 } from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import { Ownable } from "./proxy/Ownable.sol";
import { TransferEventType } from "./constant/Transfer.sol";

struct PaymentDetail {
    address token;
    address target;
    uint256 amount;
}

struct PaymentRequestDto {
    PaymentDetail[] paymentDetails;
}

struct TransferBatchRequestDto {
    uint256 referenceId;
    TransferEventType transferEventType;
    TransferRequestDto[] transferRequestDtos;
}

struct TransferRequestDto {
    address from;
    address to;
    address token;
    uint256 amount;
}

interface IPaymentV1 {
    event Transferred(uint256 referenceId, TransferEventType transferEventType);
    function collect(PaymentRequestDto calldata dto) external returns (bool);
    function payout(PaymentRequestDto calldata dto) external returns (bool);
    function transfer(TransferBatchRequestDto calldata dto) external;
    function validateContract(address contractAddress, bool isValidated) external;
    function validateTransferer(address contractAddress, bool isValidated) external;
    function getVersion() external returns (uint256);
}

contract PaymentV1 is IPaymentV1, Ownable {
    uint256 private version;
    mapping(address => bool) private validatedContracts;
    mapping(address => bool) private validatedTransferers;
    mapping(uint256 => bool) private transferIdempotency;

    function initialize(uint256 _version) public initializer {
        Ownable.initialize();
        version = _version;
    }

    function collect(PaymentRequestDto calldata dto) external override returns (bool) {
        require(validatedContracts[msg.sender], "CustomErrors: sender is not a validated contract");
        for (uint256 i = 0; i < dto.paymentDetails.length; ++i) {
            PaymentDetail memory paymentDetail = dto.paymentDetails[i];
            require(
                IERC20(paymentDetail.token).transferFrom(paymentDetail.target, address(this), paymentDetail.amount),
                "CustomErrors: collect token failed"
            );
        }

        return true;
    }

    function payout(PaymentRequestDto calldata dto) external override returns (bool) {
        require(validatedContracts[msg.sender], "CustomErrors: sender is not a validated contract");
        for (uint256 i = 0; i < dto.paymentDetails.length; ++i) {
            PaymentDetail memory paymentDetail = dto.paymentDetails[i];
            require(
                IERC20(paymentDetail.token).transfer(paymentDetail.target, paymentDetail.amount),
                "CustomErrors: payout token failed"
            );
        }

        return true;
    }

    function transfer(TransferBatchRequestDto calldata dto) external override {
        require(validatedTransferers[msg.sender], "CustomerErrors: sender is not a validated transferer");
        bool isSent = transferIdempotency[dto.referenceId];
        if (!isSent) {
            for (uint256 i = 0; i < dto.transferRequestDtos.length; ++i) {
                TransferRequestDto memory request = dto.transferRequestDtos[i];
                    require(IERC20(request.token).transferFrom(request.from, request.to, request.amount), "CustomerErrors: ERC20 transfers failed");
            }
        }
        transferIdempotency[dto.referenceId] = true;
        emit Transferred(dto.referenceId, dto.transferEventType);
    }

    function validateContract(address contractAddress, bool isValidated) external override onlyOwner {
        validatedContracts[contractAddress] = isValidated;
    }

    function validateTransferer(address transferer, bool isValidated) external override onlyOwner {
        validatedTransferers[transferer] = isValidated;
    }

    function getVersion() external view override returns (uint256) {
        return version;
    }
}
