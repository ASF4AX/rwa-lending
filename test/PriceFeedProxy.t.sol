// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { PriceSigningBase } from "./utils/PriceSigningBase.sol";
import { PriceFeedProxyHarness } from "./utils/PriceFeedProxyHarness.sol";

contract PriceFeedProxyTest is PriceSigningBase {
    uint256 signerPk;
    address signer;
    PriceFeedProxyHarness feed;

    function setUp() public {
        signerPk = 0xA11CE;
        signer = vm.addr(signerPk);
        feed = new PriceFeedProxyHarness(signer);
    }

    function testSubmit_Valid() public {
        uint256 roundId = 1;
        int256 price = int256(1e8);
        uint256 timestamp = block.timestamp;
        bytes memory signature = _signPrice(address(feed), roundId, price, timestamp, signerPk);

        feed.submit(roundId, price, timestamp, signature);

        (uint256 latestRoundId, int256 latestPrice, uint256 latestTimestamp) = feed.latest();
        assertEq(latestRoundId, roundId);
        assertEq(latestPrice, price);
        assertEq(latestTimestamp, timestamp);
    }

    function testSubmit_RevertStale() public {
        // ensure timestamp arithmetic is safe
        vm.warp(feed.maxDelay() + 10);
        uint256 roundId = 1;
        int256 price = int256(1e8);
        // older than maxDelay
        uint256 timestamp = block.timestamp - (feed.maxDelay() + 1);
        bytes memory signature = _signPrice(address(feed), roundId, price, timestamp, signerPk);

        vm.expectRevert(bytes("STALE"));
        feed.submit(roundId, price, timestamp, signature);
    }

    function testSubmit_RevertRoundNotIncreasing() public {
        uint256 timestamp = block.timestamp;
        bytes memory signature1 = _signPrice(address(feed), 1, int256(1e8), timestamp, signerPk);
        feed.submit(1, int256(1e8), timestamp, signature1);

        // same round again
        bytes memory signature2 = _signPrice(address(feed), 1, int256(1e8), timestamp, signerPk);
        vm.expectRevert(bytes("ROUND_NOT_INCREASING"));
        feed.submit(1, int256(1e8), timestamp, signature2);
    }

    function testSubmit_RevertBadSigner() public {
        uint256 roundId = 1;
        int256 price = int256(1e8);
        uint256 timestamp = block.timestamp;
        uint256 attackerPk = 0xBEEF;
        bytes memory signature = _signPrice(address(feed), roundId, price, timestamp, attackerPk);

        vm.expectRevert(bytes("BAD_SIGNER"));
        feed.submit(roundId, price, timestamp, signature);
    }

    function testSubmit_RevertDomainMismatch() public {
        // sign with same key but different verifying contract (different domain)
        PriceFeedProxyHarness other = new PriceFeedProxyHarness(signer);
        uint256 roundId = 1;
        int256 price = int256(1e8);
        uint256 timestamp = block.timestamp;
        bytes memory signatureOther = _signPrice(address(other), roundId, price, timestamp, signerPk);
        
        vm.expectRevert(bytes("BAD_SIGNER"));
        feed.submit(roundId, price, timestamp, signatureOther);
    }
}
