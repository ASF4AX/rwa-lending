// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { PriceVerifier } from "../../contracts/lib/PriceVerifier.sol";

// Simple harness to expose PriceVerifier internals for tests
contract PriceVerifierHarness {
    function domain(address feed) external view returns (bytes32) {
        return PriceVerifier.domainSeparator(feed);
    }

    function digest(address feed, uint256 roundId, int256 price, uint256 ts) external view returns (bytes32) {
        return PriceVerifier.digest(feed, roundId, price, ts);
    }

    function verify(
        address feed,
        address signer,
        uint256 lastRoundId,
        uint256 maxDelay,
        uint256 roundId,
        int256 price,
        uint256 ts,
        bytes memory sig
    ) external view returns (bool) {
        PriceVerifier.verifyAndEnforce(feed, signer, lastRoundId, maxDelay, roundId, price, ts, sig);
        return true;
    }
}
