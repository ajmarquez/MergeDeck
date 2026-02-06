# AGENTS.md

This file documents how to work in this repository as an automated or human coding agent.

## Project Overview
- Name: MergeDeck
- Platform: SwiftUI app for iOS and macOS
- Current phase: Foundation (auth + API + app shell)
- Architecture: MVVM + async/await + actor-based API client

## Repo Structure
- `MergeDeck/App/`: app entry and root views
- `MergeDeck/Features/Authentication/`: PAT auth UI and view model
- `MergeDeck/Core/Models/`: core data models
- `MergeDeck/Core/Network/`: API client, GraphQL queries, API errors
- `MergeDeck/Core/Persistence/`: token storage abstractions and keychain implementation
- `MergeDeck/Shared/Extensions/`: shared UI and model extensions
- `MergeDeckTests/`: unit tests (Swift Testing)
- `MergeDeckUITests/`: UI tests

## Build and Test Commands
Use the root `Makefile`.

- `make build` or `make build-macos`: build macOS target
- `make build-ios`: build iOS simulator target
- `make test` or `make test-macos`: run unit tests on macOS
- `make test-ios`: run unit tests on iOS simulator
- `make test-ui-macos`: run UI tests on macOS
- `make test-ui-ios`: run UI tests on iOS simulator
- `make clean`: clean derived data path used by make
- `make check-xcbeautify`: verify formatter availability

Notes:
- `xcbeautify` is auto-used when available, with fallback to raw `xcodebuild` output.
- Some environments may stall during `xcodebuild test` when UI runners initialize. Prefer unit test targets first.
- If a build/test appears stuck:
  - run `make clean`
  - retry the same command once
  - if still stuck, stop the hanging `xcodebuild` process and report the blocker with logs

## Conventions and Guardrails
- Prefer strict-concurrency-safe APIs and avoid implicit actor isolation leaks.
- Keep core models UI-agnostic. Put UI-only concerns in `Shared/Extensions/`.
- Inject dependencies (`TokenStore`, API client dependencies) rather than hard-coding globals.
- Keep authentication to PAT + Keychain for current phase.
- Keep changes minimal and scoped to the task. Do not revert unrelated user changes.

## Authentication and API
- Token storage is provided by `KeychainManager` implementing `TokenStore`.
- `GitHubAPIClient` is an `actor` and requires an injected `TokenStore`.
- GraphQL queries are defined in `MergeDeck/Core/Network/GraphQLQueries.swift`.

## Expected Workflow for Agents
1. Read current git status before changes.
2. Read `docs/Next-Session.md` at session start and follow its checklist.
3. Implement focused edits.
4. Validate both platforms:
   - `make build-macos`
   - `make build-ios`
5. Run unit tests when possible (`make test-macos` and `make test-ios`).
6. Summarize exactly what changed and what was validated.
7. Update `docs/Next-Session.md` before ending the session.

## Pending Product Scope (Not Yet Implemented)
- Full PR dashboard UI
- Widgets and App Group sharing
- OAuth flow
- Background refresh and notifications

## Session Handoff
- Canonical handoff file: `docs/Next-Session.md`
- Every session should:
  - read it at start
  - update it at end
