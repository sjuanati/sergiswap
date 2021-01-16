const Router = artifacts.require("UniswapV2Router02.sol");
const WETH = artifacts.require('WETH.sol');

module.exports = async (deployer, network) => {
    let weth;
    // from previousy Deploying 'UniswapV2Factory'
    const FACTORY_ADDRESS = '0xae71BfE6E94D5e00F908f4eEc421306463bB6621';

    if (network === 'mainnet') {
        weth = await WETH.at('0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2');
    } else {
        await deployer.deploy(WETH);
        weth = await WETH.deployed();
    };

    await deployer.deploy(Router, FACTORY_ADDRESS, weth.address);
    
};
