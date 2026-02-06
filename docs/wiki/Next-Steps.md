# Next Steps

## Phase 2 (Recommended Immediate Work)
1. Complete UX polish for auth, PR list, detail, and settings flows.
2. Improve failure/empty states with retry actions and clearer diagnostics.
3. Add filtering/sorting controls (for example, failing first or recently updated).
4. Validate macOS and iOS interaction parity for refresh and deep-link behavior.
5. Add clear setup docs for GitHub OAuth App client configuration.

## Phase 3
1. Add WidgetKit extension (small/medium/large + lock screen).
2. Add App Group persistence for widget data handoff.
3. Build timeline refresh strategy and fallback states.

## Architecture Hardening
1. Introduce a repository layer between view models and API client.
2. Add cache policy and basic offline behavior.
3. Add explicit DTO-to-domain mapper unit tests for edge cases.

## Product and Reliability
1. Add user-facing error states for auth, rate limit, and empty PR data.
2. Add logging hooks (at least debug-level request/response context without secrets).
3. Define retry/backoff behavior for transient failures.

## Evaluation Checklist
Use this to evaluate architecture quality:
- Is domain logic independent from UI frameworks?
- Are dependencies injected and mockable?
- Are async boundaries actor-safe and explicit?
- Can data flow be understood in one pass from view to network and back?
- Are build/test commands deterministic across contributors?
