# RondiTrack

RondiTrack is a Flutter application for viewing stokvel membership information, monthly savings contributions, and contribution statuses.

The project demonstrates role-based data access, reactive state management, repository-based architecture, and automated testing.

## Technology Stack

- Flutter and Dart
- Riverpod for state management
- Freezed for immutable domain models
- Material Design for the user interface
- GitHub Actions for continuous integration

## Features

### Demo Authentication
Users can sign in and out using predefined demonstration accounts.

### Stokvel Dashboard
Authenticated users can view stokvels they belong to, including:
- Stokvel name and description
- Monthly contribution amount
- Membership role
- Personal contribution status

### Stokvel Details
Members can open a stokvel to view contribution information.

### Role-Based Access
- Treasurer: Can view all contributions in their stokvel.
- Chairperson: Can view all contributions in their stokvel.
- Member: Can view only their own contributions.
- Non-member: Cannot access the stokvel's details.

### Loading and Error Handling
The application supports asynchronous data loading, retry actions, and dashboard refresh.

## Demo Accounts

| Name | Email | Role |
|------|-------|------|
| Lerato | lerato@example.com | Treasurer |
| Thabo | thabo@example.com | Member |
| Naledi | naledi@example.com | No membership |

The application uses a shared demonstration password for local testing. These accounts are not production authentication accounts.

## Getting Started

### Requirements

- Flutter SDK
- Dart SDK
- Chrome for web testing
- VS Code or Android Studio

### Installation

Clone the repository:

```bash
git clone https://github.com/Nadio75/RondiTrackApp.git
cd RondiTrackApp/mobile
```

Install dependencies:

```bash
flutter pub get
```

Run the application in Chrome:

```bash
flutter run -d chrome --dart-define-from-file=config/dev.json
```

## Testing

Run all tests:

```bash
flutter test
```

Check for analyzer issues:

```bash
dart analyze
```

Verify Dart formatting:

```bash
dart format --output=none --set-exit-if-changed lib test
```

The test suite includes checks for:
- Demo authentication
- Currency formatting
- Configuration
- Repository permissions
- Asynchronous providers
- Dashboard summaries
- Error recovery
- Session privacy
- Dashboard refresh behaviour

## Project Structure

```text
mobile/
  config/
  lib/
    app/
    core/
      config/
      money/
    features/
      home/
      session/
      stokvel/
    main.dart
  test/
  android/
  ios/
  web/
```

## Architecture

RondiTrack separates responsibilities into presentation, domain, and data layers.

- Presentation: Flutter screens and Riverpod providers
- Domain: Stokvel models, summaries, and repository contracts
- Data: Demonstration users, stokvel records, and fake repository implementations

## Continuous Integration

GitHub Actions automatically runs formatting checks, static analysis, and Flutter tests on repository updates.

## Current Limitations

- The application uses demonstration accounts rather than production authentication.
- Stokvel and contribution records are currently stored in local demonstration data.
- Contribution payments are displayed but not processed.
- The current implementation is a demonstration application and is not intended for managing real funds.

## Repository

https://github.com/Nadio75/RondiTrackApp



## Running RondiTrack in Chrome

### Requirements
- Flutter SDK
- Dart SDK
- Google Chrome

### Run the application

Open PowerShell in the mobile directory:

```powershell
flutter pub get

flutter run -d chrome `
  --dart-define=APP_FLAVOR=dev `
  --dart-define=API_BASE_URL=http://localhost:8080
```

Note: localhost:8080 is a development placeholder.
Configure a working backend URL if API connectivity is required.

### Run automated tests

```powershell
flutter test
```

### Supported stokvel scenarios
- Bitcube: Treasurer role, R500 monthly contribution
- Soweto Teachers: Member role, R750 monthly contribution
- Paid and pending contribution states
- Separate stokvel membership contexts

## Assignment 10.2 — Routes

All authenticated screens use four persistent navigation branches:
Home, Stokvels, Activity, and Profile.

| Address | Screen and tab | Signed out | Not a member | Back goes to |
|---|---|---|---|---|
| `/home` | Home dashboard / Home | Sign-in, then Home | N/A | Home root |
| `/stokvels` | Stokvel list / Stokvels | Sign-in, then list | Only member stokvels listed | Stokvels root |
| `/stokvels/:id` | Stokvel details / Stokvels | Sign-in, then detail | Not found | Stokvel list |
| `/stokvels/:id/cycles/:cycleId` | Cycle details / Stokvels | Sign-in, then cycle | Not found | Parent stokvel |
| `/activity` | Activity feed / Activity | Sign-in, then Activity | Only permitted activity | Activity root |
| `/profile` | Profile / Profile | Sign-in, then Profile | N/A | Profile root |
| `/sign-in` | Demo sign-in / Outside tabs | Remain on sign-in | N/A | Cannot return to protected pages |
| `/join/:code` | Invitation preview / Outside tabs | Sign-in, then invitation | Invalid invite shows not found | Home |

### Navigation decisions

- Each tab preserves its own navigation stack.
- Tapping the active tab returns to that tab's root.
- Switching stokvels changes the route address.
- A cold-start cycle link reconstructs its parent stokvel route.
- Unknown or inaccessible stokvels and cycles display the same not-found state.
- Only internal app addresses may be remembered across sign-in.
- Signed-out users cannot return to protected pages using Back.
- Roles and available actions are determined by membership in the selected stokvel.



## Assignment 10.2 - Implementation and Verification

### Typed navigation

RondiTrack uses `go_router` and `go_router_builder` for typed
navigation.

The four persistent navigation branches are:

- Home
- Stokvels
- Activity
- Profile

The Stokvels branch supports nested stokvel and cycle routes.

Navigation state is managed using `StatefulShellRoute.indexedStack`.

Each branch retains its navigation stack when switching tabs.
Selecting the active tab returns to its root.

### Responsive layouts

The application uses three window-size classes:

| Width | Layout |
|---|---|
| Below 600 dp | Compact layout with bottom navigation |
| 600-839 dp | Medium layout with navigation rail |
| 840 dp and above | Expanded layout with navigation rail and split stokvel list/detail |

Accessibility tests cover compact layouts at 360 dp with
200% text scaling.

### Material 3 themes

The application uses Material 3 with a shared seed color.

Light and dark color schemes are generated using
`ColorScheme.fromSeed`.

A ThemeExtension provides semantic contribution status colors.

Automated tests verify theme configuration and selected
text/background contrast ratios.

### Android deep links

The Android manifest registers the custom URL scheme:

`ronditrack://app`

Example destinations:

| Destination | URL |
|---|---|
| Bitcube details | `ronditrack://app/stokvels/bitcube-001` |
| Bitcube current cycle | `ronditrack://app/stokvels/bitcube-001/cycles/cycle-001` |
| Invitation | `ronditrack://app/join/ABC123` |

Android configuration is included in:

`android/app/src/main/AndroidManifest.xml`

**Verification limitation:** Android runtime deep-link navigation
has not been verified on the emulator. The initial Android build
was blocked by local Gradle/NDK setup delays.

The Android configuration evidence is stored in:

`evidence/android-deep-link-evidence.txt`

The custom scheme is intended for development testing.
Verified HTTPS Android App Links are not configured.

### Build flavors

Android build flavors are configured in
`android/app/build.gradle.kts`.

| Flavor | Application ID |
|---|---|
| dev | `za.co.maja.ronditrack.dev` |
| staging | `za.co.maja.ronditrack.staging` |
| prod | `za.co.maja.ronditrack` |


## Assignment 10.3 - Foundations Capstone

### Overview

Assignment 10.3 extends RondiTrack with payout rotation
functionality, session-aware state management, and a
debug-only persona switcher.

### Payout rotation

The payout rotation feature displays:

- The payout order for a stokvel contribution cycle.
- Each recipient's name and position.
- The payout amount.
- The payout status.
- The next scheduled recipient.

Payout rotation data is represented using immutable domain
models and accessed through a repository interface.

The current implementation uses a fake payout repository
with demonstration data.

### Session-aware state management

Riverpod manages asynchronous payout loading.

The payout provider watches the active user session and
refreshes when the session changes.

Users must be authenticated and have access to the
selected stokvel cycle to view its payout information.

The interface supports loading, empty, error, and
successful data states.

### Development persona switcher

The Profile screen includes a debug-only persona switcher.

Available demonstration personas:

| Persona | Email | Role |
|---|---|---|
| Lerato | lerato@example.com | Treasurer |
| Thabo | thabo@example.com | Member |
| Naledi | naledi@example.com | Non-member |

The shared demonstration password is:

`testpassword123`

The persona switcher is guarded by `kDebugMode` and is
not intended for release builds.

### Running the application

From the `mobile` directory, run:

```powershell
flutter pub get

flutter run -d chrome `
  --dart-define=APP_FLAVOR=dev `
  --dart-define=API_BASE_URL=http://localhost:8080
```


## Assignment 12.1 - Tests, Speed and Privacy

### Baseline

Measured on 24 November 2026, before implementation:

- Flutter tests: 282 passed.
- Static analysis: no issues.
- Executable lines: 2867.
- Covered lines: 1459.
- Uncovered lines: 1408.
- Baseline line coverage: 50.89%.
- Initial CI coverage threshold: 50%.

### Test plan

| Area | Planned verification |
|---|---|
| Notifiers | Loading, success, failure and refresh states |
| Failure mapping | Network, validation, authentication and server failures |
| Home widgets | Loading, empty, success, error and retry states |
| Accessibility | Semantic labels, tap targets and 200% text scaling |
| Golden tests | Stokvel cards in light and dark themes |
| Offline outbox | Persistence, retries and stable idempotency keys |
| Integration | Android application workflow and three consecutive successful runs |
| Localization | English, Sepedi, language switching and persistence |
| Performance | Contributions list rebuilds before and after optimization |
| Privacy | Scrubbing sensitive information from monitoring events |
| Analytics | Approved event names and non-sensitive properties |
| Mutation testing | Deliberately break behaviour, verify failure, restore and retest |
| CI | Formatting, analysis, tests and coverage enforcement |

All existing tests must continue to pass.

Chrome will be used for routine development and browser verification.
Android-specific requirements will be verified separately.

### Privacy

RondiTrack handles personal and financial information.
Monitoring and analytics must follow data minimisation principles
consistent with POPIA.

The following information must not be sent to Sentry or analytics:

- Member names.
- Email addresses.
- Authentication tokens.
- Passwords.
- Payment and contribution amounts.
- Proof-of-payment filenames.
- Sensitive request and response bodies.
- Authentication headers and cookies.

Monitoring events will be scrubbed before transmission.
Analytics will use explicitly approved event names and properties.
Unknown or sensitive properties will be excluded.

Monitoring configuration will be environment-specific.
Production credentials must not be committed to Git.

Locally stored session and financial data must be isolated appropriately
and cleared according to the application's session lifecycle.

The selected application language is a non-sensitive preference and
may be stored using SharedPreferences.

Privacy controls will be verified through automated tests and
deliberate mutation tests.

### Localization plan

The application will support English and Sepedi (Northern Sotho).

- English language code: en.
- Sepedi language code: nso.
- Application messages will use localization resources.
- Language selection will be available from Profile.
- The selected language will persist across application restarts.
- Dynamic messages and plurals will be localized.
- South African currency formatting will be preserved.
- Framework localization limitations will be documented.
- Both languages will be tested during final verification.

### Submission evidence

Evidence will include actual application screenshots, automated test
results, coverage measurements, performance comparisons, privacy
verification and CI results.

Unfinished or unverified requirements will be documented honestly.


## Assignment 12.1 - English and Sepedi Localization

### Implementation

RondiTrack supports English (`en`) and Sepedi (`nso`) through
Flutter's generated localization resources.

- 101 translation entries per language.
- 12 localized feature screens.
- Language selection available on Login and Profile.
- Language preferences persisted using SharedPreferences.
- English is the default language.
- Invalid stored language preferences fall back to English.
- Unsupported languages are rejected.
- Dynamic placeholders preserve member names and financial values.
- Contribution messages support singular and plural forms.
- Navigation labels update when the language changes.
- Compact, medium and expanded layouts support both languages.

### Design decisions

Flutter ARB resources are used instead of maintaining separate
hardcoded translation dictionaries.

Riverpod manages the selected language and updates the application
without requiring a restart.

Only the language code is stored in SharedPreferences. No member
identity, financial information or authentication credentials are
stored by the language preference provider.

The installed Flutter SDK does not provide native Sepedi framework
localizations. Custom delegates therefore provide an English
framework fallback while application-owned labels support Sepedi.

Financial values retain their existing South African Rand formatting
and are not converted when the language changes.

### Automated localization tests

| Test file | Passing tests |
| --- | ---: |
| localization_resources_test.dart | 12 |
| language_provider_test.dart | 7 |
| language_selector_test.dart | 5 |
| real_app_localization_test.dart | 6 |
| Total | 30 |

The tests cover translation resources, dynamic placeholders,
pluralization, persistence, invalid preferences, language switching,
framework compatibility, dark mode, responsive navigation and
large-text rendering.

The real application was tested at compact, medium and expanded
viewport sizes, including 360dp with 200% text scaling.

### Verification results

- Baseline regression suite: 282 passing tests.
- New localization tests: 30 passing tests.
- Combined regression suite: 312 passing tests.
- Static analysis: no issues found.
- Translation resource keys: identical across both languages.

### Running localization tests

```powershell
flutter gen-l10n
dart analyze --fatal-infos
flutter test test/core/localization
flutter test
```

### Remaining localization verification

Manual Chrome testing and actual application screenshots will be
completed during final Assignment 12.1 verification.

Automated tests do not replace native screen-reader testing,
human linguistic review or physical-device verification.


## Assignment 12.1 - Unit Testing Results

The regression suite contains 362 passing tests, compared with
282 tests at the start of the assignment.

| Test category | Tests |
|---|---:|
| Existing regression suite | 282 |
| English and Sepedi localization | 30 |
| Home and payout Mocktail tests | 13 |
| Failure mapping matrix | 33 |
| Populated Home Mocktail tests | 4 |
| Total | 362 |

Static analysis: no issues.

### Dependency decisions

- Mocktail 1.0.5 for repository interaction testing.
- Alchemist 0.14.1 for golden testing.
- Integration test package supplied by the Flutter SDK.
- shared_preferences_android 2.5.4 retained in the lockfile
  to satisfy the minimum dependency age requirement.
- No permanent dependency override is required.

### Verified notifier mutation

The member ID filter in HomeSummariesNotifier was temporarily removed.

Before mutation: four tests passed.
During mutation: two passed and two failed.
After restoration: four tests passed.

The failing tests were:

- Home uses own contribution status not another member status.
- Missing own contribution does not expose another member status.

Both failures demonstrated that the tests detect exposure of
another member's contribution status.

The original production code was restored and verified.

Evidence is stored under submission_evidence in the
RondiTrack_Assignment_12_1_Evidence/mutations directory.
