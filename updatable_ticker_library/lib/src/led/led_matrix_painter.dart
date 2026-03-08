import 'package:flutter/material.dart';
import 'led_bitmap.dart';

/// Painter that renders led matrix output
///
class LedMatrixPainter extends CustomPainter {
  /// - current bitmap
  final LedBitmap current;

  /// - number of horizontal LEDs (led modules * 8)
  final int ledsHorizontal;

  /// - offset
  final double offset;

  /// enable smooth pixel-precise scrolling (otherwise on false, scroll authentically on ledSize boundary)
  final bool enableSmoothScrolling;

  /// - onColor
  final Color onColor;

  /// - offColor
  final Color offColor;

  /// - ledSize
  final double ledSize;

  /// - ledGap
  final double ledGap;

  /// Creates a [LedMatrixPainter].
  LedMatrixPainter({
    required this.current,
    required this.ledsHorizontal,
    required this.offset,
    this.enableSmoothScrolling = false,
    this.onColor = Colors.red,
    this.offColor = const Color(0xFFdddddd),
    this.ledSize = 10.0,
    this.ledGap = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double totalHeight = ledSize * 8;

    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, totalHeight));

    if (enableSmoothScrolling == true) {
      canvas.translate(-(offset % 1) * ledSize, 0);
    }
    _drawBitmap(canvas, current);
  }

  void _drawBitmap(Canvas canvas, LedBitmap bitmap) {
    final int offsetFloor = offset.floor();
    final int ledMaxWidth =
        enableSmoothScrolling ? ledsHorizontal + 1 : ledsHorizontal;
    final int startCol = offsetFloor + ledMaxWidth > bitmap.width
        ? bitmap.width - ledMaxWidth < 0
            ? 0
            : bitmap.width - ledMaxWidth
        : offsetFloor;
    final int endCol = startCol + ledMaxWidth >= bitmap.width
        ? bitmap.width
        : startCol + ledMaxWidth;

    for (int row = 0; row < bitmap.height; row++) {
      for (int col = startCol; col < endCol; col++) {
        final paint = Paint()
          ..color = bitmap.pixels[row][col] ? onColor : offColor;

        final dx = (col - startCol) * ledSize;
        final dy = row * ledSize;
        final rect = Rect.fromLTWH(dx + ledGap / 2, dy + ledGap / 2,
            ledSize - ledGap, ledSize - ledGap);
        canvas.drawRRect(
            RRect.fromRectAndRadius(rect, Radius.circular(ledSize * 0.3)),
            paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant LedMatrixPainter oldDelegate) => true;
}
