pragma solidity ^0.6.1;

contract SimplePrize {
  uint256 constant salter = 987463829;
  bytes32 public constant salt = bytes32(salter);
  bytes32 public commitment;

  constructor(bytes32 _commitment) public {
    commitment = _commitment;
  }

  function createCommitment(uint256 answer) public view returns (bytes32) {
    return keccak256(abi.encode(salt, answer));
  }

  function guess(uint256 answer) public {
    require(createCommitment(answer) == commitment);
    msg.sender.transfer(address(this).balance);
  }
}
