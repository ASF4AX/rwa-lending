// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {RWALendingPool} from "../contracts/RWALendingPool.sol";
import {IPriceFeed} from "../contracts/interfaces/IPriceFeed.sol";

contract MockFeed {
    uint256 public roundId = 1;
    int256 public price = 1e18; // $1
    uint256 public timestamp = block.timestamp;
    function latest() external view returns (uint256, int256, uint256) { return (roundId, price, timestamp); }
}

contract LendingBasicTest is Test {
    RWALendingPool pool;

    function setUp() public {
        pool = new RWALendingPool(IPriceFeed(address(new MockFeed())));
    }

    function testDepositBorrowWithinLTV() public {
        pool.depositCollateral(1000e18);
        pool.borrow(650e18); // 65% LTV
        assertEq(pool.debt(address(this)), 650e18);
    }
}
