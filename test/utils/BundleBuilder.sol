// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { RWALendingPool } from "../../contracts/RWALendingPool.sol";
import { PriceSigningBase } from "./PriceSigningBase.sol";

abstract contract BundleBuilder is PriceSigningBase {
    function buildSignedBundle(
        address feed,
        uint256 roundId,
        int256 price,
        uint256 timestamp,
        uint256 signerPk
    ) internal view returns (RWALendingPool.PriceBundle memory bundle) {
        bytes memory signature = _signPrice(feed, roundId, price, timestamp, signerPk);
        bundle = RWALendingPool.PriceBundle({
            roundId: roundId,
            price: price,
            ts: timestamp,
            sig: signature
        });
    }
}
