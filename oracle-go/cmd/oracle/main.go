package main

import (
	"log"
	"net/http"

	"rwa-lending/oracle-go/internal/api"
	"rwa-lending/oracle-go/internal/config"
	"rwa-lending/oracle-go/internal/price"
	"rwa-lending/oracle-go/internal/signer"

	"github.com/joho/godotenv"
)

const listenAddr = ":8088"

func init() { godotenv.Load("../.env") }

func main() {
    cfg, err := config.Load()
    if err != nil {
        log.Fatalf("config: %v", err)
    }

    // EIP-712 signer for the on-chain PriceFeedProxy domain.
    eip712Signer, err := signer.NewEIP712(cfg.PrivateKeyHex, cfg.ChainID, cfg.FeedAddress)
    if err != nil {
        log.Fatalf("signer: %v", err)
    }

    // TODO: Replace mock with a real price source implementation.
    priceSource := &price.MockSource{}

    // HTTP router and route registration.
    router := http.NewServeMux()
    api.RegisterRoutes(router, priceSource, eip712Signer)

    log.Printf("oracle listening on %s", listenAddr)
    log.Fatal(http.ListenAndServe(listenAddr, router))
}
