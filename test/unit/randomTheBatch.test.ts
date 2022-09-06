// We are going to skimp a bit on these tests...

import { assert, expect } from "chai"
import { network, deployments, ethers } from "hardhat"
import { developmentChainId } from "../../helper-hardhat-config"
import { RandomTheBatch, VRFCoordinatorV2Mock } from "../../typechain-types"

!developmentChainId.includes(network.config?.chainId!)
  ? describe.skip
  : describe("Random The Batch Unit Tests", function () {
      let randomTheBatch: RandomTheBatch,
        deployer,
        vrfCoordinatorV2Mock: VRFCoordinatorV2Mock

      beforeEach(async () => {
        const accounts = await ethers.getSigners()
        deployer = accounts[0]
        await deployments.fixture(["mocks", "randomTheBatch"])
        randomTheBatch = await ethers.getContract("RandomTheBatch")
        vrfCoordinatorV2Mock = await ethers.getContract("VRFCoordinatorV2Mock")
      })

      describe("requestNft", function () {
        it("fails if payment isn't sent with the request", async function () {
          await expect(
            randomTheBatch.requestNft(10)
          ).to.be.revertedWithCustomError(
            randomTheBatch,
            "RandomTheBatch__BelowMintFee"
          )
        })
        it("emits and event and kicks off a random word request", async function () {
          const fee = await randomTheBatch.getMintFee()
          await expect(
            randomTheBatch.requestNft(10, { value: fee.mul(10) })
          ).to.emit(randomTheBatch, "NftRequest")
        })
      })

      describe("fulfillRandomWords", function () {
        it("mints NFT after random number returned", async function () {
          await new Promise<void>(async (resolve, reject) => {
            randomTheBatch.once("NftMint", async () => {
              try {
                const tokenUri = await randomTheBatch.tokenURI(0)
                expect(tokenUri.toString().includes("ipfs://")).to.be.true

                expect(await randomTheBatch.getTotalMinted()).to.equal(10)
                resolve()
              } catch (e) {
                console.log(e)
                reject(e)
              }
            })
            try {
              const fee = await randomTheBatch.getMintFee()
              const requestNftResponse = await randomTheBatch.requestNft(10, {
                value: fee.mul(10),
              })
              const requestNftReceipt = await requestNftResponse.wait(1)
              await vrfCoordinatorV2Mock.fulfillRandomWords(
                requestNftReceipt.events![1].args!.requestId,
                randomTheBatch.address
              )
            } catch (e) {
              console.log(e)
              reject(e)
            }
          })
        })
      })
    })
