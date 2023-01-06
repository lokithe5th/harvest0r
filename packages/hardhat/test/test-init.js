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

module.exports = {
  initialize,
  harvestor
}; 
