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


describe("HarvestorFactory Contract", function () {

  const setupTests = deployments.createFixture(async () => {
    const signers = await ethers.getSigners();
    const setup = await init.initialize(signers);

    root = setup.roles.root;
    user1 = setup.roles.user1;
    user2 = setup.roles.user2;

    tokenOne = await init.token(setup);
    tokenTwo = await init.token(setup);

    seeds = await init.mockSeeds(setup);

    await init.harvestorFactory(setup);
    harvestorFactory = setup.harvestorFactory.harvestorFactoryContract;

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

  describe("Integration - local environment", function () {
    it("Should setup the contracts correctly", async function () {

    });

    describe("Minting NFTs", function () {
      it("Should deploy a new harvestor for a new token", async function () {

      });

      it("Should revert if deploying a duplicate harvestor", async function () {

      });
    });

    describe("Deploy Harvestors", async function () {
      it("Should return the harvestor address", async function () {

      });
    });

    describe("Sell tokens", function () {
      it("Should return false if not a harvestor", async function () {

      });

      it("Should return true if a harvestor", async function () {

      });
    });

    describe("Withdraw Fees", function () {
      it("Should return false if not a harvestor", async function () {

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
