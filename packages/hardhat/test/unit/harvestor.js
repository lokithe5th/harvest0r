const { ethers } = require("hardhat");
const { expect } = require("chai");

const init = require('../test-init.js');

let seedsContract;
let seedsInterface;
let totalSupply;
let mintCost = ethers.utils.parseEther("0.069");

let root;
let user1;
let user2;

let harvestor;


describe("Harvestor Contract", function () {

  const setupTests = deployments.createFixture(async () => {
    const signers = await ethers.getSigners();
    const setup = await init.initialize(signers);

    root = setup.roles.root;
    user1 = setup.roles.user1;
    user2 = setup.roles.user2;

    harvestor = await setup.harvestor;

  });

  // quick fix to let gas reporter fetch data from gas station & coinmarketcap
  before("Setup", async () => {
    //setTimeout(await setupTests(), 2000);
    await setupTests();
  });

  describe("Harvestor", function () {
    it("Should initialize harvest0r", async function () {

    });

    describe("mint()", function () {
      it("Should be able to mint one NFT", async function () {

      });
    });

  });
});
