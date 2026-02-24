import 'package:updatable_ticker/src/led/cp437_font_proportional.dart';

import 'cp437_font.dart';

/// generates a LED bitmap
class LedBitmap {
  /// Result: rows × columns bitmap
  final List<List<bool>> pixels;

  /// Creates an [LedBitmap].
  LedBitmap(this.pixels);

  /// LED matrix width
  int get width => pixels.isEmpty ? 0 : pixels[0].length;

  /// LED matrix height
  int get height => pixels.length;

  /// generates LED bitmap from text
  ///
  static LedBitmap fromText(
    String text, {
    bool useProportionalFont = false,
  }) {
    final rows = 8;

    // Hilfsfunktion: rotiert 8x8 Bitmap 90° nach links
    List<List<bool>> rotate90Left(List<List<bool>> matrix) {
      final rows = matrix.length;
      final cols = matrix[0].length;
      final rotated =
          List.generate(cols, (_) => List<bool>.filled(rows, false));

      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          rotated[cols - 1 - c][r] = matrix[r][c];
        }
      }
      return rotated;
    }

    int textCols = 0;
    for (final rune in text.runes) {
      final List<int> glyph = useProportionalFont
          ? cp437FontProportional[rune & 0xFF]
          : cp437Font[rune & 0xFF];
      textCols += glyph.length;
    }

    final cols = textCols;
    final bitmap = List.generate(rows, (_) => List<bool>.filled(cols, false));

    // <- Hier kommt Teil 3 hin:
    int xOffset = 0;
    for (final rune in text.runes) {
      final List<int> glyph = useProportionalFont
          ? cp437FontProportional[rune & 0xFF]
          : cp437Font[rune & 0xFF];

      // normale horizontale Bitmap erstellen
      final List<List<bool>> letterBitmap = List.generate(glyph.length, (row) {
        final int rowBits = glyph[row];
        return List.generate(8, (col) => (rowBits & (1 << (7 - col))) != 0);
      });

      // ✅ 90° nach links drehen
      final rotatedGlyph = rotate90Left(letterBitmap);

      // in die Gesamtbitmap einfügen
      for (int r = 0; r < 8; r++) {
        for (int c = 0; c < glyph.length; c++) {
          if (xOffset + c >= cols) break;
          bitmap[r][xOffset + c] = rotatedGlyph[r][c];
        }
      }

      xOffset += glyph.length;
      if (xOffset >= cols) break;
    }

    return LedBitmap(bitmap);
  }
}
