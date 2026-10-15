FROM ghcr.io/gohugoio/hugo:v0.168.0@sha256:1fb8fe7f417abd5802d86747d297728aa48078d763159e7dff6559fe3f8bb8e7 AS builder

WORKDIR /project
COPY --chown=hugo:hugo go.mod go.sum hugo.toml ./
COPY --chown=hugo:hugo content/ content/
RUN hugo --minify --gc --destination /tmp/public

FROM ghcr.io/static-web-server/static-web-server:2.44.1@sha256:94618e3d17802265a21926217e6f9e7832b311b6fbf5933684001739fafed06a
COPY --from=builder /tmp/public /public
COPY sws.toml /sws.toml
USER 65534:65534
EXPOSE 8080
HEALTHCHECK NONE
ENTRYPOINT ["/static-web-server", "--config-file", "/sws.toml"]
