# Updatable Ticker

A flutter widget for a smoothly scrolling text ticker that integrates text updates cleanly so that scrolling is glitch-free and uninterrupted. The main feature is that all text updates take place in the area of the text buffer that is not yet visible, so that the text does not disrupt (glitch effect) during display.

# Getting Started

Add this to your package's pubspec.yaml file:

```
dependencies:
  updatable_ticker: ^1.0.5
```

# Usage 

Then you just have to import the package with
```
import 'package:updatable_ticker/updatable_ticker.dart';
```

# Properties

The package has a few properties to configure, it's simple.

```
String updatableText;       // (updatable) text
TextStyle style;            // text fontFamily, size, and color
double pixelsPerSecond;     // speed in pixels per second (60 frames per second)
bool forceUpdate;           // true: if a text is updated, display it without delay, 
                            // false: integrate new text smoothly into ticker without causing disruptions when scrolling
bool center;                // true: vertical centering of text
String separator;           // add this text to the end of line as separator between texts
```

# Example
This is a small example: 
```
import 'package:flutter/material.dart';
import 'package:updatable_ticker/updatable_ticker.dart';

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => ExamplePageState();
}

class ExamplePageState extends State<ExamplePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SizedBox(
          width: 800.0,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: SizedBox(
                  height: 100.0,
                  child: UpdatableTicker(
                    key: ValueKey(
                      'ExamplePage',
                    ),
                    updatableText: 'This is a sample Text',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                    pixelsPerSecond: 80,
                    forceUpdate: false,
                    separator: '    ////    ',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

But you need a little bit more if you want to update the text automatically.
First of all, you need a source of text which updates from time to time.
This variable is required for the connection with the updatableText property.

In my example, I have randomly timed the actualization of text data with a Timer.periodic, which generates demo text (lorem ipsum) with random word lengths.
The UpdatableTicker will rebuild when alignment, width or font size changes.
To do this, you must wrap the UpdatableTicker with OrientationBuilder, SizeChangedLayoutNotifier and a ValueKey with this data as the key for UpdatableTicker.

A nice example how to do this can you find on my Github Page (part of updatable_ticker repo) here: https://github.com/eventcatcher/updatable_ticker/tree/main/updatable_ticker_sample

# Feedback

Please feel free to [give me any feedback](https://github.com/eventcatcher/updatable_ticker/issues) helping support this plugin !