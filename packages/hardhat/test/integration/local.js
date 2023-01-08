const { ethers } = require("hardhat");
const { expect } = require("chai");

const init = require('../test-init.js');
const { parseEther } = require("ethers/lib/utils.js");

//  Users
let root;
let user1;
let user2;

//  Implementation contract
let harvestor;

//  Tokens
let tokenOne;
let tokenTwo;

//  NFT
let seeds;

//  Factory
let harvestorFactory;

//  Harvestors
let harvestorOne;
let harvestorTwo;

//  Mint
let mintCost = parseEther("0.069");

/**
 * Happy path
 * 
 * 1) Deploy the Harvestor Implementation contract
 * 2) Deploy the Seeds Access Voucher Contract
 * 3) Deploy the HarvestorFactory
 * 4) Deploy two MockTokens
 * 5) Mint 10 Seeds NFTs across two accounts
 * 6) Deploy two Harvestors
 * 7) Sell MockTokens from three accounts
 * 8) Withdraw fees from the Harvestor contracts
 */


describe("Integration - Local", function () {

  const setupTests = deployments.createFixture(async () => {
    const signers = await ethers.getSigners();
    const setup = await init.initialize(signers);

    root = setup.roles.root;
    user1 = setup.roles.user1;
    user2 = setup.roles.user2;

    // Set up the two mockTokens
    tokenOne = await init.token(setup);
    tokenTwo = await init.token(setup);

    // Deploy the harvestor factory
    await init.harvestorFactory(setup);
    harvestorFactory = setup.harvestorFactory.harvestorFactoryContract;
    // Deploy the SEEDS NFT
    seeds = await init.seeds(setup);
    // Deploy the Harvestor
    harvestor = await init.harvestor(setup);

    // Sets up the contracts
    await seeds.setup(harvestorFactory.address);
    await harvestorFactory.setup(harvestor.address, seeds.address);
    await harvestor.init(seeds.address, seeds.address);


  });

  // quick fix to let gas reporter fetch data from gas station & coinmarketcap
  before("Setup", async () => {
    //setTimeout(await setupTests(), 2000);
    await setupTests();

    await tokenOne.transfer(user1.address, parseEther("10"));
    await tokenOne.transfer(user2.address, parseEther("10"));

    await tokenTwo.transfer(user1.address, parseEther("10"));
    await tokenTwo.transfer(user2.address, parseEther("10"));

  });

  describe("Integration", function () {
    it("Should setup the contracts correctly", async function () {
      expect(await seeds.name()).to.equal("Seeds Access Voucher");
      expect(await seeds.symbol()).to.equal("SEEDS");

      expect(await harvestorFactory.viewImplementation()).to.equal(harvestor.address);
    });

    describe("Minting NFTs", function () {
      it("Should mint 5 NFTs for two accounts", async function () {
        await seeds.connect(user1).mint(5, {value: parseEther((0.069 * 5).toString())});
        await seeds.connect(user2).mint(5, {value: parseEther((0.069 * 5).toString())});

        expect(await seeds.balanceOf(user1.address)).to.equal(5);
        expect(await seeds.balanceOf(user2.address)).to.equal(5);
      });
    });

    describe("Deploy Harvestors", async function () {
      it("Should deploy harvestors for the two tokens", async function () {
        await harvestorFactory.newHarvestor(tokenOne.address);
        await harvestorFactory.newHarvestor(tokenTwo.address);

        harvestorOne = await harvestorFactory.findHarvestor(tokenOne.address);
        harvestorTwo = await harvestorFactory.findHarvestor(tokenTwo.address);

        harvestorOne = harvestor.attach(harvestorOne);
        harvestorTwo = harvestor.attach(harvestorTwo);
      });
    });

    describe("Sell tokens", function () {
      it("Should allow users to sell the appropriate tokens", async function () {
        await tokenOne.connect(user1).approve(harvestorOne.address, parseEther("5"));
        await tokenTwo.connect(user1).approve(harvestorTwo.address, parseEther("5"));

        await tokenOne.connect(user2).approve(harvestorOne.address, parseEther("5"));
        await tokenTwo.connect(user2).approve(harvestorTwo.address, parseEther("5"));

        await harvestorOne.connect(user1).sellToken(1, parseEther("1"));
        await harvestorOne.connect(user2).sellToken(6, parseEther("1"));

        await harvestorTwo.connect(user1).sellToken(1, parseEther("1"));
        await harvestorTwo.connect(user2).sellToken(6, parseEther("1"));
      });

      it("Should return true if a harvestor", async function () {

      });
    });

    describe("Withdraw Fees", function () {
      it("Should allow the creator to withdraw fees", async function () {
        let accumulatedFees = await seeds.viewFees();
        await seeds.withdrawFees(root.address, accumulatedFees);
      });

      it("Should return true if a harvestor", async function () {

      });
    });

    describe("Withdraw Tokens", function () {
      it("Should return false if not a harvestor", async function () {

      });

      it("Should return true if a harvestor", async function () {

      });
    });
  });
});
