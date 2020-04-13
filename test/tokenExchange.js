const TokenExchange = artifacts.require("./TokenExchange.sol");
const Token = artifacts.require("./MyToken.sol");

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
    exchange = await TokenExchange.new();

    usdc = await Token.new();
    // tusdc = await Token.new();
    await usdc.initialize("usd", "usd", 18, tokenAmount, accountD, [], []);
    // await tusdc.initialize("tusd", "tusd", 18, tokenAmount, accountB, [], []);
    // await exchange.initialize(1, tusdc.address);

    // new changes
  });

  it("Balance", async () => {
    let usdcBalance = await usdc.balanceOf(accountD);
    // let tUsdcBalance = await tusdc.balanceOf(accountB);

    assert.equal(usdcBalance.toString(), tokenAmount);

    // assert.equal(tUsdcBalance.toString(), tokenAmount);

    // transfer  entire tUsdc to exchange
    // tusdc.transfer(exchange.address, tokenAmount, { from: accountB });
    // let tUsdcExchangeBal = await tusdc.balanceOf(exchange.address);

    // assert.equal(tUsdcExchangeBal.toString(), tokenAmount);

    // remaning balance should be zero
    // tUsdcBalance = await tusdc.balanceOf(accountB);
    // assert.equal(tUsdcBalance.toString(), 0);

    // let tUsdcBalanceOfA = await tusdc.balanceOf(accountA);
    // assert.equal(tUsdcBalanceOfA.toString(), 0);

    exchange.initialize({ from: accountA });
    let owner = await exchange.owner();
    console.log("Onwer ", owner);

    // finally real shit
    await exchange.addTokenToExchange(
      usdc.address,
      "USD Platform",
      "MUS",
      18,
      tokenAmount,
      { from: accountA }
    );

    // Investor D  allocates some usdc to exchange
    await usdc.approve(exchange.address, usdcAllocated, { from: accountD });

    // transfer usdc and get tUsdc BACK
    await exchange.depositStableCoin(usdc.address, accountD, usdcAllocated, {
      from: accountA,
    });

    // CHECK FINAL BALANCES
    // accountA has tUSDC now
    // tUsdcBalanceOfA = await tusdc.balanceOf(accountA);
    // assert.equal(tUsdcBalanceOfA.toString(), usdcAllocated);

    // accountA 's usdc balance is reduced
    usdcBalance = await usdc.balanceOf(accountD);
    assert.equal(usdcBalance.toString(), tokenAmount - usdcAllocated);

    exchangeUsdcBal = await usdc.balanceOf(exchange.address);
    assert.equal(exchangeUsdcBal.toString(), usdcAllocated);

    let underlyingTokenAddress = await exchange.getPlatformToken(usdc.address);

    let tokenUnderlying = await Token.at(underlyingTokenAddress);

    // check D's Balance
    underlyingTokenBal = await tokenUnderlying.balanceOf(accountD);
    console.log(underlyingTokenBal.toString());
    assert.equal(underlyingTokenBal.toString(), usdcAllocated);
  });
});
