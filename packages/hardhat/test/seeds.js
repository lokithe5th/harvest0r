const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("Seeds NFT", function () {
  let seedsContract;
  let seedsInterface;
  let totalSupply;
  let mintCost = ethers.utils.parseEther("0.069");

  // quick fix to let gas reporter fetch data from gas station & coinmarketcap
  before((done) => {
    setTimeout(done, 2000);
  });

  describe("Seeds", function () {
    it("Should deploy Seeds", async function () {
      const mockFactory = await ethers.getContractFactory("MockFactory");
      let mock = await mockFactory.deploy();

      const seeds = await ethers.getContractFactory("Seeds");

      seedsContract = await seeds.deploy(mock.address);
    });

    describe("mint()", function () {
      it("Should be able to mint one NFT", async function () {
        await seedsContract.mint(1, {value: mintCost});

        expect(await seedsContract.totalSupply()).to.equal(1);
        totalSupply++;
      });

      it("Should be able to mint 5 NFTs", async function () {
        let batchMintCost = ethers.utils.parseEther((0.069 * 5).toString());
        await seedsContract.mint(5, {value: batchMintCost});

        expect(await seedsContract.totalSupply()).to.equal(6);
      });

      it("Should revert if attempting to mint more than 5", async function () {
        let batchMintCost = ethers.utils.parseEther((0.069 * 6).toString());
        // Bug when trying to test custom revert error
        await expect(seedsContract.mint(6, {value: batchMintCost})).to.be.reverted;
      });
    });
  });
});
