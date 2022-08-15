import { developmentChainId, networkConfig } from "../helper-hardhat-config"
import { HardhatRuntimeEnvironment } from "hardhat/types"
import verify from "../utils/verify"
import { DeployFunction } from "hardhat-deploy/dist/types"
import { storeImages } from "../utils/uploadToPinata"

const RandomIpfsNft: DeployFunction = async (
  hre: HardhatRuntimeEnvironment
) => {
  const { deployments, network, ethers } = hre
  const { deploy, log } = deployments
  const [deployer] = await ethers.getSigners()
  const chainId = network.config.chainId!
  const mintFee = ethers.utils.parseEther("0.01")
  const imagesPath = "./images/randomNft"

  const {
    vrfCoordinatorV2,
    subscriptionId: subIdMock,
    gasLane,
    callbackGasLimit,
  } = networkConfig[chainId]
  let vrfCoordinatorV2Address
  let subscriptionId
  if (developmentChainId.includes(chainId)) {
    log("----- Deploy Mock -----")
    const vrfCoordinatorV2 = await ethers.getContract("VRFCoordinatorV2Mock")
    vrfCoordinatorV2Address = vrfCoordinatorV2.address
    const tx = await vrfCoordinatorV2.createSubscription()
    const txReceipt = await tx.wait()
    subscriptionId = txReceipt.events[0].args.subId
  } else {
    vrfCoordinatorV2Address = vrfCoordinatorV2
    subscriptionId = subIdMock
  }
  log("------ Start Deploy ------")
  console.log(typeof process.env.STORE_PINATA)

  if (process.env.STORE_PINATA == "true") await storeImages(imagesPath)
  // const args: any[] = [
  //   vrfCoordinatorV2Address,
  //   gasLane,
  //   subscriptionId,
  //   callbackGasLimit,
  //   // tokenURIs,
  //   mintFee,
  // ]
  // const randomIpfsNft = await deploy("RandomIpfsNft", {
  //   from: deployer.address,
  //   args,
  //   log: true,
  //   waitConfirmations: networkConfig[chainId].waitBlockConfirmations,
  // })
  // log("------ Deploy Completed -----")
  // if (!developmentChainId.includes(chainId) && process.env.ETHERSCAN_API_KEY) {
  //   log("------ Verify -----")
  //   await verify(randomIpfsNft.address, args)
  // }
}

async function getTokenURIs() {}

export default RandomIpfsNft
RandomIpfsNft.tags = ["randomIpfs", "all"]
