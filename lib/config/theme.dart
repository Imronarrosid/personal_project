import 'package:flutter/material.dart';
import 'package:personal_project/constant/color.dart';

class AppTheme {
  //
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: COLOR_white_fff5f5f5,
    appBarTheme: AppBarTheme(
      color: COLOR_white_fff5f5f5,
      surfaceTintColor: COLOR_white_fff5f5f5,
      scrolledUnderElevation: 0,
      elevation: 0,
      iconTheme: IconThemeData(
        color: COLOR_black_ff121212,
      ),
    ),
    tabBarTheme: TabBarTheme(
        unselectedLabelColor: COLOR_black_ff121212.withOpacity(0.7),
        overlayColor: MaterialStateProperty.all<Color>(Colors.black12)),
    colorScheme: ColorScheme.light(
      primary: COLOR_purple,
      onPrimary: Colors.white,
      secondary: COLOR_grey,
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
      ),
      titleMedium: TextStyle(
        color: Colors.white70,
        fontSize: 18.0,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: COLOR_black_ff121212,
    indicatorColor: COLOR_white_fff5f5f5,
    appBarTheme: AppBarTheme(
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(
        color: COLOR_white_fff5f5f5,
      ),
    ),
    listTileTheme: ListTileThemeData(tileColor: COLOR_black_900),
    tabBarTheme: TabBarTheme(
        unselectedLabelColor: Colors.white38,
        overlayColor: MaterialStateProperty.all<Color>(Colors.black12)),
    chipTheme: ChipThemeData(
      backgroundColor: COLOR_black_900,
      selectedColor: COLOR_white_fff5f5f5,
      secondarySelectedColor: COLOR_white_fff5f5f5,
      secondaryLabelStyle: TextStyle(color: COLOR_black_ff121212),
      labelStyle: TextStyle(color: COLOR_white_fff5f5f5),
    ),
    colorScheme: ColorScheme.dark(
        primary: COLOR_white_fff5f5f5,
        onPrimary: COLOR_white_fff5f5f5,
        onSecondary: COLOR_black_ff121212,
        secondary: COLOR_black_ff121212,
        onSurface: COLOR_white_fff5f5f5,
        onTertiary: COLOR_purple,
        tertiary: COLOR_black_900),
    iconTheme: IconThemeData(
      color: COLOR_white_fff5f5f5,
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
        color: COLOR_white_fff5f5f5,
      ),
      titleMedium: TextStyle(
        color: COLOR_white_fff5f5f5,
      ),
      titleSmall: TextStyle(
        color: COLOR_white_fff5f5f5,
      ),
    ),
  );
}
