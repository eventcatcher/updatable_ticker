# Updatable Ticker Project

A flutter widget for a smoothly scrolling text ticker that integrates text updates cleanly so that scrolling is glitch-free and uninterrupted. The main feature is that all text updates take place in the area of the text buffer that is not yet visible, so that the text does not disrupt (glitch effect) during display.

![ticker-demo](https://github.com/user-attachments/assets/6e6fe6b7-72a2-4b24-ac7b-80827f504a7b)

## Project Structure

This repository contains two main components:

### 1. Updatable Ticker Library (`updatable_ticker_library`)

A pure Flutter library that provides a customizable ticker widget for animated, updatable text transitions. 

### 2. Updatable Ticker Sample App (`updatable_ticker_sample`)

A comprehensive sample application that demonstrates how to use the Updatable Ticker library:

- **Basic Demo**: A randomly timed actualization of generated demo text (lorem ipsum) with random word lengths.
The UpdatableTicker will rebuild when alignment, width or font size changes.
To do this, the UpdatableTicker is wrapped with OrientationBuilder, SizeChangedLayoutNotifier and a ValueKey.
You can control speed and fontsize with sliders.


## Getting Started

### Using the Library

Add this to your package's `pubspec.yaml` file for local testing:

```yaml
dependencies:
  updatable_ticker:
    path: path/to/flutter_ticker_library
```

or if loading from pub.dev:

```yaml
dependencies:
  updatable_ticker: ^1.0.6
```

### Running the Sample App

```bash
cd updatable_ticker_sample
flutter pub get
flutter run
```

## License

This project is licensed under the BSD 3-Clause License - see the LICENSE file for details.
