const { ethers } = require("hardhat");
const { expect } = require("chai");

const init = require('../test-init.js');
const { parseEther } = require("ethers/lib/utils.js");

let root;
let user1;
let user2;

let harvestor;
let token;
let seeds;
let harvestorFactory;

let testHarvestor;


describe("HarvestorFactory Contract", function () {

  const setupTests = deployments.createFixture(async () => {
    const signers = await ethers.getSigners();
    const setup = await init.initialize(signers);

    root = setup.roles.root;
    user1 = setup.roles.user1;
    user2 = setup.roles.user2;

    token = await init.token(setup);
    seeds = await init.mockSeeds(setup);
    await init.harvestorFactory(setup);
    harvestorFactory = setup.harvestorFactory.harvestorFactoryContract;
    harvestor = await init.harvestor(setup);

  });

  // quick fix to let gas reporter fetch data from gas station & coinmarketcap
  before("Setup", async () => {
    //setTimeout(await setupTests(), 2000);
    await setupTests();
    await token.transfer(user1.address, parseEther("10"));

  });

  describe("HarvestorFactory", function () {
    it("Should setup harvest0r", async function () {
      await harvestorFactory.setup(harvestor.address, seeds.address);
      expect(await harvestorFactory.viewImplementation()).to.equal(harvestor.address);
    });

    describe("newHarvestor()", function () {
      it("Should deploy a new harvestor for a new token", async function () {
        await expect(harvestorFactory.newHarvestor(token.address)).to.emit(harvestorFactory, "HarvestorDeployed");
      });

      it("Should revert if deploying a duplicate harvestor", async function () {
        await expect(harvestorFactory.newHarvestor(token.address)).to.be.reverted;
      });
    });

    describe("findHarvestor()", async function () {
      it("Should return the harvestor address", async function () {
        testHarvestor = await harvestorFactory.findHarvestor(token.address);
        expect(testHarvestor).to.not.be.null;
      });
    });

    describe("isHarvestor()", function () {
      it("Should return false if not a harvestor", async function () {
        expect(await harvestorFactory.isHarvestor(user2.address)).to.be.false;
      });

      it("Should return true if a harvestor", async function () {
        expect(await harvestorFactory.isHarvestor(testHarvestor)).to.be.true;
      });
    });

  });
});
