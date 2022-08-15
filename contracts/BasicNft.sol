// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BasicNft is ERC721 {
    string private constant TOKEN_URI =
        "ipfs://QmXH5bWe8K8N5vQzP59mFCzKqF87aSX2vjMeqY7phGHT4E";

    uint256 private s_tokenCounter;

    constructor() ERC721("CATAHOLIC", "CTH") {
        s_tokenCounter = 0;
    }

    function mintNft() public returns (uint256) {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter++;
        return s_tokenCounter;
    }

    // no need token id
    function tokenURI(
        uint256 /*tokenId*/
    ) public pure override returns (string memory) {
        return TOKEN_URI;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}
