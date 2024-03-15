import 'package:flutter/material.dart';

class NavigationHelper {
  static void navigateTo(BuildContext context, Widget destinationPage) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => destinationPage,
    ));
  }
}
