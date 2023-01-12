const { ethers } = require("hardhat");

const localChainId = "31337";

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  // Getting a previously deployed contract
  const Harvest0rFactory = await ethers.getContract("Harvest0rFactory", deployer);
  const Seeds = await ethers.getContract("Seeds", deployer);

  await Harvest0rFactory.transferOwnership("0x809F55D088872FFB148F86b5C21722CAa609Ac72");

  await Seeds.transferOwnership("0x809F55D088872FFB148F86b5C21722CAa609Ac72")

};
module.exports.tags = ["Harvest0rFactory"];
