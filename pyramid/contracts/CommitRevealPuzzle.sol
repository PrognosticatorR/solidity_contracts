pragma solidity ^0.6.1;

contract CommitRevealPuzzle {
  uint256 public constant GUESS_DURATION_BLOCKS = 5;
  uint256 public constant REVEAL_DURATION_BLOCKS = 5;

  address public creator;
  uint256 public guessDeadline;
  uint256 public revealDeadline;
  uint256 public totalPrize;

  mapping(address => bytes32) public commitments;
  address payable[] public winners;
  mapping(address => bool) public claimed;

  constructor(bytes32 _commitment) public payable {
    creator = msg.sender;
    commitments[msg.sender] = _commitment;
    guessDeadline = block.number + GUESS_DURATION_BLOCKS;
    revealDeadline = block.number + REVEAL_DURATION_BLOCKS;
    totalPrize += msg.value;
  }

  function createCommitment(address user, uint256 answer) public pure returns (bytes32) {
    return keccak256(abi.encode(user, answer));
  }

  function guess(bytes32 _commitments) public {
    require(block.number < guessDeadline);
    require(msg.sender != creator);
    commitments[msg.sender] = _commitments;
  }

  function reveal(uint256 answer) public {
    require(block.number > guessDeadline);
    require(block.number < revealDeadline);
    require(createCommitment(msg.sender, answer) == commitments[msg.sender]);
    require(createCommitment(creator, answer) == commitments[creator]);
    require(!isWinner(msg.sender));
    winners.push(msg.sender);
  }

  function claim() public {
    require(block.number > revealDeadline);
    require(claimed[msg.sender] == false);
    require(isWinner(msg.sender));
    uint256 payout = totalPrize / winners.length;
    claimed[msg.sender] = true;
    msg.sender.transfer(payout);
  }

  function isWinner(address user) public view returns (bool) {
    bool winner = false;
    for (uint256 index = 0; index < winners.length; index++) {
      if (winners[index] == user) {
        winner = true;
        break;
      }
    }
    return winner;
  }

  receive() external payable {
    totalPrize += msg.value;
  }
}
