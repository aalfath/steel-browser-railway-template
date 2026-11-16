// Build-time patch for Steel Browser v0.5.5-beta (upstream bug, also on main as of 2026-11-16):
// the cast WebSocket handler is only reached for URLs starting with /v1/sessions/cast,
// but it then reads the session ID from that same URL and never finds one, so the
// live viewer (UI and /v1/sessions/debug) always shows "session offline".
// Fix: when the URL carries no session ID, use the active session (Steel runs one at a time).
// The build fails if the upstream line changes, so a version bump has to re-check this.
import { readFileSync, writeFileSync } from "node:fs";
const file = "/app/api/build/plugins/browser-socket/casting.handler.js";
const before = 'const id = request.url?.split("/sessions/")[1].split("/cast")[0];';
const after =
  '/* steel-railway-patch: cast without session ID uses the active session */ ' +
  'const __castPath = (request.url ?? "").split("?")[0].replace(/\\/+$/, ""); ' +
  'const id = __castPath === "/v1/sessions/cast" ? (await sessionService.activeSession)?.id : request.url?.split("/sessions/")[1].split("/cast")[0];';
const src = readFileSync(file, "utf8");
if (!src.includes(before)) {
  console.error("patch-cast: upstream code changed, review the patch");
  process.exit(1);
}
writeFileSync(file, src.replace(before, after));
console.log("patch-cast: applied");
