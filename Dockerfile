FROM ghcr.io/gohugoio/hugo:v0.168.0@sha256:1fb8fe7f417abd5802d86747d297728aa48078d763159e7dff6559fe3f8bb8e7 AS builder

WORKDIR /project
COPY --chown=hugo:hugo . .
RUN hugo --minify --gc --destination /tmp/public
# SWS matches the percent-encoded request path, so only characters that encode to themselves are allowed
RUN bad=$(LC_ALL=C find /tmp/public -name '*[!A-Za-z0-9._~-]*') \
    && if [ -n "$bad" ]; then printf 'unsupported characters in built paths:\n%s\n' "$bad" >&2; exit 1; fi
# One cache rule per built path so a 404 or 308 matches none. SWS matches a directory index as "/dir//index.html"
RUN cp sws.toml /tmp/sws.toml \
    && find /tmp/public -type f > /tmp/files \
    && awk ' \
        function rule(s) { printf "\n[[advanced.headers]]\nsource = \"%s\"\n[advanced.headers.headers]\nCache-Control = \"public, max-age=0\"\nCDN-Cache-Control = \"max-age=300, stale-if-error=604800\"\n", s } \
        { p = $0; sub(/^\/tmp\/public/, "", p); rule(p); if (sub(/.\/index\.html$/, "&", p)) { sub(/\/index\.html$/, "//index.html", p); rule(p) } }' /tmp/files >> /tmp/sws.toml

FROM ghcr.io/static-web-server/static-web-server:2.44.1@sha256:94618e3d17802265a21926217e6f9e7832b311b6fbf5933684001739fafed06a
COPY --from=builder /tmp/public /public
COPY --from=builder /tmp/sws.toml /sws.toml
USER 65534:65534
EXPOSE 8080
HEALTHCHECK NONE
ENTRYPOINT ["/static-web-server", "--config-file", "/sws.toml"]
