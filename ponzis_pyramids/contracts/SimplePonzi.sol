// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

contract SimplePonzi {
    address payable public currentInvestor;
    uint256 public currentInvestment = 0;

    receive() external payable {
        uint256 minimumInsvestment = (currentInvestment * 11) / 10;
        require(msg.value > minimumInsvestment);

        address payable previousInvestor = currentInvestor;
        currentInvestor = payable(msg.sender);
        currentInvestment = msg.value;

        previousInvestor.transfer(msg.value);
    }
}
