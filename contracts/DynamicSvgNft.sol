// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error DynamicSvgNft__NotExistTokenId();

contract DynamicSvgNft is ERC721 {
    uint256 private s_tokenCounter;
    string private i_lowImageURI;
    string private i_highImageURI;
    string private constant ENCODE_BASE64_PREFIX =
        "data:image//svg+xml;base64,";
    mapping(uint256 => int256) public s_tokenIdToPriceExpect;
    AggregatorV3Interface private immutable i_priceFeed;

    event NftMint(address indexed minter, uint256 tokenId, int256 expectPrice);

    constructor(
        address priceFeed,
        string memory lowSvg,
        string memory highSvg
    ) ERC721("Dynamic SVG NFT", "DSN") {
        s_tokenCounter = 0;
        i_lowImageURI = svgToImageURI(lowSvg);
        i_highImageURI = svgToImageURI(highSvg);
        i_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function svgToImageURI(string memory svg)
        public
        pure
        returns (string memory)
    {
        string memory encoded = Base64.encode(
            bytes(string(abi.encodePacked(svg)))
        );

        return string(abi.encodePacked(ENCODE_BASE64_PREFIX, encoded));
    }

    function mintNft(int256 expectPrice) public {
        uint256 tokenId = s_tokenCounter;
        // set price criteria for display svg
        s_tokenIdToPriceExpect[tokenId] = expectPrice;
        _safeMint(msg.sender, tokenId);
        s_tokenCounter++;
        emit NftMint(msg.sender, tokenId, expectPrice);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        if (!_exists(tokenId)) {
            revert DynamicSvgNft__NotExistTokenId();
        }

        string memory imageURI = i_lowImageURI;

        (, int256 price, , , ) = i_priceFeed.latestRoundData();

        if (price >= s_tokenIdToPriceExpect[tokenId]) {
            imageURI = i_highImageURI;
        }

        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        abi.encodePacked(
                            '{"name":"',
                            name(),
                            '", "descripton":"An NFT art base on chainlink feed", ',
                            '"attributes": [{"trait_type": "coolness", "value": 100}], ',
                            '"image":"',
                            imageURI,
                            '"}'
                        )
                    )
                )
            );
    }

    function getLowSVG() public view returns (string memory) {
        return i_lowImageURI;
    }

    function getHighSVG() public view returns (string memory) {
        return i_highImageURI;
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return i_priceFeed;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}
