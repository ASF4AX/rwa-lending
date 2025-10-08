// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {RWARegistrar} from "../contracts/RWARegistrar.sol";

contract RegistrarTest is Test {
    RWARegistrar registrar;

    function setUp() public {
        registrar = new RWARegistrar();
    }

    function testInitialAdmin() public {
        assertEq(uint256(registrar.roles(address(this))), uint256(RWARegistrar.Role.ADMIN));
    }
}

