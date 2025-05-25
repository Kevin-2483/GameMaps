import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:r6box/main.dart';
import 'package:r6box/providers/theme_provider.dart';
import 'package:r6box/providers/locale_provider.dart';
import 'package:r6box/config/config_manager.dart';

void main() {
  group('R6Box Framework Tests', () {
    setUpAll(() async {
      // Initialize the config manager for tests
      await ConfigManager.instance.loadFromAssets();
    });

    testWidgets('App should build without errors', (WidgetTester tester) async {
      await tester.pumpWidget(const R6BoxApp());
      await tester.pumpAndSettle();
      
      // Verify that the app builds successfully
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Home page should display correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const R6BoxApp());
      await tester.pumpAndSettle();
      
      // Verify that we have basic navigation elements
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Theme provider should work', (WidgetTester tester) async {
      final themeProvider = ThemeProvider();
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: themeProvider,
          child: Consumer<ThemeProvider>(
            builder: (context, provider, child) {
              return MaterialApp(
                theme: provider.lightTheme,
                darkTheme: provider.darkTheme,
                themeMode: provider.themeMode == AppThemeMode.dark 
                    ? ThemeMode.dark 
                    : provider.themeMode == AppThemeMode.light 
                        ? ThemeMode.light 
                        : ThemeMode.system,
                home: const Scaffold(
                  body: Text('Test'),
                ),
              );
            },
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('Locale provider should work', (WidgetTester tester) async {
      final localeProvider = LocaleProvider();
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: localeProvider,
          child: Consumer<LocaleProvider>(
            builder: (context, provider, child) {
              return MaterialApp(
                locale: provider.locale,
                home: const Scaffold(
                  body: Text('Test'),
                ),
              );
            },
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      expect(find.text('Test'), findsOneWidget);
    });    test('Config manager should load configuration', () async {
      await ConfigManager.instance.loadFromAssets();
      
      expect(ConfigManager.instance.config, isNotNull);
      expect(ConfigManager.instance.config.build.appName, isNotEmpty);
      expect(ConfigManager.instance.config.build.version, isNotEmpty);
    });
  });
}
