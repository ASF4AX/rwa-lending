// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";
import { PriceVerifierHarness } from "./utils/PriceVerifierHarness.sol";
import { PriceFeedProxyHarness } from "./utils/PriceFeedProxyHarness.sol";
import { BundleBuilder } from "./utils/BundleBuilder.sol";
import { RWALendingPool } from "../contracts/RWALendingPool.sol";

contract PriceVerifierTest is Test, BundleBuilder {
    PriceVerifierHarness verifier;
    PriceFeedProxyHarness feed;
    uint256 signerPk;
    address signer;

    function setUp() public {
        verifier = new PriceVerifierHarness();
        signerPk = 0xA11CE;
        signer = vm.addr(signerPk);
        feed = new PriceFeedProxyHarness(signer);
    }

    function testDigestMatchesEIP712() public view {
        uint256 roundId = 42;
        int256 price = int256(123e16);
        uint256 timestamp = block.timestamp;

        bytes32 viaLib = verifier.digest(address(feed), roundId, price, timestamp);
        bytes32 viaEip712 = feed.hashTyped(roundId, price, timestamp);
        assertEq(viaLib, viaEip712, "digest mismatch");
    }

    function testVerify_Ok() public view {
        uint256 roundId = 1;
        int256 price = int256(1e18);
        uint256 timestamp = block.timestamp;
        RWALendingPool.PriceBundle memory b = buildSignedBundle(address(feed), roundId, price, timestamp, signerPk);
        bool ok = verifier.verify(address(feed), feed.feedSigner(), 0, feed.maxDelay(), b.roundId, b.price, b.ts, b.sig);
        assertTrue(ok);
    }

    function testVerify_RevertStale() public {
        uint256 md = feed.maxDelay();
        vm.warp(md + 5);
        RWALendingPool.PriceBundle memory b = buildSignedBundle(address(feed), 2, int256(1e18), block.timestamp - (md + 1), signerPk);
        address expectedSigner = feed.feedSigner();
        vm.expectRevert("STALE");
        verifier.verify(address(feed), expectedSigner, 0, md, b.roundId, b.price, b.ts, b.sig);
    }

    function testVerify_RevertRoundNotIncreasing() public {
        uint256 ts = block.timestamp;
        RWALendingPool.PriceBundle memory b = buildSignedBundle(address(feed), 5, int256(1e18), ts, signerPk);
        address expectedSigner = feed.feedSigner();
        uint256 md = feed.maxDelay();
        vm.expectRevert("ROUND_NOT_INCREASING");
        verifier.verify(address(feed), expectedSigner, 5, md, b.roundId, b.price, b.ts, b.sig);
    }

    function testVerify_RevertBadSigLength() public {
        uint256 ts = block.timestamp;
        bytes memory badSig = hex"01"; // not 65 bytes
        address expectedSigner = feed.feedSigner();
        uint256 md = feed.maxDelay();
        vm.expectRevert("BAD_SIG");
        verifier.verify(address(feed), expectedSigner, 0, md, 1, int256(1e18), ts, badSig);
    }

    function testVerify_RevertBadSigner() public {
        uint256 ts = block.timestamp;
        uint256 attackerPk = 0xBEEF;
        RWALendingPool.PriceBundle memory b = buildSignedBundle(address(feed), 7, int256(1e18), ts, attackerPk);
        address expectedSigner = feed.feedSigner();
        uint256 md = feed.maxDelay();
        vm.expectRevert("BAD_SIGNER");
        verifier.verify(address(feed), expectedSigner, 0, md, b.roundId, b.price, b.ts, b.sig);
    }
}
