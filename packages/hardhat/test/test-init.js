//  Init the test environment
const { ethers } = require('hardhat');

const initialize = async (accounts) => {
  const setup = {};
  setup.roles = {
    root: accounts[0],
    user1: accounts[1],
    user2: accounts[2]
  };

  return setup;
};

const harvestor = async (setup) => {
    const harvestorContractFactory = await ethers.getContractFactory("Harvest0r");
    let harvestorContract = await harvestorContractFactory.deploy();

    return harvestorContract;
}

const token = async (setup) => {
  const tokenFactory = await ethers.getContractFactory("MockToken");
  const token = await tokenFactory.deploy();

  return token;
}

const mockSeeds = async (setup) => {
  const mockSeedFactory = await ethers.getContractFactory("MockSeeds");
  let mockSeeds = await mockSeedFactory.deploy();

  return mockSeeds;
}

module.exports = {
  initialize,
  harvestor,
  token,
  mockSeeds
}; 
