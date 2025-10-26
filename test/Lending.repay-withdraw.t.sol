// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { BundleBuilder } from "./utils/BundleBuilder.sol";
import { PriceFeedProxyHarness } from "./utils/PriceFeedProxyHarness.sol";
import { RWALendingPool } from "../contracts/RWALendingPool.sol";
import { IPriceFeed } from "../contracts/interfaces/IPriceFeed.sol";

contract LendingRepayWithdrawTest is BundleBuilder {
    RWALendingPool pool;
    PriceFeedProxyHarness feed;
    uint256 signerPk;
    address signer;

    function setUp() public {
        signerPk = 0xA11CE;
        signer = vm.addr(signerPk);
        feed = new PriceFeedProxyHarness(signer);
        pool = new RWALendingPool(IPriceFeed(address(feed)));

        // deposit and borrow to establish state
        pool.depositCollateral(1000e18);
        uint256 roundId = 1;
        int256 price = int256(1e18);
        uint256 timestamp = block.timestamp;
        IPriceFeed.PriceMsg memory bundle = buildSignedBundle(
            address(feed), roundId, price, timestamp, signerPk
        );
        pool.borrow(650e18, bundle);
    }

    function testRepay_PartialAndFull() public {
        // partial repay
        pool.repay(150e18);
        assertEq(pool.debt(address(this)), 500e18);
        // overpay caps to full
        pool.repay(1_000_000e18);
        assertEq(pool.debt(address(this)), 0);
    }

    function testWithdraw_SucceedsWithinHF() public {
        // Price remains $1, withdraw small amount, stays healthy
        uint256 roundId2 = 2;
        int256 price2 = int256(1e18);
        uint256 timestamp2 = block.timestamp;
        IPriceFeed.PriceMsg memory bundle2 = buildSignedBundle(
            address(feed), roundId2, price2, timestamp2, signerPk
        );
        pool.withdraw(10e18, bundle2);
    }

    function testWithdraw_RevertHFBelow1() public {
        // Price drops; attempt to withdraw should fail due to HF < 1
        uint256 roundId2 = 2;
        int256 price2 = int256(7e17);
        uint256 timestamp2 = block.timestamp;
        IPriceFeed.PriceMsg memory bundle2 = buildSignedBundle(
            address(feed), roundId2, price2, timestamp2, signerPk
        );
        vm.expectRevert(bytes("HF_LT_1"));
        pool.withdraw(1e18, bundle2);
    }

    function testWithdraw_RevertInsufficientCollateral() public {
        uint256 roundId2 = 2; int256 price2 = int256(1e18); uint256 timestamp2 = block.timestamp;
        IPriceFeed.PriceMsg memory bundle2 = buildSignedBundle(
            address(feed), roundId2, price2, timestamp2, signerPk
        );
        vm.expectRevert(bytes("INSUFFICIENT_COLLATERAL"));
        pool.withdraw(2_000e18, bundle2);
    }

    function testWithdraw_RevertBadPrice() public {
        uint256 roundId2 = 2; int256 negativePrice = -1; uint256 timestamp2 = block.timestamp;
        IPriceFeed.PriceMsg memory bundle2 = buildSignedBundle(
            address(feed), roundId2, negativePrice, timestamp2, signerPk
        );
        vm.expectRevert(bytes("BAD_PRICE"));
        pool.withdraw(1e18, bundle2);
    }

    function testWithdraw_AllowsAtHFEquals1() public {
        // Setup: C=1000e18, D=650e18, p=1e18, LT=0.75e18
        // Require: (C' * p / 1e18) * LT / D >= 1e18  ->  C' * 0.75e18 >= 650e18
        // Minimum C' that satisfies: ceil(650e18 / 0.75e18) = 866_666_666_666_666_666_667
        uint256 keepCollateral = 866_666_666_666_666_666_667;
        uint256 withdrawAmount = 1_000_000_000_000_000_000_000 - keepCollateral; // 133_333_333_333_333_333_333

        uint256 roundId2 = 2;
        int256 price2 = int256(1e18);
        uint256 timestamp2 = block.timestamp;
        IPriceFeed.PriceMsg memory bundle2 = buildSignedBundle(
            address(feed), roundId2, price2, timestamp2, signerPk
        );
        // Exactly-at-boundary should pass (HF == 1)
        pool.withdraw(withdrawAmount, bundle2);
    }

    function testWithdraw_RevertJustBelowHF1() public {
        // Using one wei more withdrawal than boundary makes HF < 1
        uint256 keepCollateral = 866_666_666_666_666_666_666; // one wei less than boundary
        uint256 withdrawAmount = 1_000_000_000_000_000_000_000 - keepCollateral; // 133_333_333_333_333_333_334

        uint256 roundId2 = 2;
        int256 price2 = int256(1e18);
        uint256 timestamp2 = block.timestamp;
        IPriceFeed.PriceMsg memory bundle2 = buildSignedBundle(
            address(feed), roundId2, price2, timestamp2, signerPk
        );
        vm.expectRevert(bytes("HF_LT_1"));
        pool.withdraw(withdrawAmount, bundle2);
    }
}
