
const Token = artifacts.require("./token/ERC20/presets/ERC20PresetFixedSupply.sol");
const Market = artifacts.require("./lend/Market.sol");
const Controller = artifacts.require('./lend/Controller.sol');

contract("Controller", (accounts) => {
  const alice = accounts[0];
  const bob = accounts[1];
  const charlie = accounts[2];

  const MANTISSA = 1e6;
  const FACTOR = 1e18;
  const BLOCKS_PER_YEAR = 1e6;
  const ANNUAL_RATE = "1000000000000000000000";	// FACTOR / 1000 * BLOCKS_PER_YEAR = 1e21
  const UTILIZATION_RATE_FRACTION = "1000000000000000000000";	// FACTOR / 1000 * BLOCKS_PER_YEAR = 1e21

  it("create contracts", async () => {
    this.token = await Token.new("DAI", "DAI", 1e6, alice);
    this.market = await Market.new(this.token.address, ANNUAL_RATE, BLOCKS_PER_YEAR, UTILIZATION_RATE_FRACTION, { from: alice });

    this.token2 = await Token.new("BAT", "BAT", 1e6, bob);
    this.market2 = await Market.new(this.token2.address, ANNUAL_RATE, BLOCKS_PER_YEAR, UTILIZATION_RATE_FRACTION, { from: bob });

    this.controller = await Controller.new({ from: alice });
  });

  it('no market', async function () {
    try {
      const result = await this.controller.markets(this.market.address);
      assert.ok(!result);
    } catch (error) {}

    try {
      const marketByToken = await this.controller.marketsByToken(this.token.address);
      assert.equal(marketByToken, 0);
    } catch (error) {}
  });

  it('no price', async function () {
    try {
      const result = await this.controller.prices(this.token.address);
      assert.equal(result, 0);
    } catch (error) {}
  });

  it("initialize state", async () => {
    await this.controller.setCollateralFactor(1 * MANTISSA);
    await this.controller.setLiquidationFactor(MANTISSA / 2);

    await this.controller.addMarket(this.market.address);
    await this.controller.addMarket(this.market2.address);

    await this.controller.setPrice(this.market.address, 1);
    await this.controller.setPrice(this.market2.address, 2);

    await this.market.setController(this.controller.address, { from: alice });
    await this.market2.setController(this.controller.address, { from: bob });
  });

  it("check initial state", async () => {
    const owner = await this.controller.owner();
    console.log(owner);		// alice

    const controller = await this.market.controller();
    assert.equal(controller, this.controller.address);

    const controller2 = await this.market2.controller();
    assert.equal(controller2, this.controller.address);

    // assert.equal(await this.controller.MANTISSA(), MANTISSA);
    // assert.equal(await this.controller2.MANTISSA(), MANTISSA);

    const price = (await this.controller.prices(this.market.address)).toNumber();
    // console.log(price);
    assert.equal(price, 1);

    const price2 = (await this.controller.prices(this.market2.address)).toNumber();
    // console.log(price2);
    assert.equal(price2, 2);
  });
});


