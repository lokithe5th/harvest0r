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

const seeds = async (setup) => {
    const seedFactory = await ethers.getContractFactory("Seeds");
    const seedsToken = await seedFactory.deploy();

    setup.seedsToken = seedsToken;

    return seedsToken;
}

const mockSeeds = async () => {
  const mockSeedFactory = await ethers.getContractFactory("MockSeeds");
  let mockSeeds = await mockSeedFactory.deploy();

  return mockSeeds;
}

const harvestorFactory = async (setup) => {
    const factory = await ethers.getContractFactory("Harvest0rFactory");
    const harvestorFactoryContract = await factory.deploy();

    const harvestorFactory = {
        harvestorFactoryContract
    }

    setup.harvestorFactory = harvestorFactory;
    return harvestorFactory;
};

module.exports = {
  initialize,
  harvestor,
  token,
  mockSeeds,
  harvestorFactory,
  seeds
}; 
