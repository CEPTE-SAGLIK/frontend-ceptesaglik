import 'package:flutter/material.dart';

extension TContext on BuildContext {
  //get size of device
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;

  //get theme
  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  TextTheme get textTheme => Theme.of(this).textTheme;
}
