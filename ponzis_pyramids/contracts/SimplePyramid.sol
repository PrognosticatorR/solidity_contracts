pragma solidity ^0.8.1;

contract SimplePyramid {
    uint256 public constant MINIMUM_INVESTMENT = 1e15;
    uint256 public numInvestors = 0;
    uint256 public depth = 0;
    address[] public investors;
    uint256 public pyramidLevel;
    mapping(address => uint256) public balances;

    constructor() payable {
        require(
            msg.value >= MINIMUM_INVESTMENT,
            "Values must me greater then 1e15."
        );
        pyramidLevel = 3;
        investors.push(msg.sender);
        numInvestors = 1;
        depth = 1;
        balances[address(this)] = msg.value;
    }

    receive() external payable {
        require(
            msg.value >= MINIMUM_INVESTMENT,
            "Values must me greatertheen 1e15."
        );
        balances[address(this)] += msg.value;
        numInvestors += 1;
        if (numInvestors == pyramidLevel) {
            uint256 endIndex = numInvestors - 2**depth;
            uint256 startIndex = endIndex - 2**(depth - 1);
            for (uint256 index = startIndex; index < endIndex; index++) {
                balances[investors[index]] += MINIMUM_INVESTMENT;
            }
            uint256 paid = MINIMUM_INVESTMENT * 2**(depth - 1);
            uint256 eachInvestorGets = (balances[address(this)] - paid) /
                numInvestors;

            for (uint256 i = 0; i < numInvestors; i++) {
                balances[investors[i]] += eachInvestorGets;
            }
            balances[address(this)] = 0;
            depth += 1;
            pyramidLevel += 2**depth;
        }
    }

    function withdraw() public {
        uint256 payout = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(payout);
    }
}
