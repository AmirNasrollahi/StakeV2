require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",
  networks:{
    localganache:{
      url:process.env.RPC_PROVIDER,
      accounts:[process.env.PRIVATE_KEY]
    }
  }
};
