// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ZeroDekompressorLib } from "src/lib/ZeroDekompressorLib.sol";

/// @dev A mock contract that calls `ZeroDekompressorLib` and returns the result.
contract MockDekompressor {
    fallback() external {
        bytes memory d = ZeroDekompressorLib.dekompressCalldata();
        assembly {
            return(add(d, 0x20), mload(d))
        }
    }
}
