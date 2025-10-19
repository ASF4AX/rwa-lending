// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ECDSA } from "@openzeppelin/utils/cryptography/ECDSA.sol";

/// @title PriceVerifier
/// @notice Verifies EIP-712 typed price signatures produced for a specific feed contract.
/// @dev Reconstructs the domain separator using the feed contract address as verifyingContract
///      so other contracts (e.g., LendingPool) can verify off-chain oracle signatures without inheriting EIP712.
library PriceVerifier {
    // EIP-712 type strings/constants must match the signer and on-chain verifier (PriceFeedProxy)
    string internal constant NAME = "RWA Price Feed";
    string internal constant VERSION = "1";

    bytes32 internal constant EIP712_DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );
    bytes32 internal constant PRICE_TYPEHASH = keccak256(
        "PriceMessage(uint256 roundId,int256 price,uint256 timestamp)"
    );

    /// @notice Computes the domain separator for the given feed address on the current chainId.
    function domainSeparator(address feed) internal view returns (bytes32) {
        return keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256(bytes(NAME)),
                keccak256(bytes(VERSION)),
                block.chainid,
                feed
            )
        );
    }

    /// @notice Computes the EIP-712 digest for a price message under the feed's domain.
    function digest(address feed, uint256 roundId, int256 price, uint256 ts) internal view returns (bytes32) {
        bytes32 structHash = keccak256(abi.encode(PRICE_TYPEHASH, roundId, price, ts));
        bytes32 ds = domainSeparator(feed);
        return keccak256(abi.encodePacked("\x19\x01", ds, structHash));
    }

    /// @notice Verifies signature and temporal/round constraints; reverts on failure.
    /// @param feed The feed contract address the signature domain binds to.
    /// @param signer Expected signer address (feed signer).
    /// @param lastRoundId Last accepted round id to enforce monotonic increase.
    /// @param maxDelay Max allowed staleness in seconds.
    function verifyAndEnforce(
        address feed,
        address signer,
        uint256 lastRoundId,
        uint256 maxDelay,
        uint256 roundId,
        int256 price,
        uint256 ts,
        bytes memory sig
    ) internal view {
        if (ts > block.timestamp || block.timestamp - ts > maxDelay) revert("STALE");
        if (roundId <= lastRoundId) revert("ROUND_NOT_INCREASING");
        if (sig.length != 65) revert("BAD_SIG");

        bytes32 d = digest(feed, roundId, price, ts);
        address recovered = ECDSA.recover(d, sig);
        if (recovered != signer) revert("BAD_SIGNER");
    }
}
