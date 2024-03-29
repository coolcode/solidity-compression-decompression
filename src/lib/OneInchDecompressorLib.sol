// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/**
 * @title OneInchDecompressorLib
 * @dev A contract that implements a decompression algorithm to be used in conjunction with compressed data.
 * @notice This extension could result in a much higher gas consumption than expected and could potentially lead to significant memory expansion costs. Be sure to properly estimate these aspects to avoid unforeseen expenses.
 */
library OneInchDecompressorLib {
    /**
     * @dev Calculates and returns the decompressed raw data from the compressed data passed as an argument.
     * @param cd The compressed data to be decompressed.
     * @return raw The decompressed raw data.
     */
    function decompress(bytes calldata cd) external view returns (bytes memory raw) {
        assembly ("memory-safe") {
            // solhint-disable-line no-inline-assembly
            raw := mload(0x40)
            let outptr := add(raw, 0x20)
            let end := add(cd.offset, cd.length)
            for { let inptr := cd.offset } lt(inptr, end) { } {
                // solhint-disable-line no-empty-blocks
                let data := calldataload(inptr)

                let key

                // 00XXXXXX - insert X+1 zero bytes
                // 01PXXXXX - copy X+1 bytes calldata (P means padding to 32 bytes or not)
                // 10BBXXXX XXXXXXXX - use 12 bits as key for [32,20,4,31][B] bytes from storage X
                // 11BBXXXX XXXXXXXX XXXXXXXX - use 20 bits as [32,20,4,31][B] bytes from storage X
                switch shr(254, data)
                case 0 {
                    let size := add(byte(0, data), 1)
                    calldatacopy(outptr, calldatasize(), size)
                    inptr := add(inptr, 1)
                    outptr := add(outptr, size)
                    continue
                }
                case 1 {
                    let size := add(and(0x1F, byte(0, data)), 1)
                    if and(data, 0x2000000000000000000000000000000000000000000000000000000000000000) {
                        mstore(outptr, 0)
                        outptr := add(outptr, sub(32, size))
                    }
                    calldatacopy(outptr, add(inptr, 1), size)
                    inptr := add(inptr, add(1, size))
                    outptr := add(outptr, size)
                    continue
                }
                case 2 {
                    key := shr(244, shl(4, data))
                    inptr := add(inptr, 2)
                    // fallthrough
                }
                case 3 {
                    key := shr(236, shl(4, data))
                    inptr := add(inptr, 3)
                    // fallthrough
                }

                // TODO: check sload argument
                let value
                switch key
                case 0 { value := caller() }
                case 1 { value := address() }
                default { value := 0 }
                // default { value := sload(add(_dict.slot, key)) }

                switch shr(254, shl(2, data))
                case 0 {
                    mstore(outptr, value)
                    outptr := add(outptr, 32)
                }
                case 1 {
                    mstore(outptr, shl(96, value))
                    outptr := add(outptr, 20)
                }
                case 2 {
                    mstore(outptr, shl(224, value))
                    outptr := add(outptr, 4)
                }
                default {
                    mstore(outptr, shl(8, value))
                    outptr := add(outptr, 31)
                }
            }
            mstore(raw, sub(sub(outptr, raw), 0x20))
            mstore(0x40, outptr)
        }
    }
}
