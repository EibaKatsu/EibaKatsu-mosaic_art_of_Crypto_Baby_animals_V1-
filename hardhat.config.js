require('dotenv').config({path:__dirname+'/.env'})

require("@nomiclabs/hardhat-waffle");
// require("dotenv").config();
// const dotenv = require("dotenv");
// dotenv.config({path: __dirname + '/.env'});

const {ALCHEMY_KEY, PRIVATE_KEY} = process.env;
console.log("ALCHEMY_KEY:", ALCHEMY_KEY);
// console.log("process.env:", process.env);

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.4",

  networks: {
    rinkeby: {
      url: "https://eth-rinkeby.alchemyapi.io/v2/" + ALCHEMY_KEY,
      accounts: [`${PRIVATE_KEY}`],
    },
  },
};
