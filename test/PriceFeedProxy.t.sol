// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { PriceSigningBase } from "./utils/PriceSigningBase.sol";
import { PriceFeedProxyHarness } from "./utils/PriceFeedProxyHarness.sol";
import { ProxyDigestHarness } from "./utils/ProxyDigestHarness.sol";
import { IPriceFeed } from "../contracts/interfaces/IPriceFeed.sol";

contract PriceFeedProxyTest is PriceSigningBase {
    uint256 signerPk;
    address signer;
    PriceFeedProxyHarness feed;
    ProxyDigestHarness digestHarness;

    function setUp() public {
        signerPk = 0xA11CE;
        signer = vm.addr(signerPk);
        feed = new PriceFeedProxyHarness(signer);
        digestHarness = new ProxyDigestHarness();
    }

    function testEIP712Parity() public view {
        uint256 roundId = 42;
        int256 price = int256(1e18);
        uint256 timestamp = block.timestamp;
        bytes32 viaLib = digestHarness.digest(address(feed), roundId, price, timestamp);
        bytes32 viaEip712 = feed.hashTyped(roundId, price, timestamp);
        assertEq(viaLib, viaEip712, "digest mismatch");
    }

    function testUpsert_Valid() public {
        uint256 roundId = 1;
        int256 price = int256(1e8);
        uint256 timestamp = block.timestamp;
        
        bytes memory signature = _signPrice(address(feed), roundId, price, timestamp, signerPk);
        IPriceFeed.PriceMsg memory priceMsg = IPriceFeed.PriceMsg({ roundId: roundId, price: price, timestamp: timestamp, signature: signature });
        feed.upsertFromSig(priceMsg);

        (int256 latestPrice, uint256 latestTimestamp, uint80 latestRoundId) = feed.latest();
        assertEq(uint256(latestRoundId), roundId);
        assertEq(latestPrice, price);
        assertEq(latestTimestamp, timestamp);
    }

    function testUpsert_RevertStale() public {
        // ensure timestamp arithmetic is safe
        vm.warp(feed.maxDelay() + 10);
        uint256 roundId = 1;
        int256 price = int256(1e8);

        // older than maxDelay
        uint256 timestamp = block.timestamp - (feed.maxDelay() + 1);        
        bytes memory signature = _signPrice(address(feed), roundId, price, timestamp, signerPk);
        IPriceFeed.PriceMsg memory priceMsg = IPriceFeed.PriceMsg({ roundId: roundId, price: price, timestamp: timestamp, signature: signature });

        vm.expectRevert(bytes("STALE"));
        feed.upsertFromSig(priceMsg);
    }

    function testUpsert_NoOpOldRound() public {
        uint256 ts1 = block.timestamp;
        int256 price1 = int256(1e8);
        bytes memory sig1 = _signPrice(address(feed), 1, price1, ts1, signerPk);
        IPriceFeed.PriceMsg memory msg1 = IPriceFeed.PriceMsg({ roundId: 1, price: price1, timestamp: ts1, signature: sig1 });
        feed.upsertFromSig(msg1);

        // same round again but with different price to ensure no-op is observable
        int256 price2 = int256(2e8);
        uint256 ts2 = ts1;
        bytes memory sig2 = _signPrice(address(feed), 1, price2, ts2, signerPk);
        IPriceFeed.PriceMsg memory msg2 = IPriceFeed.PriceMsg({ roundId: 1, price: price2, timestamp: ts2, signature: sig2 });
        feed.upsertFromSig(msg2);

        (int256 latestPrice, uint256 latestTimestamp, uint80 latestRoundId) = feed.latest();
        assertEq(uint256(latestRoundId), 1);
        assertEq(latestPrice, price1);
        assertEq(latestTimestamp, ts1);
    }

    function testUpsert_RevertBadSigner() public {
        uint256 roundId = 1;
        int256 price = int256(1e8);
        uint256 timestamp = block.timestamp;

        uint256 attackerPk = 0xBEEF;
        bytes memory signature = _signPrice(address(feed), roundId, price, timestamp, attackerPk);
        IPriceFeed.PriceMsg memory priceMsg = IPriceFeed.PriceMsg({ roundId: roundId, price: price, timestamp: timestamp, signature: signature });
        
        vm.expectRevert(bytes("BAD_SIGNER"));
        feed.upsertFromSig(priceMsg);
    }

    function testUpsert_RevertDomainMismatch() public {
        // sign with same key but different verifying contract (different domain)
        PriceFeedProxyHarness other = new PriceFeedProxyHarness(signer);
        uint256 roundId = 1;
        int256 price = int256(1e8);
        uint256 timestamp = block.timestamp;

        bytes memory signatureOther = _signPrice(address(other), roundId, price, timestamp, signerPk);
        IPriceFeed.PriceMsg memory priceMsg = IPriceFeed.PriceMsg({ roundId: roundId, price: price, timestamp: timestamp, signature: signatureOther });
        
        vm.expectRevert(bytes("BAD_SIGNER"));
        feed.upsertFromSig(priceMsg);
    }
}
