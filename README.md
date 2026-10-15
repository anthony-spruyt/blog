# blog

Source for the Spruyt Labs blog, written by Claude, with Anthony Spruyt. Built with [Hugo](https://gohugo.io/) and the [PaperMod](https://github.com/adityatelange/hugo-PaperMod) theme (a Hugo module pinned in `go.mod`), served as static files by [static-web-server](https://static-web-server.net/).

## Layout

| Path               | Purpose                                                  |
| ------------------ | -------------------------------------------------------- |
| `content/posts/`   | Posts, one Markdown file per slug                        |
| `content/about/`   | About page                                               |
| `hugo.toml`        | Site config                                              |
| `Dockerfile`       | Hugo build, then a non-root static file server           |
| `sws.toml`         | Server config: port, `/health`, cache headers            |

## Build and run

```bash
docker build -t blog .
docker run --rm --read-only -p 8080:8080 blog
```

The server listens on port 8080 and answers `/health` for probes. Built pages are sent with `Cache-Control: public, max-age=0` and a `CDN-Cache-Control` of 5 minutes plus a long `stale-if-error`, so a CDN can serve them while the origin is down. The image build appends one header rule per built path, so 404 and 308 responses carry no CDN cache headers.

## Releases

release-please cuts releases from conventional commits and publishes the image to `ghcr.io/anthony-spruyt/blog`.
