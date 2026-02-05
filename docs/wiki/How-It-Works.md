# How It Works

## Runtime Flow
1. App launches to `ContentView`.
2. `ContentView` checks keychain for an existing token.
3. If no token: show `AuthView`.
4. If token exists: show `PRListView`.
5. `PRListView` loads PRs, supports pull-to-refresh, and auto-refreshes on configured interval.
6. Selecting a PR opens `PRDetailView` for full check run visibility and GitHub links.

## Authentication Flow
1. User enters PAT.
2. Optional: user enables enterprise mode and sets GraphQL endpoint.
3. `AuthViewModel` saves token to keychain.
4. Token is validated by executing `fetchMyPullRequests()`.
5. On failure, token is deleted and error is surfaced.

## Data Flow
- View layer triggers async action in view model.
- View model creates `GitHubAPIClient` with:
  - base URL
  - `TokenStore` dependency
- `GitHubAPIClient` builds GraphQL request and fetches response.
- Decoding maps GitHub GraphQL types into app domain models.

## Settings Flow
- `SettingsView` controls:
  - refresh interval (5/15/30)
  - GitHub.com vs Enterprise endpoint
- Endpoint normalization is centralized in `GitHubEndpoint.resolve(...)`.
- `PRListView` uses settings values at refresh time.

## CI Status Mapping
- PR rollup states are normalized into `CIStatus`.
- Check contexts are normalized into unified `CheckRun` records.
- Core status values are model-level; color/icon rendering is UI-layer.

## macOS Networking
- App Sandbox is enabled.
- `Outgoing Connections (Client)` entitlement is enabled.
- Without that entitlement, macOS blocks network requests even with correct code.
