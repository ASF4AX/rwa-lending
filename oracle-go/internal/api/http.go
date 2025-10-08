package api

import (
    "encoding/json"
    "net/http"
    "time"
)

type PriceLatest struct {
    RoundID   uint64 `json:"round_id"`
    Price     string `json:"price"`
    Timestamp int64  `json:"timestamp"`
    Signature string `json:"signature"`
}

func RegisterRoutes(mux *http.ServeMux) {
    mux.HandleFunc("/price/latest", func(w http.ResponseWriter, r *http.Request) {
        resp := PriceLatest{
            RoundID:   1,
            Price:     "1000000000000000000", // 1e18
            Timestamp: time.Now().Unix(),
            Signature: "", // TODO: fill from signer
        }
        w.Header().Set("Content-Type", "application/json")
        _ = json.NewEncoder(w).Encode(resp)
    })
}

