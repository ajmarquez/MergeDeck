# Next Session Plan

This file is the handoff checklist for the next coding session.

## Current PR/Branch State
- `feature/phase2` -> PR #1: Phase 2 product work (PR list, detail, settings, docs updates).
- `feature/github-actions` -> PR #2: base GitHub Actions setup and CI fixes.
- `feature/github-actions-make` -> PR #3: run CI via `make` targets (stacked on PR #2).

## First Steps Next Session
1. Check open PR statuses and failing checks:
   - `gh pr list --state open`
   - `gh pr checks 1`
   - `gh pr checks 2`
   - `gh pr checks 3`
2. If checks are stuck/failing, inspect logs:
   - `gh run list --limit 20`
   - `gh run view <run-id> --log`
3. Validate local builds before changing code:
   - `make clean`
   - `make build-macos`
   - `make build-ios`

## Recommended Merge Order
1. Merge PR #2 (`feature/github-actions`).
2. Merge PR #3 (`feature/github-actions-make`).
3. Merge PR #1 (`feature/phase2`).

Reason:
- CI foundation first, then CI execution-model change, then larger feature PR.

## Phase 2 Follow-up Tasks
1. Improve PR list UX:
   - add explicit loading/error retry states
   - refine row truncation for long failed check names
2. Add sorting/filtering:
   - failing-first toggle
   - recently-updated default confirmation
3. Stabilize tests:
   - keep CI-safe behavior for keychain/request tests
   - investigate iOS local test runner hangs separately from CI
4. Start widget prep:
   - define shared cache contract for app -> widgets
   - add data snapshot model for TimelineProvider

## Documentation Tasks
1. Keep `docs/wiki/` pages in sync with code changes.
2. Publish wiki updates when needed:
   - `./scripts/publish-wiki.sh ajmarquez/MergeDeck`
3. Update this file at end of session with:
   - what shipped
   - what is blocked
   - next concrete checklist

## Definition of Done for a Session
1. Both platform builds attempted:
   - `make build-macos`
   - `make build-ios`
2. Relevant tests attempted.
3. PR description updated with validation results.
4. `docs/wiki/` and `docs/Next-Session.md` updated.
