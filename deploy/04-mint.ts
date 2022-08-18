import { DeployFunction } from "hardhat-deploy/types"
import { HardhatRuntimeEnvironment } from "hardhat/types"
import {
  BasicNft,
  DynamicSvgNft,
  RandomIpfsNft,
  VRFCoordinatorV2Mock,
} from "../typechain-types"
import { developmentChainId } from "../helper-hardhat-config"
const mint: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { network, ethers } = hre
  const [deployer] = await ethers.getSigners()
  const chainId = network.config.chainId
  console.log("------ Mint ------")

  // basic nft
  const basicNft: BasicNft = await ethers.getContract("BasicNft", deployer)
  const basicNftTx = await basicNft.mintNft()
  await basicNftTx.wait()
  console.log(`Basic NFT mint token Id 0 is: ${await basicNft.tokenURI(0)}`)

  // Dynamic SVG
  const highValue = ethers.utils.parseEther("1500")
  const dynamicSvgNft: DynamicSvgNft = await ethers.getContract(
    "DynamicSvgNft",
    deployer
  )
  const dynamicSvgNftMintTx = await dynamicSvgNft.mintNft(highValue)
  await dynamicSvgNftMintTx.wait(1)
  console.log(
    `Dynamic SVG NFT index 0 tokenURI: ${await dynamicSvgNft.tokenURI(0)}`
  )

  // Random IPFS NFT
  const randomIpfsNft: RandomIpfsNft = await ethers.getContract(
    "RandomIpfsNft",
    deployer
  )
  const mintFee = await randomIpfsNft.getMintFee()
  const randomIpfsNftMintTx = await randomIpfsNft.requestNft({
    value: mintFee.toString(),
  })
  const randomIpfsNftMintTxReceipt = await randomIpfsNftMintTx.wait(1)

  // // Need listen for response
  await new Promise<void>(async (resolve, reject) => {
    try {
      // 5 minutes for timeout
      // setTimeout(() => reject("Timeout occur"), 300000)

      setTimeout(() => reject("Timeout occur"), 60000)
      // listener for event
      randomIpfsNft.once("NftMint", async () => {
        resolve()
      })

      if (developmentChainId.includes(chainId!)) {
        const requestId =
          randomIpfsNftMintTxReceipt.events![1].args!.requestId.toString()
        const vrfCoordinatorV2Mock: VRFCoordinatorV2Mock =
          await ethers.getContract("VRFCoordinatorV2Mock", deployer)
        console.log("CALL VRF")
        try {
          await vrfCoordinatorV2Mock.fulfillRandomWords(
            requestId,
            randomIpfsNft.address
          )
        } catch (error) {
          console.log("xxxxxxxxxx")

          console.log(error)
        }
      }
    } catch (error) {
      console.log(error)
      reject()
    }
  })

  console.log(
    `Random IPFS NFT index 0 tokenURI: ${await randomIpfsNft.tokenURI(0)}`
  )
}

export default mint
mint.tags = ["all", "mint"]
