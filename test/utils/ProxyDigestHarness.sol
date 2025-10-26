// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { EIP712Schema } from "../../contracts/lib/EIP712Schema.sol";
import { IERC5267 } from "@openzeppelin/interfaces/IERC5267.sol";

// Test-only helper to compute the EIP-712 digest (domain + struct) equivalent to Proxy's _hashTypedDataV4 path.
// Note: This harness is tied to Proxy's IERC5267 domain; EIP712Schema only hashes the struct.
contract ProxyDigestHarness {
    bytes32 internal constant EIP712_DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );

    function digest(address feed, uint256 roundId, int256 price, uint256 ts) external view returns (bytes32) {
        (
            ,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            ,
            
        ) = IERC5267(feed).eip712Domain();

        bytes32 domainSeparator = keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                chainId,
                verifyingContract
            )
        );
        bytes32 structHash = EIP712Schema.hashStruct(roundId, price, ts);
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}
