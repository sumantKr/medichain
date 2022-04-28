const Agent = artifacts.require("Agent");

module.exports = function (deployer) {
  deployer.deploy(Agent);
};
