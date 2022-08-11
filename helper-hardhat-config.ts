export interface networkConfigItem {
  ethUsdPriceFeed?: string
  blockConfirmation?: number
  chainId?: number
  subscriptionId?: string
  gasLane?: string
  keepersUpdateInterval?: string
  raffleEntranceFee?: string
  callbackGasLimit?: string
  vrfCoordinatorV2?: string
  verifyBlockNumber?: number
  fundAmount?: string
  waitBlockConfirmations?: number
}

export interface networkConfigInfo {
  [key: string]: networkConfigItem
}

export const networkConfig: networkConfigInfo = {
  hardhat: {
    chainId: 31337,
    subscriptionId: "588",
    gasLane:
      "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc", // 30 gwei
    keepersUpdateInterval: "30",
    raffleEntranceFee: "100000000000000000", // 0.1 ETH
    callbackGasLimit: "500000", // 500,000 gas
    fundAmount: "1000000000000000000000",
    waitBlockConfirmations: 1,
  },
  localhost: {
    chainId: 31337,
    subscriptionId: "588",
    gasLane:
      "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc", // 30 gwei
    keepersUpdateInterval: "30",
    raffleEntranceFee: "100000000000000000", // 0.1 ETH
    callbackGasLimit: "500000", // 500,000 gas
    fundAmount: "1000000000000000000000",
    waitBlockConfirmations: 1,
  },
  rinkeby: {
    ethUsdPriceFeed: "0x8A753747A1Fa494EC906cE90E9f37563A8AF630e",
    blockConfirmation: 6,
    chainId: 4,
    subscriptionId: "588",
    gasLane:
      "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc", // 30 gwei
    keepersUpdateInterval: "30",
    raffleEntranceFee: "100000000000000000", // 0.1 ETH
    callbackGasLimit: "500000", // 500,000 gas
    vrfCoordinatorV2: "0x6168499c0cFfCaCD319c818142124B7A15E857ab",
    verifyBlockNumber: 6,
    waitBlockConfirmations: 6,
  },
}

export const developmentChains = ["hardhat", "localhost"]

export const frontEndAbiFile = "../next-lottery/constants/abi.json"
export const frontEndContractsFile =
  "../next-lottery/constants/contractAddress.json"
