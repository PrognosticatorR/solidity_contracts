const Migrations = artifacts.require("Migrations");
const SimpleLottery = artifacts.require("SimpleLottery");
const RecurringLottery = artifacts.require("RecurringLottery");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  const duration = 3600 * 10;
  deployer.deploy(SimpleLottery, duration);
  deployer.deploy(RecurringLottery, 5500 * 7);
};
