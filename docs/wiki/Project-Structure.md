# Project Structure

## Top-Level Layout
- `MergeDeck/`
  - App and source code
- `MergeDeckTests/`
  - Unit tests (Swift Testing)
- `MergeDeckUITests/`
  - UI tests
- `Makefile`
  - Build/test commands via `xcodebuild` + `xcbeautify`
- `AGENTS.md`
  - Operational guidance for contributors/agents

## Source Layout
- `MergeDeck/App/`
  - `MergeDeckApp.swift`: app entry point
  - `ContentView.swift`: root gate (auth vs connected shell)
  - `ConnectedView.swift`: signed-in shell screen
  - `ConnectedViewModel.swift`: shell state + refresh action

- `MergeDeck/Features/Authentication/`
  - `AuthView.swift`: PAT + optional enterprise endpoint input
  - `AuthViewModel.swift`: token save + validation workflow

- `MergeDeck/Core/Models/`
  - `PullRequest.swift`, `Repository.swift`, `CheckRun.swift`
  - `CIStatus.swift`, `CheckStatus.swift`, `CheckConclusion.swift`

- `MergeDeck/Core/Network/`
  - `GitHubAPIClient.swift`: actor-based GraphQL client
  - `GraphQLQueries.swift`: query definitions
  - `APIError.swift`: typed network/auth/decode errors

- `MergeDeck/Core/Persistence/`
  - `TokenStore.swift`: abstraction for token persistence
  - `KeychainManager.swift`: concrete keychain implementation

- `MergeDeck/Shared/Extensions/`
  - `CIStatus+Color.swift`: UI-specific rendering mapping
  - `View+PlatformInput.swift`: iOS/macOS input behavior helpers

## Why This Shape
- Keeps product features (`Features/`) separate from generic domain/network concerns (`Core/`).
- Enables testability by injecting protocols (`TokenStore`) into view models and API client.
- Avoids UI dependencies inside core business models.
