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

## Conventions and Guardrails
- Prefer strict-concurrency-safe APIs and avoid implicit actor isolation leaks.
- Keep core models UI-agnostic. Put UI-only concerns in `Shared/Extensions/`.
- Inject dependencies (`TokenStore`, API client dependencies) rather than hard-coding globals.
- Keep authentication to PAT + Keychain for current phase.
- Keep changes minimal and scoped to the task. Do not revert unrelated user changes.

## Authentication and API
- Token storage is provided by `KeychainManager` implementing `TokenStore`.
- `GitHubAPIClient` is an `actor` and requires an injected `TokenStore`.
- OAuth Device Flow is implemented via `GitHubOAuthClient` and used by `AuthViewModel`.
- GraphQL queries are defined in `MergeDeck/Core/Network/GraphQLQueries.swift`.

## Expected Workflow for Agents
1. Read current git status before changes.
2. Implement focused edits.
3. Validate both platforms for each feature change:
   - `make build-macos`
   - `make build-ios`
4. Run unit tests when possible (`make test-macos` and `make test-ios`).
5. Update Wiki docs when behavior, architecture, structure, or workflow changes.
6. Keep `docs/wiki/` pages in sync with code changes before finalizing.
7. Publish wiki updates to GitHub Wiki when access is available.
8. Summarize exactly what changed and what was validated.

## Pending Product Scope (Not Yet Implemented)
- Widgets and App Group sharing
- Background refresh and notifications

## Workflow Orchestration

### 1) Plan Mode Default
- Enter plan mode for non-trivial work (multi-step tasks or architecture-impacting changes).
- If implementation breaks or assumptions fail, stop and re-plan before continuing.
- Use plan mode for verification strategy, not just implementation steps.
- Write detailed specs up front to reduce ambiguity.

### 2) Subagent Strategy
- Use subagents/parallel work to keep primary context focused.
- Offload research, exploration, and parallel analysis when useful.
- For complex problems, split work into focused sub-tasks.
- Prefer one clear task per subagent execution path.

### 3) Self-Improvement Loop
- After corrections, record lessons in `tasks/lessons.md` when that file exists.
- Add rules that prevent recurrence of the same issue.
- Revisit and refine lessons until repeated error rate drops.
- Review prior lessons at the start of related project work.

### 4) Verification Before Done
- Do not mark work complete without proof it works.
- Verify behavior changed as intended for affected code paths.
- Run relevant tests/builds, inspect logs, and provide concrete validation evidence.
- Use a senior-engineering quality bar before finalizing.

### 5) Demand Elegance (Balanced)
- For non-trivial changes, pause and check if a cleaner design exists.
- Avoid hacky fixes when a robust solution is practical.
- Do not over-engineer simple, obvious fixes.
- Challenge code quality before presenting results.

### 6) Autonomous Bug Fixing
- When given a bug report, drive from logs/errors/tests to resolution.
- Minimize back-and-forth when the problem can be solved directly.
- Treat failing CI/tests as actionable debugging entry points.

## Task Management
1. Plan first: write checkable tasks in `tasks/todo.md` when that file exists.
2. Verify plan: confirm the plan before implementing.
3. Track progress: mark items complete as work lands.
4. Explain changes: provide a high-level summary per major step.
5. Document results: add review notes to `tasks/todo.md` when used.
6. Capture lessons: update `tasks/lessons.md` after corrections when applicable.

## Core Principles
- Simplicity first: prefer the smallest correct change.
- No laziness: fix root causes, avoid temporary patches.
- Minimal impact: touch only required surfaces and avoid regressions.
