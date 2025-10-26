// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPriceFeed {
    struct PriceMsg {
        uint256 roundId;
        int256 price;
        uint256 timestamp;
        bytes signature;
    }

    function upsertFromSig(PriceMsg calldata priceMsg) external;

    function latest() external view returns (
        int256 price,
        uint256 timestamp,
        uint80 roundId
    );
}
