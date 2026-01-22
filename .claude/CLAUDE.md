# Claude Code Preferences

## strangeattractors GitHub Contributors

| Name | GitHub |
|------|--------|
| AdB | @adbrebs |
| Joris | @avocaddo |
| Anthony | @achsvg |
| Tomohiro | @tikutikutiku |
| AlexD | @HoldenCaulfieldRye |

## GitHub Issue Formatting (strangeattractors repos)

- Use `- [ ]` checkboxes for each item
- Use `**Bold title**: description` format
- Group by priority (P0, P1, P2, P3)
- Wording tweaks in separate section with priority inline

Example:
```markdown
## P1

- [ ] **Feature name**: Description

## P2

- [ ] **Another feature**: Description
  - Sub-bullet details if needed

## Wording tweaks

- [ ] **P2**: Description of wording change
```

---

# YouSquared Backend Project Context

## Overview
This repository (`clone-backend`) contains the backend infrastructure and API services for the YouSquared AI assistant platform. It is a monorepo-style structure housing the main API service, Google Cloud Functions, infrastructure configuration (Terraform/Tofu), and utility scripts.

The code of our iOS frontend is located in `/Users/alexdalyac/git/YouSquared-ios`, while the code of the backend is in `/Users/alexdalyac/git/clone-backend`.

### Key Components
- **`api-service/`**: The core application. A Python FastAPI service handling voice calls, user management, and AI interactions.
- **`gcp_functions/`**: Standalone Google Cloud Functions (e.g., `fix_mp3_vbr`, `wav_to_mp3`) for specific media processing tasks.
- **`infra/`**: Infrastructure as Code (IaC) using Terraform/OpenTofu for GCP resource management.
- **`scripts/`**: Utility scripts for database provisioning, testing, and maintenance.

## General

At the beginning of a task, before making any changes, please explain what you intend to do and get approval.

Note that the v3 folder is the latest version of the backend, you can ignore v1 and v2.

We are using a python env located in `.venv/bin/python`

Don't handle git operations yourself, unless explicitly asked.

Don't create the alembic migration files yourself, I will auto-generate them myself later.

It's important to always work with this DB: `DATABASE_URL=postgresql+asyncpg://yousquared:yousquared@localhost:5432/yousquared`

## Tests

You should first cd to `api-service` to run the tests.

pytest should be used with these arguments:
`--asyncio-mode=auto -n auto -o "testpaths=app/v3/tests" --dist loadgroup`

and with these environment variables set:
`GRPC_VERBOSITY=ERROR;SERVER_ENV=int;DATABASE_URL=postgresql+asyncpg://yousquared:yousquared@localhost:5432/yousquared`

(you can adjust to run pytest on specific files/functions as needed, no need to always run all tests)

Note that the tests in `tests/calls` are particularly slow, so usually you don't want to run them.

Example:
```bash
cd api-service && export GRPC_VERBOSITY=ERROR && export SERVER_ENV=int && export DATABASE_URL=postgresql+asyncpg://yousquared:yousquared@localhost:5432/yousquared && ../.venv/bin/python -m pytest --asyncio-mode=auto -n auto -o "testpaths=app/v3/tests" --dist loadgroup app/v3/tests/test_referrals.py
```

## Coding Preferences

Do not produce strings broken over multiple lines, unless absolutely necessary.

For example, instead of:
```python
query = ("SELECT * "
         "FROM table "
         "WHERE condition = true")
```
prefer:
```python
query = "SELECT * FROM table WHERE condition = true"
```

Don't use f-strings for logging, instead use % formatting.

---

# YouSquared iOS Development Guide

YouSquared is an AI secretary iOS app built with SwiftUI targeting iOS 16+. This guide captures essential patterns and workflows for this codebase.

## Architecture Overview

### Feature-Based Structure
Code is organized by features under `YouSquared/Features/` (Account, Calendar, Contacts, Interactions, Login, OnBoarding, Premium, Profile, Referrals, Secretaries). Each feature contains Models, ViewModels, Views, and Services subdirectories following MVVM.

### Shared Layer (`YouSquared/Shared/`)
- **Networking/**: `NetworkManager` handles all HTTP requests with Firebase Bearer token authentication. API routes defined in `APIRoutes.swift` using enum-based pattern with `baseURL` computed from build configuration
- **Databases/DataStores/**: Singleton stores (`UserDataStore.shared`, `ContactsDataStore.shared`) manage global state using `@Published` properties and CoreData persistence
- **Services/**: Business logic services (`AppAuthManager`, `LiveKitService`, `VAPIService`, etc.) coordinate between repositories and UI
- **Services/Repositories/**: Data layer (`UserRepository`, `AssistantRepository`, etc.) handle API calls via `NetworkManager`

### Key Singletons
- `UserDataStore.shared`: Global user state, loads from CoreData then fetches from backend
- `ContactsDataStore.shared`: Manages contacts synchronization
- `DeepLinkRouter.shared`: Handles deep linking via `@Published var pending: DeepLink?`
- `NetworkManager.shared`: Centralized HTTP client with Firebase token injection

### Navigation Pattern
- Tab-based navigation via `YouSquaredTabView` with `TabNavigationState` controlling selected tab and overlay states
- Feature-specific routers like `InboxRouter` use SwiftUI `NavigationPath` for hierarchical navigation
- Deep links flow through `DeepLinkRouter.handleAppsFlyer()` then `emit()` to set `pending` deep link

## Environment & Build Configuration

### Build Schemes
Four schemes target different environments:
- **DEBUG** (dev/local): Requires `.env` file in `YouSquared/Resources/` with `BASE_URL` pointing to tunnel (ngrok)
- **INT**: Integration environment, also needs `.env` with tunnel URL
- **STAGING**: Pre-production, requires `.env` configuration
- **PROD**: Production, uses Remote Config for base URL (no `.env` needed)

### Environment Setup for Local/INT/STAGING
1. Set up public tunnel (ngrok) per [backend repo instructions](https://github.com/strangeattractors/clone-backend)
2. Create `YouSquared/Resources/.env`:
   ```
   BASE_URL=https://your-tunnel-address.ngrok.io
   ```
3. Select appropriate scheme in Xcode (YouSquared, YouSquared INT, YouSquared STAGING)

### Configuration Files
- Firebase configs: `YouSquared/Resources/Firebase/GoogleService-Info-{Dev,Int,Staging,Prod}.plist` selected per scheme
- Build configurations use conditional compilation: `#if DEBUG || INT || STAGING`
- `AppEnvironment` detects TestFlight vs App Store vs Debug builds

## Development Workflows

### Running the App
1. Select target device/simulator in Xcode
2. Choose scheme (YouSquared for DEBUG, YouSquared INT/STAGING/PROD for others)
3. For non-PROD: Verify `.env` exists with valid `BASE_URL`
4. Cmd+R to build and run

### Testing
- **Unit tests**: `fastlane test` or Xcode Test Navigator
- **UI tests**: `fastlane ui_test_fresh` (resets simulator, sets location to Cupertino, runs with snapshot args)
- Manual simulator setup for UI tests:
  ```bash
  xcrun simctl bootstatus 'iPhone 16 Pro' -b
  xcrun simctl uninstall 'iPhone 16 Pro' ai.yousquared
  xcrun simctl privacy 'iPhone 16 Pro' reset all
  ```

### Code Formatting & Linting
- **SwiftFormat**: Auto-formats Swift code according to `.swiftformat` configuration
  - Run: `swiftformat .` from project root
  - Automatically fixes formatting issues (spacing, line breaks, etc.)
- **SwiftLint**: Checks for code style and convention violations per `.swiftlint.yml`
  - Run: `swiftlint` from project root
  - Reports warnings and errors but doesn't auto-fix
- **Best Practice**: Run both tools before committing code changes:
  ```bash
  swiftformat . && swiftlint
  ```
- Both tools respect their respective config files in the project root

### CI/CD
- Weekly releases to external TestFlight
- No push to main allowed (only for hotfixes)
- Push should be done to the current sprint branch `sprint/X.Y` only

### Debugging & Logging
- Use `log` (SwiftLog or custom wrapper) with appropriate levels:
  - `.debug("message")` - For development/debugging information (e.g., `log.debug("Added phone: \(phone)")`)
  - `.verbose("message")` - For detailed tracing information (e.g., `log.verbose("Received secretary deep link notification")`)
  - `.error("message")` - For errors and failures (e.g., `log.error("Failed to fetch referral data: \(error)")`)
  - `.warning("message")` - For warnings that don't halt execution
- **Logging Best Practices**:
  - Include context in log messages (variable values, state)
  - Use string interpolation for dynamic values
  - Log errors with error details when catching exceptions
  - Use appropriate log level based on severity
- Network debugging: Check `NetworkManager` request/response logs (verbose mode enabled)

## Code Patterns & Conventions

### ViewModels
- Use `ObservableObject` with `@Published` properties for state
- Inject repositories via initializer with default parameters for testing:
  ```swift
  init(userRepository: UserRepository = UserRepository()) {
      self.userRepository = userRepository
  }
  ```
- Handle async operations in `Task { }` blocks, updating UI on `@MainActor` when needed
- **Avoid marking entire classes or methods as `@MainActor`** - especially in ViewModels that make network calls, as this is unnecessary and can block the main thread

### SwiftUI & UI Conventions
- **File Organization**: Keep files focused and concise
  - Avoid multiple structs in the same file, especially for UI views
  - Ideally one view per file
  - Move shared reusable views to `Shared/Views/` when possible
- **Previews**: Every UI view should include a preview:
  ```swift
  struct TeachYourAIView_Previews: PreviewProvider {
      static var previews: some View {
          let mock = PersonalInfoViewModel()
          TeachYourAIView(viewModel: mock)
      }
  }
  ```
- **View Responsibilities**:
  - **No network code in views** - strictly forbidden, move to ViewModels
  - Keep logic minimal in views - delegate to ViewModels
  - Avoid recreating helper functions - reuse existing ones (e.g., `ContactsDataStore.formatPhoneNumber()`)
- **Colors**: Use semantic color names
  - Use `Color.primaryText` instead of `Color.primary`
  - Use `Color.secondaryText` instead of `Color.secondary`
  - `Color.bg` - Background for most views
  - `Color.accent` - Accent color
  - `Color.border` - Border color
  - `Color.error` - Red color for errors
- **Typography**: Use Theme font modifiers instead of `.font()` API:
  ```swift
  // ✅ Correct - Theme modifiers
  Text("Title").title1S()
  Text("Body").bodyR()
  Text("Caption").captionR()

  // ❌ Avoid - Direct .font() calls
  Text("Title").font(.title)
  ```
  Available modifiers: `.title1S()`, `.title2M()`, `.title3S()`, `.title3M()`, `.headlineM()`, `.bodyS()`, `.bodyRI()`, `.bodyR()`, `.subheadlineR()`, `.footnoteM()`, `.footnoteS()`, `.footnoteRU()`, `.footnoteR()`, `.captionR()` (S=Semibold, M=Medium, R=Regular)
- **Localization**: Strings containing underscores (e.g., `"welcome_message"`) are localized keys - do not modify these strings, modify localization files instead
- **Spacing**: Standard padding is `16` throughout the app - use this value consistently
- **Button Styles**: Use custom button modifiers instead of default SwiftUI styling:
  - `.primaryButton()` - Primary action buttons
  - `.secondaryButton()` - Secondary action buttons
  - `.tertiaryButton()` - Tertiary action buttons
  - `.primaryButtonNoPadding()` - Primary buttons without default padding
- **Icons**: Use Solar icons from Assets catalog instead of SF Symbols:
  ```swift
  // ✅ Correct - Solar icon from assets
  Image("plus")
      .resizable()
      .frame(width: 36, height: 36)
      .foregroundColor(Color.accent)

  // ❌ Avoid - SF Symbols
  Image(systemName: "plus")
  ```

### Repository Layer
- Repositories encapsulate API calls, mapping routes from `APIRoutes` enum
- Use `NetworkManager.shared.getRequest()` / `postRequest()` for HTTP
- Return decoded models directly, throw `APError` for failures

### Networking
- All authenticated requests automatically inject Firebase ID token via `setFirebaseBearer()`
- Skip auth with `skipAuth: true` parameter for public endpoints
- API versioning: URLs include `/v3/` (see `APIRoutes.SERVER_VERSION`)

### State Management
- Global app state: Singleton `DataStore` classes with `@Published` properties
- Feature state: ViewModels as `@StateObject` in views
- Navigation state: Feature-specific router classes (e.g., `InboxRouter`)

### Analytics
- Events logged via Mixpanel integration (see `analytics.md` for comprehensive event glossary)
- Screen tracking: `.logScreen("screen_name")` view modifier
- User properties: Set via `people.set` and super properties in Mixpanel
- **Event Tracking**:
  - `AnalyticsManager.shared.trackUserAction()` - For user-initiated actions (button clicks, interactions)
  - `AnalyticsManager.shared.trackEvent()` - For generic system events (state changes, background processes)
  - **Always add new events to `analytics.md`** when using `trackUserAction()` or `trackEvent()` to maintain the event glossary

### Error Handling
- Custom `APError` enum for typed errors
- ViewModels expose `@Published var alertItem: AlertItem?` for user-facing errors
- Network errors logged with `.error()` level

## Integration Points

### Third-Party Services
- **Firebase**: Auth (token management), Cloud Messaging (push), Remote Config (prod base URL), Analytics
- **RevenueCat**: Premium subscription management, login via `UserDataStore.loginToRevenueCat()`
- **Mixpanel**: Analytics and session replay
- **OneSignal**: Push notification service (separate extension: `OneSignalNotificationServiceExtension`)
- **LiveKit/VAPI**: Real-time voice communication services for AI secretary

### Backend Communication
- REST API base URL determined by build configuration (`.env` or Remote Config)
- All endpoints require Firebase authentication except explicitly skipped
- See `apis.md` for detailed endpoint documentation and payloads

### Device Permissions
- Contacts: Tracked via `UserDataStore` properties (`isContactPermissionGranted`, `isContactPermissionLimitedGranted`)
- Notifications: Requested during onboarding, status tracked in analytics
- Microphone: Required for voice features (LiveKit/VAPI services)

## Critical Files
- `YouSquared/YouSquaredApp.swift`: App entry point, Firebase/analytics initialization, permission handling
- `YouSquared/YouSquaredTabView.swift`: Main tab navigation and routing logic
- `YouSquared/DeepLinkRouter.swift`: Deep linking coordination (AppsFlyer integration)
- `YouSquared/Shared/Networking/NetworkManager.swift`: HTTP client with auth
- `YouSquared/Shared/Networking/APIRoutes.swift`: API endpoint definitions
- `YouSquared/Shared/Databases/DataStores/UserDataStore.swift`: Global user state management
- `README.md`: Setup instructions and backend configuration

## Common Tasks

**Adding a new feature**:
1. Create directory under `Features/` with Models, ViewModels, Views subdirectories
2. Add repository in `Shared/Services/Repositories/` and routes in `APIRoutes.swift`
3. **Always wrap new features with RemoteConfigHelper flag** for safe rollout:
   ```swift
   if RemoteConfigHelper.shared.hasReferrals() {
       // new feature code
   } else {
       // keep existing code as fallback
   }
   ```
   - Add new flag method in `RemoteConfigHelper` (e.g., `hasNewFeature()`)
   - Wrap all new feature UI and logic with the flag check
   - Always include fallback to existing behavior
   - This allows remote enable/disable without app updates

**Adding analytics event**: Reference `analytics.md` glossary, use Mixpanel SDK to track. Include user properties when relevant.

**Switching environments**: Change scheme in Xcode (Product > Scheme), ensure `.env` configured for non-PROD.

**Adding deep link**: Add case to `DeepLink` enum, handle in `DeepLinkRouter.handleAppsFlyer()`, consume in appropriate view.
