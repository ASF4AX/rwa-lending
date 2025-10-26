// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title EIP712Schema
/// @notice Single source of truth for EIP-712 struct typehash and struct hashing.
library EIP712Schema {
    bytes32 internal constant PRICE_TYPEHASH = keccak256(
        "PriceMessage(uint256 roundId,int256 price,uint256 timestamp)"
    );

    /// @notice Hashes the EIP-712 struct for the price message.
    function hashStruct(uint256 roundId, int256 price, uint256 timestamp) internal pure returns (bytes32) {
        return keccak256(abi.encode(PRICE_TYPEHASH, roundId, price, timestamp));
    }
}
