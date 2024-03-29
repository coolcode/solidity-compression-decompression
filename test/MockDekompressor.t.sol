// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { console } from "forge-std/Test.sol";
import { StringLib } from "src/lib/StringLib.sol";
import { ZeroDekompressorLib } from "src/lib/ZeroDekompressorLib.sol";
import { MockDekompressor } from "src/mocks/MockDekompressor.sol";
import { FFIHarness } from "./utils/FFIHarness.sol";

contract MockDekompressorTest is FFIHarness {
    using StringLib for bytes;
    using ZeroDekompressorLib for bytes;

    MockDekompressor mockDekompressor;

    error InvalidInput();

    function setUp() public {
        // Deploy a new `MockDekompressor`
        mockDekompressor = new MockDekompressor();
    }

    /// @dev Tests that the `dekompressCalldata` function returns a zero-length payload when
    /// called with an empty payload.
    function test_dekompressCalldata_empty_succeeds() public {
        (bool success, bytes memory returndata) = address(mockDekompressor).call(hex"");
        assertTrue(success);
        assertEq(returndata, hex"");
        assertEq(returndata.length, 0);
    }

    /// @dev Test dekompression
    function test_dekompressCalldata_middle_succeeds() public {
        (bool success, bytes memory returndata) = address(mockDekompressor).call(hex"7f6b590c0006220002ff");
        assertTrue(success);
        assertEq(returndata, hex"7f6b590c000000000000220000ff");
    }

    /// @dev Test dekompression
    function test_dekompressCalldata_edgeEnd_succeeds() public {
        (bool success, bytes memory returndata) = address(mockDekompressor).call(hex"0004ff");
        assertTrue(success);
        assertEq(returndata, hex"00000000ff");
    }

    /// @dev Test dekompression
    function test_dekompressCalldata_edgeStart_succeeds() public {
        (bool success, bytes memory returndata) = address(mockDekompressor).call(hex"ff0004");
        assertTrue(success);
        assertEq(returndata, hex"ff00000000");
    }

    /// @dev Test dekompression (zero rollover once)
    function test_dekompressCalldata_zeroRollover_succeeds() public {
        (bool success, bytes memory returndata) = address(mockDekompressor).call(hex"00ff0005");
        assertTrue(success);
        assertEq(
            returndata,
            hex"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        );
    }

    /// @dev Test dekompression (zero rollover multiple)
    function test_dekompressCalldata_zeroRolloverMultiple_succeeds() public {
        (bool success, bytes memory returndata) = address(mockDekompressor).call(hex"00ff00ff0005");
        assertTrue(success);
        assertEq(
            returndata,
            hex"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        );
    }

    /// @dev Tests that the `dekompressCalldata` function reverts if the input is invalid
    function test_invalidInput_reverts() public {
        (bool success, bytes memory returndata) = address(mockDekompressor).call(hex"ff0000");
        console.log("invalid input -> returndata: %s", returndata.toHex());
        assertFalse(success);

        bytes memory expectedReturndata = abi.encode(InvalidInput.selector);
        assembly ("memory-safe") {
            // Set the length of the expected returndata to 4.
            mstore(expectedReturndata, 0x04)
        }

        assertEq(returndata, expectedReturndata);
    }

    /// @dev Differential test for dekompression against the Rust implementation
    function test_diff_dekompress(bytes memory _toCompress) public {
        bytes memory compressed = zeroKompress(_toCompress);

        (bool success, bytes memory returndata) = address(mockDekompressor).call(compressed);
        assertTrue(success);
        assertEq(returndata, zeroDekompress(compressed), "diff");
    }

    function test_approve_dekompress() public {
        bytes memory _toCompress =
            hex"000000000000000000000000000000000000000000000000000000000000000b0000000000000000000000000000000000000000000000000de0b6b3a7640000";
        bytes memory compressed = zeroKompress(_toCompress);
        assertEq(compressed, hex"001f0b00180de0b6b3a7640002", "compressed");

        (bool success, bytes memory returndata) = address(mockDekompressor).call(compressed);
        assertTrue(success);
        assertEq(returndata, zeroDekompress(compressed), "diff");
        bytes memory decompressed = compressed.dekompress();
        assertEq(returndata, decompressed, "lib");
    }
}
