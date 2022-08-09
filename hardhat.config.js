require("@nomiclabs/hardhat-waffle");

require("@nomiclabs/hardhat-ethers")
// require('hardhat-deploy')
// require("@nomiclabs/hardhat-etherscan")
require("hardhat-gas-reporter");
require('dotenv').config()
const KOVAN_RPC_URL = process.env.KOVAN_RPC_URL
const POLYGON_RPC_URL = process.env.POLYGON_RPC_URL
const FUJI_RPC_URL = process.env.FUJI_RPC_URL
const AVALANCHE_RPC_URL = process.env.AVALANCHE_RPC_URL
const RINKEBY_RPC_URL = process.env.RINKEBY_RPC_URL
const VELAS_RPC_URL = process.env.VELAS_RPC_URL
const VELASTEST_RPC_URL = process.env.VELASTEST_RPC_URL
const MNEMONIC = process.env.MNEMONIC
const MNEMONIC2 = process.env.MNEMONIC2
const PRIVATE_KEY1 = process.env.PRIVATE_KEY1
const PRIVATE_KEY2 = process.env.PRIVATE_KEY2
const CMC_API_KEY = process.env.CMC_API_KEY
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY

module.exports = {
  gasReporter: {
    enabled: true,
    showTimeSpent: true,
    currency: 'avax',
    coinmarketcap: CMC_API_KEY,
    gasPrice: 25
  },
  defaultNetwork: "hardhat",

  networks: {
    // hatdhat:{
    //   chainId: 31337
    // },
    rinkeby: {
      url: RINKEBY_RPC_URL,
      accounts: {
        mnemonic: MNEMONIC
      },
      saveDeployments: true
    },
    kovan: {
      url: KOVAN_RPC_URL,
      accounts: {
        mnemonic: MNEMONIC
      },
      saveDeployments: true
    },
    polygon: {
      url: POLYGON_RPC_URL,
      accounts: {
        mnemonic: MNEMONIC
      },
      saveDeployments: true
    },
    fuji: {
      url: FUJI_RPC_URL,
      accounts: [PRIVATE_KEY1, PRIVATE_KEY2],
      // accounts: {
      //   mnemonic: [MNEMONIC, MNEMONIC2]
      // },
      saveDeployments: true
    },
    avalanche: {
      url: AVALANCHE_RPC_URL,
      chainId: 43114,
      accounts: [PRIVATE_KEY1, PRIVATE_KEY2],
      gasPrice: 225000000000,
      // accounts: {
      //   mnemonic: [MNEMONIC, MNEMONIC2]
      // },
      saveDeployments: true
    },
    velastest: {
      url: VELASTEST_RPC_URL,
      saveDeployments: true,
      accounts: [PRIVATE_KEY1, PRIVATE_KEY2]
    },
    velas: {
      url: VELAS_RPC_URL,
      saveDeployments: true,
      accounts: [PRIVATE_KEY1, PRIVATE_KEY2]
    }
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY
  },
  solidity: {
    compilers: [
      {
        version: "0.8.0"
      },
      {
        version: "0.8.4"
      },
      {
        version: "0.4.24"
      },
      {
        version: "0.6.6"
      },
      {
        version: "0.7.0"
      }
    ]
  },
  namedAccounts: {
    deployer: {
      default: 0 // First account from metamask address
    }
  }
};