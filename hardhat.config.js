require('dotenv').config();
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require('hardhat-contract-sizer');
require('hardhat-deploy-ethers');
require('hardhat-abi-exporter');
require("hardhat-gas-reporter");
require('hardhat-log-remover');
require("hardhat-tracer");
require('hardhat-deploy');

// Tasks
require('./src/tasks/update-hop-tokens')
require('./src/tasks/update-adapters')
require('./src/tasks/verify-contract')
require('./src/tasks/find-best-path')
require('./src/tasks/find-best-path-wrapped')
require('./src/tasks/list-adapters')

const ARBITRUM_RPC = getEnvValSafe('ARBITRUM_RPC')
const ARBITRUM_SEPOLIA_RPC = getEnvValSafe('ARBITRUM_SEPOLIA_RPC',false)
const XAI_RPC = getEnvValSafe('XAI_RPC',false)
const ARBITRUM_PK_DEPLOYER = getEnvValSafe('ARBITRUM_PK_DEPLOYER')
const ETHERSCAN_API_KEY = getEnvValSafe('ETHERSCAN_API_KEY')

function getEnvValSafe(key, required=true) {
  const endpoint = process.env[key];
  if (!endpoint && required)
      throw(`Missing env var ${key}`);
  return endpoint
}

module.exports = {
  mocha: {
    timeout: 1e6,
    recursive: true,
    spec: ['test/*.spec.js']
  },
  solidity: {
      version: "0.8.17",
      settings: {
        optimizer: {
          enabled: true,
          runs: 10000,
          details: {
            yulDetails: {
              optimizerSteps: "u"
            }
          },
        },
        viaIR: true,
      }
  },
  namedAccounts: {
    deployer: {
      default: 0,
    }
  },
  etherscan: {
    apiKey: {
      arbitrum: ETHERSCAN_API_KEY,
      arbitrumSepolia: ETHERSCAN_API_KEY,
      xai: ETHERSCAN_API_KEY
    },
    customChains: [{
      network: "arbitrumSepolia",
      chainId: 421614,
      urls: {
        apiURL: "https://api-sepolia.arbiscan.io/api",
        browserURL: "https://sepolia.arbiscan.io"
      }
    },{
      network: "xai",
      chainId: 660279,
      urls: {
        apiURL: "https://explorer.xai-chain.net/api",
        browserURL: "https://explorer.xai-chain.net/"
      }
    }]
  },
  defaultNetwork: 'hardhat',
  networks: {
    arbitrum: {
      chainId: 42161,
      url: ARBITRUM_RPC,
      accounts: [ ARBITRUM_PK_DEPLOYER ],
    },
    arbitrumSepolia: {
      chainId: 421614,
      url: ARBITRUM_SEPOLIA_RPC,
      accounts: [ ARBITRUM_PK_DEPLOYER ],
    },
    xai: {
      chainId: 660279,
      url: XAI_RPC,
      accounts: [ ARBITRUM_PK_DEPLOYER ],
    },
  },
  paths: {
    deployments: './src/deployments',
    artifacts: "./src/artifacts",
    sources: "./src/contracts",
    deploy: './src/deploy',
    cache: "./src/cache",
    tests: "./src/test"
  },
  abiExporter: {
    path: './abis',
    clear: true,
    flat: true
  },
  contractSizer: {
    disambiguatePaths: false,
    runOnCompile: false,
    alphaSort: false,
  },
  gasReporter: {
    showTimeSpent: true, 
    enabled: false,
    gasPrice: 225
  }
};
