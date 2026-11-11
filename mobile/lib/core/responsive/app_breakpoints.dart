enum WindowSizeClass { compact, medium, expanded }

class AppBreakpoints {
  static const double medium = 600;
  static const double expanded = 840;

  static WindowSizeClass classify(double width) {
    if (width < medium) {
      return WindowSizeClass.compact;
    }

    if (width < expanded) {
      return WindowSizeClass.medium;
    }

    return WindowSizeClass.expanded;
  }
}
