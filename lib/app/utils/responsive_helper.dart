import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  static double getCardWidth(BuildContext context) {
    if (isMobile(context)) {
      return MediaQuery.of(context).size.width;
    } else if (isTablet(context)) {
      return MediaQuery.of(context).size.width / 2 - 24;
    } else {
      return MediaQuery.of(context).size.width / 3 - 24;
    }
  }

  static Widget responsiveGrid({
    required BuildContext context,
    required List<Widget> children,
    double spacing = 8.0,
  }) {
    if (isMobile(context)) {
      // Single column layout for mobile
      return ListView(
        padding: EdgeInsets.all(spacing),
        children: children,
      );
    } else {
      // Grid layout for tablet and desktop
      final crossAxisCount = isTablet(context) ? 2 : 3;
      
      return GridView.builder(
        padding: EdgeInsets.all(spacing),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 1.5,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      );
    }
  }
}
