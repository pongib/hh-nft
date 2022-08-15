import { developmentChainId, networkConfig } from "../helper-hardhat-config"
import { HardhatRuntimeEnvironment } from "hardhat/types"
import verify from "../utils/verify"
import { DeployFunction } from "hardhat-deploy/dist/types"

const RandomIpfsNft: DeployFunction = async (
  hre: HardhatRuntimeEnvironment
) => {
  const { deployments, network, ethers } = hre
  const { deploy, log } = deployments
  const [deployer] = await ethers.getSigners()
  const chainId = network.config.chainId!
  let vrfCoordinatorV2Address
  let subscriptionId
  if (developmentChainId.includes(chainId)) {
    const vrfCoordinatorV2 = await ethers.getContract("VRFCoordinatorV2Mock")
    vrfCoordinatorV2Address = vrfCoordinatorV2.address
    const tx = await vrfCoordinatorV2.createSubscription()
    const txReceipt = await tx.wait()
    subscriptionId = txReceipt.events[0].args.subId
  } else {
    vrfCoordinatorV2Address = networkConfig[chainId].vrfCoordinatorV2
    subscriptionId = networkConfig[chainId].subscriptionId
  }
  log("----- Deploy Mock -----")
  log("------ Start Deploy ------")
  const args: any[] = []
  const randomIpfsNft = await deploy("RandomIpfsNft", {
    from: deployer.address,
    args,
    log: true,
    waitConfirmations: networkConfig[chainId].waitBlockConfirmations,
  })
  log("------ Deploy Completed -----")
  if (!developmentChainId.includes(chainId) && process.env.ETHERSCAN_API_KEY) {
    log("------ Verify -----")
    await verify(randomIpfsNft.address, args)
  }
}

export default RandomIpfsNft
RandomIpfsNft.tags = ["basic", "all"]
