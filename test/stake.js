const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const {ethers} =require('hardhat')

describe('Testing Stake contract', function(){
  async function deployContract(){
    token='0xdAC17F958D2ee523a2206206994597C13D831ec7'
    timeReward=15
    rewardPercent=11

    const [owner,account2]=await ethers.getSigners()

    const stakeContract=await ethers.getContractFactory('StakeV2')
    const stake=await stakeContract.deploy(timeReward,rewardPercent,token)

    return {stake,token,timeReward,rewardPercent,owner,account2}
  }

  describe('Deployment and check the owner and token of the contract',function(){
    
    it('should check the owner of contract',async function(){
      const {stake,owner}=await loadFixture(deployContract)
      expect(await stake.getOwner()).to.equal(owner.address)
    })

    it('should check the token of the contract',async function(){
      const {stake,token}=await loadFixture(deployContract)
      console.log(token,await stake.getToken())
      expect(await stake.getToken()).to.equal(token)
    })
  })

  describe('Transactions',function(){
    it('should stake and check the balance of the contract',async function(){
      const {stake,account2}=await loadFixture(deployContract)
      
      const amountStake=await ethers.parseEther('1')
      await stake.connect(account2).approveContract(amountStake)
      await stake.connect(account2).stake(amountStake)
      console.log(await stake.getBalance())

      expect(await stake.getBalance()).to.equal(amountStake)
    })

    // it('should allow to user unstake',async function(){
    //   const {stake,account2}=await loadFixture(deployContract)

    //   await stake.connect(account2).unSatke()
    // })
  })

})
