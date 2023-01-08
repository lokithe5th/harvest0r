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


describe("Seeds NFT", function () {

  const setupTests = deployments.createFixture(async () => {
    const signers = await ethers.getSigners();
    const setup = await init.initialize(signers);

    root = setup.roles.root;
    user1 = setup.roles.user1;
    user2 = setup.roles.user2;

  });

  // quick fix to let gas reporter fetch data from gas station & coinmarketcap
  before("Setup", async () => {
    //setTimeout(await setupTests(), 2000);
    await setupTests();
  });

  describe("Seeds", function () {
    it("Should deploy Seeds", async function () {
      const mockFactory = await ethers.getContractFactory("MockFactory");
      

      const seeds = await ethers.getContractFactory("Seeds");

      seedsContract = await seeds.deploy();

      let mock = await mockFactory.deploy(seedsContract.address, seedsContract.address);

      await seedsContract.setup(mock.address);
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

      it("Should revert if attempting to mint with unsufficient value", async function () {
        // Bug when trying to test custom revert error
        await expect(seedsContract.mint(1)).to.be.reverted;
      });
    });

    describe("viewCharge()", function () {
      it("Should return the correct amount of charges for a new NFT", async function () {
        expect(await seedsContract.viewCharge(1)).to.equal(9);
      });

      it("Should return the correct amount of charges for a used NFT", async function () {
        await seedsContract.useCharge(1);

        expect(await seedsContract.viewCharge(1)).to.equal(8);
      });

      it("Should revert if tokenId does not exist yet", async function () {
        await expect(seedsContract.viewCharge(8)).to.be.reverted;
      });
    });

    describe("useCharge()", function () {
      it("Should revert if trying to use a tokenId that does not exist yet", async function () {
        await expect(seedsContract.useCharge(10)).to.be.reverted;
      });

      it("Should revert if not using owned token", async function () {
        await expect(seedsContract.connect(user1).useCharge(1)).to.be.reverted;
      });

      it("Should be usable 9 times", async function () {
        expect(await seedsContract.viewCharge(2)).to.equal(9);

        for (let i = 0; i < 9; i++) {
          await seedsContract.useCharge(2);
        }

        expect(await seedsContract.viewCharge(2)).to.equal(0);
      });
    });

    describe("recharge()", function () {
      it("Should fail to recharge an NFT if the msg.value is unsufficient", async function () {
        await expect(seedsContract.recharge(1, {value: 0})).to.be.reverted;
      });

      it("Should recharge an NFT whose charges have been used up", async function () {
        await expect(seedsContract.recharge(1, {value: mintCost})).to.emit(seedsContract, "Recharged");
        expect(await seedsContract.viewCharge(1)).to.equal(9);
      });
    });

    describe("tokenURI()", function () {
      it("Should return the appropriate tokenURI", async function () {
        let json = await seedsContract.tokenURI(1);
        expect(json).to.contain("application/json");
      });
    });

    describe("generateSVGofTokenById()", function () {
      it("Should return the appropriate SVG", async function () {
        let svg = await seedsContract.generateSVGofTokenById(1);
        expect(svg).to.contain("Charges");
        expect(svg).to.contain('<svg xmlns="http://www.w3.org/2000/svg"');
      });
    });
  });
});
