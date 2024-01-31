require("@nomicfoundation/hardhat-foundry")
require("@nomicfoundation/hardhat-toolbox")

module.exports = {
  solidity: {
    version: "0.8.23",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  gasReporter: {
    currency: "USD",
    gasPrice: 20,
    enabled: true,
  },
  paths: {
    sources: "./src", // Use ./src rather than ./contracts as Hardhat expects
    cache: "./cache_hardhat", // Use a different cache for Hardhat than Foundry
  },
}
