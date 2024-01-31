// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

abstract contract DecompressorDelegate {
    /**
     * @dev Decompresses the compressed data (N bytes) passed to the function using the _delegatecall function.
     */
    function decompress() external payable {
        _delegatecall(decompressed());
    }

    /**
     * @dev Calculates and returns the decompressed data from the compressed calldata.
     * @return raw The decompressed raw data.
     */
    function decompressed() public view returns (bytes memory raw) {
        return _decompressed(msg.data[4:]);
    }

    /**
     * @dev Calculates and returns the decompressed raw data from the compressed data passed as an argument.
     * @param cd The compressed data to be decompressed.
     * @return raw The decompressed raw data.
     */
    function _decompressed(bytes calldata cd) internal view virtual returns (bytes memory raw) { }

    /**
     * @dev Executes a delegate call to the raw data calculated by the _decompressed function.
     * @param raw The raw data to execute the delegate call with.
     */
    function _delegatecall(bytes memory raw) internal {
        assembly ("memory-safe") {
            // solhint-disable-line no-inline-assembly
            let success := delegatecall(gas(), address(), add(raw, 0x20), mload(raw), 0, 0)
            returndatacopy(0, 0, returndatasize())
            if success { return(0, returndatasize()) }
            revert(0, returndatasize())
        }
    }
}
