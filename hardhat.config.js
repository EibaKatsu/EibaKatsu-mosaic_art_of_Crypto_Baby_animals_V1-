require("@nomiclabs/hardhat-etherscan");
require('dotenv').config({path:__dirname+'/.env'})
require("@nomiclabs/hardhat-waffle");

const {ALCHEMY_KEY, PRIVATE_KEY} = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.4",

  networks: {
    rinkeby: {
      url: "https://eth-rinkeby.alchemyapi.io/v2/" + ALCHEMY_KEY,
      accounts: [`${PRIVATE_KEY}`],
    },
  },

  etherscan: {
    apiKey: "W66I7MNM355YCSUDT9G7XVHGE7GX5QSNX5"
  }
};
