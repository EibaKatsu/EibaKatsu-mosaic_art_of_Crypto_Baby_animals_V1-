// require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
// require('dotenv').config({path:__dirname+'/.env'})
require('dotenv').config()
// require("@nomiclabs/hardhat-waffle");
require("@nomicfoundation/hardhat-chai-matchers");
require("hardhat-gas-reporter");


// const {ALCHEMY_KEY_RINKEBY, ALCHEMY_KEY_GOERLI, PRIVATE_KEY, PRIVATE_KEY2} = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.4",

  networks: {
    mainnet: {
      url: "https://eth-mainnet.g.alchemy.com/v2/" + process.env.ALCHEMY_KEY_MAINNET,
      accounts: [`${process.env.PRIVATE_KEY}`],
    },
    goerli: {
      url: "https://eth-goerli.alchemyapi.io/v2/" + process.env.ALCHEMY_KEY_GOERLI,
      accounts: [`${process.env.PRIVATE_KEY_DEV}`],
    },
    rinkeby: {
      url: "https://eth-rinkeby.alchemyapi.io/v2/" + process.env.ALCHEMY_KEY_RINKEBY,
      accounts: [`${process.env.PRIVATE_KEY_DEV}`],
    },
  },

  etherscan: {
    apiKey: "W66I7MNM355YCSUDT9G7XVHGE7GX5QSNX5"
  },

  gasReporter: {
    enabled: (process.env.REPORT_GAS) ? true : false
  }
};
