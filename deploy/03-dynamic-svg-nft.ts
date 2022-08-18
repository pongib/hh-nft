import { developmentChainId, networkConfig } from "../helper-hardhat-config"
import verify from "../utils/verify"
import { DeployFunction } from "hardhat-deploy/types"
import { HardhatRuntimeEnvironment } from "hardhat/types"
import fs from "fs"

const deployDynamicSvgNft: DeployFunction = async (
  hre: HardhatRuntimeEnvironment
) => {
  const { deployments, network, ethers } = hre
  const { deploy, log } = deployments
  const [deployer] = await ethers.getSigners()
  const chainId = network.config.chainId!
  const { ethUsdPriceFeed, waitBlockConfirmations } = networkConfig[chainId]
  let ethUsdPriceFeedAddress

  if (developmentChainId.includes(chainId)) {
    // Find ETH/USD price feed
    const EthUsdAggregator = await deployments.get("MockV3Aggregator")
    ethUsdPriceFeedAddress = EthUsdAggregator.address
  } else {
    ethUsdPriceFeedAddress = ethUsdPriceFeed
  }

  const lowSvg = fs.readFileSync("./images/dynamicNft/frown.svg", {
    encoding: "utf8",
  })

  const highSvg = fs.readFileSync("./images/dynamicNft/happy.svg", "utf8")
  const args = [ethUsdPriceFeedAddress, lowSvg, highSvg]

  const dynamicSvgNft = await deploy("DynamicSvgNft_temp", {
    from: deployer.address,
    args: args,
    log: true,
    waitConfirmations: waitBlockConfirmations,
  })

  // Verify the deployment
  if (!developmentChainId.includes(chainId) && process.env.ETHERSCAN_API_KEY) {
    log("Verifying...")
    await verify(dynamicSvgNft.address, args)
  }
}

export default deployDynamicSvgNft
deployDynamicSvgNft.tags = ["all", "dynamicsvg", "main"]
