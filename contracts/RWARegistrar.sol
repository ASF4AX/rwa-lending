// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title RWARegistrar
/// @notice Manages roles and whitelist for RWA token mint/burn.
/// @dev Minimal stub for initial scaffold; integrate with token in full impl.
contract RWARegistrar {
    enum Role { NONE, ADMIN, ISSUER, KYC_MANAGER }

    mapping(address => Role) public roles;
    mapping(address => bool) public isWhitelisted;

    event RoleSet(address indexed account, Role role);
    event WhitelistSet(address indexed account, bool allowed);

    modifier only(Role r) {
        require(roles[msg.sender] == r || roles[msg.sender] == Role.ADMIN, "NO_ROLE");
        _;
    }

    constructor() {
        roles[msg.sender] = Role.ADMIN;
        emit RoleSet(msg.sender, Role.ADMIN);
    }

    function setRole(address account, Role r) external only(Role.ADMIN) {
        roles[account] = r;
        emit RoleSet(account, r);
    }

    function setWhitelist(address account, bool allowed) external only(Role.KYC_MANAGER) {
        isWhitelisted[account] = allowed;
        emit WhitelistSet(account, allowed);
    }
}
