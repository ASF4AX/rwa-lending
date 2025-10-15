package api

import (
	"encoding/json"
	"log"
	"net/http"
	"time"
)

type PriceLatest struct {
    RoundID   uint64 `json:"round_id"`
    Price     string `json:"price"`
    Timestamp int64  `json:"timestamp"`
    Signature string `json:"signature"`
}

// Signer produces an EIP-712 compatible signature for the given message fields.
type Signer interface {
    Sign(roundID uint64, priceStr string, timestamp int64) (string, error)
}

// PriceSource provides the latest round and price information
type PriceSource interface {
    Latest() (roundID uint64, price string)
}

func writeJSON(w http.ResponseWriter, status int, v any) {
    // Basic CORS for local dev
    w.Header().Set("Access-Control-Allow-Origin", "*")
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(status)
    if err := json.NewEncoder(w).Encode(v); err != nil {
        http.Error(w, "encode error", http.StatusInternalServerError)
    }
}

func latestPriceHandler(priceSource PriceSource, eip712Signer Signer) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        round, price := priceSource.Latest()
        ts := time.Now().UTC().Unix()

        sig, err := eip712Signer.Sign(round, price, ts)
        if err != nil {
            log.Printf("sign error: %v", err)
            http.Error(w, "sign error", http.StatusInternalServerError)
            return
        }

        resp := PriceLatest{
            RoundID:   round,
            Price:     price,
            Timestamp: ts,
            Signature: sig,
        }

        log.Printf("%s %s from %s -> round=%d price=%s ts=%d",
            r.Method, r.URL.Path, r.RemoteAddr, resp.RoundID, resp.Price, resp.Timestamp)

        writeJSON(w, http.StatusOK, resp)
    }
}

func RegisterRoutes(router *http.ServeMux, priceSource PriceSource, eip712Signer Signer) {
    router.HandleFunc("/price/latest", latestPriceHandler(priceSource, eip712Signer))
}
