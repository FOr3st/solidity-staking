const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Staking", function () {
  let owner, signer1, signer2;
  let stakingToken, staking;

  beforeEach(async function () {
    [owner, signer1, signer2] = await ethers.getSigners();

    // Deploying 'TKN' token contract
    const StakingToken = await ethers.getContractFactory("StakingToken");
    stakingToken = await StakingToken.deploy("StakingToken", "TKN", 11000);
    await stakingToken.deployed();

    // Deploying Staking contract
    const Staking = await ethers.getContractFactory("Staking");
    staking = await Staking.deploy(stakingToken.address, stakingToken.address);
    await staking.deployed();

    // Fill staking, signer1 and signer2 accounts
    await stakingToken.transfer(staking.address, 10000);
    await stakingToken.transfer(signer1.address, 200);
    await stakingToken.transfer(signer2.address, 300);

    // Allowing to stake owner's tokens
    await stakingToken.approve(
      staking.address,
      await stakingToken.balanceOf(owner.address)
    );
    
    // Allowing to stake signer's tokens
    await stakingToken
      .connect(signer1)
      .approve(
        staking.address,
        await stakingToken.balanceOf(signer1.address)
      );

    await stakingToken
      .connect(signer2)
      .approve(
        staking.address,
        await stakingToken.balanceOf(signer2.address)
      );
  });

  describe("Initialization", function () {
    it("Owner, signer1, signer2 and staking account should have balances properly set", async function () {
      expect(await stakingToken.balanceOf(owner.address)).to.equal(500);
      expect(await stakingToken.balanceOf(staking.address)).to.equal(10000);
      expect(await stakingToken.balanceOf(signer1.address)).to.equal(200);
      expect(await stakingToken.balanceOf(signer2.address)).to.equal(300);
    });

    it("Owner, signer1 and signer2 should be able to send TKN tokens to staking", async function () {
      expect(
        await stakingToken.allowance(owner.address, staking.address)
      ).to.equal(await stakingToken.balanceOf(owner.address));
      expect(
        await stakingToken.allowance(signer1.address, staking.address)
      ).to.equal(await stakingToken.balanceOf(signer1.address));
      expect(
        await stakingToken.allowance(signer2.address, staking.address)
      ).to.equal(await stakingToken.balanceOf(signer2.address));
    });

    it("Should allow distribution only to owner", async function () {
      expect(staking.connect(signer1).distribute(200)).to.be.revertedWith(
        "Ownable: caller is not the owner"
      );
    });
  });

  describe("Transactions (single depositor)", function () {
    it("Should update account balances after staking", async function () {
      await staking.deposit(10);

      expect(await staking.getAmountToWithdraw(owner.address)).to.be.equal(10);
    });

    it("Should update token balances after staking", async function () {
      await staking.connect(signer1).deposit(10);

      expect(await stakingToken.balanceOf(signer1.address)).to.be.equal(190);
    });

    it("Should update account reward after distribution", async function () {
      await staking.deposit(10);
      await staking.distribute(200);

      expect(await staking.getAmountToWithdraw(owner.address)).to.be.equal(210);
    });

    it("Should withdraw tokens to depositor address", async function () {
      await staking.connect(signer1).deposit(50);
      await staking.distribute(200);
      await staking.connect(signer1).withdraw();
        
      expect(await stakingToken.balanceOf(signer1.address)).to.be.equal(400);
    });

    it("Should update account reward after withdraw", async function () {
      await staking.deposit(10);
      await staking.withdraw();

      expect(await staking.getAmountToWithdraw(owner.address)).to.be.equal(0);
    });

    it("Should restrict additional staking", async function () {
      await staking.deposit(10);

      expect(staking.deposit(10)).to.be.revertedWith("User already has deposit");
    });
  });

  describe("Transactions (multiple depositors)", function () {
    it("Should update muiltiple account balances after staking", async function () {
      await staking.deposit(10);
      await staking.connect(signer1).deposit(20);
      await staking.connect(signer2).deposit(30);

      expect(await staking.getAmountToWithdraw(owner.address)).to.be.equal(10);
      expect(await staking.getAmountToWithdraw(signer1.address)).to.be.equal(20);
      expect(await staking.getAmountToWithdraw(signer2.address)).to.be.equal(30);
    });

    it("Should update muiltiple account rewards after distribution", async function () {
      await staking.deposit(20);
      await staking.connect(signer1).deposit(30);
      await staking.connect(signer2).deposit(50);
      await staking.distribute(200);

      expect(await staking.getAmountToWithdraw(owner.address)).to.be.equal(40 + 20);
      expect(await staking.getAmountToWithdraw(signer1.address)).to.be.equal(60 + 30);
      expect(await staking.getAmountToWithdraw(signer2.address)).to.be.equal(100 + 50);
    });

    it("Should distribute rewards proportionally based on deposit time", async function () {
      await staking.deposit(50); // currentReward = 0
      await staking.distribute(200); // currentReward += reward / totalSupply = 0 + 200 / 50 = 4
      await staking.connect(signer1).deposit(50); // currentReward = 4
      await staking.distribute(400); // currentReward += reward / totalSupply = 4 + 400 / 100 = 8
      await staking.connect(signer2).deposit(50); // currentReward = 8

      expect(await staking.getAmountToWithdraw(owner.address)).to.be.equal(400 + 50);
      expect(await staking.getAmountToWithdraw(signer1.address)).to.be.equal(200 + 50);
      expect(await staking.getAmountToWithdraw(signer2.address)).to.be.equal(0 + 50);
    });
  });
});
