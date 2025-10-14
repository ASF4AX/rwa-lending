package signer

import (
	"crypto/ecdsa"
	"encoding/hex"
	"errors"
	"fmt"
	"math/big"
	"strings"

	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/crypto"
)

// EIP-712 constants aligned with the Solidity contract and on-chain verifier.
const (
    domainName    = "RWA Price Feed"
    domainVersion = "1"

    typeStrDomain   = "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    typeStrPriceMsg = "PriceMessage(uint256 roundId,int256 price,uint256 timestamp)"
)

// Precomputed ABI types, argument layouts, and type hashes to avoid runtime allocation noise.
var (
    abiBytes32 = mustNewType("bytes32")
    abiUint256 = mustNewType("uint256")
    abiInt256  = mustNewType("int256")
    abiAddress = mustNewType("address")

    argsDomain = abi.Arguments{{Type: abiBytes32}, {Type: abiBytes32}, {Type: abiBytes32}, {Type: abiUint256}, {Type: abiAddress}}
    argsPrice  = abi.Arguments{{Type: abiBytes32}, {Type: abiUint256}, {Type: abiInt256}, {Type: abiUint256}}

    typeHashDomain = crypto.Keccak256Hash([]byte(typeStrDomain))
    typeHashPrice  = crypto.Keccak256Hash([]byte(typeStrPriceMsg))
)

func mustNewType(t string) abi.Type {
    ty, err := abi.NewType(t, "", nil)
    if err != nil {
        panic(fmt.Errorf("abi.NewType(%s): %w", t, err))
    }
    return ty
}

type Signer struct {
    key       *ecdsa.PrivateKey
    chainID   *big.Int
    feedAddr  common.Address
    domainSep [32]byte
}

// NewEIP712 creates a signer for EIP-712 typed-data signatures.
func NewEIP712(privateKeyHex string, chainID uint64, feedAddress string) (*Signer, error) {
    if privateKeyHex == "" {
        return nil, errors.New("empty private key")
    }
    if feedAddress == "" {
        return nil, errors.New("empty feed address")
    }
    if !common.IsHexAddress(feedAddress) {
        return nil, fmt.Errorf("invalid feed address: %s", feedAddress)
    }

    h := strings.TrimPrefix(privateKeyHex, "0x")
    ecdsaKey, err := crypto.HexToECDSA(h)
    if err != nil {
        return nil, fmt.Errorf("HexToECDSA: %w", err)
    }

    s := &Signer{
        key:      ecdsaKey,
        chainID:  new(big.Int).SetUint64(chainID),
        feedAddr: common.HexToAddress(feedAddress),
    }
    sep, err := s.computeDomainSeparator()
    if err != nil {
        return nil, err
    }
    copy(s.domainSep[:], sep.Bytes())
    return s, nil
}


// Sign parses price as base-10 and delegates to signBig.
func (s *Signer) Sign(roundID uint64, priceStr string, timestamp int64) (string, error) {
    price := new(big.Int)
    if _, ok := price.SetString(priceStr, 10); !ok {
        return "", fmt.Errorf("invalid price: %q", priceStr)
    }
    return s.signBig(roundID, price, timestamp)
}

// signBig computes the EIP-712 digest and returns a 0x-prefixed 65-byte signature.
// The recovery id V is adjusted to 27/28 for Solidity ecrecover compatibility.
func (s *Signer) signBig(roundID uint64, price *big.Int, ts int64) (string, error) {
    if price == nil {
        return "", errors.New("nil price")
    }
    digest, err := s.digest(roundID, price, ts)
    if err != nil {
        return "", err
    }
    sig, err := crypto.Sign(digest, s.key) // 65 bytes: R || S || V(0/1)
    if err != nil {
        return "", fmt.Errorf("sign: %w", err)
    }
    sig[64] += 27 // move V to 27/28
    return "0x" + hex.EncodeToString(sig), nil
}

// computeDomainSeparator encodes and hashes the EIP-712 domain.
func (s *Signer) computeDomainSeparator() (common.Hash, error) {
    nameHash := crypto.Keccak256Hash([]byte(domainName))
    verHash := crypto.Keccak256Hash([]byte(domainVersion))

    packed, err := argsDomain.Pack(
        typeHashDomain,
        nameHash,
        verHash,
        s.chainID,
        s.feedAddr,
    )
    if err != nil {
        return common.Hash{}, fmt.Errorf("pack domain: %w", err)
    }
    return crypto.Keccak256Hash(packed), nil
}

// structHashPrice encodes the message and returns its struct hash.
func (s *Signer) structHashPrice(roundID uint64, price *big.Int, ts int64) (common.Hash, error) {
    // abi.encode(typehash, roundId, price, timestamp)
    packed, err := argsPrice.Pack(
        typeHashPrice,
        new(big.Int).SetUint64(roundID),
        price,
        new(big.Int).SetUint64(uint64(ts)),
    )
    if err != nil {
        return common.Hash{}, fmt.Errorf("pack price: %w", err)
    }
    return crypto.Keccak256Hash(packed), nil
}

// digest builds keccak256(0x1901 || domainSeparator || structHash).
func (s *Signer) digest(roundID uint64, price *big.Int, ts int64) ([]byte, error) {
    sh, err := s.structHashPrice(roundID, price, ts)
    if err != nil {
        return nil, err
    }
    prefix := []byte{0x19, 0x01}
    out := make([]byte, 0, 2+32+32)
    out = append(out, prefix...)
    out = append(out, s.domainSep[:]...)
    out = append(out, sh.Bytes()...)
    return crypto.Keccak256(out), nil
}
