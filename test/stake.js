const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const {ethers} =require('hardhat')

describe('Testing Stake contract', function(){
  async function deployContract(){
    token='0xde0B295669a9FD93d5F28D9Ec85E40f4cb697BAe'
    timeReward=15
    rewardPercent=11

    // const [owner,account2]=await ethers.getSigners()

    const signer=await ethers.provider.getSigner()
    const stakeContract=await ethers.getContractFactory('StakeV2')
    const stake=await stakeContract.deploy(timeReward,rewardPercent,token,{signer})

    return {stake,token,timeReward,rewardPercent,signer}
  }
  
  
  describe('Deployment and check the owner and token of the contract',function(){
    
    it('should check the owner of contract',async function(){
      const {stake,signer}=await deployContract()
      expect(await stake.getOwner()).to.equal(signer.address)
    })
    
    it('should check the token of the contract',async function(){
      const {stake,token}=await deployContract()
      console.log(token,await stake.getToken())
      expect(await stake.getToken()).to.equal(token)
    })
  })
  
  describe('Transactions',function(){
    it('should stake and check the balance of the user',async function(){
      const {stake,signer}=await deployContract()
      
      const usertBalanceBeforeStake=await stake.connect(signer).getBalance()
      const amountStake=await ethers.parseEther('1')
      await stake.connect(signer).approveContract(amountStake)
      await stake.connect(signer).stake(amountStake)
      console.log(await stake.getBalance())

      expect(await stake.connect(account2).getBalance()).to.equal(usertBalanceBeforeStake+amountStake)
    })

    // it('should allow to user unstake',async function(){
    //   const {stake,account2}=await loadFixture(deployContract)

    //   await stake.connect(account2).unSatke()
    //   const usertBalance=await stake.connect(account2).getBalance()

    //   expect(await stake.connect(account2).getBalance()).to.equal(0)
    // })

    // it('should withdraw the user reward',async function(){
    //   const {stake,account2}=await loadFixture(deployContract)

    //   const userBalanceBeforeWithdrawReward=await stake.connect(account2).getBalance()
    //   const userReward=await stake.connect(account2).reward()
    //   await stake.connect(account2).withdrawReward()
    //   const userBalanceAfterWithdrawReward=await stake.connect(account2).getBalance()

    //   expect(userBalanceAfterWithdrawReward).to.equal(userBalanceBeforeWithdrawReward-userReward)
    // })

    // it('should withdraw amount of user want',async function(){
    //   const {stake,account2}=await loadFixture(deployContract)

    //   const userBalanceBeforeWithdraw=await stake.connect(account2).getBalance()
    //   const withdrawAmount=await ethers.parseEther('0.1')
    //   await stake.connect(account2).withdraw(withdrawAmount)
    //   const userBalanceAfterWithdraw=await stake.connect(account2).getBalance()

    //   expect(userBalanceAfterWithdraw).to.equal(userBalanceBeforeWithdraw-withdrawAmount)
    // })
  })

})
