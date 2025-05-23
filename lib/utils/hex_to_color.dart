/// Converts a hex color string to color int (0xAARRGGBB)
int hexToColor(String hexColor) {
  // Remove '#' if present
  hexColor = hexColor.replaceAll('#', '');

  // If hex is in RRGGBB format, add full alpha (FF)
  if (hexColor.length == 6) {
    hexColor = 'FF$hexColor';
  }

  // Parse as integer with radix 16 (hex)
  return int.parse(hexColor, radix: 16);
}
