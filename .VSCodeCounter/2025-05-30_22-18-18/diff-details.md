# Diff Details

Date : 2025-05-30 22:18:18

Directory e:\\code\\r6box\\r6box

Total : 47 files,  33698 codes, 535 comments, 903 blanks, all 35136 lines

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details

## Files
| filename | language | code | comment | blank | total |
| :--- | :--- | ---: | ---: | ---: | ---: |
| [assets/config/1.json](/assets/config/1.json) | JSON | 6 | 0 | 0 | 6 |
| [assets/config/app\_config.json](/assets/config/app_config.json) | JSON | -6 | 0 | 0 | -6 |
| [assets/data/exported\_database.json](/assets/data/exported_database.json) | JSON | 5,389 | 0 | 0 | 5,389 |
| [docs/WEB\_PLATFORM\_GUIDE.md](/docs/WEB_PLATFORM_GUIDE.md) | Markdown | 69 | 0 | 39 | 108 |
| [lib/components/layout/app\_shell.dart](/lib/components/layout/app_shell.dart) | Dart | 87 | 4 | 11 | 102 |
| [lib/components/layout/main\_layout.dart](/lib/components/layout/main_layout.dart) | Dart | 47 | 4 | 7 | 58 |
| [lib/components/layout/page\_configuration.dart](/lib/components/layout/page_configuration.dart) | Dart | 27 | 3 | 8 | 38 |
| [lib/components/web/web\_readonly\_components.dart](/lib/components/web/web_readonly_components.dart) | Dart | 74 | 3 | 11 | 88 |
| [lib/config/build\_config.dart](/lib/config/build_config.dart) | Dart | 4 | -1 | -1 | 2 |
| [lib/features/page-modules/fullscreen\_test\_page\_module.dart](/lib/features/page-modules/fullscreen_test_page_module.dart) | Dart | 32 | 5 | 11 | 48 |
| [lib/features/page-modules/user\_preferences\_page\_module.dart](/lib/features/page-modules/user_preferences_page_module.dart) | Dart | 29 | 4 | 10 | 43 |
| [lib/l10n/app\_localizations.dart](/lib/l10n/app_localizations.dart) | Dart | 41 | 164 | 41 | 246 |
| [lib/l10n/app\_localizations\_en.dart](/lib/l10n/app_localizations_en.dart) | Dart | 89 | 0 | 41 | 130 |
| [lib/l10n/app\_localizations\_zh.dart](/lib/l10n/app_localizations_zh.dart) | Dart | 88 | 0 | 41 | 129 |
| [lib/main.dart](/lib/main.dart) | Dart | 20 | 5 | 1 | 26 |
| [lib/models/map\_layer.dart](/lib/models/map_layer.dart) | Dart | 2 | 0 | 0 | 2 |
| [lib/models/user\_preferences.dart](/lib/models/user_preferences.dart) | Dart | 316 | 49 | 67 | 432 |
| [lib/models/user\_preferences.g.dart](/lib/models/user_preferences.g.dart) | Dart | 129 | 4 | 13 | 146 |
| [lib/pages/config/config\_editor\_page.dart](/lib/pages/config/config_editor_page.dart) | Dart | -1 | 0 | -1 | -2 |
| [lib/pages/home/home\_page.dart](/lib/pages/home/home_page.dart) | Dart | 19 | -1 | -1 | 17 |
| [lib/pages/map\_atlas/map\_atlas\_page.dart](/lib/pages/map_atlas/map_atlas_page.dart) | Dart | 143 | 9 | 4 | 156 |
| [lib/pages/map\_editor/map\_editor\_page.dart](/lib/pages/map_editor/map_editor_page.dart) | Dart | 83 | 11 | 4 | 98 |
| [lib/pages/map\_editor/widgets/layer\_panel.dart](/lib/pages/map_editor/widgets/layer_panel.dart) | Dart | 39 | 7 | 2 | 48 |
| [lib/pages/map\_editor/widgets/legend\_group\_management\_drawer.dart](/lib/pages/map_editor/widgets/legend_group_management_drawer.dart) | Dart | 6 | 3 | 1 | 10 |
| [lib/pages/map\_editor/widgets/map\_canvas.dart](/lib/pages/map_editor/widgets/map_canvas.dart) | Dart | 58 | 59 | 9 | 126 |
| [lib/pages/settings/settings\_page.dart](/lib/pages/settings/settings_page.dart) | Dart | -34 | 0 | -1 | -35 |
| [lib/pages/settings/user\_preferences\_page.dart](/lib/pages/settings/user_preferences_page.dart) | Dart | 256 | 9 | 23 | 288 |
| [lib/pages/settings/widgets/layout\_settings\_section.dart](/lib/pages/settings/widgets/layout_settings_section.dart) | Dart | 194 | 7 | 22 | 223 |
| [lib/pages/settings/widgets/map\_editor\_settings\_section.dart](/lib/pages/settings/widgets/map_editor_settings_section.dart) | Dart | 230 | 7 | 22 | 259 |
| [lib/pages/settings/widgets/theme\_settings\_section.dart](/lib/pages/settings/widgets/theme_settings_section.dart) | Dart | 176 | 7 | 19 | 202 |
| [lib/pages/settings/widgets/tool\_settings\_section.dart](/lib/pages/settings/widgets/tool_settings_section.dart) | Dart | 375 | 9 | 29 | 413 |
| [lib/pages/settings/widgets/user\_management\_section.dart](/lib/pages/settings/widgets/user_management_section.dart) | Dart | 394 | 20 | 40 | 454 |
| [lib/pages/test/fullscreen\_test\_page.dart](/lib/pages/test/fullscreen_test_page.dart) | Dart | 45 | 1 | 3 | 49 |
| [lib/providers/theme\_provider.dart](/lib/providers/theme_provider.dart) | Dart | 101 | 5 | 11 | 117 |
| [lib/providers/user\_preferences\_provider.dart](/lib/providers/user_preferences_provider.dart) | Dart | 333 | 40 | 53 | 426 |
| [lib/router/app\_router.dart](/lib/router/app_router.dart) | Dart | 3 | -1 | -2 | 0 |
| [lib/services/combined\_database\_exporter.dart](/lib/services/combined_database_exporter.dart) | Dart | 140 | 18 | 21 | 179 |
| [lib/services/user\_preferences\_service.dart](/lib/services/user_preferences_service.dart) | Dart | 272 | 40 | 59 | 371 |
| [lib/services/web\_database\_importer.dart](/lib/services/web_database_importer.dart) | Dart | 83 | 15 | 13 | 111 |
| [lib/services/web\_database\_preloader.dart](/lib/services/web_database_preloader.dart) | Dart | 78 | 13 | 14 | 105 |
| [lib/utils/image\_utils.dart](/lib/utils/image_utils.dart) | Dart | 18 | 2 | 0 | 20 |
| [pubspec.yaml](/pubspec.yaml) | YAML | 2 | -1 | -1 | 0 |
| [scripts/build\_config\_generator.dart](/scripts/build_config_generator.dart) | Dart | 3 | -1 | 0 | 2 |
| [scripts/database\_exporter.dart](/scripts/database_exporter.dart) | Dart | 72 | 11 | 16 | 99 |
| [web/index.html](/web/index.html) | HTML | 4 | 1 | 0 | 5 |
| [web/sqflite\_sw.js](/web/sqflite_sw.js) | JavaScript | 9,504 | 1 | 2 | 9,507 |
| [web/sqlite3.wasm](/web/sqlite3.wasm) | WebAssembly Text Format | 14,659 | 0 | 242 | 14,901 |

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details