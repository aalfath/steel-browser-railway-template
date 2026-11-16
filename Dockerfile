# Steel Browser v0.5.5-beta (upstream commit 9fb9b92, built 2026-10-31).
# Upstream publishes only a moving `latest` tag, so the image is pinned by the
# digest of the multi-arch image built from the v0.5.5-beta release commit.
FROM ghcr.io/steel-dev/steel-browser:latest@sha256:b5bd99decf276ff6f9a8606def9f7408a376e17ac66a9e12cb82d8400cca23bd

# Persistent data lives on the /data volume: uploaded session files, persisted
# browser profiles and the session-log database.
RUN mkdir -p /data /app/railway \
    && rm -rf /files /app/api/user-data-dir \
    && ln -s /data/files /files \
    && ln -s /data/user-data-dir /app/api/user-data-dir

COPY --chmod=644 nginx.conf.template /app/railway/nginx.conf.template
COPY --chmod=755 start.sh /app/railway/start.sh

EXPOSE 8080

ENTRYPOINT ["/usr/bin/tini", "--", "/app/railway/start.sh"]
