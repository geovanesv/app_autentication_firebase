import 'package:flutter/material.dart';

class MyTheme {
  static get theme {
    return ThemeData(
      // definição da cor primária (primarySwatch) e secundária (secundary))
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.deepPurple,
      ).copyWith(
        secondary: Colors.green,
      ),
      // fonte principal
      fontFamily: 'Lato',
    );
  }
}
