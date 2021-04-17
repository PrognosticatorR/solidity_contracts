pragma solidity ^0.6.1;

contract Powerball {
  struct Round {
    uint256 endTime;
    uint256 drawBlock;
    uint256[6] winningNumbers;
    mapping(address => uint256[6][]) tickets;
  }

  uint256 public constant TICKET_PRICE = 2e16;
  uint256 public constant MAX_NUMBER = 69;
  uint256 public constant MAX_POWERBALL_NUMBER = 26;
  uint256 public constant ROUND_LENGTH = 3 days;

  uint256 public round;
  mapping(uint256 => Round) public rounds;

  constructor() public {
    round = 1;
    rounds[round].endTime = now + ROUND_LENGTH;
  }

  function buy(uint256[6][] memory numbers) public payable {
    require(numbers.length * TICKET_PRICE == msg.value);

    for (uint256 i = 0; i < numbers.length; i++) {
      for (uint256 j = 0; j < 6; j++) require(numbers[i][j] > 0);
      for (uint256 j = 0; j < 5; j++) require(numbers[i][j] <= MAX_NUMBER);
      require(numbers[i][5] <= MAX_POWERBALL_NUMBER);
    }
    if (now > rounds[round].endTime) {
      rounds[round].drawBlock = block.number + 5;
      round += 1;
      rounds[round].endTime = now + ROUND_LENGTH;
    }
    for (uint256 i = 0; i < numbers.length; i++) rounds[round].tickets[msg.sender].push(numbers[i]);
  }

  function drawNumbers(uint256 _round) public {
    uint256 drawBlock = rounds[round].drawBlock;
    require(now > rounds[_round].endTime);
    require(block.number >= drawBlock);
    require(rounds[_round].winningNumbers[0] == 0);

    for (uint256 i = 0; i < 5; i++) {
      bytes32 rand = keccak256(abi.encodePacked(blockhash(drawBlock), i));
      uint256 numberDraw = (uint256(rand) % MAX_NUMBER) + 1;
      rounds[_round].winningNumbers[i] = numberDraw;
    }
    bytes32 rand = keccak256(abi.encodePacked(blockhash(drawBlock), uint256(5)));
    uint256 powerballDraw = (uint256(rand) % MAX_NUMBER) + 1;
    rounds[_round].winningNumbers[5] = powerballDraw;
  }

  function claim(uint256 _round) public {
    require(rounds[_round].tickets[msg.sender].length > 0);
    require(rounds[_round].winningNumbers[0] != 0);

    uint256[6][] storage myNumbers = rounds[_round].tickets[msg.sender];
    uint256[6] storage winningNumbers = rounds[_round].winningNumbers;
    uint256 payout = 0;

    for (uint256 i = 0; i < myNumbers.length; i++) {
      uint256 numberMatches = 0;
      for (uint256 j = 0; j < 5; j++) {
        for (uint256 k = 0; k < 5; k++) {
          if (myNumbers[i][j] == winningNumbers[k]) numberMatches += 1;
        }
      }
      bool powerballMatches = (myNumbers[i][5] == winningNumbers[5]);
      // win conditions
      if (numberMatches == 5 && powerballMatches) payout = address(this).balance;
      else if (numberMatches == 5) payout += 1000 ether;
      else if (numberMatches == 4 && powerballMatches) payout += 50 ether;
      else if (numberMatches == 4) payout += 1e17;
      else if (numberMatches == 3 && powerballMatches) payout += 1e17;
      else if (numberMatches == 3) payout += 7e15;
      else if (numberMatches == 2 && powerballMatches) payout += 7e15;
      else if (powerballMatches) payout += 4e15;
    }
    msg.sender.transfer(payout);
    delete rounds[_round].tickets[msg.sender];
  }

  function ticketsFor(uint256 _round, address user) public view returns (uint256[6][] memory tickets) {
    return rounds[_round].tickets[user];
  }

  function winningNumbersFor(uint256 _round) public view returns (uint256[6] memory winningNumbers) {
    return rounds[_round].winningNumbers;
  }
}
