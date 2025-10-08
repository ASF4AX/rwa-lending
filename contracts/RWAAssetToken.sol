// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title RWAAssetToken
/// @notice ERC20-like token with whitelist-based transfer restrictions.
/// @dev Minimal stub for initial scaffold; full logic to be implemented.
contract RWAAssetToken {
    string public name = "RWA Asset Token";
    string public symbol = "RWA";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public isWhitelisted;

    address public admin;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event WhitelistSet(address indexed account, bool allowed);

    modifier onlyAdmin() {
        require(msg.sender == admin, "ONLY_ADMIN");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function setWhitelist(address account, bool allowed) external onlyAdmin {
        isWhitelisted[account] = allowed;
        emit WhitelistSet(account, allowed);
    }

    function _beforeTokenTransfer(address from, address to, uint256) internal view {
        if (from != address(0)) require(isWhitelisted[from], "FROM_NOT_WHITELISTED");
        if (to != address(0)) require(isWhitelisted[to], "TO_NOT_WHITELISTED");
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _beforeTokenTransfer(msg.sender, to, amount);
        require(balanceOf[msg.sender] >= amount, "INSUFFICIENT");
        unchecked {
            balanceOf[msg.sender] -= amount;
            balanceOf[to] += amount;
        }
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        _beforeTokenTransfer(from, to, amount);
        uint256 allowed = allowance[from][msg.sender];
        require(allowed >= amount, "ALLOWANCE");
        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;
        require(balanceOf[from] >= amount, "INSUFFICIENT");
        unchecked {
            balanceOf[from] -= amount;
            balanceOf[to] += amount;
        }
        emit Transfer(from, to, amount);
        return true;
    }

    // Mint/burn restricted to admin for initial stub; will be gated by Registrar in full impl.
    function mint(address to, uint256 amount) external onlyAdmin {
        _beforeTokenTransfer(address(0), to, amount);
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function burn(address from, uint256 amount) external onlyAdmin {
        _beforeTokenTransfer(from, address(0), amount);
        require(balanceOf[from] >= amount, "INSUFFICIENT");
        unchecked {
            balanceOf[from] -= amount;
            totalSupply -= amount;
        }
        emit Transfer(from, address(0), amount);
    }
}
