pragma solidity ^0.6.1;

contract SimplePyramid {
    uint public constant MINIMUM_INVESTMENT = 1e15;
    uint public numInvestors = 0;
    uint public depth = 0;
    address[] public investors;
    uint public pyramidLevel;
    mapping(address => uint) public balances;

    constructor() public payable{
        require(msg.value >= MINIMUM_INVESTMENT,'Values must me greater then 1e15.');
        pyramidLevel =3;
        investors.push(msg.sender);
        numInvestors = 1;
        depth = 1;
        balances[address(this)] = msg.value;
    }

    receive() external payable {
        require(msg.value >= MINIMUM_INVESTMENT,'Values must me greatertheen 1e15.');
        balances[address(this)] += msg.value;
        numInvestors += 1;
        if(numInvestors == pyramidLevel){
            uint endIndex = numInvestors - 2**depth;
            uint startIndex = endIndex - 2**(depth-1);
            for (uint index = startIndex; index < endIndex; index++) {
                balances[investors[index]] += MINIMUM_INVESTMENT;
            }
            uint paid = MINIMUM_INVESTMENT * 2**(depth-1);
            uint eachInvestorGets = (balances[address(this)]- paid) / numInvestors;

            for(uint i = 0; i < numInvestors; i++){
                balances[investors[i]] += eachInvestorGets;
            }
            balances[address(this)] = 0;
            depth += 1;
            pyramidLevel += 2**depth;
        }
    }

    function withdraw () public {
        uint payout = balances[msg.sender];
        balances[msg.sender] = 0;
        msg.sender.transfer(payout);
    }
} 