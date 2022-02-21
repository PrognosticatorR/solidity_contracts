// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

contract GradualPonzi {
    address payable[] public investors;
    mapping(address => uint256) public balances;
    uint256 public constant MINIMUM_INVESTMENT = 1e5;

    constructor() {
        investors.push(payable(msg.sender));
    }

    function withdraw() public {
        uint256 payout = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(payout);
    }

    receive() external payable {
        require(
            msg.value > MINIMUM_INVESTMENT,
            "Only owner can call this function."
        );
        uint256 eachInvetorGets = msg.value / investors.length;
        for (uint256 index = 0; index < investors.length; index++) {
            balances[investors[index]] += eachInvetorGets;
        }
        investors.push(payable(msg.sender));
    }
}
