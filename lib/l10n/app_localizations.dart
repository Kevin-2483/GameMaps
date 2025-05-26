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

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'R6Box'**
  String get appTitle;

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

  /// System language option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemLanguage;

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

  /// App subtitle description
  ///
  /// In en, this message translates to:
  /// **'Comprehensive Flutter Cross-Platform Framework'**
  String get comprehensiveFramework;

  /// Platform integration section title
  ///
  /// In en, this message translates to:
  /// **'Platform Integration'**
  String get platformIntegration;

  /// Features section title
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// Message when no features are enabled
  ///
  /// In en, this message translates to:
  /// **'No features enabled'**
  String get noFeaturesEnabled;

  /// Instructions to enable features
  ///
  /// In en, this message translates to:
  /// **'Enable features in settings to see them here'**
  String get enableFeaturesInSettings;

  /// About dialog content
  ///
  /// In en, this message translates to:
  /// **'Flutter Cross-Platform Framework\nSupporting multiple platforms with modern architecture'**
  String get aboutDialogContent;

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

  /// Android feature
  ///
  /// In en, this message translates to:
  /// **'Native Android UI'**
  String get nativeAndroidUI;

  /// Android notifications feature
  ///
  /// In en, this message translates to:
  /// **'Android Notifications'**
  String get androidNotifications;

  /// Android permissions feature
  ///
  /// In en, this message translates to:
  /// **'Android Permissions'**
  String get androidPermissions;

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

  /// iOS feature
  ///
  /// In en, this message translates to:
  /// **'Native iOS UI'**
  String get nativeIOSUI;

  /// iOS notifications feature
  ///
  /// In en, this message translates to:
  /// **'iOS Notifications'**
  String get iOSNotifications;

  /// App Store feature
  ///
  /// In en, this message translates to:
  /// **'App Store Integration'**
  String get appStoreIntegration;

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

  /// Update external resources button
  ///
  /// In en, this message translates to:
  /// **'Update External Resources'**
  String get updateExternalResources;

  /// Resource management section title
  ///
  /// In en, this message translates to:
  /// **'Resource Management'**
  String get resourceManagement;

  /// Update external resources description
  ///
  /// In en, this message translates to:
  /// **'Update map database from external file'**
  String get updateExternalResourcesDescription;

  /// Export success message
  ///
  /// In en, this message translates to:
  /// **'Database exported successfully: {path}'**
  String exportSuccessful(String path);

  /// Import success message
  ///
  /// In en, this message translates to:
  /// **'Database imported successfully'**
  String get importSuccessful;

  /// Update success message
  ///
  /// In en, this message translates to:
  /// **'External resources updated successfully'**
  String get updateSuccessful;

  /// Export error message
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// Import error message
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importFailed(String error);

  /// Update error message
  ///
  /// In en, this message translates to:
  /// **'Update failed: {error}'**
  String updateFailed(String error);

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
