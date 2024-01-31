// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { console } from "forge-std/Test.sol";
import { StringLib } from "src/lib/StringLib.sol";
import { MockDekompressorToken } from "src/mocks/MockDekompressorToken.sol";
import { FFIHarness } from "./utils/FFIHarness.sol";

contract DekompressorTokenTest is FFIHarness {
    using StringLib for bytes;

    MockDekompressorToken decompressor;
    address alice = address(0xa);
    address bob = address(0xb);

    function setUp() public {
        decompressor = new MockDekompressorToken();
        vm.deal(address(this), type(uint128).max);
        vm.deal(alice, 1 ether);
        decompressor.mint(alice, 1000e18);
    }

    function test_transfer_succeeds() public {
        bytes memory payload = abi.encodeWithSelector(decompressor.transfer.selector, bob, 1e18);
        bytes memory compressed = zeroKompress(payload);
        bytes memory callData = abi.encodePacked(decompressor.decompress.selector, compressed);
        // kompress: 0x97a65614a9059cbb001f0b00180de0b6b3a7640002
        // 1inch:    0x97a6561443a9059cbb600b0016450de0b6b3a76401
        console.log("calldata:", callData.toHex());
        console.log(
            unicode"origin: %d, compressed: %d, ⬇ %d%%",
            payload.length,
            callData.length,
            (payload.length - callData.length) * 100 / payload.length
        );
        vm.prank(alice);
        (bool success,) = address(decompressor).call(callData);
        assertTrue(success);
        uint256 balanceOfBob = decompressor.balanceOf(bob);
        assertEq(balanceOfBob, 1e18, "bob's balance");
    }
}
