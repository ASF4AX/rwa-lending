package price

// Mock price source; replace with real feed as needed.

func Latest() (roundID uint64, price string) {
    return 1, "1000000000000000000" // 1e18
}

