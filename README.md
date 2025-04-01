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

#### For development:
```
flutter run -d chrome
```

#### For web development:
```
# Enable web support if not already enabled
flutter config --enable-web

# Run for web on Chrome
flutter run -d chrome

# Run for web with a specific port
flutter run -d chrome --web-port=8080
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

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
