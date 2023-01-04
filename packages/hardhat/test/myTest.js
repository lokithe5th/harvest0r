const { ethers } = require("hardhat");
const { expect } = require("chai");
const { utils } = require("mocha");

describe("Seeds NFT", function () {
  let seedsContract;
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
      });
    });
  });
});
