FROM ghcr.io/foundry-rs/foundry:latest

# Use root only for build-time dependency installation
USER root

WORKDIR /app

# Foundry project configuration and lockfile
COPY foundry.toml soldeer.lock ./

# Project sources needed for deployment (contracts + scripts only)
COPY contracts ./contracts
COPY script ./script

# Install/update Solidity dependencies at build time so the image is self-contained,
# then drop ownership of /app to an unprivileged runtime user (UID 1000).
RUN forge soldeer update && chown -R 1000:1000 /app

# Switch to non-root runtime user
USER 1000:1000

# Entrypoint to start anvil, wait for RPC, then deploy
COPY entrypoint.sh /app/entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
