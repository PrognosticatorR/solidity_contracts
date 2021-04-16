pragma solidity ^0.6.1;

contract SimplePonzi {
    address payable public currentInvestor;
    uint public currentInvestment =0;

   fallback() external payable  {
        uint minimumInsvestment = currentInvestment * 11/10;
        require(msg.value > minimumInsvestment);
        
        address payable previousInvestor = currentInvestor;
        currentInvestor = msg.sender;
        currentInvestment = msg.value;

        previousInvestor.send(msg.value);
    }
}

// 0xF4637cf4c8F2620622575672C805ce3b6ad6a302