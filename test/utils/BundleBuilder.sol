// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IPriceFeed } from "../../contracts/interfaces/IPriceFeed.sol";
import { PriceSigningBase } from "./PriceSigningBase.sol";

abstract contract BundleBuilder is PriceSigningBase {
    function buildSignedBundle(
        address feed,
        uint256 roundId,
        int256 price,
        uint256 timestamp,
        uint256 signerPk
    ) internal view returns (IPriceFeed.PriceMsg memory bundle) {
        bytes memory signature = _signPrice(feed, roundId, price, timestamp, signerPk);
        bundle = IPriceFeed.PriceMsg({
            roundId: roundId,
            price: price,
            timestamp: timestamp,
            signature: signature
        });
    }
}
