# LifeBliss App

A beautiful Flutter application with a clean UI featuring a gradient design. LifeBliss is designed to provide a smooth user experience with a modern interface.

## Description

LifeBliss is a Flutter-based application that showcases:
- Beautiful gradient backgrounds
- Responsive design that adapts to different screen sizes
- Smooth transitions between screens
- Modern Material Design 3 implementation
- Web support for cross-platform accessibility

## Prerequisites

- Flutter SDK (>=3.2.3)
- Dart SDK (>=3.2.3)
- VS Code with Flutter extensions
- Chrome or another modern browser (for web development)

## Getting Started

### Installation

```
flutter pub get
```

### Running the app

#### On a connected device/emulator (Android/iOS):
```
# Make sure a device is connected or an emulator is running
flutter run
```

#### For web development:
```
# Enable web support if not already enabled (run only once)
# flutter config --enable-web

# Run for web on Chrome
flutter run -d chrome

# Optional: Run for web with a specific port
# flutter run -d chrome --web-port=8080
```

#### Build for web:
```
# Build a web release
flutter build web

# Build with specific optimizations
flutter build web --release --web-renderer html
```

## Project Structure

The project follows a clean architecture approach:
- `lib/core`: Core utilities and constants
- `lib/data`: Data sources and repositories
- `lib/domain`: Business logic and entities
- `lib/presentation`: UI components (pages, widgets) and state management

## Features

- Splash screen with loading animation
- Home page with responsive design
- Smooth navigation between screens
- Web-optimized UI

## Development

This project follows Test-Driven Development (TDD) principles. Please ensure you write tests for your code *before* implementing the functionality.

To run the tests:
```
flutter test
```

### Code Coverage

The project includes test coverage tooling to help maintain high quality code. To run tests with coverage and generate a report:

```bash
# Using the convenience script
./run_coverage.sh

# Or manually
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

This will:
1. Run all tests with coverage tracking
2. Generate an HTML report in the `coverage/html` directory
3. Open the report in your default browser

The coverage report helps identify areas of code that need better test coverage.

### Test Structure

The project has a comprehensive test structure:

```
test/
├── domain/          # Tests for business logic
│   └── services/    # Tests for services like ColorService
├── integration/     # End-to-end integration tests
├── mocks/           # Mock implementations for testing
├── presentation/    # UI component tests
│   └── pages/       # Tests for screen pages
├── utils/           # Test utilities and helpers
└── widget_test.dart # Main widget tests
```

For metrics and current test coverage status, see `test/metrics.md`.

## Contributing
