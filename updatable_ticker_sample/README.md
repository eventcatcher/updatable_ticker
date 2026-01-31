# Updatable Ticker Sample

Example App for Flutter package UpdatableTicker

# Usage 

First of all, you need a source of text which updates from time to time.
This variable is required for the connection with the updatableText property.

In my example, I have randomly timed the actualization of text data with a Timer.periodic, which generates demo text (lorem ipsum) with random word lengths.
The UpdatableTicker will rebuild when alignment, width or font size changes.
To do this, you must wrap the UpdatableTicker with OrientationBuilder, SizeChangedLayoutNotifier and a ValueKey with this data as the key for UpdatableTicker.

This is a nice example how to do this.

A demo video of how the ticker can look like, you can find here on my Github page: https://github.com/eventcatcher/updatable_ticker?tab=readme-ov-file#updatable-ticker-project

# Feedback

Please feel free to [give me any feedback](https://github.com/eventcatcher/updatable_ticker/issues) helping support this plugin !