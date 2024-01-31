// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Token } from "./Token.sol";
import { ZeroDekompressorLib } from "src/lib/ZeroDekompressorLib.sol";
import { DecompressorDelegate } from "src/DecompressorDelegate.sol";

contract MockZxToken is DecompressorDelegate, Token {
    /**
     * @dev Calculates and returns the decompressed raw data from the compressed data passed as an argument.
     * @param cd The compressed data to be decompressed.
     * @return raw The decompressed raw data.
     */
    function _decompressed(bytes calldata cd) internal view override returns (bytes memory raw) {
        return ZeroDekompressorLib.dekompressCalldata(cd);
    }
}
