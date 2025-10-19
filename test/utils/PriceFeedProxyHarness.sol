// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { PriceFeedProxy } from "../../contracts/PriceFeedProxy.sol";

contract PriceFeedProxyHarness is PriceFeedProxy {
    constructor(address signer) PriceFeedProxy(signer) {}
    function hashTyped(uint256 roundId, int256 price, uint256 ts) external view returns (bytes32) {
        return _hashTyped(roundId, price, ts);
    }
}
