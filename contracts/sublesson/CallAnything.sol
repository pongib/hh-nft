// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

contract CallAnything {
    address public s_address;
    uint256 public s_amount;

    function transfer(address to, uint256 amount) public returns (bytes32) {
        s_address = to;
        s_amount = amount;
        return keccak256(abi.encodePacked(to, amount));
    }

    function getFuncitonSignature() public pure returns (bytes32) {
        return keccak256("transfer(address,uint256)");
    }

    function getFunctionSelector() public pure returns (bytes4) {
        return bytes4(getFuncitonSignature());
    }

    function getDataToCallTransfer(address to, uint256 amount)
        public
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(getFunctionSelector(), to, amount);
    }

    function selfCallTransfer(address to, uint256 amount)
        public
        returns (bool, bytes4)
    {
        (bool success, bytes memory returnData) = address(this).call(
            getDataToCallTransfer(to, amount)
        );
        return (success, bytes4(returnData));
    }

    function selfCallTransferWithSignature(address to, uint256 amount)
        public
        returns (bool, bytes4)
    {
        (bool success, bytes memory returnData) = address(this).call(
            abi.encodeWithSignature("transfer(address,uint256)", to, amount)
        );
        return (success, bytes4(returnData));
    }

    //get a function selector from data sent into the call
    function getSelectorFromData() public pure returns (bytes4) {
        address to = 0x7C4e30a43ecC4d3231b5B07ed082329020D141F3;
        uint256 amount = 777;
        bytes memory returnData = abi.encodeWithSignature(
            "transfer(address,uint256)",
            to,
            amount
        );

        // return bytes4(abi.encodePacked(
        //         returnData[0],
        //         returnData[1],
        //         returnData[2],
        //         returnData[3]
        //     ));
        return
            bytes4(
                bytes.concat(
                    returnData[0],
                    returnData[1],
                    returnData[2],
                    returnData[3]
                )
            );
    }

    // get selector with assembly
    // data: 0xa9059cbb000000000000000000000000d7acd2a9fd159e69bb102a1ca21c9a3e3a5f771b000000000000000000000000000000000000000000000000000000000000007b
    function getSelectoWithAssembly(bytes calldata dataToCall)
        public
        pure
        returns (bytes4 selector)
    {
        assembly {
            selector := calldataload(dataToCall.offset)
        }
    }

    function getSelectorWithThisKeyword() public pure returns (bytes4) {
        return this.transfer.selector;
    }

    // try encode with array

    // fallback() external {}
}

contract Caller {
    address public s_callAnythingAddress;

    constructor(address callAnything) {
        s_callAnythingAddress = callAnything;
    }

    function useCallToPureFunction() public returns (bool, bytes4) {
        (bool success, bytes memory returnData) = s_callAnythingAddress.call(
            abi.encodeWithSignature("getFunctionSelector()")
        );
        return (success, bytes4(returnData));
    }

    function useStaticCallToPureFunction() public view returns (bool, bytes4) {
        (bool success, bytes memory returnData) = s_callAnythingAddress
            .staticcall(abi.encodeWithSignature("getFunctionSelector()"));
        return (success, bytes4(returnData));
    }

    function useCallToTransfer(address to, uint256 amount)
        public
        returns (bool, bytes4)
    {
        (bool success, bytes memory returnData) = s_callAnythingAddress.call(
            abi.encodeWithSignature("transfer(address,uint256)", to, amount)
        );
        return (success, bytes4(returnData));
    }
}
