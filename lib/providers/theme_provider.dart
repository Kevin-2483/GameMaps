import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.system;
  Color _primaryColor = Colors.blue;
  bool _useMaterialYou = true;
  double _fontScale = 1.0;
  bool _highContrast = false;

  AppThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  bool get useMaterialYou => _useMaterialYou;
  double get fontScale => _fontScale;
  bool get highContrast => _highContrast;

  // 转换为 Flutter 的 ThemeMode
  ThemeMode get flutterThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  // 从用户偏好设置更新主题
  void updateFromUserPreferences({
    required String themeMode,
    required int primaryColor,
    required bool useMaterialYou,
    required double fontScale,
    required bool highContrast,
  }) {
    _themeMode = _getThemeModeFromString(themeMode);
    _primaryColor = Color(primaryColor);
    _useMaterialYou = useMaterialYou;
    _fontScale = fontScale;
    _highContrast = highContrast;
    notifyListeners();
  }

  AppThemeMode _getThemeModeFromString(String themeMode) {
    switch (themeMode.toLowerCase()) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      default:
        return AppThemeMode.system;
    }
  }  // 亮色主题
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: _useMaterialYou
        ? ColorScheme.fromSeed(
            seedColor: _primaryColor,
            brightness: Brightness.light,
          )
        : ColorScheme.fromSwatch(
            primarySwatch: MaterialColor(_primaryColor.value, _generateMaterialColor(_primaryColor)),
            brightness: Brightness.light,
          ),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textTheme: _buildTextTheme(Brightness.light),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
  // 深色主题
  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: _useMaterialYou
        ? ColorScheme.fromSeed(
            seedColor: _primaryColor,
            brightness: Brightness.dark,
          )
        : ColorScheme.fromSwatch(
            primarySwatch: MaterialColor(_primaryColor.value, _generateMaterialColor(_primaryColor)),
            brightness: Brightness.dark,
          ),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textTheme: _buildTextTheme(Brightness.dark),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  // 构建自定义文本主题（应用字体缩放）
  TextTheme _buildTextTheme(Brightness brightness) {
    final baseTheme = ThemeData(brightness: brightness).textTheme;
    return baseTheme.copyWith(
      displayLarge: baseTheme.displayLarge?.copyWith(fontSize: (baseTheme.displayLarge?.fontSize ?? 57) * _fontScale),
      displayMedium: baseTheme.displayMedium?.copyWith(fontSize: (baseTheme.displayMedium?.fontSize ?? 45) * _fontScale),
      displaySmall: baseTheme.displaySmall?.copyWith(fontSize: (baseTheme.displaySmall?.fontSize ?? 36) * _fontScale),
      headlineLarge: baseTheme.headlineLarge?.copyWith(fontSize: (baseTheme.headlineLarge?.fontSize ?? 32) * _fontScale),
      headlineMedium: baseTheme.headlineMedium?.copyWith(fontSize: (baseTheme.headlineMedium?.fontSize ?? 28) * _fontScale),
      headlineSmall: baseTheme.headlineSmall?.copyWith(fontSize: (baseTheme.headlineSmall?.fontSize ?? 24) * _fontScale),
      titleLarge: baseTheme.titleLarge?.copyWith(fontSize: (baseTheme.titleLarge?.fontSize ?? 22) * _fontScale),
      titleMedium: baseTheme.titleMedium?.copyWith(fontSize: (baseTheme.titleMedium?.fontSize ?? 16) * _fontScale),
      titleSmall: baseTheme.titleSmall?.copyWith(fontSize: (baseTheme.titleSmall?.fontSize ?? 14) * _fontScale),
      bodyLarge: baseTheme.bodyLarge?.copyWith(fontSize: (baseTheme.bodyLarge?.fontSize ?? 16) * _fontScale),
      bodyMedium: baseTheme.bodyMedium?.copyWith(fontSize: (baseTheme.bodyMedium?.fontSize ?? 14) * _fontScale),
      bodySmall: baseTheme.bodySmall?.copyWith(fontSize: (baseTheme.bodySmall?.fontSize ?? 12) * _fontScale),
      labelLarge: baseTheme.labelLarge?.copyWith(fontSize: (baseTheme.labelLarge?.fontSize ?? 14) * _fontScale),
      labelMedium: baseTheme.labelMedium?.copyWith(fontSize: (baseTheme.labelMedium?.fontSize ?? 12) * _fontScale),
      labelSmall: baseTheme.labelSmall?.copyWith(fontSize: (baseTheme.labelSmall?.fontSize ?? 11) * _fontScale),
    );
  }

  // 生成 Material Color 的色板
  Map<int, Color> _generateMaterialColor(Color color) {
    final int r = color.red;
    final int g = color.green;
    final int b = color.blue;

    return {
      50: Color.fromRGBO(r, g, b, 0.1),
      100: Color.fromRGBO(r, g, b, 0.2),
      200: Color.fromRGBO(r, g, b, 0.3),
      300: Color.fromRGBO(r, g, b, 0.4),
      400: Color.fromRGBO(r, g, b, 0.5),
      500: Color.fromRGBO(r, g, b, 0.6),
      600: Color.fromRGBO(r, g, b, 0.7),
      700: Color.fromRGBO(r, g, b, 0.8),
      800: Color.fromRGBO(r, g, b, 0.9),
      900: Color.fromRGBO(r, g, b, 1.0),
    };
  }

  // 初始化主题（保持向后兼容）
  Future<void> initTheme() async {
    // 保持默认值，真正的初始化将由 UserPreferencesProvider 完成
    notifyListeners();
  }

  // 切换主题模式（保持向后兼容）
  Future<void> toggleTheme() async {
    switch (_themeMode) {
      case AppThemeMode.light:
        _themeMode = AppThemeMode.dark;
        break;
      case AppThemeMode.dark:
        _themeMode = AppThemeMode.light;
        break;
      case AppThemeMode.system:
        _themeMode = AppThemeMode.light;
        break;
    }
    notifyListeners();
  }

  // 为了保持向后兼容性而保留的方法
  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
  }
}
