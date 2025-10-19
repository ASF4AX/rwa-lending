// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { BundleBuilder } from "./utils/BundleBuilder.sol";
import { PriceFeedProxyHarness } from "./utils/PriceFeedProxyHarness.sol";
import { RWALendingPool } from "../contracts/RWALendingPool.sol";
import { IPriceFeed } from "../contracts/interfaces/IPriceFeed.sol";

contract LendingDepositBorrowTest is BundleBuilder {
    RWALendingPool pool;
    PriceFeedProxyHarness feed;
    uint256 signerPk;
    address signer;

    function setUp() public {
        signerPk = 0xA11CE;
        signer = vm.addr(signerPk);
        feed = new PriceFeedProxyHarness(signer);
        pool = new RWALendingPool(IPriceFeed(address(feed)));
        
        // Provide ample collateral for borrow success paths
        pool.depositCollateral(1_000_000e18);
    }

    function testBorrowWithinLTV() public {
        uint256 roundId = 1;
        int256 price = int256(1e18);
        uint256 timestamp = block.timestamp;
        RWALendingPool.PriceBundle memory bundle = buildSignedBundle(
            address(feed), roundId, price, timestamp, signerPk
        );
        pool.borrow(650e18, bundle);
        // lastRoundId should update
        assertEq(pool.lastRoundId(), roundId);
        assertEq(pool.debt(address(this)), 650e18);
    }

    function testBorrow_RevertExceedsLTV() public {
        uint256 roundId = 1;
        int256 price = int256(1e18);
        uint256 timestamp = block.timestamp;
        RWALendingPool.PriceBundle memory bundle = buildSignedBundle(
            address(feed), roundId, price, timestamp, signerPk
        );
        // Max debt = 1,000,000 * 65% = 650,000e18; try above that
        vm.expectRevert(bytes("EXCEEDS_LTV"));
        pool.borrow(650_001e18, bundle);
    }

    function testBorrowAgain_RevertExceedsLTV() public {
        // First borrow a large but allowed amount
        uint256 roundId1 = 100;
        int256 price = int256(1e18);
        uint256 ts = block.timestamp;
        RWALendingPool.PriceBundle memory b1 = buildSignedBundle(address(feed), roundId1, price, ts, signerPk);
        pool.borrow(600_000e18, b1); // leaves 50_000e18 headroom under 650_000e18

        // Second borrow tries to exceed combined LTV by 1e18
        RWALendingPool.PriceBundle memory b2 = buildSignedBundle(address(feed), roundId1 + 1, price, ts, signerPk);
        vm.expectRevert(bytes("EXCEEDS_LTV"));
        pool.borrow(50_001e18, b2); // total would be 650_001e18 > 650_000e18
    }

    function testBorrowAgainWithinLTV() public {
        // First borrow
        uint256 roundId1 = 200;
        int256 price = int256(1e18);
        uint256 ts = block.timestamp;
        RWALendingPool.PriceBundle memory b1 = buildSignedBundle(address(feed), roundId1, price, ts, signerPk);
        pool.borrow(600_000e18, b1);

        // Second borrow that stays within limit
        RWALendingPool.PriceBundle memory b2 = buildSignedBundle(address(feed), roundId1 + 1, price, ts, signerPk);
        pool.borrow(50_000e18, b2); // total == 650_000e18 == max

        assertEq(pool.debt(address(this)), 650_000e18);
        assertEq(pool.lastRoundId(), roundId1 + 1);
    }

    function testRoundMonotonicityAcrossActions() public {
        // First, borrow with round 10
        uint256 roundId = 10;
        int256 price = int256(1e18);
        uint256 timestamp = block.timestamp;
        RWALendingPool.PriceBundle memory bundleBorrow = buildSignedBundle(
            address(feed), roundId, price, timestamp, signerPk
        );
        pool.borrow(1e18, bundleBorrow);

        // Attempt withdraw with the same round -> should revert (ROUND_NOT_INCREASING)
        // Build the bundle first to ensure the next external call after expectRevert is withdraw
        RWALendingPool.PriceBundle memory bundleSameRound = buildSignedBundle(
            address(feed), roundId, price, timestamp, signerPk
        );
        vm.expectRevert(bytes("ROUND_NOT_INCREASING"));
        pool.withdraw(1e18, bundleSameRound);

        // Next round succeeds
        RWALendingPool.PriceBundle memory bundleNext = buildSignedBundle(
            address(feed), roundId + 1, price, timestamp, signerPk
        );
        pool.withdraw(1e18, bundleNext);
    }
}
