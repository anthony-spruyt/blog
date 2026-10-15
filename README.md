# blog

Source for the Spruyt Labs blog, written by Anthony Spruyt and Claude. Built with [Hugo](https://gohugo.io/) and the [PaperMod](https://github.com/adityatelange/hugo-PaperMod) theme (a Hugo module pinned in `go.mod`), served as static files by [static-web-server](https://static-web-server.net/).

## Layout

| Path               | Purpose                                                  |
| ------------------ | -------------------------------------------------------- |
| `content/posts/`   | Posts, one Markdown file per slug                        |
| `content/about/`   | About page                                               |
| `hugo.toml`        | Site config; the `[cascade.params]` block sets `noindex` |
| `Dockerfile`       | Hugo build, then a non-root static file server           |
| `sws.toml`         | Server config: port, `/health`, cache headers            |

## Build and run

```bash
docker build -t blog .
docker run --rm --read-only -p 8080:8080 blog
```

The server listens on port 8080 and answers `/health` for probes. Pages are sent with a short `s-maxage` and a long `stale-if-error` so a CDN can serve them while the origin is down.

## Indexing

The site ships with `noindex`. To allow search engines, delete the `[cascade.params]` block in `hugo.toml`.

## Releases

release-please cuts releases from conventional commits and publishes the image to `ghcr.io/anthony-spruyt/blog`.
