pragma solidity ^0.6.1;

contract RecurringLottery {
  struct Round {
    uint256 endBlock;
    uint256 drawBlock;
    Entry[] entries;
    uint256 totalQuantity;
    address payable winner;
  }
  struct Entry {
    address payable buyer;
    uint256 quantity;
  }

  uint256 public constant TICKET_PRICE = 1e17;
  mapping(uint256 => Round) public rounds;
  uint256 public round;
  uint256 public duration;
  mapping(address => uint256) public balances;

  // duration is in blocks. 1 day = ~5500 blocks

  constructor(uint256 _duration) public {
    duration = _duration;
    round = 1;
    rounds[round].endBlock = block.number + duration;
    rounds[round].drawBlock = block.number + duration + 5;
  }

  function buy() public payable {
    require(msg.value % TICKET_PRICE == 0, "value must be multiple of the TICKET_PRICE i.e. 1e17");
    if (block.number > rounds[round].endBlock) {
      round += 1;
      rounds[round].endBlock = block.number + duration;
      rounds[round].drawBlock = block.number + duration + 5;
    }
    uint256 quantity = msg.value / TICKET_PRICE;
    Entry memory entry = Entry(msg.sender, quantity);
    rounds[round].entries.push(entry);
    rounds[round].totalQuantity += quantity;
  }

  function drawWinner(uint256 roundNumber) public {
    Round storage drawing = rounds[roundNumber];
    require(drawing.winner == address(0));
    require(block.number > drawing.drawBlock);
    require(drawing.entries.length > 0);

    bytes32 rand = keccak256(abi.encodePacked(blockhash(drawing.drawBlock)));
    uint256 counter = uint256(rand) % drawing.totalQuantity;

    for (uint256 i = 0; i < drawing.entries.length; i++) {
      uint256 quantity = drawing.entries[i].quantity;
      if (quantity > counter) {
        drawing.winner = drawing.entries[i].buyer;
        break;
      } else {
        counter -= quantity;
      }
    }
    balances[drawing.winner] += TICKET_PRICE * drawing.totalQuantity;
  }

  function withdraw() public {
    uint256 amount = balances[msg.sender];
    balances[msg.sender] = 0;
    msg.sender.transfer(amount);
  }

  function deleteRound(uint256 _round) public {
    require(block.number > rounds[_round].drawBlock + 100);
    require(rounds[_round].winner != address(0));
    delete rounds[_round];
  }

  receive() external payable {
    buy();
  }
}
