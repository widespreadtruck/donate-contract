const { deployments, ethers, getNamedAccounts } = require("hardhat")

describe("FundMe", async function () {
  let fundMe
  beforeEach(async function () {
    // deploy fundMe using hardhat-deploy
    const deployer = await getNamedAccounts()
    await deployments.fixture(["all"])
    // get the contract that just been deployed
    fundMe = await ethers.getContract('FundMe')
  })
  describe()
})
