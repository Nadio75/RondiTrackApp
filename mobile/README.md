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
