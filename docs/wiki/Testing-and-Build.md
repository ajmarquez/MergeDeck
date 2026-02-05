# Testing and Build

## Prerequisites
- Xcode installed
- `xcbeautify` installed (optional but recommended)

Install formatter:
```bash
brew install xcbeautify
```

## Standard Commands
From repo root:
```bash
make help
make build-macos
make build-ios
make test-macos
make test-ios
make test-ui-macos
make test-ui-ios
```

## CI (GitHub Actions)
- Workflow: `.github/workflows/tests.yml`
- Triggers:
  - pull requests
  - pushes to `main`, `develop`, and `feature/**`
- Jobs:
  - macOS unit tests (`MergeDeckTests`)
  - iOS simulator unit tests (`MergeDeckTests`)

## Notes About Test Execution
- Unit and UI tests are separated in Make targets.
- Some local environments can stall around UI test runner startup.
- Prefer `make test-macos` for quick feedback on logic and mapping.

## What to Validate Before Pushing
- `make build-macos` succeeds.
- At least one unit test run is attempted for touched logic.
- No new concurrency warnings in updated files.

## Current Quality Coverage
Existing tests include:
- GraphQL decoding fixture verification
- Authorization header/body request verification
- Keychain token round-trip test
