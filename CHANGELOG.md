# Changelog

## 2026-11-16: Deploy on Railway button

- README: added the Deploy on Railway button for the published template (`steel-browser-2`). No change to the deployed service.

## 2026-11-16: Steel Browser v0.5.5-beta

- First release of the template: Steel Browser v0.5.5-beta (`ghcr.io/steel-dev/steel-browser@sha256:b5bd99de…`, built from upstream commit `9fb9b92`).
- API-key gate (nginx) on `PORT`: key as `steel-api-key` header, Bearer token, `x-api-key`, `?apiKey=` or HTTP Basic `steel:KEY` for the web UI. `/v1/health` stays open.
- Live viewer fix: patched the cast WebSocket handler so the UI's live view finds the active session (upstream bug since v0.5.5-beta).
- `/data` volume for the session-log database, persisted browser profiles and session files.
