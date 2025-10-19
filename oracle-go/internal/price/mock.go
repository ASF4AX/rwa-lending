package price

// MockSource is a simple in-memory source for development/testing.
type MockSource struct{ round uint64 }

func (m *MockSource) Latest() (roundID uint64, price string) {
    m.round++
    return m.round, "1000000000000000000"
}
