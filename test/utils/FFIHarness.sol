// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test, console } from "forge-std/Test.sol";
import { StringLib } from "src/lib/StringLib.sol";

abstract contract FFIHarness is Test {
    using StringLib for bytes;

    /// @dev ZeroKompresses the given bytes using the Rust sidecar.
    function zeroKompress(bytes memory _in) internal returns (bytes memory _out) {
        // console.log("[kompress] in: ", _in.toHex());
        string[] memory commands = new string[](5);
        commands[0] = "./diff/target/release/diff";
        commands[1] = "--in-bytes";
        commands[2] = vm.toString(_in);
        commands[3] = "--mode";
        commands[4] = "zero-kompress";
        _out = vm.ffi(commands);
        // console.log("[kompress] out:", _out.toHex());
    }

    /// @dev ZeroDekompresses the given bytes using the Rust sidecar.
    function zeroDekompress(bytes memory _in) internal returns (bytes memory _out) {
        // console.log("[dekompress] in: ", _in.toHex());
        string[] memory commands = new string[](5);
        commands[0] = "./diff/target/release/diff";
        commands[1] = "--in-bytes";
        commands[2] = vm.toString(_in);
        commands[3] = "--mode";
        commands[4] = "zero-dekompress";
        _out = vm.ffi(commands);
        // console.log("[dekompress] out:", _out.toHex());
    }

    function zipCompress(bytes memory _in) internal returns (bytes memory _out) {
        // console.log("[compress] in: ", _in.toHex());
        string[] memory commands = new string[](5);
        commands[0] = "node";
        commands[1] = "js/src/cli.js";
        commands[2] = "compress";
        commands[3] = "-d";
        commands[4] = vm.toString(_in);
        _out = vm.ffi(commands);
        // console.log("[compress] out:", _out.toHex());
    }
}
