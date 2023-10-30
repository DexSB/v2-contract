// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/access/Ownable.sol";

interface IGasTank {
    event TokenSent(address customer);
    function sendTokens(address[] calldata customer, uint256 tokenAmount) external;
    function setTokenSender(address sender) external;
}

contract GasTank is IGasTank, Ownable{

    address _sender;

    function deposit() public payable {
        //to receive native token
    }

    function sendTokens(
        address[] calldata customer,
        uint256 tokenAmount
    ) external override {
        require(msg.sender == _sender,  "CustomErrors: caller is not the sender");

        uint256 amount = tokenAmount;
        require(address(this).balance > amount * customer.length, "CustomErrors: balance not enough");

        for(uint i = 0; i < customer.length; i++) {
            (bool sent,) = customer[i].call{value : amount}("");
            require(sent, "CustomErrors: sent error");

            emit TokenSent(customer[i]);
        }

    }

    function setTokenSender(address sender) external override onlyOwner {
        _sender = sender;
    }

}
