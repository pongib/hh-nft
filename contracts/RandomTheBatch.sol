// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "erc721a/contracts/ERC721A.sol";

error RandomTheBatch__BreedOutOfRange();
error RandomTheBatch__BelowMintFee();
error RandomTheBatch__WithdrawFail();
error RandomTheBatch__AlreadyInitialize();
error RandomTheBatch__QuantityNotMatchRandomLength();

contract RandomTheBatch is VRFConsumerBaseV2, ERC721A, Ownable {
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

    struct Transaction {
        address owner;
        uint32 quantity;
    }

    // Chainlink variable
    VRFCoordinatorV2Interface private immutable i_vrfCoordintor;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATION = 3;
    uint32 private constant NUM_WORDS = 1;

    // vrf helper
    mapping(uint256 => Transaction) private s_vrfRequestIdToTransaction;

    // NFT variable
    uint256 private s_tokenCounter;
    uint8 constant MAX_CHANCE = 100;
    string[3] private s_tokenURIs;
    uint256 private immutable i_mintFee;
    bool private s_initialized = false;
    mapping(uint256 => Breed) private s_tokenIdToBreed;

    // event
    event NftRequest(address indexed requester, uint256 requestId);
    event NftMint(address indexed owner, uint256 startTokenId, uint32 quantity);

    // modifier

    constructor(
        address vrfCoordinator,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit,
        string[3] memory tokenURIs,
        uint256 mintFee
    ) VRFConsumerBaseV2(vrfCoordinator) ERC721A("THE BATCH", "TBX") {
        i_vrfCoordintor = VRFCoordinatorV2Interface(vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        _initializeTokenURIs(tokenURIs);
        i_mintFee = mintFee;
    }

    function _initializeTokenURIs(string[3] memory tokenURIs) private {
        if (s_initialized == true) {
            revert RandomTheBatch__AlreadyInitialize();
        }
        s_tokenURIs = tokenURIs;
        s_initialized = true;
    }

    function requestNft(uint32 quantity)
        public
        payable
        returns (uint256 requestId)
    {
        if (msg.value < i_mintFee * quantity) {
            revert RandomTheBatch__BelowMintFee();
        }
        requestId = i_vrfCoordintor.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATION,
            i_callbackGasLimit,
            quantity
        );

        s_vrfRequestIdToTransaction[requestId] = Transaction(
            msg.sender,
            quantity
        );

        emit NftRequest(msg.sender, requestId);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        Transaction memory txn = s_vrfRequestIdToTransaction[requestId];
        if (txn.quantity != randomWords.length) {
            revert RandomTheBatch__QuantityNotMatchRandomLength();
        }
        uint256 tokenCounter = _nextTokenId();
        for (uint256 i = 0; i < randomWords.length; i++) {
            // calculate breed
            Breed randomBreed = getBreedFromRng(randomWords[i]);
            s_tokenIdToBreed[tokenCounter + i] = randomBreed;
        }
        _safeMint(txn.owner, txn.quantity, "");

        emit NftMint(txn.owner, tokenCounter, txn.quantity);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        return s_tokenURIs[uint8(s_tokenIdToBreed[tokenId])];
    }

    function withdrawFee() external onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert RandomTheBatch__WithdrawFail();
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
        revert RandomTheBatch__BreedOutOfRange();
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

    function getTotalMinted() public view returns (uint256) {
        return _totalMinted();
    }
}
