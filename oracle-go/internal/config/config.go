package config

import (
	"fmt"
	"os"
	"strconv"

	"github.com/ethereum/go-ethereum/common"
)

const (
    EnvPrivateKey = "PRIVATE_KEY"
    EnvChainID    = "CHAIN_ID"
    EnvFeedAddr   = "FEED_ADDRESS"
)

type Config struct {
    PrivateKeyHex string
    ChainID       uint64
    FeedAddress   string
}

func Load() (*Config, error) {
    pk := os.Getenv(EnvPrivateKey)
    if pk == "" {
        return nil, fmt.Errorf("%s is required", EnvPrivateKey)
    }

    chainStr := os.Getenv(EnvChainID)
    if chainStr == "" {
        return nil, fmt.Errorf("%s is required", EnvChainID)
    }
    cid, err := strconv.ParseUint(chainStr, 10, 64)
    if err != nil {
        return nil, fmt.Errorf("%s must be a base-10 uint: %w", EnvChainID, err)
    }

    feed := os.Getenv(EnvFeedAddr)
    if feed == "" {
        return nil, fmt.Errorf("%s is required", EnvFeedAddr)
    }
    if !common.IsHexAddress(feed) {
        return nil, fmt.Errorf("%s must be a valid hex address", EnvFeedAddr)
    }

    return &Config{PrivateKeyHex: pk, ChainID: cid, FeedAddress: feed}, nil
}
