const TokenExchange = artifacts.require("./TokenExchange.sol");
const Token = artifacts.require("./MyToken.sol");

// const should = require("chai").use(require("chai-as-promised")).should();

const BigNumber = web3.utils.BN;

let exchange;
let usdc;
let tusdc;
let tokenAmount = 100000;

let usdcAllocated = 100;

let value = new BigNumber(10);

contract("Token_management", async (accounts) => {
  let accountA, accountB, accountC, accountD;

  [accountA, accountB, accountC, accountD] = accounts;

  beforeEach(async () => {
    exchange = await TokenExchange.deployed();
    usdc = await Token.new();
    tusdc = await Token.new();
    await usdc.initialize("usd", "usd", 18, tokenAmount, accountA, [], []);
    await tusdc.initialize("tusd", "tusd", 18, tokenAmount, accountB, [], []);
    await exchange.initialize(1, tusdc.address);
  });

  it("Balance", async () => {
    let usdcBalance = await usdc.balanceOf(accountA);
    let tUsdcBalance = await tusdc.balanceOf(accountB);

    assert.equal(usdcBalance.toString(), tokenAmount);
    assert.equal(tUsdcBalance.toString(), tokenAmount);

    // transfer  entire tUsdc to exchange
    tusdc.transfer(exchange.address, tokenAmount, { from: accountB });
    let tUsdcExchangeBal = await tusdc.balanceOf(exchange.address);

    assert.equal(tUsdcExchangeBal.toString(), tokenAmount);

    // remaning balance should be zero
    tUsdcBalance = await tusdc.balanceOf(accountB);
    assert.equal(tUsdcBalance.toString(), 0);

    let tUsdcBalanceOfA = await tusdc.balanceOf(accountA);
    assert.equal(tUsdcBalanceOfA.toString(), 0);

    // Investor A  allocates some usdc to exchange
    await usdc.approve(exchange.address, usdcAllocated, { from: accountA });

    // transfer usdc and get tUsdc BACK
    await exchange.depositStableCoin(usdc.address, accountA, usdcAllocated, {
      from: accountC,
    });

    // CHECK FINAL BALANCES
    // accountA has tUSDC now
    tUsdcBalanceOfA = await tusdc.balanceOf(accountA);
    assert.equal(tUsdcBalanceOfA.toString(), usdcAllocated);

    // accountA 's usdc balance is reduced
    usdcBalance = await usdc.balanceOf(accountA);
    assert.equal(usdcBalance.toString(), tokenAmount - usdcAllocated);

    exchangeUsdcBal = await usdc.balanceOf(exchange.address);
    assert.equal(exchangeUsdcBal.toString(), usdcAllocated);
  });
});
