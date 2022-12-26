const {
  networkConfig,
  developmentChains,
} = require("./../helper-hardhat-config")
const { network } = require("hardhat")
const { verify } = require("../utils/verify")

// { getNamedAccounts, deployments } are abstructed from the Hardhat Runtime Enviroment - hre
module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log, get } = deployments
  const { deployer } = await getNamedAccounts()
  const chainId = network.config.chainId

  // const ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
  let ethUsdPriceFeedAddress
  if (chainId == 31337) {
    const ethUsdAggregator = await get("MockV3Aggregator")
    ethUsdPriceFeedAddress = ethUsdAggregator.address
  } else {
    ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
  }

  // use a mock network for testing
  const args = [ethUsdPriceFeedAddress]
  const fundMe = await deploy("FundMe", {
    from: deployer,
    args: args, // pricefeed address
    log: true,
    waitConfirmations: network.config.blockConfirmations || 1,
  })
  log(`FundMe deployed at ${fundMe.address}`)

  if (
    !developmentChains.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    //verify
    await verify(fundMe.address, args)
  }
  log("----------------------------------------")
}
module.exports.tags = ["all", "fundme"]
