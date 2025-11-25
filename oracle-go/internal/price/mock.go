package price

import (
	"log"
	"math/big"
	"math/rand"
	"time"
)

// MockSource is a simple in-memory source for development/testing.
// It returns a price that randomly walks around a base value within a bounded range.
type MockSource struct {
	round uint64
	price *big.Int
}

var (
	rnd = rand.New(rand.NewSource(time.Now().UnixNano()))

	// Base price 100.0, with a global range of [80.0, 120.0]
	basePrice, _ = new(big.Int).SetString("100000000000000000000", 10)   // 100.0
	minPrice, _  = new(big.Int).SetString("80000000000000000000", 10)   // 80.0
	maxPrice, _  = new(big.Int).SetString("120000000000000000000", 10)  // 120.0
)

func (m *MockSource) Latest() (roundID uint64, price string) {
	m.round++

	// Initialize price on first call.
	if m.price == nil {
		m.price = new(big.Int).Set(basePrice)
	} else {
		// Apply a small random step in the range [-5%, +5%].
		stepPct := rnd.Intn(11) - 5 // -5..+5

		if stepPct != 0 {
			delta := new(big.Int).Mul(m.price, big.NewInt(int64(stepPct)))
			delta.Div(delta, big.NewInt(100)) // percentage
			m.price.Add(m.price, delta)
		}

		// Clamp to [minPrice, maxPrice] to keep demo stable.
		if m.price.Cmp(minPrice) < 0 {
			m.price.Set(minPrice)
		} else if m.price.Cmp(maxPrice) > 0 {
			m.price.Set(maxPrice)
		}
	}

	if m.round%10 == 1 {
		log.Printf("mock price round=%d price=%s", m.round, m.price.String())
	}

	return m.round, m.price.String()
}
