package main

import (
    "log"
    "net/http"

    "rwa-lending/oracle-go/internal/api"
)

func main() {
    mux := http.NewServeMux()
    api.RegisterRoutes(mux)
    addr := ":8080"
    log.Printf("oracle listening on %s", addr)
    log.Fatal(http.ListenAndServe(addr, mux))
}

