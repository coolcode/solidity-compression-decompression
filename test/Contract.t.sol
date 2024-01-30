// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test, console } from "forge-std/Test.sol";
import { StringLib } from "src/lib/StringLib.sol";
import { RLPLib } from "src/lib/RLPLib.sol";
import { InflateLib } from "src/lib/InflateLib.sol";

contract TestContract is Test {
    using StringLib for bytes;
    using RLPLib for bytes;
    using InflateLib for bytes;

    string longHex =
        "0x8f2b7a67000000000000000000000000a19a81a38bf2238a695629fa7b4a909a2390ddb40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000052fea3caafaaf3f95ec536b30714bff78dbac5b000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000013247aacf600000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000d500b1d8e8ef31e21c99d1db9a6444d3adf1270000000000000000000000000c17b109e146934d36c33e55fade9cbda791b03660000000000000000000000000000000000000000000000000000000000000002000000000000000000000000c17b109e146934d36c33e55fade9cbda791b03660000000000000000000000000d500b1d8e8ef31e21c99d1db9a6444d3adf1270";
    bytes longBytes =
        hex"8f2b7a67000000000000000000000000a19a81a38bf2238a695629fa7b4a909a2390ddb40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000052fea3caafaaf3f95ec536b30714bff78dbac5b000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000013247aacf600000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000d500b1d8e8ef31e21c99d1db9a6444d3adf1270000000000000000000000000c17b109e146934d36c33e55fade9cbda791b03660000000000000000000000000000000000000000000000000000000000000002000000000000000000000000c17b109e146934d36c33e55fade9cbda791b03660000000000000000000000000d500b1d8e8ef31e21c99d1db9a6444d3adf1270";

    function setUp() public { }

    function testHexEncode() public {
        string memory s = longBytes.toHex();
        // console.log(s);
        assertEq(s, longHex, "hex comparision");
    }

    function testAbiEncode() public {
        bytes memory abiEncoded = abi.encode(longBytes);
        bytes memory abiEncodePacked = abi.encodePacked(longBytes);
        bytes memory rlpEncoded = longBytes.rlpEncode();
        bytes memory puffEncoded = longBytes.puffEncode(longBytes.length);
        logBytes(abiEncoded);
        logBytes(abiEncodePacked);
        logBytes(rlpEncoded);
        logBytes(puffEncoded);
    }

    function testFuzz(bytes calldata data) public {
        vm.assume(data.length <= 256);
        uint256 len = data.length;
        assertEq(data.length, len, "data length");
    }

    function logBytes(bytes memory data) private view {
        console.log("bytes length: %d, content: %s", data.length, data.toHex());
    }
}
