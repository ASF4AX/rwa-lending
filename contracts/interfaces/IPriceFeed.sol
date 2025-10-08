// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPriceFeed {
    function latest() external view returns (
        uint256 roundId,
        int256 price,
        uint256 timestamp
    );
}

