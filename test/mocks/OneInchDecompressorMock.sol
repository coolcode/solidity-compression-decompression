// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;

import { Token } from "./Token.sol";
import { OneInchDecompressor } from "src/OneInchDecompressor.sol";

contract OneInchDecompressorMock is Token, OneInchDecompressor {
    fallback() external { }

    function setData(uint256 offset, bytes32 data) external onlyOwner {
        _setData(offset, data);
    }

    function setDataArray(uint256 offset, bytes32[] calldata dataArray) external onlyOwner {
        _setDataArray(offset, dataArray);
    }
}
