// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { console } from "forge-std/Test.sol";
import { StringLib } from "src/lib/StringLib.sol";
import { ZeroDekompressorLib } from "src/lib/ZeroDekompressorLib.sol";
import { OneInchDecompressorLib } from "src/lib/OneInchDecompressorLib.sol";
import { Token } from "src/mocks/Token.sol";
import { FFIHarness } from "./utils/FFIHarness.sol";

contract CompressorTest is FFIHarness {
    using StringLib for bytes;
    using ZeroDekompressorLib for bytes;
    using OneInchDecompressorLib for bytes;

    address alice = address(0xa);
    address bob = address(0xb);
    mapping(bytes32 => string) titles;
    bytes[] calldatas;

    function setUp() public {
        pushCalldata("transfer", abi.encodeWithSelector(bytes4(keccak256("transfer(address,uint256)")), bob, 1e18));
        pushCalldata(
            "approve", abi.encodeWithSelector(bytes4(keccak256("approve(address,uint256)")), bob, type(uint256).max)
        );
        pushCalldata(
            "transferFrom",
            abi.encodeWithSelector(bytes4(keccak256("transferFrom(address,address,uint256)")), alice, bob, 1e18)
        );
        pushCalldata(
            "long bytes",
            hex"8f2b7a67000000000000000000000000a19a81a38bf2238a695629fa7b4a909a2390ddb40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000052fea3caafaaf3f95ec536b30714bff78dbac5b000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000013247aacf600000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000d500b1d8e8ef31e21c99d1db9a6444d3adf1270000000000000000000000000c17b109e146934d36c33e55fade9cbda791b03660000000000000000000000000000000000000000000000000000000000000002000000000000000000000000c17b109e146934d36c33e55fade9cbda791b03660000000000000000000000000d500b1d8e8ef31e21c99d1db9a6444d3adf1270"
        );
    }

    function pushCalldata(string memory title, bytes memory cd) private {
        calldatas.push(cd);
        titles[keccak256(cd)] = title;
    }

    function test_compress_decompress() public {
        uint256 i = 0;
        while (i < calldatas.length) {
            bytes memory payload = calldatas[i];
            console.log("#%d. %s: %s", i + 1, titles[keccak256(payload)], payload.toHex());
            (, uint8 rateO) = test_ox(payload);
            (, uint8 rateX) = test_zx(payload);
            i++;
        }
    }

    function test_ox(bytes memory payload) private returns (bytes memory compressed, uint8 rate) {
        compressed = zipCompress(payload);
        rate = uint8((payload.length - compressed.length) * 100 / payload.length);
        console.log(unicode"[o] origin: %d, compressed: %d, ⬇ %d%%", payload.length, compressed.length, rate);
        bytes memory decompressed = compressed.decompress();
        assertEq(decompressed, payload, "[o] decompressed");
    }

    function test_zx(bytes memory payload) private returns (bytes memory compressed, uint8 rate) {
        compressed = zeroKompress(payload);
        rate = uint8((payload.length - compressed.length) * 100 / payload.length);
        console.log(unicode"[z] origin: %d, compressed: %d, ⬇ %d%%", payload.length, compressed.length, rate);
        bytes memory decompressed = compressed.dekompress();
        assertEq(decompressed, payload, "[z] decompressed");
    }
}
