import 'package:flutter/material.dart';

enum TColors { black, white, yellow, blue, orange, green }

class Themes {
  static Map<TColors, List<Color>> get swatch => {
        TColors.black: [
          Color(0xFF2c3134),
          Color(0x8B000000),
          Color(0xFF1F2326),
          Color(0xFF23272A),
        ],
        TColors.white: [
          Color(0xFFEDEDED),
          Color(0xFFEDEDED),
          Color(0xFFCCCCCC),
          Color(0xFFFFFFFF)
        ],
        TColors.yellow: [
          Color(0xFFFFC000),
          Color(0xFFFE9C0F),
          Color(0xFFEB6D0A)
        ],
        TColors.blue: [Color(0xFF00B0F0), Color(0xFF0070C0), Color(0xFF00619F)],
        TColors.orange: [
          Color(0xFFFB6127),
          Color(0xFFFA3838),
          Color(0xFFE92A26)
        ],
        TColors.green: [Color(0xFF71D32c), Color(0xFF00B050), Color(0xFF0A903D)]
      };

  static _style(Color color, double fontSize,
      {String? font, List<Shadow>? shadows}) {
    return TextStyle(
        color: color,
        fontSize: fontSize,
        fontFamily: font,
        shadows: shadows ??
            [
              BoxShadow(
                  color: Colors.black.withAlpha(150),
                  blurRadius: 3,
                  offset: Offset(0.5, 2))
            ]);
  }

  static ThemeData get darkData {
    var textTheme = TextTheme(
        caption: TextStyle(color: Colors.yellow, fontSize: 16),
        button: _style(swatch[TColors.black]![0], 24, shadows: []),
        bodyText1: _style(swatch[TColors.black]![0], 22, shadows: []),
        bodyText2: _style(swatch[TColors.black]![0], 20, shadows: []),
        subtitle1: _style(swatch[TColors.black]![0], 16, shadows: []),
        subtitle2: _style(swatch[TColors.black]![0], 14, shadows: []),
        headline1: _style(swatch[TColors.white]![3], 56),
        headline2: _style(swatch[TColors.white]![3], 36),
        headline3: _style(swatch[TColors.white]![3], 30),
        headline4: _style(swatch[TColors.white]![3], 24),
        headline5: _style(swatch[TColors.white]![3], 20),
        headline6: _style(swatch[TColors.white]![3], 16),
        overline: _style(swatch[TColors.white]![3], 32, font: "icons"));

    // var iconTheme = IconThemeData(color: primaries[50]);
    return ThemeData(
      textTheme: textTheme,
      // primarySwatch: darkMaterial,
      // iconTheme: iconTheme,
      // appBarTheme: AppBarTheme(
      //     backgroundColor: primaries[700],
      //     textTheme: textTheme,
      //     iconTheme: iconTheme),
      // floatingActionButtonTheme: FloatingActionButtonThemeData(
      //     backgroundColor: primaries[500], foregroundColor: primaries[100]),
      // sliderTheme: SliderThemeData(
      //     thumbColor: primaries[300],
      //     activeTrackColor: primaries[700],
      //     inactiveTrackColor: primaries[700],
      //     overlayColor: primaries[700]),
      // textButtonTheme: TextButtonThemeData(
      //     style: ButtonStyle(
      //         foregroundColor:
      //             MaterialStateProperty.resolveWith(getTextButtonColor),
      //         textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(
      //             fontFamily: "quicksand",
      //             fontSize: 18,
      //             fontWeight: FontWeight.bold)))),
      // textSelectionTheme: TextSelectionThemeData(
      //     cursorColor: primaries[500],
      //     selectionHandleColor: primaries[300],
      //     selectionColor: primaries[600]),
      // snackBarTheme: SnackBarThemeData(
      //     contentTextStyle: TextStyle(fontFamily: "quicksand", fontSize: 16),
      //     backgroundColor: primaries[700],
      //     actionTextColor: primaries[500]),
      // inputDecorationTheme:
      //     InputDecorationTheme(hintStyle: TextStyle(color: primaries[150])),
      fontFamily: "quicksand",
      dialogBackgroundColor: swatch[TColors.black]![1],
      // accentColor: primaries[0],
      // buttonColor: primaries[600],
      // scaffoldBackgroundColor: primaries[900],
      backgroundColor: swatch[TColors.black]![2],
      dialogTheme: DialogTheme(backgroundColor: swatch[TColors.black]![1]),
      cardColor: swatch[TColors.white]![0],
      // primaryColor: primaries[700],
      // focusColor: primaries[750],
      // textTheme: textTheme,
      colorScheme: ColorScheme.dark(
          // primary: primaries[700],
          // onPrimary: Colors.white,
          // primaryVariant: Colors.teal[50],
          // background: primaries[900],
          // onBackground: primaries[800],
          // surface: Colors.red,
          // secondary: Colors.teal[50],
          // onSecondary: Colors.red,
          // secondaryVariant: Colors.red,
          ),
    );
  }

  // static MaterialColor get material =>
  //     MaterialColor(primaries[500]!.value, primaries);
  // static MaterialColor get darkMaterial =>
  //     MaterialColor(primaries[900]!.value, primaries);
}
