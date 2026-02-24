import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:updatable_ticker/src/led/led_bitmap.dart';
import 'package:updatable_ticker/src/led/led_matrix_painter.dart';

/// class for a smoothly scrolling text ticker that integrates text updates cleanly so that scrolling is glitch-free and uninterrupted.
class UpdatableLedTicker extends StatefulWidget {
  /// text (updatable from parent)
  final String updatableText;

  /// number of modules
  final int modules;

  /// use proportional font with different glyph widths
  final bool useProportionalFont;

  /// led size
  final double ledSize;

  /// led gap
  final double ledGap;

  /// on color
  final Color onColor;

  /// off color
  final Color offColor;

  /// speed in pixels per second (60 frames per second)
  final double pixelsPerSecond;

  /// true: if a text is updated, display it without delay, false: integrate new text smoothly into ticker without causing disruptions when scrolling
  final bool forceUpdate;

  /// add this text to the end of line as separator between texts
  final String separator;

  /// the properties to configure, a few of them with defaults
  const UpdatableLedTicker({
    required this.updatableText,
    this.modules = 21,
    this.useProportionalFont = false,
    this.ledSize = 10.0,
    this.ledGap = 1.0,
    this.onColor = Colors.red,
    this.offColor = const Color(0xFFdddddd),
    this.pixelsPerSecond = 30.0,
    this.forceUpdate = false,
    this.separator = '',
    super.key,
  });

  @override
  State<UpdatableLedTicker> createState() => _UpdatableLedTickerState();
}

class _UpdatableLedTickerState extends State<UpdatableLedTicker>
    with SingleTickerProviderStateMixin {
  final int loopsToFill = 3;
  final double securitySecSpacing =
      3; // minimum of seconds before new text starts

  List nextUpdateProperties = [];
  String firstText = '';
  String secondText = '';
  String renderedText = '';
  LedBitmap? renderedTextBitmap;

  double securityPxSpacing = 50;
  double containerWidth = 0.0;
  double textHeight = 30.0;
  double secondTextWidth = 0.0;
  double posToUpdate = 0.0;
  double posSecondTextStarts = -1;
  double offset = 0.0;

  int minRepeatCountSecondText = 1;

  late final Ticker ticker;

  @override
  void initState() {
    super.initState();

    firstText = '';
    secondText = widget.updatableText + widget.separator;
    ticker = Ticker(onTick)..start();
  }

  @override
  void didUpdateWidget(UpdatableLedTicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (containerWidth > 0) {
      refreshSecuritySpacing();
      textUpdateReceived();
    }
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  void refreshSecuritySpacing() {
    securityPxSpacing = widget.pixelsPerSecond * securitySecSpacing;
    if (securityPxSpacing > containerWidth / 3) {
      securityPxSpacing = containerWidth /
          3; // max security spacing is third of container width (to have enough time to pre-generate rendering data)
    }
  }

  void textUpdateReceived() {
    if ((widget.updatableText + widget.separator) != secondText) {
      if (widget.forceUpdate == true) {
        firstText = '';
        secondText = widget.updatableText + widget.separator;
        List updateProperties = updateRenderDataList(withOffset: false);
        updateRenderingProperties(updateProperties);
        replaceTextBufferWithNewText();
      } else {
        bool firstTextIsEmpty = firstText.isEmpty;

        if (firstTextIsEmpty) {
          firstText = secondText;
        }
        String secondTextBeforeUpdate = secondText;
        secondText = widget.updatableText + widget.separator;

        bool secondTextVisible =
            offset.abs() >= (posSecondTextStarts - securityPxSpacing);
        if (firstTextIsEmpty == true ||
            (!firstTextIsEmpty &&
                posSecondTextStarts >= 0 &&
                !secondTextVisible)) {
          List updateProperties = updateRenderDataList();
          updateRenderingProperties(updateProperties);
        } else {
          // If firstText and secondText are running, then it's only possible to replace secondText with the new text and re-render it directly, as long as no part of the new text is visible.
          // If part of the secondText is already visible, it's required to wait for the switch until only secondText is displayed (set firstText = ‘’).
          // For this, nextUpdateProperties will contain the prepared rendering variables.

          firstText = secondTextBeforeUpdate;
          nextUpdateProperties = updateRenderDataList(withOffset: false);
        }
      }
    }
  }

  void updateRenderingProperties(List updateProperties) {
    renderedText = updateProperties[1];
    posToUpdate = updateProperties[2];
    posSecondTextStarts = updateProperties[3];
    minRepeatCountSecondText = updateProperties[4];
    secondTextWidth = updateProperties[5];

    nextUpdateProperties = [];

    renderedTextBitmap = LedBitmap.fromText(
      renderedText,
      useProportionalFont: widget.useProportionalFont,
    );
    print('ttt123 updateRenderingProperties => renderedTextBitmap');
  }

  double measureTextSize({required String text, bool vertical = false}) {
    if (text.isEmpty) return 0;

    final currentBitmap = LedBitmap.fromText(
      text,
      useProportionalFont: widget.useProportionalFont,
    );
    print('ttt123 measureTextSize => renderedTextBitmap');

    return vertical
        ? currentBitmap.height.toDouble()
        : currentBitmap.width.toDouble();
  }

  List updateRenderDataList({bool withOffset = true}) {
    double firstTextWidth = measureTextSize(text: firstText);
    double preparedSecondTextWidth = measureTextSize(text: secondText);

    int minRepeatCountFirstText = firstTextWidth > 0
        ? (((withOffset ? offset.abs() : 0) + containerWidth) / firstTextWidth)
            .ceil()
        : 0;
    int preparedMinRepeatCountSecondText = preparedSecondTextWidth > 0
        ? (containerWidth / preparedSecondTextWidth).ceil()
        : 1;

    List<String> textBuffer = List.filled(minRepeatCountFirstText, firstText) +
        List.filled(preparedMinRepeatCountSecondText * loopsToFill, secondText);
    double preparedPosToUpdate = firstText != ''
        ? minRepeatCountFirstText * firstTextWidth
        : preparedMinRepeatCountSecondText * preparedSecondTextWidth;
    double preparePosSecondTextStarts = firstText != ''
        ? minRepeatCountFirstText * firstTextWidth - containerWidth
        : -1;

    return [
      secondText,
      textBuffer.join(),
      preparedPosToUpdate,
      preparePosSecondTextStarts,
      preparedMinRepeatCountSecondText,
      preparedSecondTextWidth,
    ];
  }

  void replaceTextBufferWithNewText() {
    if (nextUpdateProperties.isNotEmpty) {
      offset = 0;
      if (containerWidth > 0) {
        updateRenderingProperties(nextUpdateProperties);
      }
    } else {
      List<String> textBuffer = List.filled(
        minRepeatCountSecondText * loopsToFill,
        secondText,
      );
      offset = 0;
      firstText = '';
      renderedText = textBuffer.join();
      posToUpdate = minRepeatCountSecondText * secondTextWidth;

      renderedTextBitmap = LedBitmap.fromText(
        renderedText,
        useProportionalFont: widget.useProportionalFont,
      );

      print('ttt123 replaceTextBufferWithNewText => renderedTextBitmap');
    }
  }

  void onTick(Duration elapsed) {
    final double delta = widget.pixelsPerSecond / 60; // assuming ~60fps

    setState(() {
      offset -= delta;

      if (offset.abs() >= posToUpdate) {
        replaceTextBufferWithNewText(); // switch on posToUpdate (position of the firstText part has disappeared and the seconText part has just arrived at the start of ticker area)
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (containerWidth != constraints.maxWidth) {
          containerWidth = constraints.maxWidth;
          List updateProperties = updateRenderDataList();
          updateRenderingProperties(updateProperties);
        }

        return SizedBox(
          height: (8 * widget.ledSize).toDouble(),
          child: ClipRect(
            child: CustomPaint(
              painter: LedMatrixPainter(
                current: renderedTextBitmap!,
                offset: offset,
                ledSize: widget.ledSize,
                ledGap: widget.ledGap,
                onColor: widget.onColor,
                offColor: widget.offColor,
              ),
            ),
          ),
        );
      },
    );
  }
}
