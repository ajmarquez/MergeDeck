# MergeDeck

MergeDeck is a native iOS and macOS app that keeps you informed about GitHub Pull Requests and CI status at a glance, designed for widgets and quick checks.

## Current Status (Phase 1: Foundation)
Phase 1 is complete locally and on `develop`/`main`. The app currently includes:
- Universal SwiftUI app shell (iOS + macOS)
- PAT-based authentication (Keychain-backed)
- GitHub GraphQL API client with async/await
- Core data models and status parsing
- Minimal “Connected” screen to validate API access
- Basic tests for decoding, auth headers, and keychain round-trip

### Out of Scope (Not Yet Implemented)
- PR dashboard UI and detail views
- Widgets / App Groups
- OAuth login
- Background refresh, caching, notifications

## Requirements
- Xcode 15+ (Swift 6)
- iOS 17.0+ / macOS 14.0+
- GitHub Personal Access Token (PAT)

## Getting Started
1. Open `MergeDeck.xcodeproj` in Xcode.
2. Run the app on iOS simulator or macOS.
3. Paste a GitHub PAT when prompted.
4. Optional: toggle “Use GitHub Enterprise” and supply your GraphQL endpoint.

## Authentication
MergeDeck uses a GitHub Personal Access Token stored in the Keychain.

Recommended scopes for private repo access:
- `repo`

## Project Structure
```
MergeDeck/
├── App/
├── Features/Authentication/
├── Core/Models/
├── Core/Network/
├── Core/Persistence/
├── Shared/
└── (Widgets in future phase)
```

## Development Roadmap
- Phase 2: PR list UI, refresh, settings
- Phase 3: Widgets + App Group
- Phase 4: Polish (errors, caching, background refresh)

## Notes
- Tests were added but not run in this environment.

## License
TBD
