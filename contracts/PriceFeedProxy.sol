// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { EIP712 } from "@openzeppelin/utils/cryptography/EIP712.sol";
import { SignatureChecker } from "@openzeppelin/utils/cryptography/SignatureChecker.sol";
import { EIP712Schema } from "./lib/EIP712Schema.sol";
import { IPriceFeed } from "./interfaces/IPriceFeed.sol";

/// @title PriceFeedProxy
/// @notice Stores the latest signed price; verifies oracle signatures on submit.
/// @dev EIP-712 typed-data signatures for robust domain separation.
contract PriceFeedProxy is EIP712 {
    struct PriceData { uint80 roundId; int256 price; uint256 timestamp; }

    PriceData private _latest;
    address public feedSigner;
    uint256 public maxDelay = 60 seconds;

    event PriceUpdated(uint256 roundId, int256 price, uint256 timestamp, address indexed submitter);
    event SignerUpdated(address indexed oldSigner, address indexed newSigner);

    constructor(address signer) EIP712("RWA Price Feed", "1") {
        feedSigner = signer;
    }

    function latest() external view returns (int256, uint256, uint80) {
        return (_latest.price, _latest.timestamp, _latest.roundId);
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
        bytes32 structHash = EIP712Schema.hashStruct(roundId, price, ts);
        return _hashTypedDataV4(structHash);
    }

    function upsertFromSig(IPriceFeed.PriceMsg calldata priceMsg) external {
        if (priceMsg.timestamp > block.timestamp || block.timestamp - priceMsg.timestamp > maxDelay) revert("STALE");
        if (priceMsg.roundId <= _latest.roundId) return;
        if (priceMsg.roundId > type(uint80).max) revert("ROUNDID_OOB");

        // Signature verification (EOA + ERC-1271)
        bytes32 digest = _hashTyped(priceMsg.roundId, priceMsg.price, priceMsg.timestamp);
        bool ok = SignatureChecker.isValidSignatureNow(feedSigner, digest, priceMsg.signature);
        if (!ok) revert("BAD_SIGNER");

        _latest = PriceData({ roundId: uint80(priceMsg.roundId), price: priceMsg.price, timestamp: priceMsg.timestamp });
        emit PriceUpdated(priceMsg.roundId, priceMsg.price, priceMsg.timestamp, msg.sender);
    }
}
