import 'package:flutter_test/flutter_test.dart';
import 'package:pantrysaver/providers/app_provider.dart';

void main() {
  group('AppProvider error formatting', () {
    test('strips Exception wrapper from generic errors', () {
      expect(AppProvider.formatExceptionMessage(Exception('Error')), 'Error');
    });
  });

  test('toggleDarkMode updates the app provider state', () {
    final provider = AppProvider();

    expect(provider.darkMode, isFalse);

    provider.toggleDarkMode(true);

    expect(provider.darkMode, isTrue);
  });
}
