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
