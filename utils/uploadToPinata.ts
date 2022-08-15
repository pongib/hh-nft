import pinataSDK from "@pinata/sdk"
import fs from "fs"
import path from "path"

const pinata = pinataSDK(
  process.env.PINATA_API_KEY!,
  process.env.PINATA_API_SECRET!
)

async function storeImages(imagesFilePath: string) {
  const fullPath = path.resolve(imagesFilePath)
  const files = fs.readdirSync(fullPath)
  const responses = []
  for (const file of files) {
    console.log(`Pin file ${fullPath}/${file}`)
    const streamFile = fs.createReadStream(`${fullPath}/${file}`)
    try {
      const response = await pinata.pinFileToIPFS(streamFile)
      console.log(response)
      responses.push(response)
    } catch (error: any) {
      console.error(error.message)
    }
  }

  return { responses, files }
}

export async function storeTokenURIMetadata(metadata: Object, options: Object) {
  try {
    const response = await pinata.pinJSONToIPFS(metadata, options)
    return response
  } catch (error) {
    console.log(error)
  }
}

export { storeImages }
