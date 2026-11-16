# Changelog

## 2026-11-16: Steel Browser v0.5.5-beta

- First release of the template: Steel Browser v0.5.5-beta (`ghcr.io/steel-dev/steel-browser@sha256:b5bd99de…`, built from upstream commit `9fb9b92`).
- API-key gate (nginx) on `PORT`: key as `steel-api-key` header, Bearer token, `x-api-key`, `?apiKey=` or HTTP Basic `steel:KEY` for the web UI. `/v1/health` stays open.
- `/data` volume for the session-log database, persisted browser profiles and session files.
