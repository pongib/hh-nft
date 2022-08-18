// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

contract Encoding {
    function combineString() public pure returns (string memory) {
        return string(abi.encodePacked("Hi", "Pongtsu"));
    }

    function encodeNumber1() public pure returns (bytes memory) {
        bytes memory number = abi.encode(1);
        return number;
    }

    function encodeNumber() public pure returns (bytes memory) {
        return abi.encode(1);
    }

    function encodeString() public pure returns (bytes memory) {
        return abi.encode("pong");
    }

    function encodeStringPacked() public pure returns (bytes memory) {
        return abi.encodePacked("pong");
    }

    function encodeStringBytes() public pure returns (bytes memory) {
        return bytes("pong");
    }

    function decodeString() public pure returns (string memory) {
        return abi.decode(encodeString(), (string));
    }

    function decodeStringPacked() public pure returns (string memory) {
        return abi.decode(encodeStringPacked(), (string));
    }

    function multiEncode() public pure returns (bytes memory) {
        return abi.encode("pongtsu", "gibgyb");
    }

    function mutiDecode() public pure returns (string memory, string memory) {
        return abi.decode(multiEncode(), (string, string));
    }

    function multiEncodePacked() public pure returns (bytes memory) {
        return abi.encodePacked("pongtsu", "gibgyb");
    }

    function multiDecodePacked()
        public
        pure
        returns (string memory, string memory)
    {
        return abi.decode(multiEncodePacked(), (string, string));
    }

    function multiStringCastPacked() public pure returns (string memory) {
        return string(multiEncodePacked());
    }

    function multiStringCast() public pure returns (string memory) {
        return string(multiEncode());
    }

    function stringCastFromEncode() public pure returns (string memory) {
        return string(abi.encode("pongtsu"));
    }

    function stringConcat() public pure returns (string memory) {
        return string.concat("pongtsu", "gibgyb");
    }

    function stringToBytesAccess()
        public
        pure
        returns (
            bytes1,
            bytes1,
            bytes1,
            bytes1,
            bytes1,
            bytes1,
            bytes1
        )
    {
        string memory name = "pongtsu";
        bytes memory nameInbytes = bytes(name);
        return (
            nameInbytes[0],
            nameInbytes[1],
            nameInbytes[2],
            nameInbytes[3],
            nameInbytes[4],
            nameInbytes[5],
            nameInbytes[6]
        );
    }

    function charAccess() public pure returns (string memory) {
        string memory name = "pongtsu";
        bytes memory nameInbytes = bytes(name);
        bytes memory display = new bytes(3);
        display[0] = nameInbytes[0];
        // return (string(nameInbytes[0]), string(nameInbytes[1]), string(nameInbytes[2]), string(nameInbytes[3]),string(nameInbytes[4]),string(nameInbytes[5]), string(nameInbytes[6]));
        return string(display);
    }

    function getFirstChar(string memory _originString)
        public
        pure
        returns (string memory)
    {
        bytes memory firstCharByte = new bytes(1);
        firstCharByte[0] = bytes(_originString)[0];
        return string(firstCharByte);
    }
}
