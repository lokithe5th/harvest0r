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


describe("Harvestor Contract", function () {

  const setupTests = deployments.createFixture(async () => {
    const signers = await ethers.getSigners();
    const setup = await init.initialize(signers);

    root = setup.roles.root;
    user1 = setup.roles.user1;
    user2 = setup.roles.user2;

    harvestor = await init.harvestor(setup);
    token = await init.token(setup);
    seeds = await init.mockSeeds(setup);

  });

  // quick fix to let gas reporter fetch data from gas station & coinmarketcap
  before("Setup", async () => {
    //setTimeout(await setupTests(), 2000);
    await setupTests();

    await seeds.mint(5, {value: parseEther("1")});
    await token.transfer(user1.address, parseEther("10"));

  });

  describe("Harvestor", function () {
    it("Should initialize harvest0r", async function () {
      await expect(harvestor.init(seeds.address, token.address)).
        to.emit(harvestor, "Initialized").
          withArgs(1);
    });

    describe("sellToken()", function () {
      it("Should revert if not the Seeds NFT owner", async function () {
        await expect(harvestor.connect(user1).sellToken(1, 1)).to.be.reverted;
      });

      it("Should be able to sell tokens to the harvestor", async function () {
        await token.approve(harvestor.address, parseEther("1"));
        await expect(harvestor.sellToken(1, parseEther("1"))).to.emit(harvestor, "Sale");
      });
    });

    describe("transferToken()", function () {
      it("Should revert if not the owner", async function () {
        await expect(harvestor.connect(user1).transferToken(root.address, 1)).to.be.reverted;
      });

      it("Should revert if value greater than balance", async function () {
        await expect(harvestor.transferToken(user1.address, parseEther("3"))).to.be.reverted;
      });

      it("Should be able to transfer tokens to the target address", async function () {
        await expect(harvestor.transferToken(root.address, 1)).
            to.emit(harvestor, "TokensTransferred").
                withArgs(root.address, 1);
      });
    });

    describe("viewToken()", function () {
      it("Should return the correct token", async function () {
        expect(await harvestor.viewToken()).to.equal(token.address);
      });
    });

  });
});
