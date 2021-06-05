/**
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/test/Controller_tests.js
 * 
 *  @Author defi3
 *
 *  tested on local Ganache
 * 
 */

const Token = artifacts.require("./token/ERC20/presets/ERC20PresetFixedSupply.sol");
const Market = artifacts.require("./lend/Market.sol");
const Controller = artifacts.require('./lend/Controller.sol');

contract("Controller", (accounts) => {
  const alice = accounts[0];
  const bob = accounts[1];
  const charlie = accounts[2];

  const MANTISSA = 1e6;
  const FACTOR = 1e6;
  const BLOCKS_PER_YEAR = 1e6;
  const ANNUAL_RATE = 1e9;			// FACTOR / 1000 * BLOCKS_PER_YEAR = 1e9
  const UTILIZATION_RATE_FRACTION = 1e9;	// FACTOR / 1000 * BLOCKS_PER_YEAR = 1e9

  it("deploy contracts", async () => {
    this.token = await Token.new("DAI", "DAI", 1e6 * FACTOR, alice);
    this.market = await Market.new(this.token.address, ANNUAL_RATE, BLOCKS_PER_YEAR, UTILIZATION_RATE_FRACTION, { from: alice });

    this.token2 = await Token.new("BAT", "BAT", 1e6 * FACTOR, bob);
    this.market2 = await Market.new(this.token2.address, ANNUAL_RATE, BLOCKS_PER_YEAR, UTILIZATION_RATE_FRACTION, { from: bob });

    this.controller = await Controller.new({ from: alice });
  });

  it("check original state", async () => {
    assert.equal(await this.controller.MANTISSA(), MANTISSA);
    assert.equal(await this.controller.collateralFactor(), 0);
    assert.equal(await this.controller.liquidationFactor(), 0);

    const owner = await this.controller.owner();
    // console.log(owner);
    assert.equal(owner, alice);

    const size = (await this.controller.marketListSize()).toNumber();
    // console.log(size);
    assert.equal(size, 0);


    const added = await this.controller.markets(this.market.address);
    // console.log(added);
    assert.ok(!added);

    const added2 = await this.controller.markets(this.market2.address);
    assert.ok(!added2);


    const marketAddress = await this.controller.marketsByToken(this.token.address);
    assert.equal(marketAddress, 0);

    const marketAddress2 = await this.controller.marketsByToken(this.token2.address);
    assert.equal(marketAddress2, 0);


    const price = await this.controller.prices(this.token.address);
    assert.equal(price, 0);

    const price2 = await this.controller.prices(this.token2.address);
    assert.equal(price2, 0);


    const controller = await this.market.controller();
    assert.equal(controller, 0);

    const controller2 = await this.market2.controller();
    assert.equal(controller2, 0);
  });

  it("initialize controller", async () => {
    try {
      await this.controller.setCollateralFactor(1 * MANTISSA, { from: bob });
    } catch (err) {
      console.log("only owner can set collateral factor");
    }

    await this.controller.setCollateralFactor(1 * MANTISSA, { from: alice });

    factor = await this.controller.collateralFactor();
    assert.equal(factor, 1 * MANTISSA);


    try {
      await this.controller.setLiquidationFactor(MANTISSA / 2, { from: bob });
    } catch (err) {
      console.log("only owner can set liquidation factor");
    }

    await this.controller.setLiquidationFactor(MANTISSA / 2, { from: alice });

    factor = await this.controller.liquidationFactor();
    assert.equal(factor, MANTISSA / 2);
  });

  it("set controller", async () => {
    try {
      await this.market.setController(this.controller.address, { from: bob });
    } catch (err) {
      console.log("only owner can set controller");
    }

    try {
      await this.market2.setController(this.controller.address, { from: alice });
    } catch (err) {
      console.log("only owner can set controller");
    }

    await this.market.setController(this.controller.address, { from: alice });

    const controller = await this.market.controller();
    assert.equal(controller, this.controller.address);

    await this.market2.setController(this.controller.address, { from: bob });

    const controller2 = await this.market2.controller();
    assert.equal(controller2, this.controller.address);
  });

  it("add market", async () => {
    try {
      await this.controller.addMarket(this.market.address, { from: bob });
    } catch (err) {
      console.log("only owner can add market");
    }

    try {
      await this.controller.addMarket(this.market2.address, { from: bob });
    } catch (err) {
      console.log("only owner can add market");
    }


    await this.controller.addMarket(this.market.address, { from: alice });

    size = (await this.controller.marketListSize()).toNumber();
    assert.equal(size, 1);

    await this.controller.addMarket(this.market2.address, { from: alice });

    size = (await this.controller.marketListSize()).toNumber();
    assert.equal(size, 2);


    try {
      await this.controller.setPrice(this.market.address, 1, { from: bob });
    } catch (err) {
      console.log("only owner can set price");
    }

    await this.controller.setPrice(this.market.address, 1, { from: alice });

    const price = (await this.controller.prices(this.market.address)).toNumber();
    // console.log(price);
    assert.equal(price, 1);


    try {
      await this.controller.setPrice(this.market2.address, 2, { from: bob });
    } catch (err) {
      console.log("only owner can set price");
    }

    await this.controller.setPrice(this.market2.address, 2);

    const price2 = (await this.controller.prices(this.market2.address)).toNumber();
    // console.log(price2);
    assert.equal(price2, 2);
  });

  it("check initial accounts", async () => {
    values = await this.controller.getAccountValues(alice);
    assert.equal(values.supplyValue, 0);
    assert.equal(values.borrowValue, 0);

    values2 = await this.controller.getAccountValues(bob);
    assert.equal(values2.supplyValue, 0);
    assert.equal(values2.borrowValue, 0);

    assert.equal(await this.controller.getAccountHealth(alice), 0);
    assert.equal(await this.controller.getAccountHealth(bob), 0);

    assert.equal(await this.controller.getAccountLiquidity(alice), 0);
    assert.equal(await this.controller.getAccountLiquidity(bob), 0);
  });

  it("check accounts after supply and borrow", async () => {
    await this.token.approve(this.market.address, 100 * FACTOR, { from: alice });
    await this.market.supply(100 * FACTOR, { from: alice });

    await this.token2.approve(this.market2.address, 1000 * FACTOR, { from: bob });
    await this.market2.supply(1000 * FACTOR, { from: bob });

    await this.market2.borrow(10 * FACTOR, { from: alice });

    values = await this.controller.getAccountValues(alice);
    console.log("alice's supply value: " + values.supplyValue.toNumber() + "\tborrowValue: " + values.borrowValue.toNumber());
    // assert.equal(values.supplyValue, 0);
    // assert.equal(values.borrowValue, 0);

    values2 = await this.controller.getAccountValues(bob);
    console.log("bob's supply value: " + values2.supplyValue.toNumber() + "\tborrowValue: " + values2.borrowValue.toNumber());
    // assert.equal(values2.supplyValue, 0);
    // assert.equal(values2.borrowValue, 0);

    console.log("alice's health: " + (await this.controller.getAccountHealth(alice)).toNumber());
    // assert.equal(await this.controller.getAccountHealth(alice), 0);

    console.log("bob's health: " + (await this.controller.getAccountHealth(bob)).toNumber());
    // assert.equal(await this.controller.getAccountHealth(bob), 0);

    console.log("alice's liquidity: " + (await this.controller.getAccountLiquidity(alice)).toNumber());
    // assert.equal(await this.controller.getAccountLiquidity(alice), 0);

    console.log("bob's liquidity: " + (await this.controller.getAccountLiquidity(bob)).toNumber());
    // assert.equal(await this.controller.getAccountLiquidity(bob), 0);
  });
});


