import 'package:flutter/material.dart';
import 'led_bitmap.dart';

/// Painter that renders led matrix output:
///
/// - bitmap
/// - onColor
/// - offColor
/// - ledGap
class LedMatrixPainter extends CustomPainter {
  /// - current bitmap
  final LedBitmap current;

  /// - offset
  final double offset;

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
    required this.offset,
    this.onColor = Colors.red,
    this.offColor = const Color(0xFFdddddd),
    this.ledSize = 10.0,
    this.ledGap = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final totalHeight = ledSize * 8;

    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, totalHeight));

    canvas.save();
    canvas.translate(offset * ledSize, 0);
    _drawBitmap(canvas, current);
    canvas.restore();
  }

  void _drawBitmap(Canvas canvas, LedBitmap bitmap) {
    for (int row = 0; row < bitmap.height; row++) {
      for (int col = 0; col < bitmap.width; col++) {
        final paint = Paint()
          ..color = bitmap.pixels[row][col] ? onColor : offColor;

        final dx = col * ledSize;
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
