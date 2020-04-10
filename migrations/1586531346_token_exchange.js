let TokenExchange = artifacts.require("./TokenExchange.sol");
module.exports = function (_deployer) {
  // Use deployer to state migration tasks.
  _deployer.deploy(TokenExchange);
};
