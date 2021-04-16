pragma solidity ^0.6.1;

contract SimpleLottery {
  uint256 public constant TICKIT_PRICE = 1e16;

  address payable[] public tickets;
  address payable public winner;
  uint256 public ticketingCloses;
  bytes32 private rand;

  constructor(uint256 duration) public {
    ticketingCloses = now + duration;
  }

  function buy() public payable {
    require(msg.value == TICKIT_PRICE);
    require(now < ticketingCloses);
    tickets.push(msg.sender);
  }

  function drawWinner() public {
    require(now > ticketingCloses + 1 minutes, "time is still ticking!");
    require(winner == address(0));
    rand = keccak256(abi.encodePacked(blockhash(block.number - 1)));
    winner = tickets[uint256(rand) % tickets.length];
  }

  function withdraw() public {
    require(msg.sender == winner);
    msg.sender.transfer(address(this).balance);
  }

  receive() external payable {
    buy();
  }
}
