// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

error RandomIpfsNft__BreedOutOfRange();
error RandomIpfsNft__BelowMintFee();
error RandomIpfsNft__WithdrawFail();

contract RandomIpfsNft is VRFConsumerBaseV2, ERC721URIStorage, Ownable {
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
    uint8 constant MAX_CHANCE = 100;
    string[3] s_tokenURIs;
    uint256 private immutable i_mintFee;

    // event
    event NftRequest(address indexed requester, uint256 requestId);
    event NftMint(address indexed owner, uint256 tokenId, Breed breed);

    // modifier

    constructor(
        address vrfCoordinator,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit,
        string[3] memory tokenURIs,
        uint256 mintFee
    ) VRFConsumerBaseV2(vrfCoordinator) ERC721("VRF IPFS NFT", "VIN") {
        i_vrfCoordintor = VRFCoordinatorV2Interface(vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_tokenURIs = tokenURIs;
        i_mintFee = mintFee;
    }

    function requestNft() public payable returns (uint256 requestId) {
        if (msg.value < i_mintFee) {
            revert RandomIpfsNft__BelowMintFee();
        }
        requestId = i_vrfCoordintor.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATION,
            i_callbackGasLimit,
            NUM_WORDS
        );

        s_vrfRequestIdToOwner[requestId] = msg.sender;

        emit NftRequest(msg.sender, requestId);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        require(false, "ERRRRRRRRR");
        address owner = s_vrfRequestIdToOwner[requestId];
        uint256 tokenCounter = s_tokenCounter;
        // calculate breed\
        Breed randomBreed = getBreedFromRng(randomWords[0]);
        console.log("randomBreed", uint256(randomBreed));
        console.log("owner", owner);
        console.log("tokenCounter", tokenCounter);
        _safeMint(owner, tokenCounter);
        console.log(
            "s_tokenURIs[uint8(randomBreed)]",
            s_tokenURIs[uint8(randomBreed)]
        );
        _setTokenURI(tokenCounter, s_tokenURIs[uint8(randomBreed)]);
        s_tokenCounter++;
        console.log("event");
        emit NftMint(owner, tokenCounter, randomBreed);
    }

    function withdrawFee() external onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert RandomIpfsNft__WithdrawFail();
        }
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

    function getMintFee() public view returns (uint256) {
        return i_mintFee;
    }

    function getTokenURIs(uint8 index) public view returns (string memory) {
        return s_tokenURIs[index];
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}
