# Architecture Decisions

This page documents why technical decisions were made and how to evaluate them.

## 1) MVVM + SwiftUI
Decision:
- Use SwiftUI views with `ObservableObject` view models.

Why:
- Fast iteration for UI + straightforward state handling.
- Keeps side effects (network/keychain) out of view structs.

Tradeoff:
- More files and indirection than placing logic directly in views.

## 2) Actor-based API Client
Decision:
- `GitHubAPIClient` is an `actor`.

Why:
- Provides a concurrency-safe boundary for request building/decoding.
- Aligns with Swift concurrency direction.

Tradeoff:
- Slightly more friction with isolation rules and defaults.

## 3) Dependency Injection via Protocols
Decision:
- Introduce `TokenStore` protocol and inject into client/view models.

Why:
- Decouples keychain implementation from business logic.
- Enables deterministic tests and future alternate stores.

Tradeoff:
- Slightly more setup code at call sites.

## 4) Keep Core Models UI-Agnostic
Decision:
- `CIStatus` core model contains semantic state.
- UI color mapping lives in `CIStatus+Color` extension in `Shared/Extensions`.

Why:
- Prevents `SwiftUI` dependencies from leaking into core domain.
- Reduces actor-isolation and cross-layer coupling issues.

Tradeoff:
- One extra extension file to discover UI styling behavior.

## 5) OAuth Device Flow + PAT Fallback
Decision:
- Add OAuth Device Flow as primary auth path, keep PAT as fallback.

Why:
- Supports organizations where PAT usage is restricted.
- Works on GitHub.com without browser callback handling complexity in-app.
- Preserves compatibility for environments that still rely on PAT.

Tradeoff:
- Requires GitHub OAuth App Client ID configuration.
- Device-flow UX adds one extra verification step for users.

## 6) GitHub GraphQL API
Decision:
- Use GraphQL query that fetches viewer PRs + status rollups.

Why:
- Single request for rich PR + CI shape.
- Better fit for nested status contexts.

Tradeoff:
- Query/decoder complexity is higher than simple REST endpoints.

## 7) Makefile + xcbeautify
Decision:
- Standardize local commands in `Makefile`, pretty output through `xcbeautify`.

Why:
- Consistent dev commands and cleaner logs.
- Easier onboarding and repeatable build/test steps.

Tradeoff:
- One more tooling dependency for best output formatting.

## 8) macOS App Sandbox Enabled
Decision:
- Keep sandbox on and explicitly enable outgoing network entitlement.

Why:
- Correct security posture for shipping macOS app.
- Avoids hidden runtime failures due to blocked network access.

Tradeoff:
- Entitlement management required during capability changes.
