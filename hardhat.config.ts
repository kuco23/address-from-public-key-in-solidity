import { HardhatUserConfig } from "hardhat/config"
import "@nomiclabs/hardhat-truffle5"
import "@nomicfoundation/hardhat-toolbox"
import "@nomiclabs/hardhat-web3"

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.11",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  mocha: {
    timeout: 100000000
  },
  networks: {
    coston: {
      url: "https://coston-api.flare.network/ext/C/rpc",
      chainId:  16
    },
    costwo: {
      url: "https://coston2-api.flare.network/ext/C/rpc",
      chainId: 114
    },
    fuji: {
      url: "https://api.avax-test.network/ext/bc/C/rpc",
      chainId: 43113
    }
  }
}

export default config