import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ThemeProvider extends ChangeNotifier {
    static const String _themeKey = 'theme';

    final GetStorage _box = GetStorage();

    ThemeMode _themeMode = ThemeMode.system;
    ThemeMode get themeMode => _themeMode;

    ThemeProvider() {
        _loadThemeFromStorage();
    }

    void _loadThemeFromStorage() {
        final savedTheme = _box.read(_themeKey);
        switch (savedTheme) {
            case 'light':
                _themeMode = ThemeMode.light;
                break;
            case 'dark':
                _themeMode = ThemeMode.dark;
                break;
            case 'system':
            default:
                _themeMode = ThemeMode.system;
                break;
        }
    }

    Future<void> setThemeMode(ThemeMode mode) async {
        _themeMode = mode;
        notifyListeners();

        await _box.write(_themeKey, mode.name);
    }
}
