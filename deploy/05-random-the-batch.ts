import { developmentChainId, networkConfig } from "../helper-hardhat-config"
import { HardhatRuntimeEnvironment } from "hardhat/types"
import verify from "../utils/verify"
import { DeployFunction } from "hardhat-deploy/dist/types"
import { storeImages, storeTokenURIMetadata } from "../utils/uploadToPinata"
import { VRFConsumerBaseV2 } from "../typechain-types"
import { VRFCoordinatorV2Mock } from "../typechain-types/@chainlink/contracts/src/v0.8/mocks"

const RandomTheBatch: DeployFunction = async (
  hre: HardhatRuntimeEnvironment
) => {
  const { deployments, network, ethers } = hre
  const { deploy, log } = deployments
  const [deployer] = await ethers.getSigners()
  const chainId = network.config.chainId!
  const mintFee = ethers.utils.parseEther("0.01")
  const fundSubcription = ethers.utils.parseEther("10")
  // get from handle token uris
  const tokenURIs = [
    "ipfs://QmfJdQFZ7iRmSDY3mdssiv758C5j3UWMq3B412Gb3SEa7v",
    "ipfs://QmTEa4gXCDUAv4MzK4BNJqEZbj3c6cbCkbchpejVMvVb94",
    "ipfs://QmbiwR24vepWcoxNxvD92nP8jLSrW1j2JvDZNa6TNjgvZn",
  ]

  const {
    vrfCoordinatorV2: vrfCoordinatorV2AddressConfig,
    subscriptionId: subIdMock,
    gasLane,
    callbackGasLimit,
    waitBlockConfirmations,
  } = networkConfig[chainId]

  let vrfCoordinatorV2Address
  let subscriptionId
  let vrfCoordinatorV2Mock!: VRFCoordinatorV2Mock

  if (developmentChainId.includes(chainId)) {
    log("----- Deploy Mock -----")
    vrfCoordinatorV2Mock = await ethers.getContract("VRFCoordinatorV2Mock")
    vrfCoordinatorV2Address = vrfCoordinatorV2Mock.address
    const tx = await vrfCoordinatorV2Mock.createSubscription()
    const txReceipt = await tx.wait()
    subscriptionId = txReceipt.events![0].args!.subId
    console.log("subscriptionId", subscriptionId.toString())

    await vrfCoordinatorV2Mock.fundSubscription(subscriptionId, fundSubcription)
  } else {
    vrfCoordinatorV2Address = vrfCoordinatorV2AddressConfig
    subscriptionId = subIdMock
  }
  log("------ Start Deploy ------")

  const args: any[] = [
    vrfCoordinatorV2Address,
    gasLane,
    subscriptionId,
    callbackGasLimit,
    tokenURIs,
    mintFee,
  ]

  const randomTheBatch = await deploy("RandomTheBatch", {
    from: deployer.address,
    args,
    log: true,
    waitConfirmations: waitBlockConfirmations,
  })

  if (developmentChainId.includes(chainId)) {
    await vrfCoordinatorV2Mock.addConsumer(
      subscriptionId,
      randomTheBatch.address
    )
  }

  log("------ Deploy Completed -----")
  if (!developmentChainId.includes(chainId) && process.env.ETHERSCAN_API_KEY) {
    log("------ Verify -----")
    await verify(randomTheBatch.address, args)
  }
}

export default RandomTheBatch
RandomTheBatch.tags = ["randomTheBatch", "all", "main"]
