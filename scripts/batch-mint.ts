import { deployments, ethers } from "hardhat"
import { RandomTheBatch } from "../typechain-types"

const main = async () => {
  await deployments.fixture(["randomTheBatch", "mocks"])
  const randomTheBatch: RandomTheBatch = await ethers.getContract(
    "RandomTheBatch"
  )
  const tx = await randomTheBatch.requestNft(100)
  const receipt = await tx.wait()
  console.log(`gas to mint ${receipt.gasUsed.toString()}`)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.log(error)
    process.exit(1)
  })
