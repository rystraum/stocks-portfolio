# Contributing

## Git commit SOP (default)

How changes land in this repo. One commit = one logical task, scoped to the files it
touched, carrying the tests that cover it.

- **Commit by file.** A commit contains only the files a single task changed — no
  bundling unrelated edits. Multiple tasks → multiple commits.
- **Relevant tests per task.** Every commit includes the tests that cover the change:
  - Backend (Rails) → Minitest under `backend/test` (`models`, `services`, `controllers`,
    …). Run `bin/rails test` (or the specific file).
  - Frontend (React / Vite) → Vitest + React Testing Library, `*.test.tsx` beside the
    component. Run `npm test` from `frontend/`.
- **Green before commit.** The commit’s relevant tests pass; the build is green and the changed files add no new `npm run lint` errors (the repo carries pre-existing lint debt — don’t add to it). Frontend test files may relax `no-explicit-any` via the `eslint.config.js` test override.
- **Message.** Descriptive subject; optional `area:` prefix (e.g. `stocks: …`, `api: …`).

If a change has no covering test yet, add one in the same commit (or note the gap in the
message) — do not commit untested behavior silently.
