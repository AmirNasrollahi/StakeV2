
const hardhat=require('hardhat')

async function main(){
  const tokenAddress='0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae'
  const timeReward=5
  const rewardPercent=12

  const stakeContract=await hardhat.ethers.getContractFactory('StakeV2')
  const stake=await stakeContract.deploy(timeReward,rewardPercent,tokenAddress)

  await stake.waitForDeployment(2)
  const contractAddress=await stake.getAddress()
  console.log(`contract Address:${contractAddress}`)
  console.log(await stake.getOwner())
}

main().catch((err)=>{
  console.log(err)
  process.exitCode(1)
})