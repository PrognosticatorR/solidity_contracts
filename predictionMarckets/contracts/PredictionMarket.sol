//SPDX-License-Identifier: UNLICENSED;
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PredictionMarket {
  using SafeMath for uint256;
  enum OrderType {Buy, Sell}
  enum Result {Open, Yes, No}

  struct Order {
    address user;
    OrderType orderType;
    uint256 amount;
    uint256 price;
  }

  uint256 public constant TX_FEE_NUMERATOR = 1;
  uint256 public constant TX_FEE_DENOMINATOR = 500;

  address public owner;
  Result public result;
  uint256 public deadLine;
  uint256 public counter;
  uint256 public collateral;
  mapping(uint256 => Order) public orders;
  mapping(address => uint256) public shares;
  mapping(address => uint256) public balances;

  event OrderPlaced(uint256 orderId, address user, OrderType orderType, uint256 amount, uint256 price);
  event TradeMatched(uint256 orderId, address user, uint256 amount);
  event OrderCanceled(uint256 orderId);
  event Payout(address user, uint256 amount);

  constructor(uint256 duration) payable {
    require(msg.value > 0);

    owner = msg.sender;
    deadLine = SafeMath.add(block.timestamp, duration);
    shares[msg.sender] = SafeMath.div(msg.value, 100);
    collateral = msg.value;
  }

  function orderBuy(uint256 price) public payable {
    require(block.timestamp < deadLine);
    require(msg.value > 0);
    require(price >= 0);
    require(price <= 100);

    uint256 amount = SafeMath.div(msg.value, price);
    counter++;
    orders[counter] = Order(msg.sender, OrderType.Buy, amount, price);
    emit OrderPlaced(counter, msg.sender, OrderType.Buy, amount, price);
  }

  function orderSell(uint256 price, uint256 amount) public {
    require(block.timestamp < deadLine);
    require(shares[msg.sender] >= amount);
    require(price > 0);
    require(price <= 100);

    shares[msg.sender] = SafeMath.sub(shares[msg.sender], amount);
    counter++;
    orders[counter] = Order(msg.sender, OrderType.Sell, amount, price);
    emit OrderPlaced(counter, msg.sender, OrderType.Sell, amount, price);
  }

  function tradeBuy(uint256 orderId) public payable {
    Order storage order = orders[orderId];

    require(block.timestamp < deadLine);
    require(order.user != msg.sender);
    require(order.orderType == OrderType.Sell);
    require(order.amount > 0);
    require(msg.value > 0);
    require(msg.value <= order.price * order.amount);

    uint256 amount = SafeMath.div(msg.value, order.price);
    uint256 fee = SafeMath.mul(SafeMath.mul(amount, order.price), SafeMath.div(TX_FEE_NUMERATOR, TX_FEE_DENOMINATOR));
    uint256 feeShare = SafeMath.mul(amount, SafeMath.div(TX_FEE_NUMERATOR, TX_FEE_DENOMINATOR));

    shares[msg.sender] = SafeMath.add(shares[msg.sender], SafeMath.sub(amount, feeShare));
    shares[owner] = SafeMath.add(shares[owner], feeShare);
    balances[order.user] = SafeMath.add(balances[order.user], SafeMath.sub(SafeMath.mul(amount, order.price), fee));
    balances[owner] = SafeMath.add(balances[owner], fee);
    order.amount = SafeMath.sub(order.amount, amount);
    if (order.amount == 0) delete orders[orderId];
    emit TradeMatched(orderId, msg.sender, amount);
  }

  function tradeSell(uint256 orderId, uint256 amount) public {
    Order storage order = orders[orderId];

    require(block.timestamp < deadLine);
    require(msg.sender != order.user);
    require(order.orderType == OrderType.Buy);
    require(order.amount > 0);
    require(amount <= order.amount);
    require(shares[msg.sender] >= amount);

    uint256 fee = SafeMath.mul(SafeMath.mul(amount, order.price), SafeMath.div(TX_FEE_NUMERATOR, TX_FEE_DENOMINATOR));
    uint256 feeShare = SafeMath.mul(amount, SafeMath.div(TX_FEE_NUMERATOR, TX_FEE_DENOMINATOR));

    shares[msg.sender] = SafeMath.sub(shares[msg.sender], amount);
    shares[order.user] = SafeMath.add(shares[order.user], SafeMath.sub(amount, feeShare));
    shares[owner] = SafeMath.add(shares[owner], feeShare);
    balances[msg.sender] = SafeMath.add(balances[msg.sender], SafeMath.sub(SafeMath.mul(amount, order.price), fee));
    balances[owner] = SafeMath.add(balances[owner], fee);
    order.amount = SafeMath.sub(order.amount, amount);
    if (order.amount == 0) delete orders[orderId];
    emit TradeMatched(orderId, msg.sender, amount);
  }

  function cancleOrder(uint256 orderId) public {
    Order storage order = orders[orderId];

    require(order.user == msg.sender);

    if (order.orderType == OrderType.Buy) balances[msg.sender] = SafeMath.add(balances[msg.sender], SafeMath.mul(order.amount, order.price));
    else shares[msg.sender] = SafeMath.add(shares[msg.sender], order.amount);
    delete orders[orderId];
    emit OrderCanceled(orderId);
  }

  function resolve(bool _result) public {
    require(block.timestamp > deadLine);
    require(msg.sender == owner);
    require(result == Result.Open);

    result = _result ? Result.Yes : Result.No;
    if (result == Result.No) balances[owner] = SafeMath.add(balances[owner], collateral);
  }

  function withDraw() public {
    address payable withdrawer = payable(msg.sender);
    uint256 payout = balances[withdrawer];
    balances[withdrawer] = 0;

    if (result == Result.Yes) {
      payout = SafeMath.add(payout, SafeMath.mul(shares[withdrawer], 100));
      shares[withdrawer] = 0;
    }
    withdrawer.transfer(payout);
    emit Payout(withdrawer, payout);
  }
}
