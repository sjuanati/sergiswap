const BonusToken = artifacts.require('BonusToken');
const LiquidityMigrator = artifacts.require('LiquidityMigrator');

module.exports = async (deployer) => {
  await deployer.deploy(BonusToken);
  const bonusToken = await BonusToken.Deployed();

  const routerAddress = '';
  const pairAddress = '';
  const routerForkAddress = '';
  const pairForkAddress = '';

  await deployer.deploy(
    LiquidityMigrator,
    routerAddress,
    pairAddress,
    routerForkAddress,
    pairForkAddress,
    bonusToken.address
  );

  const liquidityMigrator = await LiquidityMigrator.deployed();
   // Call setLiquidator on the BonusToken : LiquidityMigrator is awolled to mint token on BonusToken
  await bonusToken.setLiquidator(liquidityMigrator.address);
};
