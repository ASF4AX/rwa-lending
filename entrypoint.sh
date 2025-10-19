#!/usr/bin/env bash
set -euo pipefail

# Required envs (with sensible defaults):
# - PRIVATE_KEY: deploy key (must be provided via env)
# - DEPLOY_SCRIPT: forge script path to run
# - ANVIL_MNEMONIC: optional; defaults to the common foundry test mnemonic
# - ANVIL_IP_ADDR: optional; anvil reads this to decide bind address

RPC_URL="http://127.0.0.1:8545"
DEPLOY_SCRIPT="script/Deploy.s.sol"

# Start anvil in background;
anvil -p 8545 -m "${ANVIL_MNEMONIC}" &
ANVIL_PID=$!

# Wait for RPC to be ready
until cast chain-id --rpc-url "${RPC_URL}" >/dev/null 2>&1; do
  echo "waiting for anvil RPC at ${RPC_URL}..."; sleep 0.3;
done

# Broadcast deployment
forge script "${DEPLOY_SCRIPT}" \
  --broadcast \
  --rpc-url "${RPC_URL}" \
  --private-key "${PRIVATE_KEY}"

# Keep anvil in foreground
wait "${ANVIL_PID}"
