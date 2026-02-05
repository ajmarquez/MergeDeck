# MergeDeck Wiki

MergeDeck is a native SwiftUI app for iOS and macOS that provides fast visibility into the state of your GitHub pull requests, especially CI pass/fail health.

This wiki is designed for two goals:
- Understand how the project works end-to-end.
- Evaluate architecture and technical decisions with clear tradeoffs.

## Current Status
Phase 1 (foundation) is implemented:
- PAT-based authentication
- Keychain-backed token storage
- GraphQL API client with async/await
- Core CI/PR domain models
- Basic connected shell UI
- macOS app sandbox configured with outgoing network entitlement

Not implemented yet:
- Full PR dashboard
- Widgets
- OAuth flow
- Background refresh/notifications

## Read This First
1. [Project Structure](Project-Structure)
2. [How It Works](How-It-Works)
3. [Architecture Decisions](Architecture-Decisions)
4. [Testing and Build](Testing-and-Build)
5. [Next Steps](Next-Steps)

## Scope and Product Direction
Primary user goal:
- Know PR + CI health at a glance, without opening GitHub repeatedly.

MVP direction:
- Reliable auth and data layer first.
- Lightweight app shell second.
- Widget-first visibility in the next phase.
