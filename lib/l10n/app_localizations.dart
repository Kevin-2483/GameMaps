import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// Home page title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Theme setting
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Dark mode setting
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Light mode setting
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// System mode setting
  ///
  /// In en, this message translates to:
  /// **'System Mode'**
  String get systemMode;

  /// About button text
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Error page title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Page not found error message
  ///
  /// In en, this message translates to:
  /// **'Page not found: {uri}'**
  String pageNotFound(String uri);

  /// Go home button text
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHome;

  /// Features section title
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// Windows platform title
  ///
  /// In en, this message translates to:
  /// **'Windows Platform'**
  String get windowsPlatform;

  /// Windows features section title
  ///
  /// In en, this message translates to:
  /// **'Windows Features:'**
  String get windowsFeatures;

  /// Windows platform description
  ///
  /// In en, this message translates to:
  /// **'Windows specific features can be implemented here.'**
  String get windowsSpecificFeatures;

  /// Windows feature
  ///
  /// In en, this message translates to:
  /// **'Native Windows UI'**
  String get nativeWindowsUI;

  /// File system feature
  ///
  /// In en, this message translates to:
  /// **'File System Access'**
  String get fileSystemAccess;

  /// System tray feature
  ///
  /// In en, this message translates to:
  /// **'System Tray Integration'**
  String get systemTrayIntegration;

  /// Windows notifications feature
  ///
  /// In en, this message translates to:
  /// **'Windows Notifications'**
  String get windowsNotifications;

  /// macOS platform title
  ///
  /// In en, this message translates to:
  /// **'macOS Platform'**
  String get macOSPlatform;

  /// macOS features section title
  ///
  /// In en, this message translates to:
  /// **'macOS Features:'**
  String get macOSFeatures;

  /// macOS platform description
  ///
  /// In en, this message translates to:
  /// **'macOS specific features can be implemented here.'**
  String get macOSSpecificFeatures;

  /// macOS feature
  ///
  /// In en, this message translates to:
  /// **'Native macOS UI'**
  String get nativeMacOSUI;

  /// Menu bar feature
  ///
  /// In en, this message translates to:
  /// **'Menu Bar Integration'**
  String get menuBarIntegration;

  /// Touch bar feature
  ///
  /// In en, this message translates to:
  /// **'Touch Bar Support'**
  String get touchBarSupport;

  /// macOS notifications feature
  ///
  /// In en, this message translates to:
  /// **'macOS Notifications'**
  String get macOSNotifications;

  /// Android platform title
  ///
  /// In en, this message translates to:
  /// **'Android Platform'**
  String get androidPlatform;

  /// Android features section title
  ///
  /// In en, this message translates to:
  /// **'Android Features:'**
  String get androidFeatures;

  /// Android platform description
  ///
  /// In en, this message translates to:
  /// **'Android specific features can be implemented here.'**
  String get androidSpecificFeatures;

  /// Material design feature
  ///
  /// In en, this message translates to:
  /// **'Material Design'**
  String get materialDesign;

  /// Push notifications feature
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// App shortcuts feature
  ///
  /// In en, this message translates to:
  /// **'App Shortcuts'**
  String get appShortcuts;

  /// Background services feature
  ///
  /// In en, this message translates to:
  /// **'Background Services'**
  String get backgroundServices;

  /// iOS platform title
  ///
  /// In en, this message translates to:
  /// **'iOS Platform'**
  String get iOSPlatform;

  /// iOS features section title
  ///
  /// In en, this message translates to:
  /// **'iOS Features:'**
  String get iOSFeatures;

  /// iOS platform description
  ///
  /// In en, this message translates to:
  /// **'iOS specific features can be implemented here.'**
  String get iOSSpecificFeatures;

  /// Cupertino design feature
  ///
  /// In en, this message translates to:
  /// **'Cupertino Design'**
  String get cupertinoDesign;

  /// App Clips feature
  ///
  /// In en, this message translates to:
  /// **'App Clips'**
  String get appClips;

  /// Siri Shortcuts feature
  ///
  /// In en, this message translates to:
  /// **'Siri Shortcuts'**
  String get siriShortcuts;

  /// Linux platform title
  ///
  /// In en, this message translates to:
  /// **'Linux Platform'**
  String get linuxPlatform;

  /// Linux features section title
  ///
  /// In en, this message translates to:
  /// **'Linux Features:'**
  String get linuxFeatures;

  /// Linux platform description
  ///
  /// In en, this message translates to:
  /// **'Linux specific features can be implemented here.'**
  String get linuxSpecificFeatures;

  /// GTK integration feature
  ///
  /// In en, this message translates to:
  /// **'Native GTK Integration'**
  String get nativeGtkIntegration;

  /// System tray feature
  ///
  /// In en, this message translates to:
  /// **'System Tray Support'**
  String get systemTraySupport;

  /// Desktop files feature
  ///
  /// In en, this message translates to:
  /// **'Desktop Files'**
  String get desktopFiles;

  /// Package management feature
  ///
  /// In en, this message translates to:
  /// **'Package Management'**
  String get packageManagement;

  /// Web platform title
  ///
  /// In en, this message translates to:
  /// **'Web Platform'**
  String get webPlatform;

  /// Web features section title
  ///
  /// In en, this message translates to:
  /// **'Web Features:'**
  String get webFeatures;

  /// Web platform description
  ///
  /// In en, this message translates to:
  /// **'Web specific features can be implemented here.'**
  String get webSpecificFeatures;

  /// PWA feature
  ///
  /// In en, this message translates to:
  /// **'Progressive Web App'**
  String get progressiveWebApp;

  /// Browser storage feature
  ///
  /// In en, this message translates to:
  /// **'Browser Storage'**
  String get browserStorage;

  /// URL routing feature
  ///
  /// In en, this message translates to:
  /// **'URL Routing'**
  String get urlRouting;

  /// Web APIs feature
  ///
  /// In en, this message translates to:
  /// **'Web APIs'**
  String get webApis;

  /// Config editor page title
  ///
  /// In en, this message translates to:
  /// **'Config Editor'**
  String get configEditor;

  /// Config update success message
  ///
  /// In en, this message translates to:
  /// **'Configuration updated'**
  String get configUpdated;

  /// Current platform display
  ///
  /// In en, this message translates to:
  /// **'Current Platform: {platform}'**
  String currentPlatform(String platform);

  /// Available pages list
  ///
  /// In en, this message translates to:
  /// **'Available Pages: {pages}'**
  String availablePages(String pages);

  /// Available features list
  ///
  /// In en, this message translates to:
  /// **'Available Features: {features}'**
  String availableFeatures(String features);

  /// Page configuration section title
  ///
  /// In en, this message translates to:
  /// **'Page Configuration'**
  String get pageConfiguration;

  /// Feature configuration section title
  ///
  /// In en, this message translates to:
  /// **'Feature Configuration'**
  String get featureConfiguration;

  /// Debug information section title
  ///
  /// In en, this message translates to:
  /// **'Debug Info'**
  String get debugInfo;

  /// Print config tooltip
  ///
  /// In en, this message translates to:
  /// **'Print config information'**
  String get printConfigInfo;

  /// Save config tooltip
  ///
  /// In en, this message translates to:
  /// **'Save config'**
  String get saveConfig;

  /// Map atlas page title
  ///
  /// In en, this message translates to:
  /// **'Map Atlas'**
  String get mapAtlas;

  /// Empty state message for map atlas
  ///
  /// In en, this message translates to:
  /// **'No maps available'**
  String get mapAtlasEmpty;

  /// Add map button
  ///
  /// In en, this message translates to:
  /// **'Add Map'**
  String get addMap;

  /// Map title input label
  ///
  /// In en, this message translates to:
  /// **'Map Title'**
  String get mapTitle;

  /// Map title input hint
  ///
  /// In en, this message translates to:
  /// **'Enter map title'**
  String get enterMapTitle;

  /// Delete map dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Map'**
  String get deleteMap;

  /// Delete map confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the map \"{title}\"?'**
  String confirmDeleteMap(String title);

  /// Export database button
  ///
  /// In en, this message translates to:
  /// **'Export Database'**
  String get exportDatabase;

  /// Import database button
  ///
  /// In en, this message translates to:
  /// **'Import Database'**
  String get importDatabase;

  /// Resource management section title
  ///
  /// In en, this message translates to:
  /// **'Resource Management'**
  String get resourceManagement;

  /// Import failed error message
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importFailed(String error);

  /// Map add success message
  ///
  /// In en, this message translates to:
  /// **'Map added successfully'**
  String get mapAddedSuccessfully;

  /// Map delete success message
  ///
  /// In en, this message translates to:
  /// **'Map deleted successfully'**
  String get mapDeletedSuccessfully;

  /// Map add error message
  ///
  /// In en, this message translates to:
  /// **'Failed to add map: {error}'**
  String addMapFailed(String error);

  /// Map delete error message
  ///
  /// In en, this message translates to:
  /// **'Failed to delete map: {error}'**
  String deleteMapFailed(String error);

  /// Load maps error message
  ///
  /// In en, this message translates to:
  /// **'Failed to load maps: {error}'**
  String loadMapsFailed(String error);

  /// Legend manager page title
  ///
  /// In en, this message translates to:
  /// **'Legend Manager'**
  String get legendManager;

  /// Message when no legends are available
  ///
  /// In en, this message translates to:
  /// **'No legends available'**
  String get legendManagerEmpty;

  /// Add legend button
  ///
  /// In en, this message translates to:
  /// **'Add Legend'**
  String get addLegend;

  /// Legend title field label
  ///
  /// In en, this message translates to:
  /// **'Legend Title'**
  String get legendTitle;

  /// Legend title field hint
  ///
  /// In en, this message translates to:
  /// **'Please enter legend title'**
  String get enterLegendTitle;

  /// Legend version field label
  ///
  /// In en, this message translates to:
  /// **'Legend Version'**
  String get legendVersion;

  /// Center point selection label
  ///
  /// In en, this message translates to:
  /// **'Select Center Point:'**
  String get selectCenterPoint;

  /// Delete legend button
  ///
  /// In en, this message translates to:
  /// **'Delete Legend'**
  String get deleteLegend;

  /// Delete legend confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete legend \"{title}\"?'**
  String confirmDeleteLegend(String title);

  /// Legend deleted success message
  ///
  /// In en, this message translates to:
  /// **'Legend deleted successfully'**
  String get legendDeletedSuccessfully;

  /// Delete legend error message
  ///
  /// In en, this message translates to:
  /// **'Failed to delete legend: {error}'**
  String deleteLegendFailed(String error);

  /// Upload localization file button
  ///
  /// In en, this message translates to:
  /// **'Upload Localization File'**
  String get uploadLocalizationFile;

  /// Map editor page title
  ///
  /// In en, this message translates to:
  /// **'Map Editor'**
  String get mapEditor;

  /// Map preview page title
  ///
  /// In en, this message translates to:
  /// **'Map Preview'**
  String get mapPreview;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Layers panel title
  ///
  /// In en, this message translates to:
  /// **'Layers'**
  String get layers;

  /// Legend panel title
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get legend;

  /// Add layer button
  ///
  /// In en, this message translates to:
  /// **'Add Layer'**
  String get addLayer;

  /// Delete layer confirmation title
  ///
  /// In en, this message translates to:
  /// **'Delete Layer'**
  String get deleteLayer;

  /// Opacity label
  ///
  /// In en, this message translates to:
  /// **'Opacity'**
  String get opacity;

  /// Elements count label
  ///
  /// In en, this message translates to:
  /// **'elements'**
  String get elements;

  /// Drawing tools section title
  ///
  /// In en, this message translates to:
  /// **'Drawing Tools'**
  String get drawingTools;

  /// Line drawing tool
  ///
  /// In en, this message translates to:
  /// **'Line'**
  String get line;

  /// Dashed line drawing tool
  ///
  /// In en, this message translates to:
  /// **'Dashed Line'**
  String get dashedLine;

  /// Arrow drawing tool
  ///
  /// In en, this message translates to:
  /// **'Arrow'**
  String get arrow;

  /// Rectangle drawing tool
  ///
  /// In en, this message translates to:
  /// **'Rectangle'**
  String get rectangle;

  /// Hollow rectangle drawing tool
  ///
  /// In en, this message translates to:
  /// **'Hollow Rectangle'**
  String get hollowRectangle;

  /// Diagonal lines pattern tool
  ///
  /// In en, this message translates to:
  /// **'Diagonal Lines'**
  String get diagonalLines;

  /// Cross lines pattern tool
  ///
  /// In en, this message translates to:
  /// **'Cross Lines'**
  String get crossLines;

  /// Dot grid pattern tool
  ///
  /// In en, this message translates to:
  /// **'Dot Grid'**
  String get dotGrid;

  /// Stroke width label
  ///
  /// In en, this message translates to:
  /// **'Stroke Width'**
  String get strokeWidth;

  /// Color label
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// Add legend group button
  ///
  /// In en, this message translates to:
  /// **'Add Legend Group'**
  String get addLegendGroup;

  /// Delete legend group confirmation title
  ///
  /// In en, this message translates to:
  /// **'Delete Legend Group'**
  String get deleteLegendGroup;

  /// Save map button
  ///
  /// In en, this message translates to:
  /// **'Save Map'**
  String get saveMap;

  /// Mode label
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// User preferences page title
  ///
  /// In en, this message translates to:
  /// **'User Preferences'**
  String get userPreferences;

  /// Layer selection settings section
  ///
  /// In en, this message translates to:
  /// **'Layer Selection Settings'**
  String get layerSelectionSettings;

  /// Auto-select last layer in group setting
  ///
  /// In en, this message translates to:
  /// **'Auto-select last layer in group'**
  String get autoSelectLastLayerInGroup;

  /// Description for auto-select last layer in group setting
  ///
  /// In en, this message translates to:
  /// **'Automatically select the last layer when a layer group is selected'**
  String get autoSelectLastLayerInGroupDescription;

  /// Primary color setting
  ///
  /// In en, this message translates to:
  /// **'Primary Color'**
  String get primaryColor;

  /// Accent color setting
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get accentColor;

  /// Auto save setting
  ///
  /// In en, this message translates to:
  /// **'Auto Save'**
  String get autoSave;

  /// Grid size setting
  ///
  /// In en, this message translates to:
  /// **'Grid Size'**
  String get gridSize;

  /// Compact mode setting
  ///
  /// In en, this message translates to:
  /// **'Compact Mode'**
  String get compactMode;

  /// Show tooltips setting
  ///
  /// In en, this message translates to:
  /// **'Show Tooltips'**
  String get showTooltips;

  /// Enable animations setting
  ///
  /// In en, this message translates to:
  /// **'Enable Animations'**
  String get enableAnimations;

  /// Animation duration setting
  ///
  /// In en, this message translates to:
  /// **'Animation Duration (ms)'**
  String get animationDuration;

  /// Recent colors setting
  ///
  /// In en, this message translates to:
  /// **'Recent Colors'**
  String get recentColors;

  /// Favorite stroke widths setting
  ///
  /// In en, this message translates to:
  /// **'Favorite Stroke Widths'**
  String get favoriteStrokeWidths;

  /// Show advanced tools setting
  ///
  /// In en, this message translates to:
  /// **'Show Advanced Tools'**
  String get showAdvancedTools;

  /// Current user setting
  ///
  /// In en, this message translates to:
  /// **'Current User'**
  String get currentUser;

  /// User profiles setting
  ///
  /// In en, this message translates to:
  /// **'User Profiles'**
  String get userProfiles;

  /// Export settings button
  ///
  /// In en, this message translates to:
  /// **'Export Settings'**
  String get exportSettings;

  /// Import settings button
  ///
  /// In en, this message translates to:
  /// **'Import Settings'**
  String get importSettings;

  /// Reset settings button
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get resetSettings;

  /// Confirm reset settings dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all settings to defaults? This cannot be undone.'**
  String get confirmResetSettings;

  /// Settings exported success message
  ///
  /// In en, this message translates to:
  /// **'Settings exported successfully'**
  String get settingsExported;

  /// Settings imported success message
  ///
  /// In en, this message translates to:
  /// **'Settings imported successfully'**
  String get settingsImported;

  /// Settings reset success message
  ///
  /// In en, this message translates to:
  /// **'Settings reset to defaults'**
  String get settingsReset;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
