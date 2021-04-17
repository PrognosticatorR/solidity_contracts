/** @format */

const Migrations = artifacts.require("Migrations");
const SimplePrize = artifacts.require("SimplePrize");
const CommitRevealPuzzle = artifacts.require("CommitRevealPuzzle");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  // deployer.deploy(SimplePrize, "0x0");
  deployer.deploy(SimplePrize, "0xb247f645c28c3e83f2b851548d9dcd259fa52970b890151e12eb81a4454d3620");
  deployer.deploy(CommitRevealPuzzle, "0x23a87a05c8309b993c20e139ea96a43250bf7419c47666ea2b8bccfecaa0d293", { value: 2e16 });
};
