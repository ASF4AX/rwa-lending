// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";
import { PriceFeedProxy } from "contracts/PriceFeedProxy.sol";

contract PriceFeedProxyHarness is PriceFeedProxy {
    constructor(address signer) PriceFeedProxy(signer) {}
    function hashTyped(uint256 roundId, int256 price, uint256 ts) external view returns (bytes32) {
        // expose internal typed hash for testing
        return _hashTyped(roundId, price, ts);
    }
}

contract PriceFeedProxyTest is Test {
    uint256 signerPk;
    address signer;
    PriceFeedProxyHarness feed;

    function setUp() public {
        signerPk = 0xA11CE;
        signer = vm.addr(signerPk);
        feed = new PriceFeedProxyHarness(signer);
    }

    function _sign(PriceFeedProxyHarness target, uint256 roundId, int256 price, uint256 ts, uint256 pk)
        internal view returns (bytes memory sig)
    {
        bytes32 digest = target.hashTyped(roundId, price, ts);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, digest);
        sig = abi.encodePacked(r, s, v);
    }

    function testSubmit_Valid() public {
        uint256 roundId = 1;
        int256 price = int256(1e8);
        uint256 ts = block.timestamp;
        bytes memory sig = _sign(feed, roundId, price, ts, signerPk);

        feed.submit(roundId, price, ts, sig);

        (uint256 r, int256 p, uint256 t) = feed.latest();
        assertEq(r, roundId);
        assertEq(p, price);
        assertEq(t, ts);
    }

    function testSubmit_RevertStale() public {
        // ensure timestamp arithmetic is safe
        vm.warp(feed.maxDelay() + 10);
        uint256 roundId = 1;
        int256 price = int256(1e8);
        // older than maxDelay
        uint256 ts = block.timestamp - (feed.maxDelay() + 1);
        bytes memory sig = _sign(feed, roundId, price, ts, signerPk);

        vm.expectRevert(bytes("STALE"));
        feed.submit(roundId, price, ts, sig);
    }

    function testSubmit_RevertRoundNotIncreasing() public {
        uint256 ts = block.timestamp;
        bytes memory sig1 = _sign(feed, 1, int256(1e8), ts, signerPk);
        feed.submit(1, int256(1e8), ts, sig1);

        // same round again
        bytes memory sig2 = _sign(feed, 1, int256(1e8), ts, signerPk);
        vm.expectRevert(bytes("ROUND_NOT_INCREASING"));
        feed.submit(1, int256(1e8), ts, sig2);
    }

    function testSubmit_RevertBadSigner() public {
        uint256 roundId = 1;
        int256 price = int256(1e8);
        uint256 ts = block.timestamp;
        uint256 attackerPk = 0xBEEF;
        bytes memory sig = _sign(feed, roundId, price, ts, attackerPk);

        vm.expectRevert(bytes("BAD_SIGNER"));
        feed.submit(roundId, price, ts, sig);
    }

    function testSubmit_RevertDomainMismatch() public {
        // sign with same key but different verifying contract (different domain)
        PriceFeedProxyHarness other = new PriceFeedProxyHarness(signer);
        uint256 roundId = 1;
        int256 price = int256(1e8);
        uint256 ts = block.timestamp;
        bytes memory sigOther = _sign(other, roundId, price, ts, signerPk);

        vm.expectRevert(bytes("BAD_SIGNER"));
        feed.submit(roundId, price, ts, sigOther);
    }
}
