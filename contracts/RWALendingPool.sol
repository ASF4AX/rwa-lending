// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IPriceFeed } from "./interfaces/IPriceFeed.sol";

/// @title RWALendingPool
/// @notice Collateralized lending with basic parameters and HF check.
/// @dev Minimal stub for initial scaffold; uses fixed-point 1e18 precision.
contract RWALendingPool {
    IPriceFeed public priceFeed;
    uint256 public maxStaleness = 1 minutes;

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

    function borrow(uint256 amount, IPriceFeed.PriceMsg calldata priceMsg) external {
        uint256 price = _readFreshPrice(priceMsg);        
        require(_canBorrowWithPrice(msg.sender, amount, price), "EXCEEDS_LTV");

        debt[msg.sender] += amount;
        emit Borrow(msg.sender, amount);
    }

    function repay(uint256 amount) external {
        uint256 currentDebt = debt[msg.sender];
        if (amount > currentDebt) amount = currentDebt;
        debt[msg.sender] = currentDebt - amount;
        emit Repay(msg.sender, amount);
    }

    function withdraw(uint256 amount, IPriceFeed.PriceMsg calldata priceMsg) external {
        require(collateral[msg.sender] >= amount, "INSUFFICIENT_COLLATERAL");
        uint256 price = _readFreshPrice(priceMsg);

        collateral[msg.sender] -= amount;
        require(_healthFactorWithPrice(msg.sender, price) >= 1e18, "HF_LT_1");
        emit Withdraw(msg.sender, amount);
    }

    function liquidate(address user, uint256 repayAmount, IPriceFeed.PriceMsg calldata priceMsg) external {
        uint256 price = _readFreshPrice(priceMsg);        
        require(_healthFactorWithPrice(user, price) < 1e18, "HF_GTE_1");
        
        uint256 currentDebt = debt[user];
        if (repayAmount > currentDebt) repayAmount = currentDebt;
        debt[user] = currentDebt - repayAmount;
        emit Liquidate(user, msg.sender, repayAmount);
    }

    function _canBorrowWithPrice(address user, uint256 addDebt, uint256 price) internal view returns (bool) {
        // collateralUSD = collateral * price / 1e18
        uint256 collateralUsd = collateral[user] * price / 1e18;
        uint256 maxDebt = collateralUsd * MAX_LTV / 1e18;
        return debt[user] + addDebt <= maxDebt;
    }

    function _healthFactorWithPrice(address user, uint256 price) internal view returns (uint256) {
        uint256 collateralUsd = collateral[user] * price / 1e18;
        if (debt[user] == 0) return type(uint256).max;
        return collateralUsd * LIQ_THRESHOLD / debt[user];
    }

    function _toUintPrice(int256 signedPrice) internal pure returns (uint256) {
        require(signedPrice > 0, "BAD_PRICE");
        return uint256(signedPrice);
    }

    function _readFreshPrice(IPriceFeed.PriceMsg calldata priceMsg) internal returns (uint256) {
        priceFeed.upsertFromSig(priceMsg);
        (int256 latestPrice, uint256 ts, ) = priceFeed.latest();
        require(block.timestamp - ts <= maxStaleness, "STALE");
        return _toUintPrice(latestPrice);
    }
}
