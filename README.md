# MergeDeck

MergeDeck is a native iOS and macOS app that keeps you informed about GitHub Pull Requests and CI status at a glance, designed for widgets and quick checks.

## Current Status
Current build includes:
- Universal SwiftUI app shell (iOS + macOS)
- OAuth Device Flow authentication (GitHub.com by default)
- PAT authentication fallback (Keychain-backed)
- GitHub GraphQL API client with async/await
- Core data models and status parsing
- PR list, detail, and settings screens
- Basic tests for decoding, auth headers, and keychain round-trip

### Out of Scope (Not Yet Implemented)
- Widgets / App Groups
- Background refresh, caching, notifications

## Requirements
- Xcode 15+ (Swift 6)
- iOS 17.0+ / macOS 14.0+
- GitHub Personal Access Token (PAT)

## Getting Started
1. Open `MergeDeck.xcodeproj` in Xcode.
2. Run the app on iOS simulator or macOS.
3. In auth screen, choose:
   - `OAuth`: provide OAuth App Client ID and complete device verification.
   - `Personal Access Token`: paste PAT.
4. Optional: toggle “Use GitHub Enterprise” and supply your enterprise base URL.

## Authentication
MergeDeck supports:
- OAuth Device Flow (recommended for GitHub.com and enterprises that block PAT usage).
- Personal Access Token (fallback).

Access token is stored in Keychain.

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
