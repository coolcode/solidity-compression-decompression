// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Token } from "./Token.sol";
import { ZeroDekompressorLib } from "src/lib/ZeroDekompressorLib.sol";
import { DecompressorDelegate } from "src/DecompressorDelegate.sol";

contract MockDekompressorToken is DecompressorDelegate, Token {
    // 0x97a65614
    bytes4 constant DECOMPRESS_SELECTOR = bytes4(keccak256("decompress()"));

    fallback() external {
        bytes4 functionSelector;
        assembly {
            // Read the first 32 bytes of msg.data
            let data := mload(0x40) 
            // Set functionSelector to the first four bytes
            functionSelector := mload(add(data, 0x20))
        }
        
        // Check if the extracted function selector matches the expected selector
        if (functionSelector == DECOMPRESS_SELECTOR) {
            return;
        }

        bytes memory d = ZeroDekompressorLib.dekompressCalldata();
        assembly {
            return(add(d, 0x20), mload(d))
        }
    }

    /**
     * @dev Calculates and returns the decompressed raw data from the compressed data passed as an argument.
     * @param cd The compressed data to be decompressed.
     * @return raw The decompressed raw data.
     */
    function _decompressed(bytes calldata cd) internal view override returns (bytes memory raw) {
        return ZeroDekompressorLib.dekompressCalldata(cd);
    }
}
