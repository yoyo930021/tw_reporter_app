import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tw_reporter_app/core/theme/theme_notifier.dart';

void main() {
  group('ThemeNotifier', () {
    test('initial themeMode is ThemeMode.system', () {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final notifier = ThemeNotifier();
      expect(notifier.themeMode, ThemeMode.system);
    });

    test('setThemeMode updates value and notifies listeners', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final notifier = ThemeNotifier();

      // Wait for constructor's async _loadThemeMode to complete
      await Future<void>.delayed(const Duration(milliseconds: 50));

      var callCount = 0;
      notifier.addListener(() => callCount++);

      await notifier.setThemeMode(ThemeMode.dark);
      expect(notifier.themeMode, ThemeMode.dark);
      expect(callCount, 1);
    });

    test('setThemeMode with same value does not notify', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final notifier = ThemeNotifier();

      // Wait for constructor's async _loadThemeMode to complete
      await Future<void>.delayed(const Duration(milliseconds: 50));

      var callCount = 0;
      notifier.addListener(() => callCount++);

      // themeMode defaults to system
      await notifier.setThemeMode(ThemeMode.system);
      expect(callCount, 0);
    });

    test('loads saved theme mode from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'theme_mode': 'dark',
      });
      final notifier = ThemeNotifier();

      // Wait for async _loadThemeMode
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(notifier.themeMode, ThemeMode.dark);
    });

    test('invalid stored value falls back to ThemeMode.system', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'theme_mode': 'invalid_value',
      });
      final notifier = ThemeNotifier();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(notifier.themeMode, ThemeMode.system);
    });

    test('setThemeMode persists value to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final notifier = ThemeNotifier();

      await notifier.setThemeMode(ThemeMode.light);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'light');
    });
  });
}
