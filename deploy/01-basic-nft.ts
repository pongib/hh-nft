import { developmentChainId, networkConfig } from "../helper-hardhat-config"
import { HardhatRuntimeEnvironment } from "hardhat/types"
import verify from "../utils/verify"
import { DeployFunction } from "hardhat-deploy/dist/types"

const BasicNft: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const { deployments, network, ethers } = hre
  const { deploy, log } = deployments
  const [deployer] = await ethers.getSigners()
  log("------ Start Deploy Basic Nft ------")
  const args: any[] = []
  const chainId = network.config.chainId!
  const basicNft = await deploy("BasicNft", {
    from: deployer.address,
    args,
    log: true,
    waitConfirmations: networkConfig[chainId].waitBlockConfirmations,
  })
  log("------ Deploy Completed -----")
  if (!developmentChainId.includes(chainId) && process.env.ETHERSCAN_API_KEY) {
    log("------ Verify -----")
    await verify(basicNft.address, args)
  }
}

export default BasicNft
BasicNft.tags = ["basic", "all"]
