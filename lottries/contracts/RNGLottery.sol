pragma solidity ^0.6.1;

contract RNGLottery {
    uint256 public constant TICKET_VALUE = 1e17;

    address payable[] public tickets;
    address payable winner;
    bytes32 public seed;
    mapping(address => bytes32) public commitments;

    uint256 public ticketDeadline;
    uint256 public drawBlock;
    uint256 public revealDeadline;

    constructor(uint256 duration, uint256 revealDuration) public {
        ticketDeadline = block.number + duration;
        revealDeadline = ticketDeadline + revealDuration;
        drawBlock = revealDeadline + 5;
    }

    function createCommitment(address user, uint256 N)
        public
        pure
        returns (bytes32 commitment)
    {
        return keccak256(user, N);
    }

    function buy(bytes32 commitment) public payable {
        require(msg.value == TICKET_PRICE);
        require(block.number <= ticketDeadline);

        commitments[msg.sender] = commitment;
    }

    function reveal(uint256 N) public {
        require(block.number > ticketDeadline);
        require(block.number <= revealDeadline);

        bytes32 hash = createCommitment(msg.sender, N);
        require(hash == commitments[msg.sender]);

        seed = keccak256(seed, N);
        tickets.push(msg.sender);
    }

    function drawWinner() public {
        require(block.number > drawBlock);
        require(winner == address(0));

        uint256 randIndex = uint256(seed) % tickets.length;
        winner = tickets[randIndex];
    }

    function withdraw() public {
        require(msg.sender == winner);
        msg.sender.transfer(address(this).balance);
    }
}