// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title PriceFeedProxy
/// @notice Stores the latest signed price; verifies oracle signatures on submit.
/// @dev Minimal stub for initial scaffold; signature verification to be implemented.
contract PriceFeedProxy {
    struct PriceData { uint256 roundId; int256 price; uint256 timestamp; }

    PriceData private _latest;
    address public feedSigner;
    uint256 public maxDelay = 1 hours;

    event Submit(uint256 roundId, int256 price, uint256 timestamp, address indexed submitter);

    constructor(address signer) {
        feedSigner = signer;
    }

    function latest() external view returns (uint256, int256, uint256) {
        return (_latest.roundId, _latest.price, _latest.timestamp);
    }

    function setMaxDelay(uint256 seconds_) external {
        // In full impl: restrict via access control
        maxDelay = seconds_;
    }

    function submit(
        uint256 roundId,
        int256 price,
        uint256 ts,
        bytes calldata /*sig*/
    ) external {
        require(ts <= block.timestamp && block.timestamp - ts <= maxDelay, "STALE");
        require(roundId > _latest.roundId, "ROUND_NOT_INCREASING");
        // TODO: verify signature ecrecover(...)
        _latest = PriceData({ roundId: roundId, price: price, timestamp: ts });
        emit Submit(roundId, price, ts, msg.sender);
    }
}
