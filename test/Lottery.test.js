const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Lottery Contract", () => {
  let LotteryContract, lottery, RNGContract, rng, owner, user1, user2;

  beforeEach(async function () {
    [owner, user1, user2] = await ethers.getSigners();
    LotteryContract = await ethers.getContractFactory("Lottery");
    RNGContract = await ethers.getContractFactory("RandomNumberGenerator");

    rng = await RNGContract.deploy();
    lottery = await LotteryContract.deploy(1000, 500, rng.address);
  });

  describe("Deployment", () => {
    it("should set the right owner for both contracts", async () => {
      expect(await lottery.owner()).to.equal(owner.address);
    });
    it("initialize right parameters for Lottery", async () => {
      expect(await lottery.entryFee()).to.equal(1000);
      expect(await lottery.ownerCut()).to.equal(500);
      expect(await lottery.state()).to.equal(0);
    });
  });
});
