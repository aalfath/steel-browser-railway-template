# Steel Browser on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/steel-browser-2?utm_medium=integration&utm_source=button&utm_campaign=steel-browser)

Railway template for [Steel Browser](https://github.com/steel-dev/steel-browser), the open-source browser API for AI agents and automation: Chrome sessions you drive over CDP (Puppeteer, Playwright, Selenium), plus quick actions (scrape, screenshot, PDF) and a web UI for watching sessions live.

This repo wraps the official image with a small API-key gate, because Steel Browser has no authentication of its own and a public instance would otherwise be an open browser and proxy for anyone.

## What it deploys

| | |
|---|---|
| App | Steel Browser **v0.5.5-beta** (upstream commit `9fb9b92`) |
| Image | `ghcr.io/steel-dev/steel-browser@sha256:b5bd99decf276ff6f9a8606def9f7408a376e17ac66a9e12cb82d8400cca23bd` (upstream only publishes a moving `latest` tag, so the pin is the digest built from the release commit) |
| Services | 1 (`Steel Browser`), built from this repo's `Dockerfile` |
| Volume | `/data`: session-log database (`/data/logs`), persisted browser profiles (`persist: true` sessions) and session files |
| Health check | `/v1/health` (open, no key needed) |

## Variables

| Variable | Default | What it does |
|---|---|---|
| `STEEL_API_KEY` | 48 random letters and digits (`${{secret(48,...)}}`) | Key for every request. Find it in the service's Variables tab |
| `PORT` | `8080` | Port of the API-key gate (the public domain points here) |

Optional, set them on the service if you need them: `PROXY_URL` (send browser traffic through a proxy), `DEFAULT_TIMEZONE`, `CHROME_ARGS`, `ENABLE_COMMANDS_API=true`, `SKIP_FINGERPRINT_INJECTION=true`. See [upstream `api/.env.example`](https://github.com/steel-dev/steel-browser/blob/main/api/.env.example).

## Using it

Send the key in any of these ways:

- header `steel-api-key: KEY` (what the Steel SDKs send), `Authorization: Bearer KEY` or `x-api-key: KEY`;
- query parameter `?apiKey=KEY`, which is what CDP/WebSocket clients need;
- in a browser, open `https://YOUR-DOMAIN/ui` and log in as user `steel` with the key as the password.

```js
// Create a session, then drive it with Puppeteer
const base = "https://YOUR-DOMAIN";
const s = await (await fetch(`${base}/v1/sessions`, {
  method: "POST",
  headers: { "steel-api-key": KEY, "content-type": "application/json" },
  body: "{}",
})).json();
const browser = await puppeteer.connect({
  browserWSEndpoint: `wss://YOUR-DOMAIN/?apiKey=${KEY}&sessionId=${s.id}`,
});
```

With the Steel SDK: `new Steel({ steelAPIKey: KEY, baseURL: "https://YOUR-DOMAIN" })`.

API reference: `https://YOUR-DOMAIN/documentation`.

## How it works

- `start.sh` renders `nginx.conf.template`: nginx listens on `PORT`, checks the key, and proxies HTTP and WebSocket traffic to the Steel API on `127.0.0.1:3000`. Chrome's raw DevTools port stays on localhost.
- The public domain and `wss://` URLs in session responses come from Railway's `RAILWAY_PUBLIC_DOMAIN`.
- `patch-cast.mjs` fixes an upstream bug in v0.5.5-beta (still on upstream `main` on 2026-11-16): the live viewer's WebSocket (`/v1/sessions/cast`) never found the session, so the UI always showed "session offline". The patch makes it use the active session. The image build fails if the upstream code changes, so every version bump re-checks it.
- One browser runs per instance (Steel Browser's open-source design). For parallel sessions, deploy more instances.

## Updates

Railway notifies everyone who deployed this template when a change is merged to `main` here. Read [`CHANGELOG.md`](CHANGELOG.md) before applying an update. The upstream image digest is bumped on a branch, tested on a scratch Railway project, then merged.
