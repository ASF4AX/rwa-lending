// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {RWALendingPool} from "../contracts/RWALendingPool.sol";
import {IPriceFeed} from "../contracts/interfaces/IPriceFeed.sol";

contract MockFeedVar is IPriceFeed {
    uint256 public roundId = 1;
    int256 public price = 1e18;
    uint256 public timestamp = block.timestamp;
    function latest() external view returns (uint256, int256, uint256) { return (roundId, price, timestamp); }
    function setPrice(int256 p) external { price = p; }
}

contract LendingLiquidationTest is Test {
    RWALendingPool pool;
    MockFeedVar feed;

    function setUp() public {
        feed = new MockFeedVar();
        pool = new RWALendingPool(feed);
        pool.depositCollateral(1000e18);
        pool.borrow(650e18);
    }

    function testCanLiquidateWhenHFBelow1() public {
        feed.setPrice(7e17); // $0.7 -> HF drops
        pool.liquidate(address(this), 100e18);
        assertLt(pool.debt(address(this)), 650e18);
    }
}
