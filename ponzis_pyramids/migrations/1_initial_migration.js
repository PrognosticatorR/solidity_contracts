const Migrations = artifacts.require("Migrations");
const SimplePonzi = artifacts.require("SimplePonzi");
const GradualPonzi = artifacts.require("GradualPonzi");
const SimplePyramid = artifacts.require("SimplePyramid");
const Government = artifacts.require("Government");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(SimplePonzi);
  deployer.deploy(GradualPonzi);
  deployer.deploy(SimplePyramid, { value: 100e17 });
  deployer.deploy(Government);
};
