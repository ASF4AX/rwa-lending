// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {RWAAssetToken} from "../contracts/RWAAssetToken.sol";
import {RWARegistrar} from "../contracts/RWARegistrar.sol";
import {PriceFeedProxy} from "../contracts/PriceFeedProxy.sol";
import {RWALendingPool} from "../contracts/RWALendingPool.sol";
import {IPriceFeed} from "../contracts/interfaces/IPriceFeed.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();

        RWARegistrar registrar = new RWARegistrar();
        RWAAssetToken token = new RWAAssetToken();
        PriceFeedProxy feed = new PriceFeedProxy(msg.sender);
        RWALendingPool pool = new RWALendingPool(IPriceFeed(address(feed)));

        // TODO: seed roles/whitelists and wire token with registrar in full impl
        (registrar, token, feed, pool);

        vm.stopBroadcast();
    }
}
