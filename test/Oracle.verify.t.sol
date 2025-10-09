// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {PriceFeedProxy} from "../contracts/PriceFeedProxy.sol";

contract OracleVerifyTest is Test {
    PriceFeedProxy feed;

    function setUp() public {
        feed = new PriceFeedProxy(address(this));
    }

    function testSubmitStoresLatest() public {
        feed.submit(1, 100e18, block.timestamp, bytes(""));
        (uint256 r, int256 p, uint256 t) = feed.latest();
        assertEq(r, 1);
        assertEq(p, 100e18);
        assertEq(t, block.timestamp);
    }
}
