// require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
// require('dotenv').config({path:__dirname+'/.env'})
require('dotenv').config()
// require("@nomiclabs/hardhat-waffle");
require("@nomicfoundation/hardhat-chai-matchers");


const {ALCHEMY_KEY_RINKEBY, ALCHEMY_KEY_GOERLI, PRIVATE_KEY, PRIVATE_KEY2} = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.4",

  networks: {
    goerli: {
      url: "https://eth-goerli.alchemyapi.io/v2/" + ALCHEMY_KEY_GOERLI,
      accounts: [`${PRIVATE_KEY2}`],
    },
    rinkeby: {
      url: "https://eth-rinkeby.alchemyapi.io/v2/" + ALCHEMY_KEY_RINKEBY,
      accounts: [`${PRIVATE_KEY}`],
    },
  },

  etherscan: {
    apiKey: "W66I7MNM355YCSUDT9G7XVHGE7GX5QSNX5"
  }
};
