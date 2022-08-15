import { assert, expect } from "chai"
import { network, deployments, ethers } from "hardhat"
import { developmentChainId } from "../../helper-hardhat-config"
import { BasicNft } from "../../typechain-types"

!developmentChainId.includes(network.config?.chainId!)
  ? describe.skip
  : describe("Basic NFT Unit Tests", function () {
      let basicNft: BasicNft
      let deployer

      beforeEach(async () => {
        const accounts = await ethers.getSigners()
        deployer = accounts[0]
        await deployments.fixture(["mocks", "basic"])
        basicNft = await ethers.getContract("BasicNft")
      })

      it("Allows users to mint an NFT, and updates appropriately", async function () {
        const TOKEN_URI =
          "ipfs://QmXH5bWe8K8N5vQzP59mFCzKqF87aSX2vjMeqY7phGHT4E"
        const txResponse = await basicNft.mintNft()
        await txResponse.wait(1)
        const tokenURI = expect(await basicNft.getTokenCounter()).to.equal("1")
        expect(await basicNft.tokenURI(0)).to.equal(TOKEN_URI)
      })
    })
