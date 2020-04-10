let MyToken = artifacts.require("./MyToken.sol");
module.exports = function (_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(MyToken);
};
