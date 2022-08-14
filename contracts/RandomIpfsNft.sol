// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/token/ERC721/extension/ERC721URIStorage.sol";

error RandomIpfsNft__BreedOutOfRange();

contract RandomIpfsNft is VRFConsumerBaseV2, ERC721URIStorage {
    /* feat
      1. Mint with random from vrf
      2. NFT have rare level with 3 type
      3. Mint have to pay and owner have withdraw
    */

    // ENUM
    enum Breed {
        PUG,
        SHIBA_INU,
        ST_BERNARD
    }

    // Chainlink variable
    VRFCoordinatorV2Interface private immutable i_vrfCoordintor;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATION = 3;
    uint32 private constant NUM_WORDS = 1;

    // vrf helper
    mapping(uint256 => address) private s_vrfRequestIdToOwner;

    // NFT variable
    uint256 private s_tokenCounter;
    uint8 internal constant MAX_CHANCE = 100;
    string[3] internal s_tokenURIs;

    constructor(
        address vrfCoordinator,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit,
        string[3] memory tokenURIs
    ) VRFConsumerBaseV2(vrfCoordinator) ERC721("VRF IPFS NFT", "VIN") {
        i_vrfCoordintor = VRFCoordinatorV2Interface(vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_tokenURIs = tokenURIs;
    }

    function mintNft() public returns (uint256 requestId) {
        requestId = i_vrfCoordintor.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATION,
            i_callbackGasLimit,
            NUM_WORDS
        );
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        address owner = s_vrfRequestIdToOwner[requestId];
        uint256 tokenCounter = s_tokenCounter;
        // calculate breed\

        Breed randomBreed = getBreedFromRng(randomWords[0]);
        _safeMint(owner, tokenCounter);
        _setTokenURI(tokenCounter, tokenURIs[uint8(randomBreed)]);
        s_tokenCounter++;
    }

    /* Chance
        7 -> PUG
        12 -> SHIBA
        45 -> St. Bernard
    */
    function getBreedFromRng(uint256 randomWord) public pure returns (Breed) {
        uint8 moddedRng = uint8(randomWord % MAX_CHANCE);
        uint8[3] memory chanceArray = getChanceArray();
        uint8 cummulativeSum = 0;
        for (uint256 i = 0; i < chanceArray.length; i++) {
            // formular [0, 10) => [10, 30) => [30, 100)
            if (
                moddedRng >= cummulativeSum &&
                moddedRng < chanceArray[i] + cummulativeSum
            ) {
                return Breed(i);
            }
            cummulativeSum += chanceArray[i];
        }
        revert RandomIpfsNft__BreedOutOfRange();
    }

    function getChanceArray() public pure returns (uint8[3] memory) {
        return [10, 20, 70]; // 10% 20% 70%
    }

    function tokenURI(uint256) public view override returns (string memory) {}
}
