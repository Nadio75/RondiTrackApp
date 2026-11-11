import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/responsive/app_breakpoints.dart';

void main() {
  group('Responsive breakpoints', () {
    test('360 dp is compact', () {
      expect(AppBreakpoints.classify(360), WindowSizeClass.compact);
    });

    test('599 dp is compact', () {
      expect(AppBreakpoints.classify(599), WindowSizeClass.compact);
    });

    test('600 dp is medium', () {
      expect(AppBreakpoints.classify(600), WindowSizeClass.medium);
    });

    test('839 dp is medium', () {
      expect(AppBreakpoints.classify(839), WindowSizeClass.medium);
    });

    test('840 dp is expanded', () {
      expect(AppBreakpoints.classify(840), WindowSizeClass.expanded);
    });

    test('1200 dp is expanded', () {
      expect(AppBreakpoints.classify(1200), WindowSizeClass.expanded);
    });
  });
}
