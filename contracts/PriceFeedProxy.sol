// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ECDSA } from "@openzeppelin/utils/cryptography/ECDSA.sol";
import { EIP712 } from "@openzeppelin/utils/cryptography/EIP712.sol";

/// @title PriceFeedProxy
/// @notice Stores the latest signed price; verifies oracle signatures on submit.
/// @dev EIP-712 typed-data signatures for robust domain separation.
contract PriceFeedProxy is EIP712 {
    struct PriceData { uint256 roundId; int256 price; uint256 timestamp; }

    PriceData private _latest;
    address public feedSigner;
    uint256 public maxDelay = 1 hours;

    event Submit(uint256 roundId, int256 price, uint256 timestamp, address indexed submitter);
    event SignerUpdated(address indexed oldSigner, address indexed newSigner);

    // EIP-712 typehash for the signed payload
    bytes32 private constant PRICE_TYPEHASH = keccak256(
        "PriceMessage(uint256 roundId,int256 price,uint256 timestamp)"
    );

    constructor(address signer) EIP712("RWA Price Feed", "1") {
        feedSigner = signer;
    }

    function latest() external view returns (uint256, int256, uint256) {
        return (_latest.roundId, _latest.price, _latest.timestamp);
    }

    function setMaxDelay(uint256 seconds_) external {
        // TODO: restrict via access control
        maxDelay = seconds_;
    }

    function setSigner(address newSigner) external {
        // TODO: restrict via access control
        emit SignerUpdated(feedSigner, newSigner);
        feedSigner = newSigner;
    }

    function _hashTyped(uint256 roundId, int256 price, uint256 ts) internal view returns (bytes32) {
        // Canonical form without custom assembly for safety/readability
        bytes32 structHash = keccak256(abi.encode(PRICE_TYPEHASH, roundId, price, ts));
        return _hashTypedDataV4(structHash);
    }

    function submit(
        uint256 roundId,
        int256 price,
        uint256 ts,
        bytes calldata sig
    ) external {
        require(ts <= block.timestamp && block.timestamp - ts <= maxDelay, "STALE");
        require(roundId > _latest.roundId, "ROUND_NOT_INCREASING");

        require(sig.length == 65, "BAD_SIG");
        bytes32 digest = _hashTyped(roundId, price, ts);
        address recovered = ECDSA.recover(digest, sig);
        require(recovered == feedSigner, "BAD_SIGNER");

        _latest = PriceData({ roundId: roundId, price: price, timestamp: ts });
        emit Submit(roundId, price, ts, msg.sender);
    }
}
