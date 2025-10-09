// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";

contract SeedDemo is Script {
    function run() external {
        vm.startBroadcast();
        // TODO: set KYC, roles, mint demo amounts based on env variables
        vm.stopBroadcast();
    }
}
