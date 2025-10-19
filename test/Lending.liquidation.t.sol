// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { BundleBuilder } from "./utils/BundleBuilder.sol";
import { PriceFeedProxyHarness } from "./utils/PriceFeedProxyHarness.sol";
import { RWALendingPool } from "../contracts/RWALendingPool.sol";
import { IPriceFeed } from "../contracts/interfaces/IPriceFeed.sol";

contract LendingLiquidationTest is BundleBuilder {
    RWALendingPool pool;
    PriceFeedProxyHarness feed;
    uint256 signerPk;
    address signer;

    function setUp() public {
        signerPk = 0xA11CE;
        signer = vm.addr(signerPk);
        feed = new PriceFeedProxyHarness(signer);
        pool = new RWALendingPool(IPriceFeed(address(feed)));
        pool.depositCollateral(1000e18);

        uint256 roundId1 = 1;
        int256 price1 = int256(1e18);
        uint256 timestamp1 = block.timestamp;
        RWALendingPool.PriceBundle memory bundle1 = buildSignedBundle(
            address(feed), roundId1, price1, timestamp1, signerPk
        );
        pool.borrow(650e18, bundle1);
    }

    function testCanLiquidateWhenHFBelow1() public {
        // lower price -> HF drops; use next round
        uint256 roundId2 = 2;
        int256 price2 = int256(7e17);
        uint256 timestamp2 = block.timestamp;
        RWALendingPool.PriceBundle memory bundle2 = buildSignedBundle(
            address(feed), roundId2, price2, timestamp2, signerPk
        );
        pool.liquidate(address(this), 100e18, bundle2);
        assertLt(pool.debt(address(this)), 650e18);
    }

    function testCannotLiquidateWhenHFAtOrAbove1() public {
        // With collateral=1000, debt=650 at price=1, HF = (1000 * p * 0.75) / 650
        // Solve HF=1 -> p = 650/750 = 0.866666...e18
        // Use ceiling division to counteract integer rounding so HF >= 1 holds on-chain.
        uint256 roundId2 = 2;
        uint256 priceBoundary = (uint256(650e18) + 750 - 1) / uint256(750); // ceil(650e18/750)
        int256 priceAtBoundary = int256(priceBoundary);
        uint256 timestamp2 = block.timestamp;
        RWALendingPool.PriceBundle memory bundle2 = buildSignedBundle(
            address(feed), roundId2, priceAtBoundary, timestamp2, signerPk
        );
        vm.expectRevert(bytes("HF_GTE_1"));
        pool.liquidate(address(this), 1e18, bundle2);
    }
}
