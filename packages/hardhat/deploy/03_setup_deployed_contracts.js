const { ethers } = require("hardhat");

const localChainId = "31337";

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  // Getting a previously deployed contract
  const Harvest0rFactory = await ethers.getContract("Harvest0rFactory", deployer);
  const Seeds = await ethers.getContract("Seeds", deployer);
  const Harvest0r = await ethers.getContract("Harvest0r", deployer);

  await Harvest0r.init(Seeds.address, Seeds.address, Seeds.address);
  
  await Harvest0rFactory.setup(Harvest0r.address, Seeds.address);

  await Seeds.setup(Harvest0rFactory.address);

  try {
    if (chainId !== localChainId) {
      await run("verify:verify", {
        address: Seeds.address,
        contract: "contracts/Seeds.sol:Seeds",
        constructorArguments: [],
      });
    }
  } catch (error) {
    console.error(error);
  }

  try {
    if (chainId !== localChainId) {
      await run("verify:verify", {
        address: Harvest0r.address,
        contract: "contracts/Harvest0r.sol:Harvest0r",
        constructorArguments: [],
      });
    }
  } catch (error) {
    console.error(error);
  }   
  
  try {
    if (chainId !== localChainId) {
      await run("verify:verify", {
        address: Harvest0rFactory.address,
        contract: "contracts/Harvest0rFactory.sol:Harvest0rFactory",
        constructorArguments: [],
      });
    }
  } catch (error) {
    console.error(error);
  }


};
module.exports.tags = ["Harvest0rFactory"];
