pragma solidity ^0.6.1;

contract GradualPonzi {
    address payable [] public investors;
    mapping (address => uint) public balances;
    uint public constant MINIMUM_INVESTMENT = 1e5;

    constructor() public {
        investors.push(msg.sender);
    }

     function withdraw () public {
        uint payout = balances[msg.sender];
        balances[msg.sender] =0;
        msg.sender.transfer(payout);
    }

    receive() external payable {
        require(msg.value > MINIMUM_INVESTMENT,"Only owner can call this function.");
        uint eachInvetorGets = msg.value/investors.length;
        for (uint index = 0; index < investors.length; index++) {
            balances[investors[index]] += eachInvetorGets;
        }   
        investors.push(msg.sender);
    }
}

// web3.eth.sendTransaction({ from: accounts[1], to:ponzi.address, value: 1e15, gas: 200e3 })

// web3.eth.sendTransaction({from: '0x6aFdb8B57f9e44A4e2EC4fCED98E4A9b52b68d23',to:'0x208B2EA2f89760151D2c3c07498eE2fc3cd47779' ,value: '1000000000000000000'})



//   '0x6aFdb8B57f9e44A4e2EC4fCED98E4A9b52b68d23',
//   '0x59a20A47Aff69ba7bB3cec71232D79ec27CE3fd8',
//   '0x8412F373b75e0fafB5036c5DAFDc4d4382524897',
//   '0xA9E2080bA758d0B5148BeD6E55A6fC66515beACe',
//   '0x9b62c5AbE0d920f7b254E1fA85c33Ce946a87903',
//   '0xa235564571f78FF04BBbe534CA246B27eac79218',
//   '0x6AA38792d33404fefE50070fe349bECe2A0E4FA4',
//   '0x701cF55dD2959dA887E66b7e5E627411979a26AB',
//   '0x6e4eDecf00aEC6a048Ec3A27469CB22A8f3Bcd97',
//   '0x228F7899f38bf9e1E33F5F72Eb9E87e0FFF6EA12',
//   '0x0079c49e05538CB17228Dc1753a193dbc605D725',
//   '0x559BEbee560B7a1027ff973f1bAF7E433EA399d7',
//   '0x0EFE0F993F740b682B6f7DBd391f06F1A32083CB',
//   '0xD4bae5C269a67033623dd330CEAe7C3636b8cD3e',
//   '0xDF37942DF6f9097a59047BafdbB2aa9B896a5547',
//   '0xBdBAa2d85065a2B85d2e7cfbddB1F490f6a6037F'