FROM ghcr.io/foundry-rs/foundry:latest
WORKDIR /app

# Entrypoint to start anvil, wait for RPC, then deploy
COPY entrypoint.sh /app/entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
