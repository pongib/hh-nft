import { developmentChainId, networkConfig } from "../helper-hardhat-config"
import { HardhatRuntimeEnvironment } from "hardhat/types"
import verify from "../utils/verify"
import { DeployFunction } from "hardhat-deploy/dist/types"
import { storeImages, storeTokenURIMetadata } from "../utils/uploadToPinata"
import { VRFConsumerBaseV2 } from "../typechain-types"
import { VRFCoordinatorV2Mock } from "../typechain-types/@chainlink/contracts/src/v0.8/mocks"

const RandomIpfsNft: DeployFunction = async (
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

  if (process.env.STORE_PINATA == "true") await handleTokenURIs()
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
  const randomIpfsNft = await deploy("RandomIpfsNft", {
    from: deployer.address,
    args,
    log: true,
    waitConfirmations: waitBlockConfirmations,
  })

  if (developmentChainId.includes(chainId)) {
    await vrfCoordinatorV2Mock.addConsumer(
      subscriptionId,
      randomIpfsNft.address
    )
  }

  log("------ Deploy Completed -----")
  if (!developmentChainId.includes(chainId) && process.env.ETHERSCAN_API_KEY) {
    log("------ Verify -----")
    await verify(randomIpfsNft.address, args)
  }
}

async function handleTokenURIs() {
  const tokenURIs = []
  const metadataTemplate = {
    name: "",
    description: "",
    image: "",
    attributes: [
      {
        trait_type: "Cuteness",
        value: "100",
      },
    ],
  }

  const imagesPath = "./images/randomNft"
  const { responses: imgResponses, files } = await storeImages(imagesPath)
  for (const index in imgResponses) {
    // create new object metadata
    const metadata = { ...metadataTemplate }
    metadata.name = files[index].replace(".png", "")
    metadata.description = `An adorable ${metadata.name}!`
    metadata.image = `ipfs://${imgResponses[index].IpfsHash}`
    const options = {
      pinataMetadata: {
        name: `${metadata.name} metadata`,
      },
    }
    console.log(metadata)
    console.log(options)
    const metadataResponse = await storeTokenURIMetadata(metadata, options)
    tokenURIs.push(`ipfs://${metadataResponse?.IpfsHash}`)
  }

  console.log("tokenURIs", tokenURIs)
  return tokenURIs
}

export default RandomIpfsNft
RandomIpfsNft.tags = ["randomIpfs", "all", "main"]
