// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IPriceFeed} from "./interfaces/IPriceFeed.sol";

/// @title RWALendingPool
/// @notice Collateralized lending with basic parameters and HF check.
/// @dev Minimal stub for initial scaffold; uses fixed-point 1e18 precision.
contract RWALendingPool {
    IPriceFeed public priceFeed;

    uint256 public constant MAX_LTV = 65e16;         // 65%
    uint256 public constant LIQ_THRESHOLD = 75e16;   // 75%
    uint256 public constant INTEREST_APY = 5e16;     // 5%
    uint256 public constant LIQ_BONUS = 8e16;        // 8%

    mapping(address => uint256) public collateral;   // in RWA units (1e18)
    mapping(address => uint256) public debt;         // in USD units (1e18)

    event Deposit(address indexed user, uint256 amount);
    event Borrow(address indexed user, uint256 amount);
    event Repay(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Liquidate(address indexed user, address indexed liquidator, uint256 repayAmount);

    constructor(IPriceFeed feed) {
        priceFeed = feed;
    }

    function depositCollateral(uint256 amount) external {
        collateral[msg.sender] += amount;
        emit Deposit(msg.sender, amount);
    }

    function borrow(uint256 amount) external {
        require(_canBorrow(msg.sender, amount), "EXCEEDS_LTV");
        debt[msg.sender] += amount;
        emit Borrow(msg.sender, amount);
    }

    function repay(uint256 amount) external {
        uint256 d = debt[msg.sender];
        if (amount > d) amount = d;
        debt[msg.sender] = d - amount;
        emit Repay(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        require(collateral[msg.sender] >= amount, "INSUFFICIENT_COLLATERAL");
        collateral[msg.sender] -= amount;
        require(_healthFactor(msg.sender) >= 1e18, "HF_LT_1");
        emit Withdraw(msg.sender, amount);
    }

    function liquidate(address user, uint256 repayAmount) external {
        require(_healthFactor(user) < 1e18, "HF_GTE_1");
        uint256 d = debt[user];
        if (repayAmount > d) repayAmount = d;
        debt[user] = d - repayAmount;
        emit Liquidate(user, msg.sender, repayAmount);
    }

    function _canBorrow(address user, uint256 addDebt) internal view returns (bool) {
        ( , int256 p, ) = priceFeed.latest();
        require(p > 0, "BAD_PRICE");
        uint256 price = uint256(p);
        // collateralUSD = collateral * price / 1e18
        uint256 collateralUsd = collateral[user] * price / 1e18;
        uint256 maxDebt = collateralUsd * MAX_LTV / 1e18;
        return debt[user] + addDebt <= maxDebt;
    }

    function _healthFactor(address user) internal view returns (uint256) {
        ( , int256 p, ) = priceFeed.latest();
        if (p <= 0) return 0;
        uint256 price = uint256(p);
        uint256 collateralUsd = collateral[user] * price / 1e18;
        if (debt[user] == 0) return type(uint256).max;
        // HF = (collateralUSD * LIQ_THRESHOLD) / debtUSD
        return collateralUsd * LIQ_THRESHOLD / 1e18 / debt[user];
    }
}
