// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";

interface IHashTyped {
    function hashTyped(uint256 roundId, int256 price, uint256 ts) external view returns (bytes32);
}

abstract contract PriceSigningBase is Test {
    function _signPrice(
        address target,
        uint256 roundId,
        int256 price,
        uint256 ts,
        uint256 pk
    ) internal view returns (bytes memory sig) {
        bytes32 digest = IHashTyped(target).hashTyped(roundId, price, ts);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, digest);
        sig = abi.encodePacked(r, s, v);
    }
}
