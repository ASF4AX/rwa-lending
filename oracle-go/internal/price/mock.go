package price

// MockSource is a simple in-memory source for development/testing.
type MockSource struct{}

// Latest returns a fixed round and price (1e18) for local runs.
func (MockSource) Latest() (roundID uint64, price string) {
    return 1, "1000000000000000000"
}
