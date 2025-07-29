// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get systemMode => 'System Mode';

  @override
  String get about => 'About';

  @override
  String get error => 'Error';

  @override
  String pageNotFound(String uri) {
    return 'Page not found: $uri';
  }

  @override
  String get goHome => 'Go Home';

  @override
  String get features => 'Features';

  @override
  String get windowsPlatform => 'Windows Platform';

  @override
  String get windowsFeatures => 'Windows Features:';

  @override
  String get windowsSpecificFeatures =>
      'Windows specific features can be implemented here.';

  @override
  String get nativeWindowsUI => 'Native Windows UI';

  @override
  String get fileSystemAccess => 'File System Access';

  @override
  String get systemTrayIntegration => 'System Tray Integration';

  @override
  String get windowsNotifications => 'Windows Notifications';

  @override
  String get macOSPlatform => 'macOS Platform';

  @override
  String get macOSFeatures => 'macOS Features:';

  @override
  String get macOSSpecificFeatures =>
      'macOS specific features can be implemented here.';

  @override
  String get nativeMacOSUI => 'Native macOS UI';

  @override
  String get menuBarIntegration => 'Menu Bar Integration';

  @override
  String get touchBarSupport => 'Touch Bar Support';

  @override
  String get macOSNotifications => 'macOS Notifications';

  @override
  String get androidPlatform => 'Android Platform';

  @override
  String get androidFeatures => 'Android Features:';

  @override
  String get androidSpecificFeatures =>
      'Android specific features can be implemented here.';

  @override
  String get materialDesign => 'Material Design';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get appShortcuts => 'App Shortcuts';

  @override
  String get backgroundServices => 'Background Services';

  @override
  String get iOSPlatform => 'iOS Platform';

  @override
  String get iOSFeatures => 'iOS Features:';

  @override
  String get iOSSpecificFeatures =>
      'iOS specific features can be implemented here.';

  @override
  String get cupertinoDesign => 'Cupertino Design';

  @override
  String get appClips => 'App Clips';

  @override
  String get siriShortcuts => 'Siri Shortcuts';

  @override
  String get linuxPlatform => 'Linux Platform';

  @override
  String get linuxFeatures => 'Linux Features:';

  @override
  String get linuxSpecificFeatures =>
      'Linux specific features can be implemented here.';

  @override
  String get nativeGtkIntegration => 'Native GTK Integration';

  @override
  String get systemTraySupport => 'System Tray Support';

  @override
  String get desktopFiles => 'Desktop Files';

  @override
  String get packageManagement => 'Package Management';

  @override
  String get webPlatform => 'Web Platform';

  @override
  String get webFeatures => 'Web Features:';

  @override
  String get webSpecificFeatures =>
      'Web specific features can be implemented here.';

  @override
  String get progressiveWebApp => 'Progressive Web App';

  @override
  String get browserStorage => 'Browser Storage';

  @override
  String get urlRouting => 'URL Routing';

  @override
  String get webApis => 'Web APIs';

  @override
  String get configEditor => 'Config Editor';

  @override
  String get configUpdated => 'Configuration updated';

  @override
  String currentPlatform(String platform) {
    return 'Current Platform: $platform';
  }

  @override
  String availablePages(String pages) {
    return 'Available Pages: $pages';
  }

  @override
  String availableFeatures(String features) {
    return 'Available Features: $features';
  }

  @override
  String get pageConfiguration => 'Page Configuration';

  @override
  String get featureConfiguration => 'Feature Configuration';

  @override
  String get debugInfo => 'Debug Info';

  @override
  String get printConfigInfo => 'Print config information';

  @override
  String get saveConfig => 'Save config';

  @override
  String get mapAtlas => 'Map Atlas';

  @override
  String get mapAtlasEmpty => 'No maps available';

  @override
  String get addMap => 'Add Map';

  @override
  String get mapTitle => 'Map Title';

  @override
  String get enterMapTitle => 'Enter map title';

  @override
  String get deleteMap => 'Delete Map';

  @override
  String confirmDeleteMap(String title) {
    return 'Are you sure you want to delete the map \"$title\"?';
  }

  @override
  String get exportDatabase => 'Export Database';

  @override
  String get importDatabase => 'Import Database';

  @override
  String get resourceManagement => 'Resource Management';

  @override
  String importFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get mapAddedSuccessfully => 'Map added successfully';

  @override
  String get mapDeletedSuccessfully => 'Map deleted successfully';

  @override
  String addMapFailed(String error) {
    return 'Failed to add map: $error';
  }

  @override
  String deleteMapFailed(String error) {
    return 'Failed to delete map: $error';
  }

  @override
  String loadMapsFailed(String error) {
    return 'Failed to load maps: $error';
  }

  @override
  String get legendManager => 'Legend Manager';

  @override
  String get legendManagerEmpty => 'No legends available';

  @override
  String get addLegend => 'Add Legend';

  @override
  String get legendTitle => 'Legend Title';

  @override
  String get enterLegendTitle => 'Please enter legend title';

  @override
  String get legendVersion => 'Legend Version';

  @override
  String get selectCenterPoint => 'Select Center Point:';

  @override
  String get deleteLegend => 'Delete Legend';

  @override
  String confirmDeleteLegend(String title) {
    return 'Are you sure you want to delete legend \"$title\"?';
  }

  @override
  String get legendDeletedSuccessfully => 'Legend deleted successfully';

  @override
  String deleteLegendFailed(String error) {
    return 'Failed to delete legend: $error';
  }

  @override
  String get uploadLocalizationFile => 'Upload Localization File';

  @override
  String get mapEditor => 'Map Editor';

  @override
  String get mapPreview => 'Map Preview';

  @override
  String get close => 'Close';

  @override
  String get layers => 'Layers';

  @override
  String get legend => 'Legend';

  @override
  String get addLayer => 'Add Layer';

  @override
  String get deleteLayer => 'Delete Layer';

  @override
  String get opacity => 'Opacity';

  @override
  String get elements => 'elements';

  @override
  String get drawingTools => 'Drawing Tools';

  @override
  String get line => 'Line';

  @override
  String get dashedLine => 'Dashed Line';

  @override
  String get arrow => 'Arrow';

  @override
  String get rectangle => 'Rectangle';

  @override
  String get hollowRectangle => 'Hollow Rectangle';

  @override
  String get diagonalLines => 'Diagonal Lines';

  @override
  String get crossLines => 'Cross Lines';

  @override
  String get dotGrid => 'Dot Grid';

  @override
  String get strokeWidth => 'Stroke Width';

  @override
  String get color => 'Color';

  @override
  String get addLegendGroup => 'Add Legend Group';

  @override
  String get deleteLegendGroup => 'Delete Legend Group';

  @override
  String get saveMap => 'Save Map';

  @override
  String get mode => 'Mode';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get userPreferences => 'User Preferences';

  @override
  String get layerSelectionSettings => 'Layer Selection Settings';

  @override
  String get autoSelectLastLayerInGroup => 'Auto-select last layer in group';

  @override
  String get autoSelectLastLayerInGroupDescription =>
      'Automatically select the last layer when a layer group is selected';

  @override
  String get primaryColor => 'Primary Color';

  @override
  String get accentColor => 'Accent Color';

  @override
  String get autoSave => 'Auto Save';

  @override
  String get gridSize => 'Grid Size';

  @override
  String get compactMode => 'Compact Mode';

  @override
  String get showTooltips => 'Show Tooltips';

  @override
  String get enableAnimations => 'Enable Animations';

  @override
  String get animationDuration => 'Animation Duration (ms)';

  @override
  String get recentColors => 'Recent Colors';

  @override
  String get favoriteStrokeWidths => 'Favorite Stroke Widths';

  @override
  String get showAdvancedTools => 'Show Advanced Tools';

  @override
  String get currentUser => 'Current User';

  @override
  String get userProfiles => 'User Profiles';

  @override
  String get exportSettings => 'Export Settings';

  @override
  String get importSettings => 'Import Settings';

  @override
  String get resetSettings => 'Reset to Defaults';

  @override
  String get confirmResetSettings =>
      'Are you sure you want to reset all settings to defaults? This cannot be undone.';

  @override
  String get settingsExported => 'Settings exported successfully';

  @override
  String get settingsImported => 'Settings imported successfully';

  @override
  String get settingsReset => 'Settings reset to defaults';
}
