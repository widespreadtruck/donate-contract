const { assert, expect } = require("chai")
const { deployments, ethers, getNamedAccounts } = require("hardhat")

describe("FundMe", async function () {
  let fundMe
  let deployer
  let mockV3Aggregator
  beforeEach(async function () {
    // deploy fundMe using hardhat-deploy
    // const accounts = await ethers.getSigners()
    // const accountZero = accounts[0]
    deployer = (await getNamedAccounts()).deployer
    await deployments.fixture(["all"])
    // get the contract that just been deployed with the deployer account name
    fundMe = await ethers.getContract("FundMe", deployer)
    mockV3Aggregator = await ethers.getContract("MockV3Aggregator", deployer)
  })

  describe("constructor", function () {
    it("sets the aggregator addresses correctly", async () => {
      const response = await fundMe.priceFeed()
      assert.equal(response, mockV3Aggregator.address)
    })
  })
})
