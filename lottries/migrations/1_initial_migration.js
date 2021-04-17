/** @format */

const Migrations = artifacts.require("Migrations");
const SimpleLottery = artifacts.require("SimpleLottery");
const RecurringLottery = artifacts.require("RecurringLottery");
const RNGLottery = artifacts.require("RNGLottery");
const Powerball = artifacts.require("Powerball");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  const duration = 3600 * 10;
  deployer.deploy(SimpleLottery, duration);
  deployer.deploy(RecurringLottery, 5500 * 7);
  const rngduration = 5500 * 7; // 7 days
  const revealDuration = 5500 * 3; // 3 days
  deployer.deploy(RNGLottery, rngduration, revealDuration);
  deployer.deploy(Powerball);
};
