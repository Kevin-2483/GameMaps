// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get about => 'About';

  @override
  String get aboutPageTitle_4821 => 'About';

  @override
  String get aboutPageTitle_4901 => 'About';

  @override
  String get aboutR6box_7281 => 'About R6BOX';

  @override
  String get about_5421 => 'About';

  @override
  String get accentColor => 'Accent color';

  @override
  String get accountAdded_5421 => 'Account added';

  @override
  String get accountDeletedSuccess_4821 =>
      'Authenticated account has been deleted';

  @override
  String accountInUseMessage_4821(Object configCount) {
    return 'This account is being used by $configCount configurations and cannot be deleted';
  }

  @override
  String get accountNameHint_7532 => 'e.g. My Account';

  @override
  String get accountSettings_7421 => 'Account Settings';

  @override
  String get accountUpdated_5421 => 'Account updated';

  @override
  String activeClientDisplay(Object displayName) {
    return 'Active client: $displayName';
  }

  @override
  String get activeClient_7281 => 'Active client';

  @override
  String get activeConfigCancelled_7281 => 'Active configuration canceled';

  @override
  String activeConfigChange(Object clientId, Object displayName) {
    return 'Active configuration change: $displayName ($clientId)';
  }

  @override
  String get activeConfigCleared_7281 => 'Active configuration cleared';

  @override
  String activeConfigLog(Object displayName) {
    return 'Currently active configuration: $displayName';
  }

  @override
  String get activeConfigSetSuccess_4821 =>
      'Active configuration set successfully';

  @override
  String activeMapWithCount(Object count) {
    return 'Active maps ($count)';
  }

  @override
  String get activeMap_7281 => 'Active Map';

  @override
  String get activeMap_7421 => 'Active Map';

  @override
  String activeWebSocketClientConfigSet(Object clientId) {
    return 'Active WebSocket client configuration set: $clientId';
  }

  @override
  String get activityLog_7281 => 'Activity Log';

  @override
  String get actualSize_7421 => 'Actual size';

  @override
  String get adaptiveIconTheme_7421 => 'Adapt icon color to current theme';

  @override
  String get addAccount_7421 => 'Add Account';

  @override
  String get addAllLayers_4821 => 'Add all layers';

  @override
  String get addAtLeastOneExportItem_4821 =>
      'Please add at least one export item';

  @override
  String get addAuthAccount_8753 => 'Add authentication account';

  @override
  String get addBackground_7281 => 'Add background';

  @override
  String get addButton_4821 => 'Add';

  @override
  String get addButton_5421 => 'Add';

  @override
  String get addButton_7284 => 'Add';

  @override
  String get addButton_7421 => 'Add';

  @override
  String addColorFailed(Object e) {
    return 'Failed to add color: $e';
  }

  @override
  String get addColorFailed_4829 => 'Failed to add color';

  @override
  String get addColor_7421 => 'Add color';

  @override
  String get addConfiguration_7421 => 'Add Configuration';

  @override
  String addCustomColorFailed(Object error) {
    return 'Failed to add custom color: $error';
  }

  @override
  String addCustomColorFailed_7285(Object e) {
    return 'Failed to add custom color: $e';
  }

  @override
  String get addCustomColor_4271 => 'Add custom color';

  @override
  String get addCustomColor_7421 => 'Add custom color';

  @override
  String get addCustomField_4949 => 'Add Custom Field';

  @override
  String addCustomTagFailed(Object error) {
    return 'Failed to add custom tag: $error';
  }

  @override
  String addCustomTagFailed_7285(Object e) {
    return 'Failed to add custom tag: $e';
  }

  @override
  String get addCustomTagHint_4821 => 'Add custom tag';

  @override
  String get addCustomTag_4271 => 'Add custom tag';

  @override
  String addDefaultLayerWithReactiveSystem(Object name) {
    return 'Add default layer with reactive system: $name';
  }

  @override
  String get addDividerLine_4821 => 'Add divider line';

  @override
  String addDrawingElement(Object elementId, Object layerId) {
    return 'Add drawing element: $layerId/$elementId';
  }

  @override
  String get addExportItem_4964 => 'Add Export Item';

  @override
  String get addImageAreaTooltip_4282 => 'Add image area';

  @override
  String get addLabel_4271 => 'Add label';

  @override
  String get addLayer => 'Add Layer';

  @override
  String addLayerFailed_4821(Object error) {
    return 'Failed to add layer: $error';
  }

  @override
  String get addLayerHint_7281 =>
      'Click the plus icon on the left  \nAdd layer';

  @override
  String addLayerLog(Object name) {
    return 'Add layer: $name';
  }

  @override
  String get addLayerOrItemFromLeft_4821 => 'Add a layer or item from the left';

  @override
  String addLayerWithReactiveSystem(Object name) {
    return 'Add layer with reactive system: $name';
  }

  @override
  String get addLayer_7281 => 'Add Layer';

  @override
  String get addLegend => 'Add Legend';

  @override
  String addLegendFailed_7285(Object e) {
    return 'Failed to add legend: $e';
  }

  @override
  String get addLegendGroup => 'Add Legend Group';

  @override
  String addLegendGroupElement(
    Object isLegendSelected,
    Object legendRenderOrder,
  ) {
    return 'Add legend group element - renderOrder=$legendRenderOrder, selected=$isLegendSelected';
  }

  @override
  String addLegendGroupFailed(Object error) {
    return 'Failed to add legend group: $error';
  }

  @override
  String get addLegendGroup_7352 => 'Add Legend Group';

  @override
  String get addLegendTooltip_7281 => 'Add legend';

  @override
  String get addLegend_4271 => 'Add Legend';

  @override
  String get addLegend_4521 => 'Add Legend';

  @override
  String addLineWidthFailed(Object error) {
    return 'Failed to add common line width: $error';
  }

  @override
  String get addLineWidth_4821 => 'Add line width';

  @override
  String get addMap => 'Add Map';

  @override
  String addMapFailed(Object error) {
    return 'Failed to add map: $error';
  }

  @override
  String get addNewLineWidth_4821 => 'Add new line width';

  @override
  String addNewMapWithVersion(Object title, Object version) {
    return 'Add new map: $title (Version $version)';
  }

  @override
  String get addNewShortcut_7421 => 'Add new shortcut:';

  @override
  String get addNewTagHint_4821 => 'Add new tag';

  @override
  String addNoteDebug_7421(Object id) {
    return 'Add sticky note: $id';
  }

  @override
  String addNoteFailed(Object e) {
    return 'Failed to add note: $e';
  }

  @override
  String addNoteFailed_7285(Object e) {
    return 'Failed to add note: $e';
  }

  @override
  String get addNote_7421 => 'Add Note';

  @override
  String addRecentColorFailed(Object error) {
    return 'Failed to add recent color: $error';
  }

  @override
  String get addRecentColorsTitle_7421 => 'Add recently used colors';

  @override
  String addRecentTagFailed(Object error) {
    return 'Failed to add recent tag: $error';
  }

  @override
  String get addScript => 'Add Script';

  @override
  String get addShortcut_7421 => 'Add shortcut';

  @override
  String get addStickyNote_7421 => 'Add sticky note';

  @override
  String get addTagTooltip_7281 => 'Add tag';

  @override
  String get addTag_7421 => 'Add';

  @override
  String addTextToNoteWithFontSize(Object fontSize) {
    return 'Add text to note (font size: ${fontSize}px)';
  }

  @override
  String get addTextToNote_7421 => 'Add text to note';

  @override
  String get addTextTooltip_4821 => 'Add text';

  @override
  String addTextWithFontSize(Object fontSize) {
    return 'Add text (font size: ${fontSize}px)';
  }

  @override
  String get addText_4271 => 'Add text';

  @override
  String get addToCustom_7281 => 'Add to custom';

  @override
  String get addToPlaylist_4271 => 'Add to playlist';

  @override
  String get addWebDavConfig => 'Add WebDAV Configuration';

  @override
  String get addedLineWidth_4821 => 'Added line width:';

  @override
  String addedPathsCount(Object count) {
    return 'Added paths: $count';
  }

  @override
  String get addedToQueue_7421 => 'Added to playback queue';

  @override
  String addingCustomColor_7281(Object color) {
    return 'Start adding custom color: $color';
  }

  @override
  String get adjustDrawingElementHandleSize_7281 =>
      'Adjust the size of drawing element handles';

  @override
  String adjustNewIndexTo(Object newIndex) {
    return 'Adjust newIndex to: $newIndex';
  }

  @override
  String get adjustVoicePitch_4271 => 'Adjust voice pitch';

  @override
  String get adjustVoiceSpeed_4271 => 'Adjust voice playback speed';

  @override
  String get adjustVoiceVolume_4251 => 'Adjust voice playback volume';

  @override
  String adjustedNewIndex_7421(Object newIndex) {
    return 'Adjusted newIndex: $newIndex';
  }

  @override
  String get advancedColorPicker_4821 => 'Advanced Color Picker';

  @override
  String get affectsPerspectiveBuffer_4821 => 'Affects perspective buffer';

  @override
  String get albumLabel_4821 => 'Album';

  @override
  String allLayersDebugMessage_7421(Object layers) {
    return 'allLayers retrieved from _currentMap: $layers';
  }

  @override
  String allLayersHiddenLegendAutoHidden(Object totalLayersCount) {
    return 'Enabled: All $totalLayersCount bound layers are hidden, legend group is auto-hidden';
  }

  @override
  String get allLayersShown_7281 => 'All layers are shown';

  @override
  String get allPathsValid_7281 =>
      'All file paths have been verified and are ready for import.';

  @override
  String get allReactiveVersionsSavedToVfs_7281 =>
      'All reactive version data has been successfully saved to VFS storage';

  @override
  String get allTimersCleared_4821 => 'All timers have been cleared';

  @override
  String get allTimersStopped_7281 => 'All timers have stopped';

  @override
  String get allUserPreferencesCleared_4821 =>
      'All user preference data has been cleared';

  @override
  String allVersionsSaved_7281(Object mapTitle) {
    return 'All versions marked as saved [$mapTitle]';
  }

  @override
  String get allWebDavPasswordsCleared_7281 =>
      'All WebDAV passwords have been cleared';

  @override
  String get analysis_2346 => 'Analysis';

  @override
  String anchorJumpFailed_4829(Object e) {
    return 'Anchor jump failed: $e';
  }

  @override
  String anchorJumpFailed_7285(Object e) {
    return 'Failed to jump to anchor: $e';
  }

  @override
  String anchorNotFound_7425(Object searchText) {
    return 'Anchor not found: $searchText';
  }

  @override
  String get androidFeatures => 'Android Features:';

  @override
  String get androidPlatform => 'Android platform';

  @override
  String get androidSpecificFeatures =>
      'Android-specific features can be implemented here.';

  @override
  String get animateColorChange_9202 => 'Animate color change';

  @override
  String get animateElementMovement_1222 => 'Animate element movement';

  @override
  String get animationDuration => 'Animation duration (milliseconds)';

  @override
  String get animationDuration_4271 => 'Animation duration';

  @override
  String get animationScriptExample_7181 => 'Animation script example';

  @override
  String get animation_5678 => 'Animation';

  @override
  String get animation_7281 => 'Animation';

  @override
  String get annotationLayer_1234 => 'Annotation Layer';

  @override
  String apiResponseStatusError_7284(Object status) {
    return 'API response status error: $status';
  }

  @override
  String get appClips => 'App Clips';

  @override
  String get appDescriptionText_4904 =>
      'R6BOX is a comprehensive toolbox application designed for Rainbow Six Siege players. It provides map editor, tactical analysis, data statistics and other functions to help players improve their gaming experience and competitive level.';

  @override
  String get appDescription_4903 => 'App Description';

  @override
  String get appName_4914 => 'R6BOX';

  @override
  String get appSettings_4821 => 'App Settings';

  @override
  String get appShortcuts => 'App Shortcuts';

  @override
  String appVersion_4902(Object buildNumber, Object version) {
    return 'Version $version ($buildNumber)';
  }

  @override
  String get applySameResolutionToAllConflicts_4821 =>
      'Apply the same resolution to all remaining conflicts';

  @override
  String get applyToAllConflicts_7281 => 'Apply to all conflicts';

  @override
  String get arabicSA_4890 => 'Arabic (Saudi Arabia)';

  @override
  String get arabic_4836 => 'Arabic';

  @override
  String get argbColorDescription_7281 => '• ARGB: FFFF0000 (red, opaque)';

  @override
  String get arrow => 'Arrow';

  @override
  String get arrowLabel_5421 => 'Arrow';

  @override
  String get arrowTool_7890 => 'Arrow';

  @override
  String get arrow_4823 => 'Arrow';

  @override
  String get arrow_6423 => 'Arrow';

  @override
  String get artistLabel_4821 => 'Artist';

  @override
  String assetDeletionFailed_7425(Object e, Object hash, Object mapTitle) {
    return 'Failed to delete asset [$mapTitle/$hash]: $e';
  }

  @override
  String assetFetchFailed(Object arg0, Object arg1, Object arg2) {
    return 'Failed to fetch asset [$arg0/$arg1]: $arg2';
  }

  @override
  String asyncFunctionCompleteDebug(Object functionName, Object runtimeType) {
    return 'Asynchronous function $functionName completed, result type: $runtimeType';
  }

  @override
  String asyncFunctionError_4821(Object error, Object functionName) {
    return 'Error in async function $functionName: $error';
  }

  @override
  String get atlasClient_7421 => 'Atlas Client';

  @override
  String get audioBackgroundPlay_7281 =>
      '🎵 Window closed, audio continues playing in the background';

  @override
  String audioBalanceError_4821(Object e) {
    return 'Failed to set audio balance: $e';
  }

  @override
  String audioBalanceSet_7421(Object balance) {
    return 'Audio balance set to $balance';
  }

  @override
  String get audioBalance_7281 => 'Audio Balance';

  @override
  String get audioConversionComplete_7284 =>
      '🎵 AudioProcessor.convertMarkdownAudios: Conversion complete';

  @override
  String audioCountLabel(Object audioCount) {
    return 'Audio count: $audioCount';
  }

  @override
  String get audioEqualizer_4821 => 'Audio Equalizer';

  @override
  String get audioFile_7281 => 'Audio file';

  @override
  String get audioInfo_4271 => 'Audio Info';

  @override
  String get audioInfo_7284 => 'Audio Info';

  @override
  String get audioInfo_7421 => 'Audio Info';

  @override
  String get audioLinkCopiedToClipboard_4821 =>
      'Audio link copied to clipboard';

  @override
  String get audioList_7421 => 'Audio list:';

  @override
  String get audioLoadFailed_7281 => 'Audio loading failed';

  @override
  String audioNodeBuildStart_7421(Object src) {
    return '🎵 AudioNode.build: Start building - src: $src';
  }

  @override
  String audioNodeGenerationLog(
    Object attributes,
    Object playerId,
    Object tag,
    Object textContent,
  ) {
    return '🎵 AudioProcessor: Generating AudioNode - tag: $tag, attributes: $attributes, textContent: $textContent, uuid: $playerId';
  }

  @override
  String audioPlaybackFailed(Object e) {
    return 'Failed to stop audio playback: $e';
  }

  @override
  String get audioPlayerClearQueue_4821 =>
      '🎵 AudioPlayerService: Clear Playback Queue';

  @override
  String audioPlayerError_4821(Object error) {
    return 'AudioNode: Player error - $error';
  }

  @override
  String get audioPlayerFallback_4821 =>
      '🎵 AudioPlayerService: Seek operation timed out, using fallback solution';

  @override
  String audioPlayerInitFailed(Object e) {
    return 'Failed to initialize audio player: $e';
  }

  @override
  String get audioPlayerInitFailed_4821 => 'Initialization failed';

  @override
  String audioPlayerInitFailed_7284(Object e) {
    return 'Audio player initialization failed: $e';
  }

  @override
  String get audioPlayerInitialized_7281 =>
      '🎵 AudioPlayerService: Audio player initialization completed';

  @override
  String get audioPlayerPaused_7281 => '🎵 AudioPlayerService: Paused';

  @override
  String get audioPlayerQueueUpdated_7281 =>
      '🎵 AudioPlayerService: Playback queue updated';

  @override
  String get audioPlayerReachedEnd_7281 =>
      '🎵 AudioPlayerService: Reached the end of the playback queue';

  @override
  String get audioPlayerReachedStart_7281 =>
      '🎵 AudioPlayerService: Reached the start of the playback queue';

  @override
  String get audioPlayerServiceGenerateUrl_4821 =>
      '🎵 AudioPlayerService: Generating playback URL from VFS';

  @override
  String audioPlayerStartPlaying_7421(Object audioSource) {
    return 'Start playing - $audioSource';
  }

  @override
  String audioPlayerStopFailure_4821(Object e) {
    return 'Failed to stop - $e';
  }

  @override
  String get audioPlayerStopped_7281 => '🎵 AudioPlayerService: Stopped';

  @override
  String audioPlayerTempQueuePlaying_7421(Object title) {
    return '🎵 AudioPlayerService: Temporary queue started playing - $title';
  }

  @override
  String get audioPlayerTimeout_4821 =>
      '🎵 AudioPlayerService: Pause operation timed out, but processing continues';

  @override
  String get audioPlayerTimeout_7421 =>
      '🎵 AudioPlayerService: Playback operation timed out, but processing continues';

  @override
  String get audioPlayerTitle_7281 => 'Audio Player';

  @override
  String get audioPlayerUsingNetworkUrl_4821 =>
      '🎵 AudioPlayerService: Playing with network URL';

  @override
  String audioProcessorConvertMarkdownAudios(Object audioTag) {
    return 'AudioProcessor.convertMarkdownAudios: Generate tag $audioTag';
  }

  @override
  String audioProcessorConvertMarkdownAudios_7428(Object src) {
    return 'AudioProcessor.convertMarkdownAudios: Convert $src';
  }

  @override
  String get audioProcessorConvertStart_7281 =>
      '🎵 AudioProcessor.convertMarkdownAudios: Conversion started';

  @override
  String get audioProcessorCreated_4821 =>
      '🎵 AudioProcessor: Audio generator created';

  @override
  String audioProcessorDebugInfo(Object result, Object textLength) {
    return '🎵 AudioProcessor.containsAudio: text length=$textLength, contains audio=$result';
  }

  @override
  String audioServiceCleanupFailed(Object e) {
    return 'Failed to clean up audio service: $e';
  }

  @override
  String audioServiceError_4829(Object e) {
    return 'An error occurred while stopping the audio service: $e';
  }

  @override
  String audioServiceStopFailed(Object e) {
    return 'Failed to stop audio playback service: $e';
  }

  @override
  String audioServiceStopTime(Object elapsedMilliseconds) {
    return 'Audio service stop time: ${elapsedMilliseconds}ms';
  }

  @override
  String get audioServiceStopped_7281 => 'Audio service stopped successfully';

  @override
  String get audioSourceLoaded_7281 =>
      '🎵 AudioPlayerService: Audio source loaded successfully';

  @override
  String audioSourceLoading_4821(Object source) {
    return 'Starting to load audio source - $source';
  }

  @override
  String audioStatus_7421(Object status) {
    return 'Audio $status';
  }

  @override
  String get audioSyntaxParserAdded_7281 =>
      '🎵 _buildMarkdownContent: Added audio syntax parser and generator';

  @override
  String get authFailedChallengeDecrypt_7281 => 'authFailedChallengeDecrypt';

  @override
  String get authFailedMessage_4821 => 'Authentication failed';

  @override
  String authMessageSent(Object type) {
    return 'Authentication message sent: $type';
  }

  @override
  String authProcessError_4821(Object e) {
    return 'Authentication process error: $e';
  }

  @override
  String get authenticating_6934 => 'Authenticating';

  @override
  String get authenticating_6943 => 'Authenticating';

  @override
  String get authenticationAccount_7281 => 'Authenticate account';

  @override
  String authenticationError(Object e) {
    return 'An error occurred during authentication: $e';
  }

  @override
  String authenticationError_7425(Object e) {
    return 'An error occurred during authentication: $e';
  }

  @override
  String authenticationFailed(Object reason) {
    return 'authenticationFailed: $reason';
  }

  @override
  String get authenticationResult_7425 => 'Authentication result';

  @override
  String get authenticationSuccess_7421 => 'authenticationSuccess';

  @override
  String get authenticationTimeout_7281 => 'Authentication process timed out';

  @override
  String get author_4937 => 'Author';

  @override
  String get author_5028 => 'Author';

  @override
  String get autoCleanupDescription_4984 =>
      'Temporary files will be automatically cleaned up after processing';

  @override
  String get autoCleanup_4983 => 'Auto Cleanup';

  @override
  String get autoCloseTooltip_4821 =>
      'Auto close: Automatically close this toolbar when clicking on other toolbars';

  @override
  String get autoCloseWhenLoseFocus_7281 => 'Auto Close';

  @override
  String get autoClose_7421 => 'Auto Close';

  @override
  String autoControlLegendVisibility(Object totalLayersCount) {
    return 'When enabled, automatically controls the visibility of legend groups based on the visibility of bound layers ($totalLayersCount layers in total)';
  }

  @override
  String get autoPlayText_4821 => 'Auto play';

  @override
  String get autoPresenceEnterMapEditor_7421 =>
      'Call AutoPresenceManager.enterMapEditor';

  @override
  String get autoResizeWindowHint_4821 =>
      'Automatically records window size changes and restores them on next launch';

  @override
  String get autoSave => 'Auto Save';

  @override
  String get autoSavePanelStateOnExit_4821 =>
      'Automatically save panel collapse/expand state when exiting the map editor';

  @override
  String get autoSaveSetting_7421 => 'Auto Save';

  @override
  String get autoSaveWindowSizeDisabled_7281 =>
      'Auto-save window size is disabled, skipping save';

  @override
  String get autoSaveWindowSize_4271 => 'Auto-save window size';

  @override
  String get autoSave_7421 => 'Auto Save';

  @override
  String get autoSelectLastLayerInGroup =>
      'Automatically select the last layer in the group';

  @override
  String get autoSelectLastLayerInGroupDescription =>
      'Automatically select the last layer in the group when selecting a layer group';

  @override
  String autoSwitchLegendGroupDrawer(Object name) {
    return 'Automatically switch the legend group drawer to the bound legend group: $name';
  }

  @override
  String get autoThemeDark => 'Auto Theme (Currently Dark)';

  @override
  String get autoThemeLight => 'Auto theme (currently light)';

  @override
  String get automationScriptExample_1234 => 'Automation script example';

  @override
  String get automation_1234 => 'Automation';

  @override
  String get automation_7281 => 'Automation';

  @override
  String availableFeatures(Object features) {
    return 'Available features: $features';
  }

  @override
  String availableFeaturesMessage_7281(Object features) {
    return 'Available features: $features';
  }

  @override
  String availableLanguages_7421(Object availableLanguages) {
    return 'Available languages: $availableLanguages';
  }

  @override
  String availableLayersCount(Object count) {
    return 'Available layers ($count)';
  }

  @override
  String availableLegendGroups(Object count) {
    return 'Available legend groups ($count)';
  }

  @override
  String availablePages(Object pages) {
    return 'Available pages: $pages';
  }

  @override
  String availablePagesList_7281(Object pages) {
    return 'Available pages: $pages';
  }

  @override
  String availableVoicesMessage(Object availableVoices) {
    return 'Available voices: $availableVoices';
  }

  @override
  String get avatarRemoved_4281 => 'Avatar removed';

  @override
  String get avatarTitle_4821 => 'Avatar';

  @override
  String get avatarUploaded_7421 => 'Avatar uploaded';

  @override
  String get avatarUrlOptional_4821 => 'Avatar URL (optional)';

  @override
  String get backButton_7421 => 'Back';

  @override
  String get backButton_75 => 'Back';

  @override
  String get back_4821 => 'Back';

  @override
  String get backgroundDialogClosed_7281 =>
      'The background image settings dialog was closed without applying changes.';

  @override
  String get backgroundElement_4821 => 'Background element';

  @override
  String backgroundImageOpacityLabel(Object value) {
    return 'Background image opacity: $value%';
  }

  @override
  String get backgroundImageRemoved_4821 => 'Background image has been removed';

  @override
  String get backgroundImageSetting_4271 => 'Background Image Settings';

  @override
  String get backgroundImageSetting_4821 => 'Background Image Settings';

  @override
  String get backgroundImageSettings_7421 => 'Background Image Settings';

  @override
  String get backgroundImageUploaded_4821 => 'Background image uploaded';

  @override
  String get backgroundImage_7421 => 'Background image';

  @override
  String get backgroundLayer_1234 => 'Background Layer';

  @override
  String get backgroundOpacity_4271 => 'Background Opacity';

  @override
  String get backgroundPattern_4271 => 'Background pattern';

  @override
  String backgroundPlayStatus(Object status) {
    return '🎵 AudioPlayerService: Background playback $status';
  }

  @override
  String get backgroundServices => 'Background Services';

  @override
  String get background_5421 => 'Background';

  @override
  String get background_7281 => 'Background';

  @override
  String get backupRestoreUnimplemented_7281 =>
      'Backup restore feature not yet implemented';

  @override
  String base64DecodeFailed(Object e) {
    return 'Failed to decode base64 image: $e';
  }

  @override
  String baseBufferMultiplierLog(Object multiplier) {
    return '- Base buffer multiplier: ${multiplier}x';
  }

  @override
  String baseBufferMultiplierText(Object value) {
    return 'Base buffer multiplier: ${value}x';
  }

  @override
  String baseGridSpacing_4827(Object value) {
    return 'Base grid spacing: ${value}px';
  }

  @override
  String baseIconSizeText(Object size) {
    return 'Base icon size: ${size}px';
  }

  @override
  String get baseLayer_1234 => 'Base Layer';

  @override
  String basicDisplayArea_7421(Object height, Object width) {
    return 'Basic display area: $width x $height';
  }

  @override
  String get basicFloatingWindowDescription_4821 =>
      'The simplest floating window with a title and content';

  @override
  String get basicFloatingWindowExample_4821 => 'Basic Floating Window Example';

  @override
  String get basicFloatingWindowTitle_4821 => 'Basic Floating Window';

  @override
  String get basicFloatingWindow_4821 => 'Basic floating window';

  @override
  String get basicInfo_4821 => 'Basic Information';

  @override
  String get basicOperations_4821 => 'Basic Operations';

  @override
  String basicScreenSize(Object height, Object width) {
    return 'Basic screen size: $width x $height';
  }

  @override
  String get batchAddToQueue_7421 => 'Batch add to playback queue';

  @override
  String batchDownloadFailed(Object error, Object fileName) {
    return 'Batch download failed for file \"$fileName\": $error';
  }

  @override
  String batchLoadComplete_7281(Object count, Object directoryPath) {
    return 'Batch load completed: $directoryPath, $count legends in total';
  }

  @override
  String batchLoadDirectoryFailed(Object directoryPath, Object e) {
    return 'Failed to batch load directory: $directoryPath, error: $e';
  }

  @override
  String batchUpdateElements(Object count, Object layerId) {
    return 'Batch update drawing elements: $layerId, count: $count';
  }

  @override
  String batchUpdateLayerFailed(Object error) {
    return 'Batch update layer failed: $error';
  }

  @override
  String batchUpdateLayersCount(Object count) {
    return 'Batch update layers, count: $count';
  }

  @override
  String batchUpdateTimerFailed(Object e) {
    return 'Batch update timer failed: $e';
  }

  @override
  String batchUpdateTimerFailed_7285(Object e) {
    return 'Batch update timer failed: $e';
  }

  @override
  String get batchUpdateWarning_7281 =>
      'Warning: No batch update API available, unable to properly move group';

  @override
  String get bindLayer_7281 => 'Bind Layer';

  @override
  String get bindLegendGroup_5421 => 'Bind Legend Group';

  @override
  String get bindScriptFailed => 'Failed to bind script';

  @override
  String get blankPattern_4821 => 'Blank';

  @override
  String blockCountUnit_7281(Object count) {
    return '$count';
  }

  @override
  String get blockFormula_4821 => 'Block-level formula';

  @override
  String get blueRectangles_7282 => 'blue rectangles';

  @override
  String get bookmark_7281 => 'Bookmark';

  @override
  String get booleanType_3456 => 'Boolean';

  @override
  String get bottomCenter_0123 => 'Bottom center';

  @override
  String get bottomLeftCut_4824 => 'Bottom left cut';

  @override
  String get bottomLeftTriangle_4821 => 'Bottom left triangle';

  @override
  String get bottomLeft_6789 => 'Bottom left';

  @override
  String get bottomLeft_7145 => 'Bottom left';

  @override
  String get bottomRightCut_4825 => 'Bottom right cut';

  @override
  String get bottomRightTriangle_4821 => 'Bottom right triangle';

  @override
  String get bottomRight_4567 => 'Bottom right';

  @override
  String get bottomRight_8256 => 'Bottom right';

  @override
  String boundGroupsCount(Object boundGroupsCount) {
    return '$boundGroupsCount legend groups bound';
  }

  @override
  String boundLayersLog_7284(Object boundLayerNames) {
    return 'Bound layers: $boundLayerNames';
  }

  @override
  String boundLayersTitle(Object count) {
    return 'Bound layers ($count)';
  }

  @override
  String boundLegendGroupsTitle(Object count) {
    return 'Bound legend groups ($count)';
  }

  @override
  String get boxFitContain_4821 => 'Contain';

  @override
  String get boxFitContain_4822 => 'Contain';

  @override
  String get boxFitContain_7281 => 'Contain';

  @override
  String get boxFitCover_4822 => 'Cover';

  @override
  String get boxFitCover_4823 => 'Cover';

  @override
  String get boxFitCover_7285 => 'Cover';

  @override
  String get boxFitFill_4821 => 'Fill';

  @override
  String get boxFitFill_4823 => 'Fill';

  @override
  String get boxFitFitHeight_4825 => 'Fit height';

  @override
  String get boxFitFitWidth_4824 => 'Fit Width';

  @override
  String boxFitModeSetTo(Object fit) {
    return 'Image fit mode set to: $fit';
  }

  @override
  String get boxFitNone_4826 => 'Original';

  @override
  String get boxFitScaleDown_4827 => 'Scale down';

  @override
  String get breadcrumbPath => '/ Root / Documents / Project Files';

  @override
  String get brightnessLabel_4821 => 'Brightness';

  @override
  String brightnessPercentage(Object percentage) {
    return 'Brightness: $percentage%';
  }

  @override
  String get brightness_4825 => 'Brightness';

  @override
  String get brightness_7285 => 'Brightness';

  @override
  String get brightness_7890 => 'Brightness';

  @override
  String broadcastStatusUpdateFailed(Object error) {
    return 'Failed to broadcast user status update: $error';
  }

  @override
  String get browserContextMenuDisabled_4821 =>
      '• The browser\'s default context menu has been disabled';

  @override
  String get browserStorage => 'Browser Storage';

  @override
  String get brushTool_4821 => 'Brush';

  @override
  String get brushTool_5678 => 'Brush';

  @override
  String bufferCalculationFormula_4821(
    Object areaMultiplier,
    Object baseMultiplier,
    Object bufferFactor,
    Object perspectiveStrength,
    Object result,
  ) {
    return '💡 Buffer calculation formula: $baseMultiplier × (1 + $perspectiveStrength × $bufferFactor × $areaMultiplier) = $result';
  }

  @override
  String bufferedAreaSize(Object height, Object width) {
    return '- Buffered area: $width x $height';
  }

  @override
  String get buildContextExtensionTip_7281 =>
      'Using BuildContext extension methods allows for quicker creation of simple floating windows.';

  @override
  String get buildInfo_7421 => 'Build information:';

  @override
  String get buildLegendSessionManager_4821 =>
      'Build with Legend Session Manager';

  @override
  String get buildLegendStickerWidget_7421 =>
      '*** Building Legend Sticker Widget ***';

  @override
  String get buildLegendSticker_7421 => 'Build legend sticker';

  @override
  String get buildMarkdownStart_7283 =>
      '🔧 _buildMarkdownContent: Start building';

  @override
  String get builderPatternDescription_3821 =>
      'Use the builder pattern to create floating windows with complex configurations';

  @override
  String get builderPatternTitle_3821 => 'Builder Pattern';

  @override
  String get builderPatternWindow_4821 => 'Builder Pattern Window';

  @override
  String get builderPattern_4821 => 'Builder Pattern';

  @override
  String buildingLegendGroupTitle(Object name) {
    return 'Building legend group: $name';
  }

  @override
  String get buildingMapCanvas_7281 => '=== Building Map Canvas ===';

  @override
  String get building_4821 => 'Building';

  @override
  String get bulgarianBG_4859 => 'Bulgarian (Bulgaria)';

  @override
  String get bulgarian_4858 => 'Bulgarian';

  @override
  String cacheCleanError_7284(Object e) {
    return 'An error occurred while clearing cache: $e';
  }

  @override
  String cacheCleanFailed(Object e, Object path) {
    return 'Failed to clean cache from path: $path, error: $e';
  }

  @override
  String cacheCleanPath(Object legendGroupId, Object path) {
    return 'Clean from cache path: $legendGroupId -> $path';
  }

  @override
  String cacheCleanedPath_7281(Object path) {
    return 'Cache cleaned from path: $path';
  }

  @override
  String cacheCleanupTime(Object elapsedMilliseconds) {
    return 'Cache cleanup time: ${elapsedMilliseconds}ms';
  }

  @override
  String get cacheCleared_7281 => 'Cache cleared successfully';

  @override
  String get cacheLegend_4521 => 'Cache Legend';

  @override
  String get cacheLegend_7421 => 'Cache Legend';

  @override
  String cachedLegendCategories(
    Object totalOtherSelected,
    Object totalOwnSelected,
    Object totalUnselected,
  ) {
    return '[CachedLegendsDisplay] Cached legend categories completed: own group $totalOwnSelected, other groups $totalOtherSelected, unselected $totalUnselected';
  }

  @override
  String cachedLegendPath_7421(Object legendPath) {
    return 'Cached legend: $legendPath';
  }

  @override
  String cachedLegendsCount_7421(Object count) {
    return 'Currently cached legends count: $count';
  }

  @override
  String calculatedNewGlobalIndex(Object newGlobalIndex) {
    return 'Calculated new global index: $newGlobalIndex';
  }

  @override
  String cameraSpeedLabel(Object speed) {
    return 'Camera movement speed: ${speed}px/s';
  }

  @override
  String get camera_4829 => 'Camera';

  @override
  String get cancel => 'Cancel';

  @override
  String cancelActiveConfigFailed_7285(Object e) {
    return 'Failed to cancel active configuration: $e';
  }

  @override
  String get cancelActiveConfig_7421 =>
      'Canceling current active configuration...';

  @override
  String get cancelActive_7281 => 'Cancel active';

  @override
  String get cancelButton_4271 => 'Cancel';

  @override
  String get cancelButton_7281 => 'Cancel';

  @override
  String get cancelButton_7284 => 'Cancel';

  @override
  String get cancelButton_7421 => 'Cancel';

  @override
  String get cancelOperation_4821 => 'Cancel operation';

  @override
  String get cancelSelection_4271 => 'Cancel selection';

  @override
  String get cancelWebDAVDownload_5032 => 'Cancel WebDAV download';

  @override
  String get cancelWebDAVImport_5017 => 'Cancel WebDAV import';

  @override
  String get cancel_4821 => 'Cancel';

  @override
  String get cancel_4832 => 'Cancel';

  @override
  String get cancel_4928 => 'Cancel';

  @override
  String get cancel_7281 => 'Cancel';

  @override
  String cannotDeleteAuthAccountWithConfigs(Object count) {
    return 'Cannot delete the authenticated account, $count configurations are still using it';
  }

  @override
  String get cannotDeleteDefaultVersion_4271 =>
      'Cannot delete the default version';

  @override
  String get cannotDeleteDefaultVersion_4821 =>
      'Cannot delete the default version';

  @override
  String get cannotDeleteDefaultVersion_7281 =>
      'Cannot delete the default version';

  @override
  String get cannotGenerateMetadataPath_5012 =>
      'Cannot generate metadata.json system temporary file path';

  @override
  String get cannotGenerateTempPath_4821 =>
      'Unable to generate system temporary file path';

  @override
  String cannotLoadLicense_4913(Object error) {
    return 'Cannot load LICENSE file: $error';
  }

  @override
  String cannotOperateLegend(Object name) {
    return 'Cannot operate legend: Please first select a layer bound to the legend group \"$name';
  }

  @override
  String get cannotReadDirectoryContent_5034 => 'Cannot read directory content';

  @override
  String get cannotReadFileContent_4986 =>
      'Cannot read file content, please ensure the file exists and has read permissions';

  @override
  String get cannotReadWebDAVDirectory_5021 => 'Cannot read WebDAV directory';

  @override
  String cannotReleaseLock(Object elementId) {
    return 'Unable to release another user\'s lock: $elementId';
  }

  @override
  String get cannotSelectLegend_4821 =>
      'Cannot select legend: Please first select a layer bound to this legend group';

  @override
  String cannotViewPermissionError_4821(Object error) {
    return 'Failed to view permission: $error';
  }

  @override
  String canvasBoundaryMarginDescription(Object margin) {
    return 'Controls the distance between canvas content and container edges: ${margin}px';
  }

  @override
  String get canvasCaptureError_4821 => 'Failed to capture canvas area';

  @override
  String get canvasMargin_4821 => 'Canvas margin';

  @override
  String canvasPositionDebug(Object dx, Object dy) {
    return 'Canvas position: ($dx, $dy)';
  }

  @override
  String get canvasThemeAdaptationEnabled_7421 =>
      'Canvas theme adaptation is enabled';

  @override
  String get canvasThemeAdaptation_7281 => 'Canvas Theme Adaptation';

  @override
  String get cardWithActionsTitle_4821 => 'With action buttons';

  @override
  String get cardWithIconAndSubtitle_4821 => 'With icon and subtitle';

  @override
  String get catalogTitle_4821 => 'Catalog';

  @override
  String get centerLeft_3456 => 'Center Left';

  @override
  String centerOffsetDebug(Object dx, Object dy) {
    return '- Center offset: ($dx, $dy)';
  }

  @override
  String get centerRadius_4821 => 'Center radius';

  @override
  String get centerRight_1235 => 'Center right';

  @override
  String get center_7890 => 'Center';

  @override
  String get challengeDecryptedSuccess_7281 =>
      'Challenge decrypted successfully';

  @override
  String challengeDecryptionFailed_7421(Object e) {
    return 'Challenge decryption failed: $e';
  }

  @override
  String challengeResponseSentResult(Object sendResult) {
    return 'challengeResponseSentResult: $sendResult';
  }

  @override
  String get changeAvatar_7421 => 'Change avatar';

  @override
  String get changeBackgroundImage_5421 => 'Change background image';

  @override
  String get changeDisplayName_4821 => 'Change display name';

  @override
  String get changeImage_4821 => 'Change image';

  @override
  String characterCount_7421(Object charCount) {
    return 'Character count: $charCount';
  }

  @override
  String chartSessionInitFailed_7421(Object e) {
    return 'Chart session initialization failed: $e';
  }

  @override
  String get checkAndCorrectInputError_4821 =>
      'Please check and correct the parameter input errors';

  @override
  String get checkAndModifyPath_4821 =>
      'Please check and modify the destination path of the file. You can directly edit the path or click the folder icon to select the target location.';

  @override
  String checkFolderEmptyFailed_7421(Object e, Object folderName) {
    return 'Failed to check if folder is empty: $folderName, error: $e';
  }

  @override
  String checkLanguageAvailability_7421(Object isAvailable, Object language) {
    return 'Checking language $language availability: $isAvailable';
  }

  @override
  String checkPlayStatus(Object currentSource, Object targetSource) {
    return '🎵 Check playback status - Current source: $currentSource, Target source: $targetSource';
  }

  @override
  String checkPrivateKeyFailed_4821(Object e) {
    return 'Failed to check private key existence: $e';
  }

  @override
  String checkRedoStatusFailed_4821(Object e) {
    return 'Failed to check redo status: $e';
  }

  @override
  String get checkUndoStatusFailed_4821 => 'Failed to check undo status';

  @override
  String checkWebDavPasswordExistenceFailed_4821(Object e) {
    return 'Failed to check WebDAV password existence: $e';
  }

  @override
  String get checkerboardPattern_4821 => 'Checkerboard';

  @override
  String get checkingFileConflicts_4921 => 'Checking file conflicts...';

  @override
  String get chineseCharacter_4821 => 'Middle';

  @override
  String get chineseHK_4894 => 'Chinese (Hong Kong)';

  @override
  String get chineseLanguage_5732 => 'Chinese';

  @override
  String get chineseSG_4895 => 'Chinese (Singapore)';

  @override
  String get chineseSimplified_4822 => 'Chinese (Simplified)';

  @override
  String get chineseTraditional_4823 => 'Chinese (Traditional)';

  @override
  String get chinese_4821 => 'Chinese';

  @override
  String get circleTool_5689 => 'Circle';

  @override
  String get circularList_7421 => 'Circular List';

  @override
  String cleanDirectoryFailed(Object directoryPath, Object error) {
    return 'Failed to clean directory: $directoryPath, error: $error';
  }

  @override
  String cleanScriptHandler_7421(Object scriptId) {
    return 'Clean script function handler: $scriptId';
  }

  @override
  String cleanTempFilesFailed_4821(Object e) {
    return '🗑️ Failed to clean temporary files: $e';
  }

  @override
  String cleanVersionSessionData(Object mapTitle, Object versionId) {
    return 'Clean version session data [$mapTitle/$versionId]';
  }

  @override
  String get cleanWebDavTempFilesFailed_4721 =>
      'Failed to clean up WebDAV import temporary files';

  @override
  String cleanedOrphanedCacheItems(Object count, Object items) {
    return 'Cleaned $count orphaned image cache items: $items';
  }

  @override
  String cleanedPaths_7285(Object keysToRemove) {
    return 'Cleaned paths: $keysToRemove';
  }

  @override
  String cleanedPrivateKeysCount(Object count) {
    return 'Cleaned $count private keys';
  }

  @override
  String get cleaningExpiredLogs_7281 => 'Cleaning expired log files...';

  @override
  String get cleaningTempFiles_4923 => 'Cleaning temporary files...';

  @override
  String get cleaningTempFiles_5009 => 'Cleaning temporary files...';

  @override
  String get cleaningTempFiles_7421 => 'Cleaning temporary files...';

  @override
  String cleanupCacheFailed_4859(Object error) {
    return 'Cache cleanup failed: $error';
  }

  @override
  String cleanupCompleted(Object elapsedMilliseconds) {
    return 'App cleanup completed, total time elapsed: ${elapsedMilliseconds}ms';
  }

  @override
  String cleanupErrorWithDuration(Object e, Object elapsedMilliseconds) {
    return 'An error occurred during cleanup: $e, time elapsed: ${elapsedMilliseconds}ms';
  }

  @override
  String cleanupFailedMessage(Object error, Object path) {
    return 'Failed to clean up file/directory: $path, error: $error';
  }

  @override
  String cleanupFailed_7285(Object e) {
    return 'Failed to clean up old data: $e';
  }

  @override
  String cleanupTempFilesFailed(Object cleanupError) {
    return 'Failed to clean up temporary files: $cleanupError';
  }

  @override
  String cleanupTempFilesFailed_4917(Object error) {
    return 'Failed to cleanup temporary files: $error';
  }

  @override
  String get clearAllFilters_4271 => 'Clear all filters';

  @override
  String get clearAllNotifications_7281 => 'Clear all notifications';

  @override
  String get clearAllScriptLogs_7281 => 'Clear all script execution logs';

  @override
  String get clearButton_7421 => 'Clear';

  @override
  String get clearCurrentLocation_4821 => 'Clear current location';

  @override
  String get clearCustomColors_4271 => 'Clear custom colors';

  @override
  String get clearCustomTags_4271 => 'Clear custom tags';

  @override
  String get clearExtensionSettingsTitle_4821 => 'Clear Extension Settings';

  @override
  String get clearExtensionSettingsWarning_4821 =>
      'Are you sure you want to clear all extension settings? This action cannot be undone.';

  @override
  String get clearLayerSelection_3828 => 'Clear layer/layer group selection';

  @override
  String clearLegendCacheFailed(Object e) {
    return 'Failed to clear legend cache: $e';
  }

  @override
  String clearLegendFailed_7285(Object e) {
    return 'Failed to clear legend: $e';
  }

  @override
  String get clearLink => 'Clear Link';

  @override
  String get clearLogs_4271 => 'Clear logs';

  @override
  String get clearMapInfo_4821 => 'Clear map info';

  @override
  String clearPrivateKeysFailed_7421(Object e) {
    return 'Failed to clear all private keys: $e';
  }

  @override
  String get clearRecentColors_4271 => 'Clear recent colors';

  @override
  String get clearScriptEngineDataAccessor_7281 =>
      'Clear script engine data accessor';

  @override
  String get clearSelection_4821 => 'Clear selection';

  @override
  String get clearSelection_4825 => 'Clear selection';

  @override
  String clearSessionState_7421(Object arg0) {
    return 'Clear all version session states [$arg0]';
  }

  @override
  String get clearText_4821 => 'Clear';

  @override
  String clearTimerFailed(Object e) {
    return 'Failed to clear timer: $e';
  }

  @override
  String clearTimerFailed_4821(Object e) {
    return 'Failed to clear timer: $e';
  }

  @override
  String clearWebDavPasswordsFailed(Object e) {
    return 'Failed to clear all WebDAV passwords: $e';
  }

  @override
  String get clear_4821 => 'Clear';

  @override
  String get clearedImageCache_7281 => 'All image cache has been cleared';

  @override
  String clearedMapLegendGroups_7421(Object mapId) {
    return 'Cleared all legend group zoom factor settings for map $mapId';
  }

  @override
  String clearedMapLegendSettings(Object mapId) {
    return 'Cleared all smart hide settings for legend groups on map $mapId';
  }

  @override
  String clearedSettingsWithPrefix(Object prefix) {
    return 'Extension settings: Cleared all settings with prefix $prefix';
  }

  @override
  String get clearingCache_7421 => 'Clearing cache...';

  @override
  String get clickAndDragWindowTitle_4821 =>
      '• Click and drag the title bar to move the window';

  @override
  String get clickToAddAccount_7281 => 'Click \"Add Account\" to get started';

  @override
  String get clickToAddConfig => 'Click \"Add Configuration\" to get started';

  @override
  String get clickToAddCustomColor_4821 =>
      'Click the palette button to add a custom color';

  @override
  String get clickToAddText_7281 => 'Click to add text';

  @override
  String get clickToEditTitleAndContent_7281 =>
      'Click to edit title and content';

  @override
  String get clickToGeneratePreview_4821 =>
      'Click \"Generate Preview\" to view the PDF effect';

  @override
  String get clickToInputColorValue => 'Click to input color value';

  @override
  String get clickToSelectLegend_5832 => 'Click to select legend item';

  @override
  String get clickToStartRecording_4821 => 'Click to start recording';

  @override
  String get clickToUploadImage_4821 => 'Click to upload image';

  @override
  String clientConfigCreatedSuccessfully(Object clientId, Object displayName) {
    return 'Client configuration created successfully: $displayName ($clientId)';
  }

  @override
  String clientConfigDeleted(Object clientId) {
    return 'Client configuration deleted: $clientId';
  }

  @override
  String clientConfigDeletedSuccessfully_7421(Object clientId) {
    return 'Client configuration deleted successfully: $clientId';
  }

  @override
  String clientConfigFailed_7285(Object e) {
    return 'Failed to create default client configuration: $e';
  }

  @override
  String get clientConfigNotFound_7281 => 'Client configuration not found';

  @override
  String clientConfigNotFound_7285(Object clientId) {
    return 'Client configuration does not exist: $clientId';
  }

  @override
  String clientConfigUpdateFailed(Object e) {
    return 'Failed to update client configuration: $e';
  }

  @override
  String clientConfigUpdatedSuccessfully_7284(Object clientId) {
    return 'Client configuration updated successfully: $clientId';
  }

  @override
  String clientConfigUpdated_7281(Object displayName) {
    return 'Client configuration updated: $displayName';
  }

  @override
  String clientConfigValidationFailed_4821(Object e) {
    return 'Client configuration validation failed: $e';
  }

  @override
  String clientCreatedSuccessfully(Object clientId) {
    return 'Default client created successfully: $clientId';
  }

  @override
  String clientCreationFailed_5421(Object e) {
    return 'Client creation failed: $e';
  }

  @override
  String clientCreationFailed_7285(Object e) {
    return 'Failed to create default client: $e';
  }

  @override
  String clientIdLabel(Object clientId) {
    return 'Client ID: $clientId';
  }

  @override
  String clientInfoFetchFailed(Object e) {
    return 'Failed to fetch client information: $e';
  }

  @override
  String clientInfoLoaded(Object clientId, Object displayName) {
    return 'Client information loaded: ID=$clientId, Name=$displayName';
  }

  @override
  String clientInitializationFailed_7281(Object e) {
    return 'Client initialization failed: $e';
  }

  @override
  String clientInitializationSuccess_7421(Object displayName) {
    return 'Client initialization successful: $displayName';
  }

  @override
  String get clientManagement_7281 => 'Client Management';

  @override
  String clientSetSuccessfully_4821(Object clientId) {
    return 'Active client set successfully: $clientId';
  }

  @override
  String clipboardCopyImageFailed(Object e) {
    return 'Failed to copy image using super_clipboard: $e';
  }

  @override
  String clipboardGifReadSuccess(Object length) {
    return 'super_clipboard: Successfully read GIF image from clipboard, size: $length bytes';
  }

  @override
  String clipboardImageReadFailed(Object e) {
    return 'Failed to read image from clipboard: $e';
  }

  @override
  String get clipboardImageReadSuccess_7285 =>
      'Image successfully read from clipboard';

  @override
  String clipboardImageReadSuccess_7425(Object bytesLength) {
    return 'Image successfully read from clipboard, size: $bytesLength bytes';
  }

  @override
  String get clipboardLabel_4271 => 'Clipboard';

  @override
  String get clipboardNoSupportedImageFormat_4821 =>
      'super_clipboard: No supported image format in clipboard';

  @override
  String clipboardPngReadSuccess(String isSynthesized, Object length) {
    String _temp0 = intl.Intl.selectLogic(isSynthesized, {
      'true': ' (synthesized)',
      'other': '',
    });
    return 'super_clipboard: Successfully read PNG image from clipboard, size: $length bytes$_temp0';
  }

  @override
  String get clipboardReadError_4821 =>
      'Platform-specific clipboard reading is not supported or failed';

  @override
  String clipboardReadFailed_7285(Object e) {
    return 'Platform-specific clipboard read implementation failed: $e';
  }

  @override
  String get clipboardUnavailableWeb_9274 =>
      'Web: System clipboard unavailable, using event listener method';

  @override
  String get clipboardUnavailable_7281 =>
      'System clipboard unavailable, attempting platform-specific implementation';

  @override
  String get clipboardUnavailable_7421 =>
      'System clipboard unavailable, using platform-specific implementation';

  @override
  String get close => 'Close';

  @override
  String get closeButton_4821 => 'Close';

  @override
  String get closeButton_5421 => 'Close';

  @override
  String get closeButton_7281 => 'Close';

  @override
  String get closeButton_7421 => 'Close';

  @override
  String get closeEditorTooltip_7421 => 'Close editor';

  @override
  String closeLastElementLink(Object name) {
    return 'Close the link of the last element in the group: $name';
  }

  @override
  String closeLayerLinkToLastPosition(Object name) {
    return 'Close the layer link to the last position: $name';
  }

  @override
  String closeLegendDatabaseFailed(Object e) {
    return 'Failed to close legend database: $e';
  }

  @override
  String closeNewGroupLastElementLink(Object name) {
    return 'Close the link of the last element in the new group: $name';
  }

  @override
  String closeUserPrefDbFailed(Object e) {
    return 'Failed to close user preferences database: $e';
  }

  @override
  String get close_5031 => 'Close';

  @override
  String get closingDbConnection_7281 => 'Closing database connection...';

  @override
  String get closingVfsSystem_7281 => 'Closing VFS system...';

  @override
  String get codeExample_7281 => 'Code example:';

  @override
  String collabServiceInitStatus(Object connectionState) {
    return 'Collaboration service initialization completed, WebSocket connection status: $connectionState';
  }

  @override
  String get collabServiceNotInitialized_4821 =>
      'Collaboration service not initialized, skipping enterMapEditor';

  @override
  String collabServiceStatus(Object status) {
    return 'Collaboration service initialized, WebSocket connection status: $status';
  }

  @override
  String get collaborationConflict_4826 => 'Collaboration Conflict';

  @override
  String get collaborationConflict_7281 => 'Collaboration Conflict';

  @override
  String get collaborationFeatureExample_4821 =>
      'Collaboration Feature Integration Example';

  @override
  String collaborationInitFailed_7281(Object error) {
    return 'Failed to initialize collaboration state: $error';
  }

  @override
  String get collaborationServiceCleaned_7281 =>
      'Collaboration service has been cleaned';

  @override
  String collaborationServiceCleanupFailed_7421(Object e) {
    return 'Collaboration service cleanup failed: $e';
  }

  @override
  String collaborationServiceInitFailed_4821(Object e) {
    return 'Collaboration service initialization failed: $e';
  }

  @override
  String get collaborationServiceNotInitialized_4821 =>
      'Collaboration service not initialized';

  @override
  String get collaborationStateInitialized_7281 =>
      'Collaboration state initialized';

  @override
  String get collaborativeMap_4271 => 'Collaborative Map';

  @override
  String get collapseNote_5421 => 'Collapse note';

  @override
  String get collapse_4821 => 'Collapse';

  @override
  String get collapsedState_5421 => 'Collapsed';

  @override
  String get collectionLabel_4821 => 'Collection';

  @override
  String collectionStatsError(Object collection, Object dbName, Object e) {
    return 'Failed to fetch collection stats: $dbName/$collection - $e';
  }

  @override
  String get color => 'Color';

  @override
  String get colorAddedToCustom_7281 => 'Color added to custom';

  @override
  String get colorAlreadyExists_1537 =>
      'This color already exists in custom colors';

  @override
  String get colorAlreadyExists_7281 => 'The color already exists';

  @override
  String colorFilterCleanupError_4821(Object e) {
    return 'Failed to clean up color filter in dispose: $e';
  }

  @override
  String get colorFilterSettingsTitle_4287 => 'Color Filter Settings';

  @override
  String get colorFilterSettings_7421 => 'Color Filter Settings';

  @override
  String get colorFilter_4821 => 'Color Filter';

  @override
  String get colorLabel_4821 => 'Color';

  @override
  String get colorLabel_5421 => 'Color';

  @override
  String get colorPickerTitle_4821 => 'Select color';

  @override
  String get colorValueHint_4821 => 'For example: FF0000, #FF0000, red';

  @override
  String get colorValueLabel_4821 => 'Color value';

  @override
  String get colorWithHashTag_7281 => 'With #: #FF0000';

  @override
  String colorWithHex_7421(Object colorHex) {
    return 'Color: $colorHex';
  }

  @override
  String get commonLineWidth_4521 => 'Common line width';

  @override
  String get commonLineWidth_4821 => 'Common line width';

  @override
  String commonStrokeWidthAdded(Object strokeWidth) {
    return 'Common stroke width added: ${strokeWidth}px';
  }

  @override
  String get compactMode => 'Compact mode';

  @override
  String get compactMode_7281 => 'Compact mode';

  @override
  String compareVersionPathDiff(Object previousVersionId, Object versionId) {
    return 'Compare version path differences: $previousVersionId vs $versionId';
  }

  @override
  String compareVersionPathDiff_4827(Object fromVersionId, Object toVersionId) {
    return 'Comparing version path differences: $fromVersionId -> $toVersionId';
  }

  @override
  String get completedTag_3456 => 'Completed';

  @override
  String get completedTag_9012 => 'Completed';

  @override
  String get completed_9012 => 'Completed';

  @override
  String get compressingFiles_5006 => 'Compressing files...';

  @override
  String compressionDownloadFailed(Object e) {
    return 'Compression download failed: $e';
  }

  @override
  String compressionDownloadFailed_4821(Object e) {
    return 'Compression download failed: $e';
  }

  @override
  String get compressionFailed_7281 => 'Compression failed';

  @override
  String get configAdded_17 => 'Configuration added';

  @override
  String configCheckFailed_7425(Object e) {
    return 'Configuration check failed: $e';
  }

  @override
  String configDeletedSuccessfully(Object configId) {
    return 'Configuration deleted successfully: $configId';
  }

  @override
  String get configDirCreatedOrExists_7281 =>
      'Configuration directory already exists or has been created';

  @override
  String configDirCreationError_4821(Object e) {
    return 'Configuration directory creation: $e';
  }

  @override
  String get configDisabled_4821 => 'Configuration disabled';

  @override
  String get configEditor => 'Configuration Editor';

  @override
  String get configEditorDisplayName_4821 => 'Configuration Editor';

  @override
  String get configEnabled_4822 => 'Configuration enabled';

  @override
  String configFileCreated(Object name) {
    return 'Configuration file \"$name\" has been created';
  }

  @override
  String configImportSuccess(Object importedConfigId, Object name) {
    return 'Configuration imported successfully: $name ($importedConfigId)';
  }

  @override
  String configInitFailed_7285(Object e) {
    return 'Failed to initialize configuration management system: $e';
  }

  @override
  String configListLoaded(Object count) {
    return 'Configuration list loaded, $count configurations in total';
  }

  @override
  String configListUpdated(Object count) {
    return 'Configuration list updated, $count configurations in total';
  }

  @override
  String configLoadedSuccessfully(Object configId) {
    return 'Configuration loaded and applied successfully: $configId';
  }

  @override
  String get configNotFoundOrLoadFailed_4821 =>
      'Configuration does not exist or failed to load';

  @override
  String get configNotFound_4821 => 'Configuration not found';

  @override
  String configSavedSuccessfully(Object configId, Object name) {
    return 'Configuration saved successfully: $name ($configId)';
  }

  @override
  String configUpdateSuccess(Object configId, Object name) {
    return 'Configuration updated successfully: $name ($configId)';
  }

  @override
  String get configUpdated => 'Configuration updated';

  @override
  String get configUpdated_42 => 'Configuration updated';

  @override
  String configValidationFailedPrivateKeyMissing(Object privateKeyId) {
    return 'Configuration validation failed: Private key does not exist $privateKeyId';
  }

  @override
  String configValidationFailedWithError(Object error) {
    return 'Configuration validation failed: Invalid public key format $error';
  }

  @override
  String configValidationFailed_7281(Object e) {
    return 'Configuration validation failed: $e';
  }

  @override
  String configValidationResult(Object result) {
    return 'Configuration validation result: $result';
  }

  @override
  String get configurationCopiedToClipboard_4821 =>
      'Configuration copied to clipboard';

  @override
  String get configurationDeletedSuccessfully_7281 =>
      'Configuration deleted successfully';

  @override
  String get configurationDeletedSuccessfully_7421 =>
      'Configuration deleted successfully';

  @override
  String get configurationDeleted_4821 => 'Configuration deleted';

  @override
  String get configurationDescription_4521 => 'Configuration description';

  @override
  String get configurationImportSuccess_7281 =>
      'Configuration imported successfully';

  @override
  String get configurationInfo_7284 => '=== Configuration Info ===';

  @override
  String get configurationLoadedSuccessfully_4821 =>
      'Configuration loaded successfully';

  @override
  String get configurationManagement_7421 => 'Configuration Management';

  @override
  String get configurationName_4821 => 'Configuration name';

  @override
  String get configurationNotFound_7281 => 'Configuration not found';

  @override
  String get configurationSavedSuccessfully_4821 =>
      'Configuration saved successfully';

  @override
  String get configurationsCount_7421 => 'configurations';

  @override
  String get configureAppSettings_7285 =>
      'Configure application settings and preferences';

  @override
  String get configurePreferences_5732 => 'Configure your preferences';

  @override
  String get confirmAndProcess_7281 => 'Confirm and Process';

  @override
  String get confirmButton_4821 => 'Confirm';

  @override
  String get confirmButton_7281 => 'Confirm';

  @override
  String get confirmClearAllTags_7281 =>
      'Are you sure you want to clear all custom tags?';

  @override
  String get confirmClearCustomColors_7421 =>
      'Are you sure you want to clear all custom colors?';

  @override
  String get confirmClearRecentColors_4821 =>
      'Are you sure you want to clear all recently used colors?';

  @override
  String confirmDeleteAccount_7421(Object accountDisplayName) {
    return 'Are you sure you want to delete the verified account \"$accountDisplayName\"? This action cannot be undone.';
  }

  @override
  String confirmDeleteConfig(Object displayName) {
    return 'Are you sure you want to delete the configuration \"$displayName\"?';
  }

  @override
  String confirmDeleteElement_4821(Object type) {
    return 'Are you sure you want to delete this $type element?';
  }

  @override
  String get confirmDeleteFolder_4837 =>
      'Are you sure you want to delete this folder?';

  @override
  String confirmDeleteFolder_7281(Object folderName) {
    return 'Are you sure you want to delete the folder \"$folderName\"?  \n\nNote: Only empty folders can be deleted.';
  }

  @override
  String confirmDeleteItem_7421(Object item) {
    return 'Are you sure you want to delete \"$item\"?';
  }

  @override
  String confirmDeleteLayer_7421(Object name) {
    return 'Are you sure you want to delete the layer \"$name\"? This action cannot be undone.';
  }

  @override
  String confirmDeleteLegend(Object title) {
    return 'Confirm to delete the legend \"$title\"?';
  }

  @override
  String confirmDeleteLegendGroup_7281(Object name) {
    return 'Are you sure you want to delete the legend group \"$name\"? This action cannot be undone.';
  }

  @override
  String get confirmDeleteLegend_4821 =>
      'Are you sure you want to delete this legend? This action cannot be undone.';

  @override
  String confirmDeleteMap(Object title) {
    return 'Confirm to delete the map \"$title\"?';
  }

  @override
  String confirmDeleteMessage_4821(Object count) {
    return 'Are you sure you want to delete the selected $count items? This action cannot be undone.';
  }

  @override
  String confirmDeleteNote(Object title) {
    return 'Are you sure you want to delete the note \"$title\"? This action cannot be undone.';
  }

  @override
  String confirmDeleteScript_7421(Object name) {
    return 'Are you sure you want to delete the script \"$name\"?';
  }

  @override
  String get confirmDeleteTimer_7421 =>
      'Are you sure you want to delete this timer?';

  @override
  String get confirmDeleteTitle_4821 => 'Confirm deletion';

  @override
  String confirmDeleteVersion(Object versionId) {
    return 'Are you sure you want to delete version \"$versionId\"? This action cannot be undone.';
  }

  @override
  String get confirmDelete_7281 => 'Confirm deletion';

  @override
  String confirmDeletionMessage_4821(Object count) {
    return 'Are you sure you want to delete the selected $count items? This action cannot be undone.';
  }

  @override
  String get confirmDeletionTitle_4821 => 'Confirm deletion';

  @override
  String get confirmExit_7284 => 'Exit Anyway';

  @override
  String confirmLoadConfig_7421(Object name) {
    return 'Are you sure you want to load the configuration \"$name\"?  \n\nThis will overwrite all current settings (except user information).';
  }

  @override
  String get confirmRemoveAvatar_7421 =>
      'Are you sure you want to remove the current avatar?';

  @override
  String get confirmResetLayoutSettings_4821 =>
      'Are you sure you want to reset the layout settings to default? This action cannot be undone.';

  @override
  String get confirmResetSettings =>
      'Are you sure you want to reset all settings to default? This action cannot be undone.';

  @override
  String get confirmResetTtsSettings_4821 =>
      'Are you sure you want to reset TTS settings to default?';

  @override
  String get confirmResetWindowSize_4821 =>
      'Are you sure you want to reset the window size to the default?';

  @override
  String get confirm_4821 => 'Confirm';

  @override
  String get confirm_4843 => 'Confirm';

  @override
  String conflictCount(Object count) {
    return '$count conflicts';
  }

  @override
  String get conflictCreated_7425 => 'Conflict created';

  @override
  String get conflictResolved_7421 => 'Conflict resolved';

  @override
  String get connect_4821 => 'Connect';

  @override
  String get connected_3632 => 'Connected';

  @override
  String get connected_4821 => 'Connected';

  @override
  String get connected_7154 => 'Connected';

  @override
  String connectingToTarget(Object clientId, Object displayName) {
    return 'Connecting to: $displayName ($clientId)';
  }

  @override
  String connectingToWebSocketServer(Object host, Object port) {
    return 'Connecting to WebSocket server: $host:$port';
  }

  @override
  String get connectingWebDAV_5018 => 'Connecting to WebDAV...';

  @override
  String get connecting_5723 => 'Connecting';

  @override
  String get connecting_5732 => 'Connecting';

  @override
  String get connectionConfig_7281 => 'Connection Configuration';

  @override
  String get connectionDisconnected_4821 => 'Connection disconnected';

  @override
  String connectionError_5421(Object e) {
    return 'Connection error: $e';
  }

  @override
  String connectionFailedWithError_7281(Object error) {
    return 'Connection failed: $error';
  }

  @override
  String get connectionFailed_4821 => 'Connection failed';

  @override
  String connectionFailed_7281(Object error) {
    return 'Connection failed: $error';
  }

  @override
  String connectionFailed_7285(Object e) {
    return 'GlobalCollaborationService disconnection failed: $e';
  }

  @override
  String get connectionFailed_9372 => 'Connection failed';

  @override
  String get connectionInProgress_4821 =>
      'Connection in progress, ignoring duplicate connection requests';

  @override
  String connectionStateChanged_7281(Object state) {
    return 'Connection state changed: $state';
  }

  @override
  String get connectionStatus_4821 => 'Connection status';

  @override
  String get connectionSuccess_4821 => 'Connection successful';

  @override
  String get connectionTimeoutError_4821 => 'Connection timeout';

  @override
  String get connectionToPlayerComplete_7281 =>
      '🎵 Connection to existing player completed:';

  @override
  String get consistentDesktopExperience_4821 =>
      '• Consistent interaction experience with desktop platforms';

  @override
  String get contentLabel_4521 => 'Content';

  @override
  String contrastPercentage(Object percentage) {
    return 'Contrast: $percentage%';
  }

  @override
  String get contrast_1235 => 'Contrast';

  @override
  String get contrast_4826 => 'Contrast';

  @override
  String get controlPanel_4821 => 'Control Panel';

  @override
  String convertedCanvasPosition_7281(Object canvasPosition) {
    return 'Converted canvas coordinates: $canvasPosition';
  }

  @override
  String coordinateConversion(Object clampedPosition, Object localPosition) {
    return 'Coordinate Conversion: Local($localPosition) → Canvas($clampedPosition)';
  }

  @override
  String coordinateConversionFailed_7421(Object e) {
    return 'Coordinate conversion failed: $e, using original coordinates';
  }

  @override
  String copiedFrom_5729(Object sourceVersionId) {
    return '(copied from $sourceVersionId)';
  }

  @override
  String copiedItemsCount(Object count) {
    return '$count items copied';
  }

  @override
  String get copiedMessage_7421 => 'Copied';

  @override
  String get copiedMessage_7532 => 'Copied';

  @override
  String copiedProjectLink(Object index) {
    return 'Copied project $index link';
  }

  @override
  String get copiedToClipboard_4821 => 'Copied to clipboard';

  @override
  String get copyAllContent_7281 => 'Copy all content';

  @override
  String copyAudioLink_4821(Object vfsPath) {
    return 'Copy audio link: $vfsPath';
  }

  @override
  String copyDataFromVersion(Object sourceVersion, Object version) {
    return 'Copy data from version $sourceVersion to version $version';
  }

  @override
  String copyDirectoryFailed(
    Object error,
    Object sourcePath,
    Object targetPath,
  ) {
    return 'Failed to copy directory [$sourcePath -> $targetPath]: $error';
  }

  @override
  String get copyFeatureComingSoon_7281 =>
      'The copy feature will be available in the next version';

  @override
  String get copyInfo_4821 => 'Copy information';

  @override
  String get copyLabel_4821 => 'Copy';

  @override
  String get copyLayer_4821 => 'Copy Layer';

  @override
  String get copyLink_1234 => 'Copy Link';

  @override
  String get copyLink_4271 => 'Copy Link';

  @override
  String get copyLink_4821 => 'Copy Link';

  @override
  String copyMapSelectionFailed_4829(Object e) {
    return 'Failed to copy the selected map area: $e';
  }

  @override
  String get copyMarkdownContent_7281 => 'Copy Markdown content';

  @override
  String get copyNote_7281 => 'Copy note';

  @override
  String copyPathSelectionStatus(Object sourceVersionId, Object versionId) {
    return 'Copy path selection status from version $sourceVersionId to $versionId';
  }

  @override
  String get copySelectedItems_4821 => 'Copy selected items';

  @override
  String get copySelected_4821 => 'Copy Selected';

  @override
  String get copySuffix_3632 => '(copy)';

  @override
  String get copySuffix_4821 => '(Copy)';

  @override
  String get copySuffix_7281 => '(copy)';

  @override
  String get copySuffix_7285 => '(copy)';

  @override
  String get copySuffix_7421 => '(copy)';

  @override
  String get copyText_4821 => 'Copy';

  @override
  String copyToClipboardFailed(Object e) {
    return 'Failed to copy to clipboard: $e';
  }

  @override
  String get copyToClipboardFailed_4821 => 'Failed to copy to clipboard';

  @override
  String copyVersionDataFailed(
    Object e,
    Object mapTitle,
    Object sourceVersion,
    Object targetVersion,
  ) {
    return 'Failed to copy version data [$mapTitle:$sourceVersion->$targetVersion]: $e';
  }

  @override
  String copyVersionSession(
    Object mapTitle,
    Object newVersionId,
    Object sourceVersionId,
  ) {
    return 'Copy version session [$mapTitle]: $sourceVersionId -> $newVersionId';
  }

  @override
  String copyVideoLink(Object vfsPath) {
    return 'Copy video link: $vfsPath';
  }

  @override
  String copyVideoLink_5421(Object vfsPath) {
    return 'Copy video link: $vfsPath';
  }

  @override
  String get copyWithNumber_3632 => 'Copy';

  @override
  String get copyWithTimestamp_3632 => 'Copy';

  @override
  String get copyWithTimestamp_8254 => 'Copy';

  @override
  String get copy_3832 => 'Copy';

  @override
  String get copy_4821 => 'Copy';

  @override
  String get copyingFileProgress_5004 => 'Copying file';

  @override
  String copyingFiles_4922(Object processed, Object total) {
    return 'Copying files to target location... ($processed/$total)';
  }

  @override
  String get countUnit_7281 => 'piece';

  @override
  String get countdownDescription_4821 =>
      'Count down from the set time to zero';

  @override
  String get countdownMode_4821 => 'Countdown';

  @override
  String coverSizeInfo_4821(Object size) {
    return 'Cover: $size';
  }

  @override
  String coverSizeLabel_7421(Object size) {
    return 'Cover size: ${size}KB';
  }

  @override
  String get coverText_4821 => 'Cover';

  @override
  String get coverText_7281 => 'Cover';

  @override
  String get cover_4827 => 'Cover';

  @override
  String get createButton_7281 => 'Create';

  @override
  String get createButton_7421 => 'Create';

  @override
  String createClientWithWebApiKey(Object displayName) {
    return 'Create client with Web API Key: $displayName';
  }

  @override
  String createDefaultClient_7281(Object displayName) {
    return 'Create default client: $displayName';
  }

  @override
  String createEmptyVersionDirectory(Object version) {
    return 'Create empty version directory: $version';
  }

  @override
  String get createFirstConnectionHint_4821 =>
      'Click the \"New\" button to create your first connection configuration';

  @override
  String createFolderFailed(Object e) {
    return 'Failed to create folder: $e';
  }

  @override
  String createFolderFailed_4835(Object error) {
    return 'Failed to create folder: $error';
  }

  @override
  String createFolderFailed_7285(Object e) {
    return 'Failed to create folder: $e';
  }

  @override
  String get createFolderTitle_4821 => 'New Folder';

  @override
  String get createFolderTooltip_7281 => 'Create folder';

  @override
  String get createFolder_4271 => 'Create folder';

  @override
  String get createFolder_4821 => 'Create Folder';

  @override
  String get createFolder_4825 => 'Create Folder';

  @override
  String get createGroup_4821 => 'Create group';

  @override
  String get createLayerGroup_7532 => 'Create Layer Group';

  @override
  String get createNewClientConfig_7281 => 'Create new client configuration';

  @override
  String get createNewFile_7281 => 'New File';

  @override
  String get createNewFolder_4821 => 'New Folder';

  @override
  String get createNewLayer_4821 => 'New Layer';

  @override
  String get createNewProfile_4271 => 'Create new profile';

  @override
  String get createNewProject_7281 => 'New Project';

  @override
  String get createNewTimer_4271 => 'Create new timer';

  @override
  String get createNewTimer_4821 => 'Create new timer';

  @override
  String get createNewVersion_3869 => 'New Version';

  @override
  String get createNewVersion_4271 => 'Create new version';

  @override
  String get createNewVersion_4821 => 'Create new version';

  @override
  String get createNewVersion_4824 => 'Create new version';

  @override
  String createNoteImageSelectionElement_7421(Object imageBufferData) {
    return 'Create note image selection element: imageData=$imageBufferData';
  }

  @override
  String get createResponsiveScript_4821 => 'Create Responsive Script';

  @override
  String get createSampleDataFailed_7281 => 'Failed to create sample data';

  @override
  String get createSampleData_7421 => 'WebDatabaseImporter: Create sample data';

  @override
  String get createScript_4271 => 'Create script';

  @override
  String get createScript_4821 => 'Create Script';

  @override
  String get createTempDir_7425 => 'Create app temp directory';

  @override
  String createTextElementLog(Object text, Object x, Object y) {
    return 'Create text element: \"$text\" at position ($x, $y)';
  }

  @override
  String get createTimerTooltip_7421 => 'Create timer';

  @override
  String get createTimer_4271 => 'Create timer';

  @override
  String createVersionSession_4821(
    Object mapTitle,
    Object versionId,
    Object versionName,
  ) {
    return 'Create new version session [$mapTitle/$versionId]: $versionName';
  }

  @override
  String get createWebDavTempDir_4721 =>
      'Create WebDAV import temporary directory';

  @override
  String get create_4833 => 'Create';

  @override
  String get creatingMetadataTable_7281 =>
      'The metadata table does not exist, creating now...';

  @override
  String creationTimeLabel_5421(Object createdTime) {
    return 'Creation time: $createdTime';
  }

  @override
  String creationTimeText_7421(Object date) {
    return 'Creation time: $date';
  }

  @override
  String get creationTime_4821 => 'Creation time';

  @override
  String get creationTime_7281 => 'Creation time';

  @override
  String get croatianHR_4861 => 'Croatian (Croatia)';

  @override
  String get croatian_4860 => 'Croatian';

  @override
  String get crossLineArea_4827 => 'Cross-line area';

  @override
  String get crossLines => 'Crosshairs';

  @override
  String get crossLinesLabel_4821 => 'Cross lines';

  @override
  String get crossLinesTool_3467 => 'Cross lines';

  @override
  String get crossLinesTooltip_7532 => 'Draw cross lines';

  @override
  String get crossLines_0857 => 'Cross Lines';

  @override
  String get crossLines_4827 => 'Cross lines';

  @override
  String get cssColorNames_4821 => '• CSS color names: red, blue, green, etc.';

  @override
  String get cupertinoDesign => 'Cupertino design';

  @override
  String currentCacheKeys(Object keys) {
    return 'Current cache keys: $keys';
  }

  @override
  String currentConfigDisplay(Object displayName) {
    return 'Current configuration: $displayName';
  }

  @override
  String currentConnectionState_7421(Object state) {
    return 'Current connection status: $state';
  }

  @override
  String currentCount(Object count) {
    return 'Current count: $count/5';
  }

  @override
  String currentIndexLog(Object currentIndex) {
    return '- Current index: $currentIndex';
  }

  @override
  String currentLayerOrderDebug(Object layers) {
    return 'Current _currentMap.layers order: $layers';
  }

  @override
  String currentMapTitle_7421(Object title) {
    return 'Current map: $title';
  }

  @override
  String currentMapUpdatedLayersOrder_7421(Object layers) {
    return '_currentMap has been updated, layers order: $layers';
  }

  @override
  String get currentNameLabel_4821 => 'Current name:';

  @override
  String get currentOperation_7281 => 'Currently executing:';

  @override
  String currentPermissions_7421(Object permissions) {
    return 'Current permissions: $permissions';
  }

  @override
  String currentPitch(Object value) {
    return 'Current: $value';
  }

  @override
  String currentPlatform(Object platform) {
    return 'Current platform: $platform';
  }

  @override
  String get currentPlatform_5678 => 'This platform';

  @override
  String currentPlaying(Object currentSource) {
    return 'Now playing: $currentSource';
  }

  @override
  String get currentPosition_4821 => 'Current location';

  @override
  String currentSelectedLayer_7421(Object name) {
    return 'Current: $name';
  }

  @override
  String get currentSelection_4821 => 'Current selection:';

  @override
  String currentSettingWithWidth_7421(Object width) {
    return 'Current setting: ${width}px';
  }

  @override
  String get currentSettings_4521 => 'Current settings';

  @override
  String currentSettings_7421(Object value) {
    return 'Current settings: ${value}px';
  }

  @override
  String get currentShortcutKey_4821 => 'Current shortcut:';

  @override
  String currentSize_7421(Object size) {
    return 'Current: ${size}px';
  }

  @override
  String currentSpeechRate(Object percentage) {
    return 'Current: $percentage%';
  }

  @override
  String get currentUser => 'Current user';

  @override
  String get currentUserSuffix_4821 => '(Me)';

  @override
  String get currentUserSuffix_7281 => '(Me)';

  @override
  String currentValuePercentage(Object value) {
    return 'Current value: $value%';
  }

  @override
  String currentValueWithUnit(Object value) {
    return 'Current value: ${value}x';
  }

  @override
  String get currentValue_4913 => 'Current Value';

  @override
  String currentVersionLabel(Object currentVersionId) {
    return 'Current version: $currentVersionId';
  }

  @override
  String get currentVersion_7281 => 'Current version';

  @override
  String currentVolume(Object percentage) {
    return 'Current: $percentage%';
  }

  @override
  String get curvatureLabel_7281 => 'Curvature';

  @override
  String curvaturePercentage(Object percentage) {
    return 'Curvature: $percentage%';
  }

  @override
  String customColorAddedSuccessfully(Object count) {
    return 'Custom color added successfully. Current number of custom colors: $count';
  }

  @override
  String customColorAdded_7281(Object color) {
    return 'Custom color added: $color';
  }

  @override
  String get customColor_7421 => 'Custom color';

  @override
  String get customFields_4943 => 'Custom Fields';

  @override
  String get customLabel_7281 => 'Custom Label';

  @override
  String get customLayoutDescription_4521 =>
      'This is a custom layout,  \nwith the Markdown renderer embedded  \nin the right panel.';

  @override
  String get customLayoutExample_4821 => 'Custom Layout Example';

  @override
  String get customMetadata_7281 => 'Custom metadata';

  @override
  String get customSizeDescription_4821 =>
      'Specify a floating window with specific width and height ratio';

  @override
  String get customSizeTitle_4821 => 'Custom Size';

  @override
  String customTagCount(Object count) {
    return 'Custom tags ($count)';
  }

  @override
  String get customTagHintText_4521 => 'Enter custom tag';

  @override
  String customTagLoadFailed_7421(Object e) {
    return 'Failed to load custom tags: $e';
  }

  @override
  String get customVoice_5732 => 'Custom Voice';

  @override
  String get customWindowSize_4271 => 'Custom window size';

  @override
  String get cutSelectedItems_4821 => 'Cut selected items';

  @override
  String get cutSelected_4821 => 'Cut Selected';

  @override
  String get cut_4821 => 'Cut';

  @override
  String cuttingTriangleName_7421(Object name) {
    return 'Cut: $name';
  }

  @override
  String get cuttingType_4821 => 'Cutting type';

  @override
  String get czechCZ_4853 => 'Czech (Czechia)';

  @override
  String get czech_4852 => 'Czech';

  @override
  String get danishDK_4845 => 'Danish (Denmark)';

  @override
  String get danish_4844 => 'Danish';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get darkModeAutoInvertApplied_4821 =>
      'Color inversion has been automatically applied in dark mode, currently displaying your custom settings.';

  @override
  String get darkModeColorInversion_4821 =>
      'Color inversion will be automatically applied in dark mode.';

  @override
  String get darkModeFilterApplied_4821 =>
      'The color inversion has been automatically applied in dark mode, and the theme filter is currently in use.';

  @override
  String get darkModeTitle_4721 => 'Dark Mode';

  @override
  String get darkMode_7285 => 'Dark mode';

  @override
  String get darkThemeCanvasAdjustment_4821 =>
      'Adjust canvas background and element visibility in dark theme';

  @override
  String get darkTheme_5732 => 'Dark theme';

  @override
  String get darkTheme_7632 => 'Dark theme';

  @override
  String get dashedLine => 'dashed line';

  @override
  String get dashedLineTool_3456 => 'Dashed line';

  @override
  String get dashedLine_4821 => 'Dashed line';

  @override
  String get dashedLine_4822 => 'Dashed line';

  @override
  String get dashedLine_5732 => 'Dashed line';

  @override
  String dataChangeListenerFailed_4821(Object e) {
    return 'Data change listener execution failed: $e';
  }

  @override
  String dataLoadFailed(Object e) {
    return 'Failed to load data: $e';
  }

  @override
  String get dataMigrationComplete_7281 => 'Data migration completed';

  @override
  String dataMigrationFailed_7281(Object e) {
    return 'Data migration failed: $e';
  }

  @override
  String get dataMigrationSkipped_7281 =>
      'Data has already been migrated, skipping migration';

  @override
  String dataSerializationComplete(Object fields) {
    return 'Data serialization complete, fields: $fields';
  }

  @override
  String get dataSync_7284 => 'Data Sync';

  @override
  String dataWithLayers_5729(Object layersCount) {
    return 'Data available (Layers: $layersCount)';
  }

  @override
  String databaseCloseError_4821(Object e) {
    return 'An error occurred while closing the database connection: $e';
  }

  @override
  String get databaseConnected_7281 => 'Database connected successfully';

  @override
  String get databaseConnectionClosed_7281 =>
      'Database connection closed successfully';

  @override
  String databaseExportFailed_4829(Object e) {
    return 'Failed to merge database export: $e';
  }

  @override
  String databaseExportSuccess(
    Object dbVersion,
    Object mapCount,
    Object outputFile,
  ) {
    return 'Database exported successfully: $outputFile (Version: $dbVersion, Map count: $mapCount)';
  }

  @override
  String get databaseExportSuccess_7421 =>
      'Database merge export completed successfully';

  @override
  String databaseImportFailed_7421(Object e) {
    return 'Failed to import database: $e';
  }

  @override
  String get databaseLabel_4821 => 'Database';

  @override
  String get databaseLabel_7421 => 'Database';

  @override
  String databaseStatsError_4821(Object e) {
    return 'Failed to retrieve database statistics: $e';
  }

  @override
  String databaseUpdateComplete(Object updateResult) {
    return 'Database update completed, affected rows: $updateResult';
  }

  @override
  String get databaseUpgradeLayoutData_7281 =>
      'Database upgrade: Adding windowControlsMode field to layout_data';

  @override
  String get databaseUpgradeMessage_7281 =>
      'Database upgrade: Added home_page_data field';

  @override
  String get daysAgo_7283 => 'days ago';

  @override
  String dbConnectionCloseTime(Object elapsedMilliseconds) {
    return 'Database connection closing time: ${elapsedMilliseconds}ms';
  }

  @override
  String debugAddNoteElement(
    Object isSelected,
    Object renderOrder,
    Object zIndex,
  ) {
    return 'Add note element - renderOrder=$renderOrder (original zIndex=$zIndex), selected=$isSelected';
  }

  @override
  String get debugAsyncFunction_7425 =>
      'Processing asynchronous external function';

  @override
  String debugClearMapLegendSettings(Object mapId) {
    return 'Extended settings: Cleared all legend group auto-hide settings for map $mapId';
  }

  @override
  String debugCompleteGroupCheck(Object wasCompleteGroup) {
    return 'Whether the original group was a fully connected group: $wasCompleteGroup';
  }

  @override
  String debugIndexChange(Object newIndex, Object oldIndex) {
    return 'Group oldIndex: $oldIndex, newIndex: $newIndex';
  }

  @override
  String debugLayerCount(Object count) {
    return 'Fetching data from current BLoC state: Layer count: $count';
  }

  @override
  String debugLegendSessionManagerExists(Object isExists) {
    return 'Whether the legend session manager exists: $isExists';
  }

  @override
  String debugRemoveElement(Object elementId, Object layerId) {
    return 'Remove drawing element using reactive system: $layerId/$elementId';
  }

  @override
  String debugRemoveLegendGroup(Object name) {
    return 'Remove legend group using responsive system: $name';
  }

  @override
  String get decorationLayer_1234 => 'Decoration Layer';

  @override
  String defaultClientConfigCreated(Object displayName) {
    return 'Default client configuration created successfully: $displayName';
  }

  @override
  String get defaultLanguage_7421 => 'Default';

  @override
  String defaultLayerAdded_7421(Object name) {
    return 'Default layer added: \"$name';
  }

  @override
  String get defaultLayerSuffix_7532 => '(default)';

  @override
  String get defaultLegendSize_4821 => 'Default legend size';

  @override
  String get defaultOption_7281 => 'Default';

  @override
  String get defaultText_1234 => 'Default';

  @override
  String get defaultUser_4821 => 'User';

  @override
  String defaultVersionCreated_7281(Object versionId) {
    return 'Default version created: $versionId';
  }

  @override
  String get defaultVersionExists_7281 => 'Default version already exists';

  @override
  String get defaultVersionName_4721 => 'Default version';

  @override
  String get defaultVersionName_4821 => 'Default version';

  @override
  String get defaultVersionName_7281 => 'Default version';

  @override
  String get defaultVersionSaved_7281 => 'Default version saved (full rebuild)';

  @override
  String get defaultVersion_4915 => '1.2.0';

  @override
  String get defaultVoice_4821 => 'Default';

  @override
  String get delayReturnToMenu_7281 => 'Delay return to main menu';

  @override
  String delayUpdateLog(Object delay) {
    return 'Delayed update: ${delay}ms';
  }

  @override
  String delayWithMs(Object delay) {
    return '${delay}ms';
  }

  @override
  String get delete => 'Delete';

  @override
  String get deleteButton_7281 => 'Delete';

  @override
  String deleteClientConfig(Object clientId) {
    return 'Delete client configuration: $clientId';
  }

  @override
  String deleteClientConfigFailed(Object e) {
    return 'Failed to delete client configuration: $e';
  }

  @override
  String deleteConfigFailed_7281(Object e) {
    return 'Failed to delete configuration: $e';
  }

  @override
  String deleteConfigFailed_7284(Object e) {
    return 'Failed to delete configuration: $e';
  }

  @override
  String deleteConfigLog_7421(Object clientId, Object displayName) {
    return 'Delete configuration: $displayName ($clientId)';
  }

  @override
  String get deleteConfiguration_4271 => 'Delete Configuration';

  @override
  String get deleteConfiguration_7281 => 'Delete Configuration';

  @override
  String get deleteConflict_4829 => 'Delete Conflict';

  @override
  String deleteCustomTagFailed_7421(Object e) {
    return 'Failed to delete custom tag: $e';
  }

  @override
  String deleteDrawingElement(Object elementId, Object layerId) {
    return 'Delete drawing element: $layerId/$elementId';
  }

  @override
  String deleteElementError_4821(
    Object elementId,
    Object error,
    Object layerId,
    Object mapTitle,
    Object version,
  ) {
    return 'Failed to delete drawing element [$mapTitle/$layerId/$elementId:$version]: $error';
  }

  @override
  String deleteElementFailed(Object e) {
    return 'Failed to delete element: $e';
  }

  @override
  String get deleteElementTooltip_7281 => 'Delete element';

  @override
  String deleteEmptyDirectory_7281(Object path) {
    return 'Delete empty directory: $path';
  }

  @override
  String deleteExpiredLogFile(Object path) {
    return 'Delete expired log file: $path';
  }

  @override
  String deleteFailed_7425(Object e) {
    return 'Delete failed: $e';
  }

  @override
  String get deleteField_4948 => 'Delete field';

  @override
  String deleteFilesFailed_4924(Object error) {
    return 'Failed to delete files: $error';
  }

  @override
  String deleteFolderFailed(Object e, Object folderPath) {
    return 'Failed to delete folder: $folderPath, error: $e';
  }

  @override
  String get deleteFolderFailed_4821 =>
      'Deletion failed: folder is not empty or does not exist';

  @override
  String get deleteFolderFailed_4840 => 'Failed to delete folder';

  @override
  String get deleteFolder_4271 => 'Delete folder';

  @override
  String get deleteFolder_4836 => 'Delete Folder';

  @override
  String deleteItem_4822(Object itemNumber) {
    return 'Delete item $itemNumber';
  }

  @override
  String get deleteLayer => 'Delete Layer';

  @override
  String deleteLayerWithReactiveSystem(Object name) {
    return 'Delete layer with reactive system: $name';
  }

  @override
  String get deleteLayer_4271 => 'Delete Layer';

  @override
  String get deleteLayer_4821 => 'Delete Layer';

  @override
  String deleteLayer_7425(Object layerId) {
    return 'Delete layer: $layerId';
  }

  @override
  String get deleteLegend => 'Delete Legend';

  @override
  String deleteLegendFailed(Object e, Object title) {
    return 'Failed to delete legend: $title, error: $e';
  }

  @override
  String get deleteLegendGroup => 'Delete legend group';

  @override
  String deleteLegendGroupFailed(
    Object error,
    Object groupId,
    Object mapTitle,
    Object version,
  ) {
    return 'Failed to delete legend group [$mapTitle/$groupId:$version]: $error';
  }

  @override
  String deleteLegendGroupFailed_7421(Object error) {
    return 'Failed to delete legend group: $error';
  }

  @override
  String get deleteLegendGroup_4271 => 'Delete legend group';

  @override
  String get deleteLegend_7421 => 'Delete Legend';

  @override
  String get deleteMap => 'Delete Map';

  @override
  String deleteMapFailed(Object error) {
    return 'Failed to delete map: $error';
  }

  @override
  String deleteNoteDebug(Object noteId) {
    return 'Delete note: $noteId';
  }

  @override
  String deleteNoteElementFailed(Object e) {
    return 'Failed to delete note element: $e';
  }

  @override
  String deleteNoteFailed(Object e) {
    return 'Failed to delete note: $e';
  }

  @override
  String deleteNoteFailed_7281(Object e) {
    return 'Failed to delete note: $e';
  }

  @override
  String get deleteNoteLabel_4821 => 'Delete note';

  @override
  String get deleteNoteTooltip_7281 => 'Delete note';

  @override
  String get deleteNote_7421 => 'Delete note';

  @override
  String deleteOldDataError(Object e, Object mapTitle) {
    return 'Error deleting old data directory [$mapTitle]: $e';
  }

  @override
  String deletePrivateKeyFailed(Object e) {
    return 'Failed to delete private key: $e';
  }

  @override
  String get deleteScript_4271 => 'Delete script';

  @override
  String get deleteSelectedItems_4821 => 'Delete selected items';

  @override
  String get deleteSelected_4821 => 'Delete Selected';

  @override
  String deleteStickyNoteElementDebug(Object elementId, Object id) {
    return 'Delete sticky note drawing element using responsive system: $id/$elementId';
  }

  @override
  String deleteStickyNoteError_7425(
    Object e,
    Object mapTitle,
    Object stickyNoteId,
    Object version,
  ) {
    return 'Failed to delete sticky note data [$mapTitle/$stickyNoteId:$version]: $e';
  }

  @override
  String deleteSuccessLog_7421(Object fullRemotePath) {
    return 'Deleted successfully: $fullRemotePath';
  }

  @override
  String deleteTempFile(Object path) {
    return 'Delete temporary file: $path';
  }

  @override
  String deleteTempFileFailed_7421(Object error, Object path) {
    return 'Failed to delete temporary file: $path, error: $error';
  }

  @override
  String get deleteText_4821 => 'Delete';

  @override
  String deleteTimerFailed(Object e) {
    return 'Failed to delete timer: $e';
  }

  @override
  String deleteUserFailed_7421(Object error) {
    return 'Failed to delete user: $error';
  }

  @override
  String deleteVersionFailed(Object error) {
    return 'Failed to delete version: $error';
  }

  @override
  String deleteVersionMetadataFailed(
    Object e,
    Object mapTitle,
    Object versionId,
  ) {
    return 'Failed to delete version metadata [$mapTitle:$versionId]: $e';
  }

  @override
  String deleteVersionSession(Object mapTitle, Object versionId) {
    return 'Delete version session [$mapTitle/$versionId]';
  }

  @override
  String get deleteVersion_4271 => 'Delete version';

  @override
  String deleteVfsVersionDataFailed(Object e) {
    return 'Failed to delete VFS version data: $e';
  }

  @override
  String get delete_3834 => 'Delete';

  @override
  String get delete_4821 => 'Delete';

  @override
  String get delete_4838 => 'Delete';

  @override
  String get delete_4963 => 'Delete';

  @override
  String get delete_5421 => 'Delete';

  @override
  String get delete_7281 => 'Delete';

  @override
  String deletedItems_4821(Object count) {
    return 'Deleted $count items';
  }

  @override
  String get deletedMessage_7421 => 'Deleted';

  @override
  String get demoMapBlueTheme_4821 => 'Demo Map - Blue Theme';

  @override
  String get demoMapGreenTheme_7281 => 'Demo Map - Green Theme';

  @override
  String get demoMapSynced_7281 => 'Demo map 1 information has been synced';

  @override
  String get demoMapSynced_7421 => 'Demo map 2 information has been synced';

  @override
  String get demoModeTitle_7281 => 'Embedded Mode Demo';

  @override
  String get demoText_4271 => 'Demo';

  @override
  String get demoUpdateNoticeWithoutAnimation_4821 =>
      '🔄 Demo Update Notice (No Re-animation)';

  @override
  String get demoUser_4721 => 'Demo User';

  @override
  String get densityLabel_4821 => 'Density';

  @override
  String densityValue_7281(Object value) {
    return 'Density: ${value}x';
  }

  @override
  String get dependencyDescription_4821 =>
      'Additionally, this project relies on numerous excellent open-source packages from the Flutter ecosystem. Tap the button below to view the complete list of dependencies and license information.';

  @override
  String get descriptionHint_4942 =>
      'Enter detailed description of the resource pack';

  @override
  String get descriptionLabel_4821 => 'Description';

  @override
  String get description_4941 => 'Description';

  @override
  String desktopExportFailed(Object e) {
    return 'Failed to export image on desktop: $e';
  }

  @override
  String desktopExportImageFailed_7285(Object e) {
    return 'Failed to export single image on desktop: $e';
  }

  @override
  String get desktopFiles => 'Desktop files';

  @override
  String get desktopMobilePlatforms_4821 => 'On desktop/mobile platforms:';

  @override
  String get desktopMobile_6943 => 'Desktop/Mobile';

  @override
  String get desktopMode_2634 => 'Desktop mode';

  @override
  String get destructible_4830 => 'Destructible';

  @override
  String get destructible_4831 => 'Destructible';

  @override
  String get detectOldDataMigration_7281 =>
      'Old data requiring migration detected';

  @override
  String detectionResultShouldEnableLink_7421(Object shouldEnableLink) {
    return 'Detection Result - Should Enable Link: $shouldEnableLink';
  }

  @override
  String get device_4824 => 'Device';

  @override
  String get device_4828 => 'Device';

  @override
  String get diagonalAreaLabel_4821 => 'Diagonal area';

  @override
  String get diagonalArea_4826 => 'Diagonal area';

  @override
  String get diagonalCutting_4521 => 'Diagonal cutting';

  @override
  String get diagonalLines => 'Diagonal lines';

  @override
  String get diagonalLinesTool_9023 => 'Single diagonal line';

  @override
  String get directUse_4821 => 'Use directly';

  @override
  String directoryCopyComplete(Object sourcePath, Object targetPath) {
    return 'Directory copy completed: $sourcePath -> $targetPath';
  }

  @override
  String directoryCreatedSuccessfully(Object fullRemotePath) {
    return 'Directory created successfully: $fullRemotePath';
  }

  @override
  String directoryCreationFailed_7285(Object e) {
    return 'Directory creation failed: $e';
  }

  @override
  String directoryListSuccess(Object fullRemotePath, Object length) {
    return 'Directory list retrieved successfully: $fullRemotePath ($length items)';
  }

  @override
  String directorySelectedByGroup(Object groupName) {
    return 'This directory has been selected by the legend group \"$groupName';
  }

  @override
  String get directorySelectedByOthers_4821 =>
      'This directory has been selected by another legend group';

  @override
  String get directorySelectionNotAllowed_4821 =>
      'Folder selection is not allowed';

  @override
  String directoryUsedByGroups(Object groupNames) {
    return 'This directory is selected by the following legend groups: $groupNames';
  }

  @override
  String get directory_4821 => 'Directory';

  @override
  String get directory_5030 => 'Directory';

  @override
  String get disableAudioRendering_4821 => 'Disable audio rendering';

  @override
  String get disableAutoPlay_5421 => 'Disable auto-play';

  @override
  String get disableCrosshair_42 => 'Disable crosshair';

  @override
  String get disableHtmlRendering_4721 => 'Disable HTML rendering';

  @override
  String get disableLatexRendering_4821 => 'Disable LaTeX rendering';

  @override
  String get disableLoopPlayback_7281 => 'Disable loop playback';

  @override
  String get disableVideoRendering_4821 => 'Disable video rendering';

  @override
  String get disable_4821 => 'Disable';

  @override
  String get disabledInParentheses_4829 => '(Disabled)';

  @override
  String get disabledIndicator_7421 => '(Disabled)';

  @override
  String get disabledLabel_4821 => '(Disabled)';

  @override
  String get disabledStatus_4821 => 'Disabled';

  @override
  String get disabledTrayNavigation_4821 =>
      'This page has disabled TrayNavigation';

  @override
  String get disabled_4821 => 'Disabled';

  @override
  String get discardChanges_7421 => 'Discard changes';

  @override
  String get disconnectCurrentConnection_7281 =>
      'Disconnect current connection...';

  @override
  String disconnectFailed_7285(Object e) {
    return 'Disconnect failed: $e';
  }

  @override
  String get disconnectWebSocket_4821 =>
      'GlobalCollaborationService WebSocket disconnected';

  @override
  String get disconnectWebSocket_7421 => 'Disconnect WebSocket connection';

  @override
  String get disconnect_7421 => 'Disconnect';

  @override
  String get disconnectedOffline_3632 => 'Disconnected (Offline Mode)';

  @override
  String get disconnected_4821 => 'Disconnected';

  @override
  String get disconnected_9067 => 'Disconnected';

  @override
  String get displayAreaMultiplierLabel_4821 => 'Display area multiplier';

  @override
  String displayAreaMultiplierText(Object value) {
    return 'Display area multiplier: ${value}x';
  }

  @override
  String get displayDuration_7284 => 'Display duration:';

  @override
  String get displayLocaleSetting_4821 => 'Display locale settings';

  @override
  String get displayLocation_7421 => 'Display location';

  @override
  String get displayNameCannotBeEmpty_4821 => 'Display name cannot be empty';

  @override
  String get displayNameHint_4821 => 'Enter client display name';

  @override
  String get displayNameHint_7532 => 'Please enter your display name';

  @override
  String get displayNameLabel_4821 => 'Display name';

  @override
  String get displayNameMinLength_4821 =>
      'Display name must be at least 2 characters long';

  @override
  String get displayNameTooLong_42 =>
      'Display name cannot exceed 50 characters';

  @override
  String get displayName_1234 => 'Display Name';

  @override
  String get displayName_4521 => 'Display Name';

  @override
  String get displayName_4821 => 'Display name';

  @override
  String displayOrderLayersDebug(Object layers) {
    return 'Current _displayOrderLayers sequence: $layers';
  }

  @override
  String get dividerText_4821 => 'Divider';

  @override
  String get doNotAutoClose_7281 => 'Do not auto close';

  @override
  String get documentName_4821 => 'Document';

  @override
  String get documentNavigation_7281 => 'Document Navigation';

  @override
  String get documentNoAudioContent_4821 =>
      'This document does not contain audio content';

  @override
  String get documentWithoutLatex_4721 =>
      'This document does not contain LaTeX formulas';

  @override
  String get documentationDescription_4912 =>
      'View detailed usage instructions and development documentation';

  @override
  String get door_4825 => 'Door';

  @override
  String get dotGrid => 'Dot grid';

  @override
  String get dotGridArea_4828 => 'Dot Grid Area';

  @override
  String get dotGridLabel_5421 => 'Dot Grid';

  @override
  String get dotGridTool_7901 => 'Dot Grid';

  @override
  String get dotGrid_1968 => 'Dot Grid';

  @override
  String get dotGrid_4828 => 'Dot Grid';

  @override
  String get downText_4821 => 'Down';

  @override
  String get downloadAndImportFailed_5039 => 'Download and import failed';

  @override
  String get downloadAndImport_5029 => 'Download and Import';

  @override
  String get downloadAsZip_4821 => 'Download as ZIP';

  @override
  String get downloadAsZip_4975 => 'Download as ZIP';

  @override
  String get downloadCurrentDirectoryCompressed_4821 =>
      'Download Current Directory (Compressed)';

  @override
  String get downloadCurrentDirectory_4821 => 'Download Current Directory';

  @override
  String get downloadExportFile_4966 => 'Download Export File';

  @override
  String downloadFailed_7284(Object error) {
    return 'Download failed: $error';
  }

  @override
  String downloadFailed_7285(Object e) {
    return 'Download failed: $e';
  }

  @override
  String downloadFailed_7425(Object e) {
    return 'Download failed: $e';
  }

  @override
  String downloadFilesAndFolders(
    Object downloadPath,
    Object fileCount,
    Object folderCount,
  ) {
    return 'Downloaded $fileCount files and $folderCount folders to $downloadPath';
  }

  @override
  String get downloadSelectedCompressed_4821 =>
      'Download Selected (Compressed)';

  @override
  String get downloadSelected_4821 => 'Download Selected';

  @override
  String get downloadSelected_4974 => 'Download Selected';

  @override
  String downloadSummary(
    Object downloadPath,
    Object fileCount,
    Object folderCount,
  ) {
    return 'Downloaded $fileCount files and $folderCount folders to $downloadPath';
  }

  @override
  String get downloadZipFileFailed_5037 => 'Failed to download ZIP file';

  @override
  String get download_4821 => 'Download';

  @override
  String get download_4973 => 'Download';

  @override
  String downloadedFilesAndDirectories(
    Object directoryCount,
    Object fileCount,
  ) {
    return 'Downloaded $fileCount files and $directoryCount directories';
  }

  @override
  String downloadedFilesCount(Object fileCount) {
    return '$fileCount files downloaded';
  }

  @override
  String downloadedFilesFromDirectories(Object directoryCount) {
    return 'Downloaded files from $directoryCount directories';
  }

  @override
  String downloadedFilesInDirectories(Object directoryCount) {
    return 'Downloaded files in $directoryCount directories';
  }

  @override
  String downloadingFileProgress_4821(Object percent) {
    return 'Downloading file... $percent%';
  }

  @override
  String get downloading_5036 => 'Downloading';

  @override
  String dragComplete_7281(Object legendPath) {
    return 'Drag completed: $legendPath';
  }

  @override
  String get dragDemoTitle_4821 => 'Drag Function Demo';

  @override
  String get dragEndCheckDrawer_4821 =>
      'Drag ended: Check if the legend group management drawer needs to be reopened';

  @override
  String dragEndLegend_7281(Object legendPath, Object wasAccepted) {
    return 'Drag end legend: $legendPath, accepted: $wasAccepted';
  }

  @override
  String get dragEndReopenLegendDrawer_7281 =>
      'Drag ended: reopen legend group management drawer';

  @override
  String get dragFeature_4521 => 'Drag feature';

  @override
  String get dragHandleSizeHint_4821 => 'Drag handle size';

  @override
  String dragLegendAccepted_5421(Object legendPath) {
    return 'Drag legend received (onAccept): $legendPath';
  }

  @override
  String dragLegendFromCache(Object canvasPosition, Object legendPath) {
    return 'Drag legend from cache: $legendPath to position: $canvasPosition';
  }

  @override
  String dragLegendStart(Object legendPath) {
    return 'Start dragging legend: $legendPath';
  }

  @override
  String dragReleasePosition_7421(Object globalPosition, Object localPosition) {
    return 'Drag release position - Global: $globalPosition, Local: $localPosition';
  }

  @override
  String get dragStartCloseDrawer_4821 =>
      'Drag to start: temporarily close the legend group management drawer';

  @override
  String dragToAddLegendItem_7421(Object id, Object legendId) {
    return 'Drag to add legend item to map editor: ID=$id, legendId=$legendId';
  }

  @override
  String get dragToMoveHint_7281 =>
      '💡 Tip: Press and hold the mouse on the title bar area to drag';

  @override
  String dragToReorderFailed_7285(Object e) {
    return 'Failed to reorder note by dragging: $e';
  }

  @override
  String get draggableWindowDescription_4821 => 'Draggable floating window';

  @override
  String get draggableWindowTitle_4521 => 'Draggable Window';

  @override
  String get draggableWindowTitle_4821 => 'Draggable Window';

  @override
  String get draggableWindow_4271 => 'Draggable window';

  @override
  String get draggingText_4821 => 'Dragging...';

  @override
  String get drawArrowTooltip_8732 => 'Draw arrow';

  @override
  String get drawDashedLine_7532 => 'Draw dashed line';

  @override
  String get drawDiagonalAreaTooltip_7532 => 'Draw diagonal area';

  @override
  String get drawDotGridTooltip_8732 => 'Draw dot grid';

  @override
  String get drawHollowRectangle_8423 => 'Draw hollow rectangle';

  @override
  String get drawLineTooltip_4522 => 'Draw a straight line';

  @override
  String get drawRectangleTooltip_4522 => 'Draw rectangle';

  @override
  String drawToDefaultLayer_4726(Object name) {
    return 'Draw to: $name (default top layer)';
  }

  @override
  String drawToLayer_4725(Object name) {
    return 'Draw to: $name';
  }

  @override
  String drawToStickyNote_4724(Object title) {
    return 'Draw to sticky note: $title';
  }

  @override
  String get drawerWidthSetting_4521 => 'Drawer width setting';

  @override
  String get drawerWidth_4271 => 'Drawer width';

  @override
  String get drawingAreaHint_4821 => 'You can draw in this area';

  @override
  String get drawingElementDeleted_7281 => 'Drawing element deleted';

  @override
  String get drawingLayer_4821 => 'Drawing Layer';

  @override
  String get drawingPanel_1234 => 'Drawing Panel';

  @override
  String get drawingToolDisabled_4287 => 'Drawing tool is disabled';

  @override
  String get drawingToolManagerCallbackNotSet_4821 =>
      'DrawingToolManager: The addDrawingElement callback is not set or the target layer ID is empty, unable to add element';

  @override
  String get drawingToolsTitle_4722 => 'Drawing Tools';

  @override
  String get drawingTools_4821 => 'Drawing Tools';

  @override
  String get duplicateExportName_4962 => 'Duplicate export name';

  @override
  String duplicateItemExists_7281(Object item) {
    return 'An item with the same name \"$item\" already exists in the target location:';
  }

  @override
  String get duplicateLayer_4821 => 'Duplicate Layer';

  @override
  String duplicateMapTitle(Object newTitle) {
    return 'The map title \"$newTitle\" already exists';
  }

  @override
  String duplicateShortcutWarning(Object shortcut) {
    return 'Duplicate shortcut: $shortcut already exists in the current list';
  }

  @override
  String duplicateShortcutsWarning_7421(Object duplicates) {
    return 'Duplicate shortcuts found in the list: $duplicates';
  }

  @override
  String get durationLabel_4821 => 'Duration';

  @override
  String get dutchNL_4841 => 'Dutch (Netherlands)';

  @override
  String get dutch_4840 => 'Dutch';

  @override
  String dynamicBufferMultiplierInfo(Object multiplier) {
    return '- Dynamic buffer multiplier: ${multiplier}x (Smart calculation)';
  }

  @override
  String dynamicFormulaLegendSizeCalculation(
    Object currentZoomLevel,
    Object legendSize,
    Object zoomFactor,
  ) {
    return 'Calculating legend size with dynamic formula: zoomFactor=$zoomFactor, currentZoom=$currentZoomLevel, legendSize=$legendSize';
  }

  @override
  String get dynamicFormulaText_7281 =>
      'Using dynamic formula: 1/(scale*factor)';

  @override
  String get dynamicSize_4821 => 'Dynamic Size';

  @override
  String get editAuthAccount_5421 => 'Edit authentication account';

  @override
  String get editButton_7281 => 'Edit';

  @override
  String get editConflict_4827 => 'Edit conflict';

  @override
  String get editDensity_4271 => 'Edit Density';

  @override
  String get editFontSize_4821 => 'Edit font size';

  @override
  String editImageTitle(Object index) {
    return 'Edit Image $index';
  }

  @override
  String editItemMessage_4821(Object itemNumber) {
    return 'Edit item $itemNumber';
  }

  @override
  String editItemMessage_5421(Object item) {
    return 'Edit $item';
  }

  @override
  String get editJson_7281 => 'Edit JSON';

  @override
  String get editLabel_4271 => 'Edit';

  @override
  String get editLabel_4521 => 'Edit';

  @override
  String get editLabel_4821 => 'Edit';

  @override
  String get editLabel_5421 => 'Edit';

  @override
  String get editLegendGroupName_4271 => 'Edit legend group name';

  @override
  String get editLegendGroup_4271 => 'Edit Legend Group';

  @override
  String get editLegend_4271 => 'Edit Legend';

  @override
  String get editMode_4821 => 'Edit Mode';

  @override
  String get editMode_5421 => 'Edit mode';

  @override
  String get editNameTooltip_7281 => 'Edit name';

  @override
  String editNoteDebug(Object id) {
    return 'Edit note: $id';
  }

  @override
  String get editNote_4271 => 'Edit note';

  @override
  String get editRadial_7421 => 'Edit Radius';

  @override
  String get editRotationAngle_4271 => 'Edit rotation angle';

  @override
  String get editScriptParams => 'Edit Script Parameters';

  @override
  String editScriptParamsFailed(Object e) {
    return 'Failed to edit script parameters: $e';
  }

  @override
  String editScriptTitle(Object scriptName) {
    return 'Edit script: $scriptName';
  }

  @override
  String get editShortcutTooltip_4821 => 'Edit shortcut';

  @override
  String get editShortcuts_7421 => 'Edit Shortcuts';

  @override
  String get editStrokeWidth_4271 => 'Edit stroke width';

  @override
  String get editTextContent_4821 => 'Edit text content';

  @override
  String get editUserInfo_4821 => 'Edit user information';

  @override
  String get editWebDavConfig => 'Edit WebDAV Configuration';

  @override
  String get editZIndexTitle_7281 => 'Edit Z Index';

  @override
  String get edit_7281 => 'Edit';

  @override
  String get editingLabel_7421 => 'Editing:';

  @override
  String editingMapTitle(Object currentMapTitle) {
    return 'Editing: $currentMapTitle';
  }

  @override
  String get editingStatus_4821 => 'Editing';

  @override
  String get editingStatus_7154 => 'Editing';

  @override
  String editingVersion_7421(Object versionId) {
    return 'Editing: $versionId';
  }

  @override
  String get editorStatus_4521 => 'Editor status';

  @override
  String elementCount(Object count) {
    return 'Elements: $count';
  }

  @override
  String elementDebugInfo_7428(Object i, Object imageData, Object typeName) {
    return 'Element [$i]: type=$typeName, imageData=$imageData';
  }

  @override
  String elementListWithCount(Object count) {
    return 'Element list ($count)';
  }

  @override
  String get elementLockConflict_4821 => 'Element lock conflict';

  @override
  String get elementLockFailed_7281 => 'Element lock failed';

  @override
  String get elementLockReleased_7425 => 'Element lock released';

  @override
  String elementLockedSuccessfully_7281(
    Object currentUserId,
    Object elementId,
  ) {
    return '[CollaborationStateManager] Element locked successfully: $elementId by $currentUserId';
  }

  @override
  String elementNotFound_4821(Object elementId) {
    return 'Element not found: $elementId';
  }

  @override
  String get element_3141 => 'Element';

  @override
  String elements(Object elements) {
    return '$elements elements';
  }

  @override
  String elements_3343(Object elementsCount) {
    return '$elementsCount elements';
  }

  @override
  String elements_7383(Object elementsCount) {
    return '$elementsCount elements';
  }

  @override
  String get elevator_4823 => 'Elevator';

  @override
  String get embeddedModeDescription_4821 =>
      'Pure rendering component, embeddable in any layout';

  @override
  String get embeddedModeTitle_4821 => '3. Embedded Mode';

  @override
  String get emptyDirectory_7281 => 'The current directory is empty';

  @override
  String get emptyFolderDescription_4827 => 'No maps in this folder yet';

  @override
  String get emptyFolderMessage_4826 => 'This folder is empty';

  @override
  String get emptyLayerSkipped_7281 => 'Layer is empty, skipped';

  @override
  String get emptyNote_4251 => 'Empty Note';

  @override
  String get emptyNotesMessage_7421 =>
      'No notes yet  \nTap the button above to add a new note';

  @override
  String get enableAnimation_7281 => 'Enable animation';

  @override
  String get enableAnimations => 'Enable animations';

  @override
  String get enableAudioRendering_4821 => 'Enable audio rendering';

  @override
  String get enableAutoPlay_5421 => 'Enable auto-play';

  @override
  String get enableConfiguration_4271 => 'Enable configuration';

  @override
  String get enableCrosshair_42 => 'Enable crosshair';

  @override
  String get enableEditing_5421 => 'Enable editing';

  @override
  String get enableHtmlRendering_5832 => 'Enable HTML rendering';

  @override
  String get enableLatexRendering_4822 => 'Enable LaTeX rendering';

  @override
  String enableLayerLinkingToMaintainGroupIntegrity(Object name) {
    return 'Enable layer linking to maintain group integrity: $name';
  }

  @override
  String get enableLoopPlayback_7282 => 'Enable loop playback';

  @override
  String enableMobileLayerLink_7421(Object name) {
    return 'Enable mobile layer link: $name';
  }

  @override
  String get enableSpeechSynthesis_4271 => 'Enable speech synthesis';

  @override
  String get enableThemeColorFilter_7281 => 'Enable theme color filter';

  @override
  String get enableVideoRendering_4822 => 'Enable video rendering';

  @override
  String get enableVoiceReadingFeature_4821 =>
      'Enable to support voice reading feature';

  @override
  String get enable_4821 => 'Enable';

  @override
  String get enable_7532 => 'Enable';

  @override
  String get enabledStatus_4821 => 'Enabled';

  @override
  String get enabled_4821 => 'Enabled';

  @override
  String get englishAU_4896 => 'English (Australia)';

  @override
  String get englishCA_4897 => 'English (Canada)';

  @override
  String get englishIN_4898 => 'English (India)';

  @override
  String get englishLanguage_4821 => 'English';

  @override
  String get englishUK_4826 => 'English (UK)';

  @override
  String get englishUS_4825 => 'English (US)';

  @override
  String get english_4824 => 'English';

  @override
  String get ensureValidExportPaths_4821 =>
      'Please ensure all export items have valid source paths and export names';

  @override
  String enterActiveMap(Object mapTitle) {
    return 'Enter active map: $mapTitle';
  }

  @override
  String get enterAuthorName_4938 => 'Enter author name';

  @override
  String get enterConfigurationDescriptionHint_4522 =>
      'Please enter configuration description (optional)';

  @override
  String get enterConfigurationName_5732 =>
      'Please enter the configuration name';

  @override
  String get enterDisplayName_4821 => 'Please enter a display name';

  @override
  String get enterExportName_4960 => 'Enter export name';

  @override
  String get enterFieldName_4945 => 'Enter field name';

  @override
  String get enterFieldValue_4947 => 'Enter field value';

  @override
  String get enterFileName_4821 => 'Please enter the file name';

  @override
  String get enterFolderName_4831 => 'Please enter folder name';

  @override
  String get enterFullscreen_4821 => 'Fullscreen';

  @override
  String get enterFullscreen_4822 => 'Fullscreen';

  @override
  String get enterFullscreen_5832 => 'Fullscreen';

  @override
  String get enterImmediately_4821 => 'Enter Now';

  @override
  String get enterLegendTitle => 'Please enter the legend title';

  @override
  String get enterMapTitle => 'Please enter the map title';

  @override
  String get enterMapVersion_4822 => 'Enter map version number';

  @override
  String get enterNumberHint_4521 => 'Please enter a number';

  @override
  String get enterPassword_4821 => 'Please enter your password';

  @override
  String get enterResourcePackName_4934 => 'Enter resource pack name';

  @override
  String get enterScriptName_4821 => 'Please enter the script name';

  @override
  String enterSubMenuAfterDelay_4721(Object delay) {
    return 'Enter submenu after mouse stops moving for ${delay}ms';
  }

  @override
  String get enterSubMenuImmediately_4721 => 'Enter submenu immediately';

  @override
  String enterSubMenuNow_7421(Object label) {
    return 'Enter submenu now: $label';
  }

  @override
  String get enterTimerName_4821 => 'Please enter the timer name';

  @override
  String get enterValidUrl_4821 => 'Please enter a valid URL';

  @override
  String get enterWebApiKey_4821 => 'Please enter Web API Key';

  @override
  String enteredMapEditorMode(Object title) {
    return 'Entered map editor collaboration mode: $title';
  }

  @override
  String get entrance_4821 => 'Entrance';

  @override
  String get entrance_4823 => 'Entrance';

  @override
  String get enumType_7890 => 'Select';

  @override
  String get eraserItem_4821 => 'Eraser';

  @override
  String get eraserLabel_4821 => 'Eraser';

  @override
  String get eraserTool_3478 => 'Eraser';

  @override
  String get eraserTool_4821 => 'Eraser';

  @override
  String get eraserTooltip_4822 => 'Erase element';

  @override
  String get eraser_4291 => 'Eraser';

  @override
  String get eraser_4829 => 'Eraser';

  @override
  String get eraser_4831 => 'Eraser';

  @override
  String get error => 'Error';

  @override
  String get errorLabel_4821 => 'Error';

  @override
  String errorLog_7421(Object error) {
    return 'Error: $error';
  }

  @override
  String errorMessage(Object error) {
    return 'Error: $error';
  }

  @override
  String errorMessage_4821(Object error) {
    return 'Error: $error';
  }

  @override
  String get error_4821 => 'Error';

  @override
  String get error_5016 => 'Error';

  @override
  String get error_5732 => 'Error';

  @override
  String get error_8956 => 'Error';

  @override
  String get error_9376 => 'Error';

  @override
  String get estonianEE_4867 => 'Estonian (Estonia)';

  @override
  String get estonian_4866 => 'Estonian';

  @override
  String get example3ListItemMenu_7421 => 'Example 3: List Item Menu';

  @override
  String get exampleInputField_4521 => 'Example input field';

  @override
  String get exampleLibrary_7421 => 'Legend Library';

  @override
  String get exampleMyCloud_4822 => 'Example: My Cloud';

  @override
  String get exampleRightClickMenu_4821 => 'Example 1: Simple Right-Click Menu';

  @override
  String get exampleTag_4825 => 'Example';

  @override
  String excludedListSkipped_7285(Object path) {
    return 'Excluded list skipped: path=\"$path';
  }

  @override
  String get executeAction_7421 => 'Execute';

  @override
  String get executePermission_4821 => 'Execute';

  @override
  String get executeScript_4821 => 'Execute script';

  @override
  String get executing_7421 => 'Executing...';

  @override
  String get executionEngine_4521 => 'Execution Engine';

  @override
  String get executionEngine_4821 => 'Execution Engine';

  @override
  String get executionFailed_5421 => 'Execution failed';

  @override
  String get executionFailed_7281 => 'Execution failed';

  @override
  String executionSuccessWithTime(Object time) {
    return 'Execution successful (${time}ms)';
  }

  @override
  String get executionSuccess_5421 => 'Execution successful';

  @override
  String exitConfirmationCheck(Object first, Object second) {
    return 'Exit confirmation check: _hasUnsavedChanges=$first, hasUnsavedVersions=$second';
  }

  @override
  String get exitFullscreen_4721 => 'Exit fullscreen';

  @override
  String get exitFullscreen_4821 => 'Exit fullscreen';

  @override
  String get exitWithoutSaving_7281 => 'Exit without saving';

  @override
  String get expandNote_5421 => 'Expand note';

  @override
  String get expandPlayer_7281 => 'Expand player';

  @override
  String get expand_4821 => 'Expand';

  @override
  String get expandedState_5421 => 'Expand';

  @override
  String get expiredDataCleaned_7281 => 'Expired data cleanup completed';

  @override
  String expiredLocksCleaned_4821(Object count) {
    return '$count expired locks have been cleaned up';
  }

  @override
  String get exportAsPdf_7281 => 'Export as PDF';

  @override
  String get exportBoundaryNotFound_7281 => 'Export boundary not found';

  @override
  String exportClientConfigFailed(Object e) {
    return 'Failed to export client configuration: $e';
  }

  @override
  String exportConfigFailed_7421(Object error) {
    return 'Failed to export configuration: $error';
  }

  @override
  String get exportConfig_7281 => 'Export Configuration';

  @override
  String get exportDatabase => 'Export database';

  @override
  String get exportDatabaseDialogTitle_4721 =>
      'Export R6Box Database (Web Platform Only)';

  @override
  String exportDatabaseFailed_7421(Object e) {
    return 'Failed to export database: $e';
  }

  @override
  String get exportDescription_4953 =>
      'Select files or folders to export and specify export names for them. The system will create a ZIP file containing the selected resources and metadata.';

  @override
  String get exportExternalResources_4952 => 'Export External Resources';

  @override
  String get exportFailedRetry_4821 => 'Export failed, please try again';

  @override
  String get exportFailed_5011 => 'Export failed';

  @override
  String exportFailed_7284(Object e) {
    return 'Export failed: $e';
  }

  @override
  String exportFailed_7285(Object e) {
    return 'Export failed: $e';
  }

  @override
  String exportFileInfoFailed(Object e) {
    return 'Failed to get export file info: $e';
  }

  @override
  String exportFileNotExist_7285(Object filePath) {
    return 'Export file does not exist: $filePath';
  }

  @override
  String exportFileValidationPassed(Object filePath) {
    return 'Export file validation passed: $filePath';
  }

  @override
  String exportGroupFailed_7285(Object e) {
    return 'Failed to export group: $e';
  }

  @override
  String exportImageFailed_7421(Object e) {
    return 'Failed to export image: $e';
  }

  @override
  String exportImageTitle_7421(Object index) {
    return 'Export image $index';
  }

  @override
  String get exportImage_7421 => 'Export Image';

  @override
  String get exportInfoTitle_4728 => 'Export Information';

  @override
  String get exportLabel_7421 => 'Export';

  @override
  String get exportLayerAsPng_7281 => 'Export layer as PNG';

  @override
  String exportLayerFailed_7421(Object e) {
    return 'Failed to export layer: $e';
  }

  @override
  String exportLayerSuccess(Object name) {
    return 'Layer exported: $name';
  }

  @override
  String get exportLayer_7421 => 'Export Layer';

  @override
  String get exportLegendDatabaseTitle_4821 => 'Export Legend Database';

  @override
  String get exportLegendDatabase_4821 => 'Export Legend Database';

  @override
  String exportLegendFailed_7285(Object e) {
    return 'Failed to export legend database: $e';
  }

  @override
  String get exportList_7281 => 'Export List';

  @override
  String exportLocalDbFailed(Object e) {
    return 'Failed to export localization database: $e';
  }

  @override
  String exportMapFailed_7285(Object e) {
    return 'Failed to export map package: $e';
  }

  @override
  String get exportMapLocalizationFileTitle_4821 =>
      'Export Map Localization File';

  @override
  String get exportName_4955 => 'Export Name';

  @override
  String get exportPdf_5678 => 'Export PDF';

  @override
  String get exportPdf_7281 => 'Export PDF';

  @override
  String get exportPreview_4821 => 'Export Preview';

  @override
  String get exportSettings => 'Export Settings';

  @override
  String exportSettingsFailed_7421(Object error) {
    return 'Failed to export settings: $error';
  }

  @override
  String exportSuccessMessage(Object exportPath) {
    return 'Map data successfully exported to: $exportPath';
  }

  @override
  String get exportSuccess_5010 => 'Export successful!';

  @override
  String get exportToFolder_4967 => 'Export to Folder';

  @override
  String exportValidationFailed_4821(Object e) {
    return 'Failed to validate export file: $e';
  }

  @override
  String get exportVersion_9234 => 'Export version';

  @override
  String get exportingImage_7421 => 'Exporting image...';

  @override
  String get exportingVfsMapDatabase_7281 =>
      'Starting to export VFS map database...';

  @override
  String get exporting_4965 => 'Exporting...';

  @override
  String get exporting_7421 => 'Exporting';

  @override
  String get extendedSettingsStorage_4821 => 'Extended settings storage';

  @override
  String get extensionManagerInitialized_7281 =>
      'Extension settings manager initialized';

  @override
  String get extensionManagerNotInitialized_7281 =>
      'Extension settings manager is not initialized';

  @override
  String get extensionMethodsDescription_4821 =>
      'Use BuildContext extension methods to quickly create floating windows';

  @override
  String get extensionMethodsTitle_4821 => 'Extension Methods';

  @override
  String extensionSettingsClearedMapLegendZoom_7421(Object mapId) {
    return 'Extension settings: Cleared all legend group zoom factor settings for map $mapId';
  }

  @override
  String get extensionSettingsCleared_4821 => 'Extension settings cleared';

  @override
  String get extensionSettingsSaved_4821 => 'Extension settings saved';

  @override
  String get extensionStorageDisabled_4821 =>
      'Extension settings storage is disabled';

  @override
  String get extensionWindowTitle_7281 => 'Extension Method Window';

  @override
  String externalFunctionError_4821(Object error, Object functionName) {
    return 'External function $functionName execution error: $error';
  }

  @override
  String get externalFunctionsRegisteredToIsolateExecutor_7281 =>
      'All external functions have been registered to the Isolate executor';

  @override
  String get externalResourceManagement_7421 => 'External Resource Management';

  @override
  String get externalResourcesManagement_4821 => 'External Resource Management';

  @override
  String get externalResourcesUpdateSuccess_4924 =>
      'External resources updated successfully';

  @override
  String get extractTo_4821 => 'Extract to...';

  @override
  String get extractingFilesToTempDir_4990 =>
      'Extracting files to temporary directory...';

  @override
  String get extractingZipFile_4989 => 'Extracting ZIP file...';

  @override
  String extractionFailed_5011(Object error) {
    return 'Extraction failed: $error';
  }

  @override
  String extractionSuccess_5010(Object count) {
    return 'Successfully extracted $count files';
  }

  @override
  String get failedToGetAudioFile_4821 =>
      'Failed to retrieve audio file from VFS';

  @override
  String failedToGetImageSize(Object e) {
    return 'Failed to get image size: $e';
  }

  @override
  String failedToGetLegendFromPath_7281(Object absolutePath, Object e) {
    return 'Failed to get legend from absolute path: $absolutePath, error: $e';
  }

  @override
  String failedToGetVoiceSpeedRange(Object e) {
    return 'Failed to get voice speed range: $e';
  }

  @override
  String failedToGetWebDavAccountIds(Object e) {
    return 'Failed to get all WebDAV account IDs: $e';
  }

  @override
  String get failedToInitializeReactiveVersionManagement_7285 =>
      'Failed to initialize reactive version management: current map is empty';

  @override
  String failedToLoadDrawingElement(
    Object e,
    Object layerId,
    Object mapTitle,
    Object version,
  ) {
    return 'Failed to load drawing element [$mapTitle/$layerId:$version]: $e';
  }

  @override
  String failedToLoadElement_4821(
    Object e,
    Object elementId,
    Object layerId,
    Object mapTitle,
    Object version,
  ) {
    return 'Failed to load drawing element [$mapTitle/$layerId/$elementId:$version]: $e';
  }

  @override
  String get failedToLoadVfsDirectory_7281 => 'Failed to load VFS directory';

  @override
  String failedToParseLegendUpdateJson(Object e) {
    return 'Failed to parse legend group update parameter JSON: $e';
  }

  @override
  String failedToParseLegendUpdateParamsJson(Object error) {
    return 'Failed to parse legend update parameters JSON: $error';
  }

  @override
  String get failedToReadImageData_7284 => 'Failed to read image data';

  @override
  String get failedToReadImageFile_4821 => 'Failed to read image file';

  @override
  String get failedToReadTextFile_4821 => 'Failed to read text file';

  @override
  String get failure_7423 => 'Failure';

  @override
  String get failure_8364 => 'Failed';

  @override
  String get failure_9352 => 'Failure';

  @override
  String get fallbackToAsyncLoading_7281 => 'Fallback to async loading';

  @override
  String fallbackToTextModeCopy(Object height, Object platform, Object width) {
    return 'Fallen back to text mode copy: ${width}x$height ($platform)';
  }

  @override
  String get fastForward10Seconds_4821 => 'Fast forward 10 seconds';

  @override
  String get fastForward10Seconds_7281 => 'Fast forward 10 seconds';

  @override
  String fastForwardFailed_4821(Object e) {
    return 'Fast forward failed: $e';
  }

  @override
  String get fastForwardFailed_7285 => 'Fast forward operation failed';

  @override
  String get fastRewind10Seconds_7281 => 'Rewind 10 seconds';

  @override
  String fastRewindFailed_4821(Object e) {
    return 'Fast rewind failed: $e';
  }

  @override
  String get fast_4821 => 'Fast';

  @override
  String get favoriteStrokeWidths => 'Favorite Stroke Widths';

  @override
  String get featureConfiguration => 'Feature Configuration';

  @override
  String get featureEnhancement_4821 =>
      '🎉 More powerful: Supports 9 positions, stack management, and stunning animations!';

  @override
  String get features => 'Features';

  @override
  String get feedbackTitle_4271 => 'Feedback';

  @override
  String get fetchConfigFailed_4821 => 'Failed to fetch configuration';

  @override
  String fetchConfigFailed_7284(Object e) {
    return 'Failed to fetch configuration: $e';
  }

  @override
  String fetchConfigListFailed_7285(Object error) {
    return 'Failed to fetch configuration list: $error';
  }

  @override
  String fetchCustomTagFailed_7285(Object e) {
    return 'Failed to fetch custom tag: $e';
  }

  @override
  String fetchDataResult_7281(Object result, Object sourceVersionId) {
    return 'Fetching data from source version [$sourceVersionId]: $result';
  }

  @override
  String fetchDirectoryFailed_7285(Object e) {
    return 'Failed to fetch directory list: $e';
  }

  @override
  String fetchFolderListFailed_4821(Object e) {
    return 'Failed to fetch folder list: $e';
  }

  @override
  String fetchImageFailed_7285(Object e) {
    return 'Failed to fetch image: $e';
  }

  @override
  String fetchLegendListFailed_4821(Object e) {
    return 'Failed to fetch legend list: $e';
  }

  @override
  String fetchLegendListFailed_7285(Object e) {
    return 'Failed to fetch legend list: $e';
  }

  @override
  String fetchLegendListPath_7421(Object basePath) {
    return 'Fetch legend list, path: $basePath';
  }

  @override
  String fetchLocalizationFailed(Object e) {
    return 'Failed to fetch localization data: $e';
  }

  @override
  String fetchMapFailed_7285(Object e) {
    return 'Failed to fetch all maps: $e';
  }

  @override
  String fetchMapListFailed_7285(Object e) {
    return 'Failed to fetch map list: $e';
  }

  @override
  String fetchMapSummariesFailed_7285(Object e) {
    return 'Failed to fetch all map summaries: $e';
  }

  @override
  String fetchOnlineStatusFailed(Object error) {
    return 'Failed to fetch online status list: $error';
  }

  @override
  String fetchPrivateKeyIdsFailed_7285(Object e) {
    return 'Failed to fetch all private key IDs: $e';
  }

  @override
  String fetchTtsLanguagesFailed_4821(Object e) {
    return 'Failed to fetch TTS language list: $e';
  }

  @override
  String fetchUserPreferenceFailed(Object e) {
    return 'Failed to fetch user preferences: $e';
  }

  @override
  String fetchUserPreferencesFailed_4821(Object e) {
    return 'Failed to fetch user preferences: $e';
  }

  @override
  String fetchVersionNamesFailed(Object e, Object mapTitle) {
    return 'Failed to fetch all version names [$mapTitle]: $e';
  }

  @override
  String get fieldName_4944 => 'Field Name';

  @override
  String get fieldValue_4946 => 'Field Value';

  @override
  String get fileBrowser_4821 => 'File Browser';

  @override
  String get fileConflict_4821 => 'File conflict';

  @override
  String get fileConflict_4926 => 'File Conflict';

  @override
  String fileCount(Object count) {
    return '$count files';
  }

  @override
  String get fileCount_4821 => 'File count';

  @override
  String get fileDetails_4722 => 'File Details';

  @override
  String get fileDownloadComplete_4821 => 'File download completed!';

  @override
  String fileDownloadFailed_7281(Object e) {
    return 'File download failed: $e';
  }

  @override
  String fileDownloadSuccess(Object fullRemotePath, Object localFilePath) {
    return 'File downloaded successfully: $fullRemotePath -> $localFilePath';
  }

  @override
  String fileExtensionNotice(Object extension) {
    return 'Note: The file extension \"$extension\" will remain unchanged';
  }

  @override
  String get fileInfoCopiedToClipboard_4821 =>
      'File information has been copied to clipboard';

  @override
  String fileInfoTitle(Object name) {
    return 'File Info - $name';
  }

  @override
  String fileInfoWithSizeAndDate_5421(Object date, Object size) {
    return '$size • $date';
  }

  @override
  String get fileInfo_4821 => 'File Info';

  @override
  String get fileInfo_7281 => 'File Info';

  @override
  String fileLoadFailed_7284(Object e) {
    return 'Failed to load file: $e';
  }

  @override
  String fileLoadFailed_7285(Object e) {
    return 'Failed to load file: $e';
  }

  @override
  String get fileManagerStyle_4821 => 'File Manager Style';

  @override
  String get fileManager_1234 => 'File Manager';

  @override
  String get fileMappingList_4521 => 'File Mapping List';

  @override
  String get fileNameHint_4521 => 'Please enter the file name';

  @override
  String fileNameLabel(Object fileName) {
    return 'File name: $fileName';
  }

  @override
  String fileNameWithIndex(Object index) {
    return 'File $index.txt';
  }

  @override
  String get fileName_4821 => 'File name';

  @override
  String get fileName_5421 => 'File name';

  @override
  String get fileName_7891 => 'File name';

  @override
  String fileNotExist_4721(Object vfsPath) {
    return 'File does not exist - $vfsPath';
  }

  @override
  String fileNotFound_7421(Object fileName) {
    return 'File does not exist: $fileName';
  }

  @override
  String get fileOpenFailed_5421 => 'Failed to open file';

  @override
  String fileOpenFailed_7285(Object e) {
    return 'Failed to open file: $e';
  }

  @override
  String filePathLabel(Object path) {
    return 'Path: $path';
  }

  @override
  String get filePath_8423 => 'File path';

  @override
  String filePermissionFailed_7285(Object e) {
    return 'Failed to obtain file permission: $e';
  }

  @override
  String filePickerFailedWithError(Object e) {
    return 'File picker failed, attempting to download: $e';
  }

  @override
  String fileProcessingError_7281(Object error, Object fileName) {
    return 'Error processing file $fileName: $error';
  }

  @override
  String fileSaveFailed(Object e) {
    return 'Failed to save file: $e';
  }

  @override
  String get fileSavedSuccessfully_4821 => 'File saved successfully';

  @override
  String fileSelectionFailed(Object e) {
    return 'File selection failed: $e';
  }

  @override
  String get fileSelectionModeWarning_4821 =>
      'The current selection mode only allows selecting files';

  @override
  String fileSizeExceededWebLimit(Object fileSize) {
    return 'File too large (${fileSize}MB exceeds 4MB limit), cannot generate URL on Web platform';
  }

  @override
  String fileSizeInfo_7425(Object fileSize, Object modifiedTime) {
    return 'Size: $fileSize • Modified: $modifiedTime';
  }

  @override
  String fileSizeLabel(Object size) {
    return 'File size: $size';
  }

  @override
  String get fileSizeLabel_4821 => 'Size';

  @override
  String get fileSizeLabel_5421 => 'Size';

  @override
  String get fileSizeLabel_7421 => 'Size';

  @override
  String get fileSize_4821 => 'File size';

  @override
  String get fileSystemAccess => 'File System Access';

  @override
  String fileTypeRestriction_7421(Object extensions) {
    return 'Only specified file types ($extensions) • Folders are navigable';
  }

  @override
  String get fileTypeStatistics_4521 => 'File Type Statistics';

  @override
  String get fileTypeStatistics_4821 => 'File Type Statistics';

  @override
  String fileTypeWithExtension(Object extension) {
    return 'File type: .$extension';
  }

  @override
  String get fileType_4821 => 'File';

  @override
  String get fileType_4823 => 'File';

  @override
  String get fileType_5421 => 'File';

  @override
  String get fileUnavailable_4287 => 'File information unavailable';

  @override
  String fileUploadFailed_7284(Object e) {
    return 'File upload failed: $e';
  }

  @override
  String fileUploadFailed_7285(Object e) {
    return 'File upload failed: $e';
  }

  @override
  String fileUploadSuccess(Object successCount) {
    return 'Successfully uploaded $successCount files';
  }

  @override
  String get file_4821 => 'File';

  @override
  String get filesAndFolders_7281 => 'Files and Folders';

  @override
  String filesCompressedInfo(Object fileSize, Object totalFiles) {
    return '$totalFiles files have been compressed for download  \nCompressed package size: $fileSize';
  }

  @override
  String filesDownloaded_7421(Object downloadPath, Object fileCount) {
    return '$fileCount files downloaded to $downloadPath';
  }

  @override
  String get filesExistOverwrite_4927 =>
      'The following files already exist, do you want to overwrite them?';

  @override
  String get filipinoPH_4881 => 'Filipino (Philippines)';

  @override
  String get filipino_4880 => 'Filipino';

  @override
  String get fillModeLabel_4821 => 'Fill mode:';

  @override
  String get fillMode_4821 => 'Fill mode';

  @override
  String get filterLabel_4281 => 'Filter';

  @override
  String get filterPreview_4821 => 'Filter Preview';

  @override
  String get filterRemoved_4821 => 'Removed';

  @override
  String get filterScriptExample_3242 => 'Filter script example';

  @override
  String get filterType_4821 => 'Filter type';

  @override
  String get filter_9012 => 'Filter';

  @override
  String finalDisplayOrderLayersDebug(Object layers) {
    return 'Final displayOrderLayers sequence: $layers';
  }

  @override
  String finalLegendTitleList(Object titles) {
    return 'Final legend title list: $titles';
  }

  @override
  String findJsonFileWithPath(Object jsonPath) {
    return 'Find JSON file: $jsonPath (use original title)';
  }

  @override
  String get finnishFI_4849 => 'Finnish (Finland)';

  @override
  String get finnish_4848 => 'Finnish';

  @override
  String get fitHeight_4821 => 'Fit height';

  @override
  String get fitWidthOption_4821 => 'Fit width';

  @override
  String get fitWindowTooltip_4521 => 'Fit to window';

  @override
  String fixedLegendSizeUsage(Object legendSize) {
    return 'Use fixed legend size: $legendSize';
  }

  @override
  String fixedSizeText_7281(Object size) {
    return 'Fixed size: $size';
  }

  @override
  String get floatingWindowBuilderDescription_4821 =>
      'The FloatingWindowBuilder offers an elegant way to configure various properties of a floating window. You can use method chaining to set features like the window\'s title, icon, size, and drag support.';

  @override
  String get floatingWindowDemo_4271 => 'Floating Window Demo';

  @override
  String get floatingWindowExample_4271 => 'Floating Window Example';

  @override
  String get floatingWindowExample_4521 =>
      'This is a simple floating window example that mimics the design style of the VFS file picker.';

  @override
  String get floatingWindowTip_7281 =>
      'Click the button to experience different types of floating windows';

  @override
  String get floatingWindowWithActionsDesc_4821 =>
      'Floating window with custom action buttons in the header';

  @override
  String get floatingWindowWithIconAndTitle_4821 =>
      'Floating window with icon, main title, and subtitle';

  @override
  String get flutterCustomContextMenu_4821 =>
      '• Using Flutter\'s custom context menu';

  @override
  String folderAndFileTypesRestriction(Object extensions) {
    return 'Folders and specified file types ($extensions)';
  }

  @override
  String get folderCount_4821 => 'Number of folders';

  @override
  String get folderCreatedSuccessfully_4821 => 'Folder created successfully';

  @override
  String get folderCreatedSuccessfully_4834 => 'Folder created successfully';

  @override
  String get folderCreatedSuccessfully_7281 => 'Folder created successfully';

  @override
  String folderCreationFailed(Object e) {
    return 'Failed to create folder: $e';
  }

  @override
  String get folderCreationFailed_4821 => 'Failed to create folder';

  @override
  String folderCreationFailed_7285(Object e) {
    return 'Failed to create folder: $e';
  }

  @override
  String folderCreationFailed_7421(Object e, Object folderPath) {
    return 'Failed to create folder [$folderPath]: $e';
  }

  @override
  String get folderDeletedSuccessfully_4821 => 'Folder deleted successfully';

  @override
  String get folderDeletedSuccessfully_4839 => 'Folder deleted successfully';

  @override
  String folderDeletionFailed(Object e, Object folderPath) {
    return 'Failed to delete folder [$folderPath]: $e';
  }

  @override
  String get folderEmpty_4821 => 'This folder is empty';

  @override
  String get folderLabel_5421 => 'Folder';

  @override
  String folderLegendError_7421(Object e, Object folderPath) {
    return 'Failed to get legend in folder: $folderPath, error: $e';
  }

  @override
  String folderNameConversion(Object desanitized, Object name) {
    return 'Folder name conversion: \"$name\" -> \"$desanitized';
  }

  @override
  String get folderNameExists_4821 => 'Folder name already exists';

  @override
  String get folderNameHint_4821 => 'Folder name';

  @override
  String get folderNameHint_5732 => 'Folder name';

  @override
  String get folderNameLabel_4821 => 'Folder name';

  @override
  String get folderNameRules_4821 =>
      'Can only contain letters, numbers, slashes (/), underscores (_), hyphens (-). Chinese characters are not allowed. Maximum length is 100 characters.';

  @override
  String get folderName_4821 => 'Folder name';

  @override
  String get folderName_4830 => 'Folder Name';

  @override
  String folderNotEmptyCannotDelete(Object folderPath) {
    return 'The folder is not empty and cannot be deleted: $folderPath';
  }

  @override
  String get folderNotExist_4821 => 'The selected folder does not exist';

  @override
  String get folderOnly_7281 => 'Folders only';

  @override
  String get folderPathLabel_4821 => 'Folder path';

  @override
  String get folderRenameSuccess_4821 => 'Folder renamed successfully';

  @override
  String folderRenameSuccess_4827(Object newPath, Object oldPath) {
    return 'Folder renamed successfully: $oldPath -> $newPath';
  }

  @override
  String get folderRenamedSuccessfully_4844 => 'Folder renamed successfully';

  @override
  String get folderSelectionRequired_4821 =>
      'The current selection mode only allows folder selection';

  @override
  String get folderType_4821 => 'Folder';

  @override
  String get folderType_4822 => 'Folder';

  @override
  String get folderType_5421 => 'Folder';

  @override
  String get folder_7281 => 'Folder';

  @override
  String foldersDownloadedToPath_7281(Object downloadPath, Object folderCount) {
    return '$folderCount folders downloaded to $downloadPath';
  }

  @override
  String foldersDownloaded_7281(Object downloadPath, Object folderCount) {
    return '$folderCount folders downloaded to $downloadPath';
  }

  @override
  String get folders_4822 => 'Folders';

  @override
  String fontSizeLabel(Object value) {
    return 'Font size: ${value}px';
  }

  @override
  String get fontSizeLabel_4821 => 'Font size';

  @override
  String get fontSize_4821 => 'Font size';

  @override
  String get forceExecutePendingTasks_7281 =>
      'Force execution of all pending throttled tasks...';

  @override
  String forceExecuteThrottleTasks(Object activeCount) {
    return 'Force execution of $activeCount pending throttle tasks';
  }

  @override
  String get forceExitWarning_4821 =>
      'Forced exit may result in data loss or abnormal program state. It is recommended to wait for the current task to complete before exiting.';

  @override
  String forcePreviewSubmission_7421(Object id) {
    return 'Force submit preview: $id';
  }

  @override
  String forceSaveFailed_4829(Object e) {
    return 'Failed to force save pending changes: $e';
  }

  @override
  String get forceTerminateAllWorkStatus_4821 =>
      'Force terminate all work status';

  @override
  String forceUpdateMessage_7285(Object forceUpdate) {
    return 'Force update: $forceUpdate';
  }

  @override
  String get foregroundLayer_1234 => 'Foreground Layer';

  @override
  String get formatJsonTooltip_7281 => 'Format JSON';

  @override
  String formulaWithCount_7421(Object totalCount) {
    return 'Formula: $totalCount';
  }

  @override
  String get forward_4821 => 'Forward';

  @override
  String get foundBlueRectangles_5262 => 'Found';

  @override
  String foundFilesCount_7421(Object count, Object fileList) {
    return 'Found $count files: $fileList';
  }

  @override
  String foundLegendFilesInDirectory(Object count, Object directoryPath) {
    return 'Found $count legend files in directory $directoryPath';
  }

  @override
  String foundLegendFolders(Object folders) {
    return 'Found .legend folders: $folders';
  }

  @override
  String foundStoredVersions_7281(Object count, Object ids) {
    return 'Found $count stored versions: $ids';
  }

  @override
  String foundSvgFilesCount_5421(Object count) {
    return 'Found $count SVG files';
  }

  @override
  String get fourPerPage_4823 => 'Four per page';

  @override
  String get freeDrawingLabel_4821 => 'Free Drawing';

  @override
  String get freeDrawingTooltip_7532 => 'Free Drawing';

  @override
  String get freeDrawing_4830 => 'Free Drawing';

  @override
  String get frenchCA_4883 => 'French (Canada)';

  @override
  String get frenchFR_4882 => 'French (France)';

  @override
  String get french_4829 => 'French';

  @override
  String get fullScreenModeInDevelopment_7281 =>
      'Full screen mode in development...';

  @override
  String fullScreenStatusError(Object error) {
    return 'Failed to get full-screen status: $error';
  }

  @override
  String get fullScreenTestPage_7421 => 'Full Screen Test Page';

  @override
  String get fullscreenMode_7281 => 'Fullscreen Mode';

  @override
  String get fullscreenTest_4821 => 'Full Screen Test';

  @override
  String fullscreenToggleFailed(Object e) {
    return 'Failed to toggle fullscreen mode: $e';
  }

  @override
  String futureBuilderData(Object data) {
    return 'FutureBuilder data: $data';
  }

  @override
  String futureBuilderError(Object error) {
    return 'FutureBuilder error: $error';
  }

  @override
  String futureBuilderStatus(Object connectionState) {
    return 'FutureBuilder status: $connectionState';
  }

  @override
  String generateAuthToken(Object clientId) {
    return 'Generate authentication token: $clientId';
  }

  @override
  String get generateDataUri_7425 => 'Generate Data URI';

  @override
  String generateFileUrl(Object vfsPath) {
    return 'Generate file URL - $vfsPath';
  }

  @override
  String generateFileUrlFailed_4821(Object e) {
    return 'Failed to generate file URL - $e';
  }

  @override
  String get generatePreview_7421 => 'Generate Preview';

  @override
  String generateTagMessage(Object videoTag) {
    return 'Generate tag $videoTag';
  }

  @override
  String generatedPlayUrl(Object playableUrl) {
    return 'Generated playback URL - $playableUrl';
  }

  @override
  String get generatingMetadata_5005 => 'Generating metadata...';

  @override
  String get generatingPdf_7421 => 'Generating PDF...';

  @override
  String get generatingPreviewImage_7281 => 'Generating preview image...';

  @override
  String get generatingPreview_7421 => 'Generating preview...';

  @override
  String get generatingRsaKeyPair_7284 => 'Generating 2048-bit RSA key pair...';

  @override
  String get germanDE_4884 => 'German (Germany)';

  @override
  String get german_4830 => 'German';

  @override
  String getSubfolderFailed_7281(Object e, Object parentPath) {
    return 'Failed to get subfolder: $parentPath, error: $e';
  }

  @override
  String getUserPreferenceFailed_4821(Object e) {
    return 'Failed to get user preference display name: $e';
  }

  @override
  String get githubDescription_4910 =>
      'View source code, report issues and contribute code';

  @override
  String get githubRepository_4909 => 'GitHub Repository';

  @override
  String get globalCollaborationNotInitialized_4821 =>
      'GlobalCollaborationService is not initialized';

  @override
  String get globalCollaborationNotInitialized_7281 =>
      'GlobalCollaborationService is not initialized';

  @override
  String globalCollaborationServiceConnectionFailed(Object e) {
    return 'GlobalCollaborationService connection failed: $e';
  }

  @override
  String globalCollaborationServiceInitFailed(Object e) {
    return 'Global collaboration service initialization failed: $e';
  }

  @override
  String get globalCollaborationServiceInitialized_4821 =>
      'GlobalCollaborationService initialization completed';

  @override
  String get globalCollaborationServiceInitialized_7281 =>
      'Global collaboration service initialized successfully';

  @override
  String get globalCollaborationServiceReleaseResources_7421 =>
      'GlobalCollaborationService is releasing resources';

  @override
  String globalCollaborationUserInfoSet(Object displayName, Object userId) {
    return 'GlobalCollaborationService user info has been set: userId=$userId, displayName=$displayName';
  }

  @override
  String globalIndexDebug_7281(Object newGlobalIndex, Object oldGlobalIndex) {
    return 'Global index: oldGlobalIndex=$oldGlobalIndex, newGlobalIndex=$newGlobalIndex';
  }

  @override
  String globalServiceNotInitialized_7285(Object e) {
    return 'Global collaboration service not initialized, using local instance: $e';
  }

  @override
  String get goHome => 'Go to Home';

  @override
  String googleFontLoadFailed(Object e) {
    return 'Failed to load Google Chinese font, using default font: $e';
  }

  @override
  String get gplLicense_4906 => 'GPL v3 License';

  @override
  String get grayscale_4822 => 'Grayscale';

  @override
  String get grayscale_5678 => 'Grayscale';

  @override
  String get gridPattern_4821 => 'Grid';

  @override
  String get gridSize => 'Grid size';

  @override
  String gridSpacingInfo(Object actualSpacing, Object baseSpacing) {
    return '- Base grid spacing: ${baseSpacing}px → Actual spacing: ${actualSpacing}px';
  }

  @override
  String get gridView_4969 => 'Grid View';

  @override
  String groupGlobalIndexDebug(Object newGlobalIndex, Object oldGlobalIndex) {
    return 'Group global index: oldGlobalIndex=$oldGlobalIndex, newGlobalIndex=$newGlobalIndex';
  }

  @override
  String groupGlobalStartPosition(Object groupStartIndex) {
    return 'Group\'s global starting position: $groupStartIndex';
  }

  @override
  String groupIndexDebug(Object newIndex, Object oldIndex) {
    return 'Group oldIndex: $oldIndex, newIndex: $newIndex';
  }

  @override
  String get groupIndexOutOfRange_7281 => 'Group index out of range';

  @override
  String groupLayerReorderLog(Object length, Object newIndex, Object oldIndex) {
    return 'Reordered layers within group: $oldIndex -> $newIndex, updated layer count: $length';
  }

  @override
  String groupLayersDebug_4821(Object layers) {
    return 'Layers in group: $layers';
  }

  @override
  String groupLayersDebug_7421(Object layers) {
    return '- Layers in group: $layers';
  }

  @override
  String get groupPermissions_4821 => 'Group Permissions';

  @override
  String get groupPermissions_7421 => 'Group permissions';

  @override
  String groupReorderTriggered(Object newIndex, Object oldIndex) {
    return 'Group reorder triggered: oldIndex=$oldIndex, newIndex=$newIndex';
  }

  @override
  String get groupReorderingComplete_7281 =>
      '=== Group Reordering Complete ===';

  @override
  String get groupReorderingLog_7281 =>
      '=== Performing in-group reordering (processing both link states and order) ===';

  @override
  String get groupReordering_7281 => '=== Group Reordering ===';

  @override
  String groupSize(Object length) {
    return 'Group size: $length';
  }

  @override
  String get groupSuffix_7281 => '(Group)';

  @override
  String handleOnlineStatusError_4821(Object error) {
    return 'Error occurred while processing online status list response: $error';
  }

  @override
  String get handleSize_4821 => 'Handle size';

  @override
  String get hasAvatar_4821 => 'Has avatar';

  @override
  String hasLayersMessage_5832(Object layersCount) {
    return '(Layers: $layersCount)';
  }

  @override
  String get hasSessionData => 'Session data exists';

  @override
  String get hasUnsavedChanges => 'There are unsaved changes';

  @override
  String get hebrewIL_4875 => 'Hebrew (Israel)';

  @override
  String get hebrew_4874 => 'Hebrew';

  @override
  String get helpInfo_4821 => 'Help information';

  @override
  String get help_5732 => 'Help';

  @override
  String get help_7282 => 'Help';

  @override
  String get hiddenMenu_7281 => 'Hidden menu';

  @override
  String get hideAllLayersInGroup_7282 =>
      'All layers in the group have been hidden';

  @override
  String get hideOtherLayerGroups_3861 => 'Hide other layer groups';

  @override
  String get hideOtherLayerGroups_4827 => 'Hide other layer groups';

  @override
  String hideOtherLayersMessage(Object name) {
    return 'Other layers have been hidden, only \"$name\" is displayed';
  }

  @override
  String get hideOtherLayers_3860 => 'Hide Other Layers';

  @override
  String get hideOtherLayers_4271 => 'Hide Other Layers';

  @override
  String get hideOtherLayers_4826 => 'Hide Other Layers';

  @override
  String get hideOtherLegendGroups_3864 => 'Hide other legend groups';

  @override
  String get hideOtherLegendGroups_4825 => 'Hide other legend groups';

  @override
  String get hidePointer_4271 => 'Hide Pointer';

  @override
  String get hideToc_4821 => 'Hide Table of Contents';

  @override
  String get hide_4821 => 'Hide';

  @override
  String get highContrastMode_4271 => 'High contrast';

  @override
  String get highPriorityTag_6789 => 'High Priority';

  @override
  String get high_7281 => 'High';

  @override
  String get hindiIN_4893 => 'Hindi (India)';

  @override
  String get hindi_4839 => 'Hindi';

  @override
  String get hintLabelName_7532 => 'Enter label name';

  @override
  String get historyRecord_4271 => 'History';

  @override
  String get hollowRectangle => 'Hollow Rectangle';

  @override
  String get hollowRectangleTool_5679 => 'Hollow Rectangle';

  @override
  String get hollowRectangle_4825 => 'Hollow Rectangle';

  @override
  String get hollowRectangle_7421 => 'Hollow Rectangle';

  @override
  String get hollowRectangle_8635 => 'Hollow Rectangle';

  @override
  String get home => 'Home';

  @override
  String get homePageSettings_4821 => 'Home Page Settings';

  @override
  String get homePageTitle_4821 => 'Home';

  @override
  String get homePage_7281 => 'Home';

  @override
  String get hoursAgo_4827 => 'hours ago';

  @override
  String hoursAgo_7281(Object hours) {
    return '$hours hours ago';
  }

  @override
  String get hoursLabel_4821 => 'hours';

  @override
  String get hoverHelpText_4821 => 'Show help information on hover';

  @override
  String hoverItem_7421(Object label) {
    return 'Hover item: $label';
  }

  @override
  String get htmlContentInfo_7281 => 'HTML content information';

  @override
  String get htmlContentStatistics_7281 => 'HTML Content Statistics';

  @override
  String htmlImageCount(Object count) {
    return 'HTML images: $count';
  }

  @override
  String get htmlInfo_7421 => 'HTML Info';

  @override
  String htmlLinkCount(Object count) {
    return 'HTML links: $count';
  }

  @override
  String htmlParseComplete(Object count) {
    return '🔧 HtmlProcessor.parseHtml: Parsing complete, node count: $count';
  }

  @override
  String get htmlParseFailed_7281 => 'Parsing failed';

  @override
  String htmlParsingFailed_7285(Object e) {
    return 'HTML parsing failed: $e';
  }

  @override
  String htmlParsingStart(Object content) {
    return '🔧 HtmlProcessor.parseHtml: Parsing started - textContent: $content...';
  }

  @override
  String htmlProcessingComplete(Object count) {
    return '🔧 HtmlProcessor.parseHtml: Conversion complete, SpanNode count: $count';
  }

  @override
  String get htmlProcessorNoHtmlTags_4821 =>
      '🔧 HtmlProcessor.parseHtml: No HTML tags found, returning text node';

  @override
  String get htmlRenderingStatus_4821 => 'HTML rendering status';

  @override
  String htmlStatusLabel_4821(Object status) {
    return 'HTML$status';
  }

  @override
  String get htmlTagDetected_7281 =>
      '🔧 HtmlProcessor.parseHtml: HTML tags detected, starting parsing';

  @override
  String htmlTagProcessing(Object attributes, Object localName) {
    return '🔧 HtmlToSpanVisitor.visitElement: Processing tag - $localName, attributes: $attributes';
  }

  @override
  String htmlToMarkdownFailed_4821(Object e) {
    return 'HTML to Markdown conversion failed: $e';
  }

  @override
  String hueValue(Object value) {
    return 'Hue: $value°';
  }

  @override
  String get hue_0123 => 'Hue';

  @override
  String get hue_4828 => 'Hue';

  @override
  String get hungarianHU_4855 => 'Hungarian (Hungary)';

  @override
  String get hungarian_4854 => 'Hungarian';

  @override
  String get iOSFeatures => 'iOS Features:';

  @override
  String get iOSPlatform => 'iOS platform';

  @override
  String get iOSSpecificFeatures =>
      'iOS-specific features can be implemented here.';

  @override
  String iconEnlargementFactorLabel(Object factor) {
    return 'Icon enlargement factor: ${factor}x';
  }

  @override
  String iconSizeDebug(Object actualSize, Object baseSize) {
    return '- Base icon size: ${baseSize}px → Actual size: ${actualSize}px';
  }

  @override
  String get idChanged_4821 => 'ID changed';

  @override
  String idMappingInitFailed_7425(Object e) {
    return 'Failed to initialize ID mapping: $e';
  }

  @override
  String get ideaTag_8901 => 'Idea';

  @override
  String get idea_2345 => 'Idea';

  @override
  String get idleStatus_6194 => 'Online';

  @override
  String get idleStatus_6934 => 'Online';

  @override
  String get idleStatus_6943 => 'Online';

  @override
  String get idleStatus_7421 => 'Idle status';

  @override
  String get ignore_4821 => 'Ignore';

  @override
  String ignoredMessageType_7281(Object messageType) {
    return 'ignoredMessageType: $messageType';
  }

  @override
  String get imageAreaLabel_4281 => 'Image area';

  @override
  String imageAssetExistsOnMap_7421(Object filename, Object mapTitle) {
    return 'The image asset already exists on the map [$mapTitle], skipping save: $filename';
  }

  @override
  String get imageBuffer_4821 => 'Image Buffer';

  @override
  String get imageBuffer_7281 => 'Image Buffer';

  @override
  String imageCompressionFailed_7284(Object e) {
    return 'Image compression failed: $e';
  }

  @override
  String imageCopiedToBuffer_7421(String mimeType, Object sizeInKB) {
    String _temp0 = intl.Intl.selectLogic(mimeType, {
      'null': '',
      'other': ' · Type: $mimeType',
    });
    return 'The image has been read from the clipboard to the buffer  \nSize: ${sizeInKB}KB$_temp0';
  }

  @override
  String get imageCopiedToClipboardLinux_4821 =>
      'Linux: Image successfully copied to clipboard';

  @override
  String get imageCopiedToClipboard_4821 =>
      'macOS: Image successfully copied to clipboard';

  @override
  String imageCount(Object count) {
    return '$count images';
  }

  @override
  String imageCountText_7281(Object imageCount) {
    return 'Images: $imageCount';
  }

  @override
  String imageDataLoadedFromAssets(Object bytes, Object imageHash) {
    return 'Image data loaded from assets, hash: $imageHash ($bytes bytes)';
  }

  @override
  String imageDecodeFailed_4821(Object error) {
    return 'Failed to decode image: $error';
  }

  @override
  String get imageDescriptionHint_4522 =>
      'Please enter the image description (optional)';

  @override
  String imageDimensions(Object height, Object width) {
    return 'Dimensions: $width × $height';
  }

  @override
  String get imageEditAreaRightClickOptions_4821 =>
      'Image editing area - Right-click for options';

  @override
  String get imageEditMenuTitle_7421 => 'Example 2: Image Editing Menu';

  @override
  String imageFetchFailed(Object e) {
    return 'Failed to fetch image: $e';
  }

  @override
  String get imageFitMethod_4821 => 'Image fit method';

  @override
  String get imageFitMethod_7281 => 'Image fit method';

  @override
  String get imageGenerationFailed_4821 => 'Image generation failed';

  @override
  String imageListTitle(Object count) {
    return 'Image List ($count items)';
  }

  @override
  String imageLoadFailed(Object error) {
    return 'Image failed to load: $error';
  }

  @override
  String get imageLoadFailed_4721 => 'Image failed to load';

  @override
  String get imageLoadFailed_7281 => 'Image loading failed';

  @override
  String get imageLoadFailed_7421 => 'Image failed to load';

  @override
  String imageLoadWarning(Object imageHash) {
    return 'Warning: Failed to load image from asset system, hash: $imageHash';
  }

  @override
  String get imageNotAvailable_7281 => 'Image not available';

  @override
  String get imageNoteLabel_4821 => 'Image Note';

  @override
  String get imageProcessingInstructions_4821 =>
      '1. Click \"Upload Image\" to select a file or \"Clipboard\" to paste an image  \n2. Drag on the canvas to create a selection area  \n3. The image will automatically adapt to the selection size  \n4. Adjust via the Z-level inspector';

  @override
  String get imageRemoved_4821 => 'Image removed';

  @override
  String get imageRotated_4821 => 'Image rotated';

  @override
  String imageSavedToMapAssets(Object hash, Object length) {
    return 'The image has been saved to the map assets system, hash: $hash ($length bytes)';
  }

  @override
  String get imageSelectionArea_4832 => 'Image Selection Area';

  @override
  String get imageSelectionCancelled_4521 => 'Image selection cancelled';

  @override
  String get imageSelectionComplete_4821 => '✅ Image selection complete!';

  @override
  String get imageSelectionDemo_4271 => 'Image Selection Demo';

  @override
  String imageSelectionError_4829(Object e) {
    return 'An error occurred while selecting an image: $e';
  }

  @override
  String get imageSelectionTool_7912 => 'Image Selection Area';

  @override
  String get imageSelection_4832 => 'Image Selection';

  @override
  String get imageSelection_5302 => 'Image Selection';

  @override
  String imageSizeAndOffset_7281(Object dx, Object dy, Object imageSize) {
    return 'Image size: $imageSize, center offset: ($dx, $dy)';
  }

  @override
  String get imageSpacing_3632 => 'Image spacing';

  @override
  String get imageTitleHint_4522 => 'Please enter an image title (optional)';

  @override
  String imageTitleWithIndex(Object index) {
    return 'Image $index';
  }

  @override
  String get imageTooLargeError_4821 =>
      'The image file is too large, please select an image smaller than 10MB';

  @override
  String imageUploadFailed(Object e) {
    return 'Failed to upload image: $e';
  }

  @override
  String imageUploadFailed_7285(Object e) {
    return 'Image upload failed: $e';
  }

  @override
  String get imageUploadInstructions_4821 =>
      '1. Click \"Upload Image\" to select a file or \"Clipboard\" to paste an image  \n2. Drag on the canvas to create a selection  \n3. The image will automatically adapt to the selection size  \n4. Adjust via the Z-level inspector';

  @override
  String get imageUploadSuccess_4821 => 'Image uploaded successfully';

  @override
  String imageUploadedToBuffer(String mimeType, Object sizeInKB) {
    String _temp0 = intl.Intl.selectLogic(mimeType, {
      'null': '',
      'other': ' · Type: $mimeType',
    });
    return 'Image uploaded to buffer  \nSize: ${sizeInKB}KB$_temp0';
  }

  @override
  String get imageUrlLabel_4821 => 'Image URL';

  @override
  String get image_4821 => 'Image';

  @override
  String importConfigFailed_7421(Object error) {
    return 'Failed to import configuration: $error';
  }

  @override
  String get importConfigFromJson_4821 => 'Import configuration from JSON data';

  @override
  String get importConfig_4271 => 'Import Configuration';

  @override
  String get importConfig_7421 => 'Import Configuration';

  @override
  String get importDatabase => 'Import database';

  @override
  String get importExportBrowseData_4821 =>
      'Import, export, and browse app data';

  @override
  String importFailed(Object error) {
    return 'Import failed: $error';
  }

  @override
  String get importFailed_7281 => 'Import failed';

  @override
  String importLegendDatabaseFailed(Object e) {
    return 'Failed to import legend database: $e';
  }

  @override
  String importLegendDbFailed(Object e) {
    return 'Failed to import legend database: $e';
  }

  @override
  String get importLegendFailed_7281 => 'Failed to import legend';

  @override
  String importLocalizationFailed_7285(Object e) {
    return 'Failed to import localization file: $e';
  }

  @override
  String importPreviewWithCount(Object totalFiles) {
    return 'Import Preview ($totalFiles items in total)';
  }

  @override
  String get importSettings => 'Import Settings';

  @override
  String importSettingsFailed_7421(Object e) {
    return 'Failed to import settings: $e';
  }

  @override
  String get import_4521 => 'Import';

  @override
  String get importantTag_1234 => 'Important';

  @override
  String get important_1234 => 'Important';

  @override
  String get important_4829 => 'Important';

  @override
  String get important_4832 => 'Important';

  @override
  String get importedFromJson_4822 => '(Imported from JSON)';

  @override
  String importedMapLegendSettings(Object length, Object mapId) {
    return 'Imported map legend auto-hide settings for $mapId: $length items';
  }

  @override
  String get importedSuffix_4821 => '(Imported)';

  @override
  String get inProgress_7421 => 'In Progress';

  @override
  String get includeLegends_3567 => 'Include legends';

  @override
  String get includeLocalizations_4678 => 'Include localizations';

  @override
  String get includeMaps_2456 => 'Include maps';

  @override
  String get incompleteVersionData_7281 => 'Incomplete version data';

  @override
  String get increaseTextContrast_4821 =>
      'Increase text and background contrast';

  @override
  String get indexOutOfRange_7281 => 'oldIndex is out of range, skipping';

  @override
  String get indonesianID_4877 => 'Indonesian (Indonesia)';

  @override
  String get indonesian_4876 => 'Indonesian';

  @override
  String get infoMessage_7284 => 'Info message';

  @override
  String get info_7554 => 'Information';

  @override
  String get information_7281 => 'Information';

  @override
  String get initMapEditorSystem_7281 =>
      'Initializing map editor reactive system';

  @override
  String initReactiveScriptManager(Object mapTitle) {
    return 'Initializing new reactive script manager, map title: $mapTitle';
  }

  @override
  String initUserPrefsFailed(Object error) {
    return 'Failed to initialize user preferences: $error';
  }

  @override
  String initVersionSession(Object arg0, Object arg1, Object arg2) {
    return 'Initializing version session [$arg0/$arg1]: $arg2';
  }

  @override
  String initialDataSetupSuccess(Object versionId) {
    return 'Initial data setup for new version [$versionId] completed successfully';
  }

  @override
  String initialDataSyncComplete(
    Object layerCount,
    Object noteCount,
    Object versionId,
  ) {
    return 'Initial data sync completed [$versionId], Layers: $layerCount, Notes: $noteCount';
  }

  @override
  String get initializationComplete_7421 => 'Initialization complete';

  @override
  String initializationFailed(Object error) {
    return 'Initialization failed: $error';
  }

  @override
  String initializationFailed_7285(Object e) {
    return 'Initialization failed: $e';
  }

  @override
  String get initializeWebSocketClientManager_4821 =>
      'Initializing WebSocket client manager';

  @override
  String get initializingAppDatabase_7281 =>
      'Starting to initialize the application database...';

  @override
  String initializingClientWithKey(Object webApiKey) {
    return 'Initializing client with Web API Key: $webApiKey';
  }

  @override
  String get initializingGlobalCollaborationService_7281 =>
      'Initializing GlobalCollaborationService';

  @override
  String initializingReactiveVersionManagement(Object title) {
    return 'Starting to initialize reactive version management, map title: $title';
  }

  @override
  String initializingScriptEngine(Object maxConcurrentExecutors) {
    return 'Initializing new reactive script engine (supports $maxConcurrentExecutors concurrent scripts)';
  }

  @override
  String get initializingVfsSystem_7281 =>
      'Starting to initialize the app VFS system...';

  @override
  String inlineCountUnit_4821(Object count) {
    return '$count';
  }

  @override
  String get inlineFormula_7284 => 'Inline formula';

  @override
  String get inputAvatarUrl_7281 => 'Enter avatar URL';

  @override
  String get inputColorValue_4821 => 'Enter color value';

  @override
  String get inputConfigName_4821 => 'Please enter the configuration name';

  @override
  String get inputDisplayName_4821 => 'Please enter a display name';

  @override
  String get inputFolderPath_4821 => 'Please enter the storage folder path';

  @override
  String get inputIntegerHint_4521 => 'Please enter an integer';

  @override
  String get inputJsonData_4821 => 'Please enter JSON data';

  @override
  String get inputLabelHint_4521 => 'Enter label name';

  @override
  String get inputLinkOrSelectFile_4821 =>
      'Enter a web link, select a VFS file, or bind a script';

  @override
  String get inputMessageContent_7281 => 'Please enter the message content';

  @override
  String get inputMessageHint_4521 => 'Enter the message content to display';

  @override
  String get inputNewNameHint_4821 => 'Enter new name';

  @override
  String get inputNumberHint_4522 => 'Enter a number';

  @override
  String get inputNumberHint_5732 => 'Enter a number';

  @override
  String inputPrompt(Object name) {
    return 'Please enter $name';
  }

  @override
  String get inputUrlOrSelectVfsFile_4823 =>
      'Enter a web link or select a VFS file';

  @override
  String insertToPlayQueue_7425(Object index) {
    return 'Insert into play queue [$index]';
  }

  @override
  String get instructions_4521 => 'Instructions';

  @override
  String insufficientPathSegments(Object absolutePath) {
    return 'Insufficient path segments: $absolutePath';
  }

  @override
  String get integerType_5678 => 'Integer';

  @override
  String integrationAdapterAddLegendGroup(Object name) {
    return 'Integration Adapter: Add Legend Group $name';
  }

  @override
  String integrationAdapterDeleteLegendGroup(Object legendGroupId) {
    return 'Integration Adapter: Delete Legend Group $legendGroupId';
  }

  @override
  String intensityPercentage(Object percentage) {
    return 'Intensity: $percentage%';
  }

  @override
  String get interfaceSwitchAnimation_7281 =>
      'Interface switching and transition animations';

  @override
  String invalidAbsolutePathFormat(Object absolutePath) {
    return 'Invalid absolute path format: $absolutePath';
  }

  @override
  String get invalidCharactersError_4821 =>
      'The name contains invalid characters: < > : \" / \\ | ? *';

  @override
  String get invalidCharacters_4821 =>
      'The name contains invalid characters: < > : \" / \\ | ? *';

  @override
  String get invalidClipboardImageData_4271 =>
      'The data in the clipboard is not a valid image file';

  @override
  String get invalidClipboardImageData_4821 =>
      'The data in the clipboard is not a valid image file';

  @override
  String get invalidColorFormat_4821 =>
      'Invalid color format, please check your input';

  @override
  String invalidConfigCleanup(Object clientId) {
    return 'Invalid configuration detected, preparing to clean up: $clientId';
  }

  @override
  String get invalidExportFileFormat_4821 =>
      'The export file format is invalid, required fields are missing';

  @override
  String get invalidImage => 'Invalid image';

  @override
  String get invalidImageData_7281 => 'Invalid image data';

  @override
  String get invalidImageFileError_4821 =>
      'Invalid image file, please select a valid one';

  @override
  String get invalidImageUrlError_4821 =>
      'Please enter an image URL (supports formats like jpg, png, gif, etc.)';

  @override
  String get invalidImportDataFormat_4271 => 'Invalid import data format';

  @override
  String get invalidImportDataFormat_7281 => 'Invalid import data format';

  @override
  String get invalidIntegerError_4821 => 'Please enter a valid integer';

  @override
  String invalidLegendCenterPoint(Object title) {
    return 'The center point coordinates of the legend \"$title\" are invalid';
  }

  @override
  String get invalidLegendDataFormat_7281 =>
      'The legend data format is invalid';

  @override
  String invalidLegendVersion_7421(Object title) {
    return 'The legend \"$title\" has an invalid version number';
  }

  @override
  String get invalidMapDataFormat_7281 => 'The map data format is invalid';

  @override
  String get invalidNameDotError_4821 =>
      'The name cannot start or end with a dot.';

  @override
  String get invalidNumberInput_4821 => 'Please enter a valid number';

  @override
  String get invalidPathCharactersError_4821 =>
      'The storage path can only contain letters, numbers, slashes (/), underscores (_), or hyphens (-)';

  @override
  String get invalidPathFormat_4821 => 'Invalid path format';

  @override
  String get invalidPath_4957 => 'Invalid path';

  @override
  String invalidPathsFound_4918(Object count) {
    return 'Invalid paths found, please correct them before proceeding. Invalid path count: $count';
  }

  @override
  String get invalidRemoteDataFormat_7281 => 'Invalid remote data format';

  @override
  String get invalidServerPath_4821 => 'Invalid server path';

  @override
  String get invalidTagCharacters_4821 => 'The tag contains invalid characters';

  @override
  String invalidTargetPath_4920(Object path) {
    return 'Invalid target path: $path';
  }

  @override
  String get invalidUrlPrompt_7281 => 'Please enter a valid URL';

  @override
  String invalidVersionIdWarning(Object activeEditingVersionId) {
    return 'Warning: The version ID being edited is invalid: $activeEditingVersionId';
  }

  @override
  String get invalid_5739 => 'Invalid';

  @override
  String get invalid_9352 => 'Invalid';

  @override
  String get invert_3456 => 'Invert colors';

  @override
  String get invert_4824 => 'Invert colors';

  @override
  String get isInPlaylistCheck_7425 => 'Is it in the playlist';

  @override
  String isSelectedCheck(Object isLegendSelected) {
    return 'Is selected: $isLegendSelected';
  }

  @override
  String get isSelectedNote_7425 => 'Is selected';

  @override
  String get italianIT_4887 => 'Italian (Italy)';

  @override
  String get italian_4832 => 'Italian';

  @override
  String itemsCutCount(Object count) {
    return '$count items cut';
  }

  @override
  String itemsCutMessage(Object count) {
    return '$count items cut';
  }

  @override
  String get iterateAllElements_1121 => 'Iterate through all elements';

  @override
  String get japaneseJP_4899 => 'Japanese (Japan)';

  @override
  String get japanese_4827 => 'Japanese';

  @override
  String jpegImageReadSuccess(Object length) {
    return 'super_clipboard: Successfully read JPEG image from clipboard, size: $length bytes';
  }

  @override
  String get jsonDataHint_4522 => 'Paste configuration JSON data...';

  @override
  String get jsonDataLabel_4521 => 'JSON Data';

  @override
  String get jsonData_4821 => 'JSON data';

  @override
  String jsonFileNotExist_4821(Object jsonPath) {
    return 'JSON file does not exist: $jsonPath';
  }

  @override
  String jsonFileSearch_7281(
    Object jsonPath,
    Object sanitizedTitle,
    Object title,
  ) {
    return 'Search for JSON file: $jsonPath (Original title: \"$title\" -> Sanitized: \"$sanitizedTitle\")';
  }

  @override
  String get jsonFormatComplete_4821 => 'JSON formatting complete';

  @override
  String jsonFormatFailed(Object e) {
    return 'JSON formatting failed: $e';
  }

  @override
  String jsonParseError_7282(Object error) {
    return 'Error parsing options JSON: $error';
  }

  @override
  String jumpFailed_4821(Object e) {
    return 'Jump failed: $e';
  }

  @override
  String jumpToDestination(Object headingText) {
    return 'Jumped to: $headingText';
  }

  @override
  String get justNow_4821 => 'Just now';

  @override
  String get keepOpenWhenLoseFocus_7281 => 'Keep open';

  @override
  String get keepTwoFilesRenameNew_4821 =>
      'Keep both files, rename the new one';

  @override
  String keyGenerationFailed_7285(Object e) {
    return 'Failed to generate server-compatible key pair: $e';
  }

  @override
  String get keyboardShortcutsInitialized_7421 =>
      'Keyboard shortcut operation instance initialization completed';

  @override
  String get koreanKR_4900 => 'Korean (South Korea)';

  @override
  String get korean_4828 => 'Korean';

  @override
  String get labelName_4821 => 'Label name';

  @override
  String get label_4821 => 'Label';

  @override
  String get label_5421 => 'Label';

  @override
  String get landscapeOrientation_5678 => 'Landscape';

  @override
  String get language => 'Language';

  @override
  String languageCheckFailed_4821(Object e) {
    return 'Failed to check language availability: $e';
  }

  @override
  String languageCheckFailed_7285(Object e) {
    return 'Failed to check language availability: $e';
  }

  @override
  String languageLog_7284(Object language) {
    return ', language: $language';
  }

  @override
  String get languageSetting_4821 => 'Language';

  @override
  String languageUpdated(Object name) {
    return 'Language has been updated to $name';
  }

  @override
  String get language_4821 => 'Language';

  @override
  String get largeBrush_4821 => 'Large brush';

  @override
  String largeFileWarning(Object fileSize) {
    return '🔗 VfsServiceProvider: Warning - Large file (${fileSize}MB) may affect performance';
  }

  @override
  String lastLoginTime(Object time) {
    return 'Last login: $time';
  }

  @override
  String latencyWithValue(Object value) {
    return 'Latency: ${value}ms';
  }

  @override
  String get latexDisabled_7421 => '(Disabled)';

  @override
  String latexErrorWarning(Object textContent) {
    return '⚠️ LaTeX Error: $textContent';
  }

  @override
  String get latexFormulaInfo_7281 => 'LaTeX formula information';

  @override
  String get latexFormulaStatistics_4821 => 'LaTeX Formula Statistics';

  @override
  String get latexInfoTooltip_7281 => 'LaTeX Info';

  @override
  String get latexRenderingStatus_4821 => 'LaTeX rendering status';

  @override
  String get latvianLV_4869 => 'Latvian (Latvia)';

  @override
  String get latvian_4868 => 'Latvian';

  @override
  String get layer1_7281 => 'Layer 1';

  @override
  String layerAdded(Object name) {
    return 'Layer \"$name\" has been added';
  }

  @override
  String layerBackgroundLoaded(Object hash, Object length) {
    return 'Layer background image loaded from assets system, hash: $hash ($length bytes)';
  }

  @override
  String layerBackgroundUpdated_7281(Object name) {
    return 'The background image setting for layer \"$name\" has been updated';
  }

  @override
  String get layerBinding_4271 => 'Layer Binding';

  @override
  String get layerCleared_4821 => 'Layer label cleared';

  @override
  String layerDataParseFailed_7421(Object e) {
    return 'Failed to parse layer data: $e';
  }

  @override
  String layerDeleted(Object name) {
    return 'Layer \"$name\" has been deleted';
  }

  @override
  String layerDeletionFailed(
    Object e,
    Object layerId,
    Object mapTitle,
    Object version,
  ) {
    return 'Failed to delete layer [$mapTitle/$layerId:$version]: $e';
  }

  @override
  String layerDeletionFailed_7421(Object error) {
    return 'Failed to delete layer: $error';
  }

  @override
  String get layerElementLabelUpdated_4821 => 'Layer element label updated';

  @override
  String layerFilterSetMessage(Object filterName, Object layerName) {
    return 'The color filter for layer \"$layerName\" has been set to: $filterName';
  }

  @override
  String layerGroupInfo(Object groupIndex, Object layerCount) {
    return 'Layer group $groupIndex ($layerCount layers)';
  }

  @override
  String get layerGroupOrderUpdated_4821 =>
      'The order within the layer group has been updated';

  @override
  String layerGroupReorderLog(Object newIndex, Object oldIndex) {
    return 'Layer group reordered: oldIndex=$oldIndex, newIndex=$newIndex';
  }

  @override
  String get layerGroupSelectionCancelled_4821 =>
      'Layer group selection cancelled';

  @override
  String layerGroupTitle(Object groupNumber, Object layerCount) {
    return 'Layer Group $groupNumber ($layerCount layers)';
  }

  @override
  String layerGroupWithCount(Object count) {
    return 'Layer group ($count layers)';
  }

  @override
  String get layerGroup_4821 => 'Layer group';

  @override
  String get layerGroup_7281 => 'Layer Group';

  @override
  String get layerGroups_4821 => 'Layer group';

  @override
  String layerId(Object id) {
    return 'Layer ID: $id';
  }

  @override
  String layerImageSavedToAssets(Object hash, Object length) {
    return 'Layer background image saved to assets, hash: $hash ($length bytes)';
  }

  @override
  String get layerIndexOutOfRange_4821 =>
      'Global layer index not found or out of range';

  @override
  String get layerLegendSettingsWidth_4821 =>
      'Set the width for layer legend binding, legend group management, and Z-level inspector';

  @override
  String layerListLoadFailed(Object e, Object mapTitle, Object version) {
    return 'Failed to load layer list [$mapTitle:$version]: $e';
  }

  @override
  String layerLoadingFailed_4821(
    Object e,
    Object layerId,
    Object mapTitle,
    Object version,
  ) {
    return 'Failed to load layer [$mapTitle/$layerId:$version]: $e';
  }

  @override
  String layerLockFailedPreviewQueued(Object targetLayerId) {
    return 'Failed to lock layer $targetLayerId, preview has been queued';
  }

  @override
  String layerLockedPreviewQueued(Object targetLayerId) {
    return 'Layer $targetLayerId is locked, preview queued';
  }

  @override
  String get layerNameHint_7281 => 'Enter layer name';

  @override
  String layerName_7421(Object name) {
    return 'Layer: $name';
  }

  @override
  String get layerNoElements_4822 => 'The layer has no drawn elements';

  @override
  String get layerOperations_4821 => 'Layer Operations';

  @override
  String layerOrderText(Object order) {
    return 'Order: $order';
  }

  @override
  String get layerOrderUpdated_4821 => 'Layer order has been updated';

  @override
  String get layerPanel_5678 => 'Layer Panel';

  @override
  String layerPreviewQueueCleared_4821(Object layerId) {
    return 'The preview queue for layer $layerId has been cleared';
  }

  @override
  String layerReorderDebug_7281(
    Object length,
    Object newIndex,
    Object oldIndex,
  ) {
    return 'Reordering layers within group: oldIndex=$oldIndex, newIndex=$newIndex, updated layer count: $length';
  }

  @override
  String layerReorderFailed_7285(Object error) {
    return 'Failed to reorder layers in group: $error';
  }

  @override
  String layerSaveFailed_7421(
    Object error,
    Object layerId,
    Object mapTitle,
    Object version,
  ) {
    return 'Failed to save layer [$mapTitle/$layerId:$version]: $error';
  }

  @override
  String get layerSelectionSettings => 'Layer Selection Settings';

  @override
  String layerSerializationFailed_4829(Object e) {
    return 'Layer data serialization failed: $e';
  }

  @override
  String layerSerializationFailed_7284(Object e) {
    return 'Layer data serialization failed: $e';
  }

  @override
  String layerSerializationSuccess(Object length) {
    return 'Layer data serialized successfully, length: $length';
  }

  @override
  String get layerThemeDisabled_4821 =>
      'You have disabled theme adaptation for this layer and are currently using custom settings.';

  @override
  String layerUpdateFailed_7421(Object error) {
    return 'Failed to update layer: $error';
  }

  @override
  String layerVisibilityStatus(
    Object totalLayersCount,
    Object visibleLayersCount,
  ) {
    return 'Enabled: $visibleLayersCount of $totalLayersCount bound layers are visible, legend group is automatically displayed';
  }

  @override
  String get layer_1323 => 'Layer';

  @override
  String get layer_4821 => 'Layer';

  @override
  String get layers => 'Layers';

  @override
  String get layersLabel_4821 => 'Layers';

  @override
  String get layersLabel_7281 => 'Layers';

  @override
  String layersReorderedLog(Object count, Object newIndex, Object oldIndex) {
    return 'Calling onLayersInGroupReordered($oldIndex, $newIndex, $count layers updated)';
  }

  @override
  String get layersTitle_7281 => 'Layers';

  @override
  String layers_9101(Object count) {
    return '$count layers';
  }

  @override
  String layoutDataMigrationError(Object e) {
    return 'An error occurred while migrating layout_data: $e';
  }

  @override
  String get layoutResetSuccess_4821 => 'Layout settings have been reset';

  @override
  String get layoutSettings_4821 => 'Interface Layout Settings';

  @override
  String layoutTypeName(Object layoutName) {
    return 'Layout: $layoutName';
  }

  @override
  String get layoutType_7281 => 'Layout type:';

  @override
  String get learnMore_7421 => 'Learn more';

  @override
  String get leftText_4821 => 'Left';

  @override
  String get legend => 'Legend';

  @override
  String get legendAddedSuccessfully_4821 => 'Legend added successfully';

  @override
  String legendAddedToCache(Object legendPath) {
    return 'Legend added to cache: $legendPath';
  }

  @override
  String legendAddedToGroup(Object count, Object name) {
    return 'Legend has been added to $name ($count legends)';
  }

  @override
  String get legendAlreadyExists_4271 => 'Legend already exists';

  @override
  String get legendBlockedMessage_4821 => 'Legend is blocked';

  @override
  String legendCacheCleaned(Object count, Object folderPath) {
    return 'Legend cache (stepped): Cleared $count cache items in directory \"$folderPath\" (excluding subdirectories)';
  }

  @override
  String legendCacheCleanupFailed_7285(Object e) {
    return 'Failed to clean up legend cache in dispose: $e';
  }

  @override
  String legendCacheCleanupInfo_4857(Object count, Object folderPath) {
    return 'Directory \"$folderPath\" has $count legends in use, these legends will be excluded from cleanup';
  }

  @override
  String legendCacheCleanupSuccess_4858(Object count, Object folderPath) {
    return 'Cleaned legend cache in directory \"$folderPath\" (excluded $count legends in use)';
  }

  @override
  String legendCacheNoItemsToClean(Object folderPath) {
    return 'Legend cache (stepped): No cache items to clean in directory \"$folderPath';
  }

  @override
  String legendCount(Object count) {
    return '$count legends';
  }

  @override
  String legendCountBeforeUpdate(Object count) {
    return 'Legend count before update: $count';
  }

  @override
  String legendDataLoadFailed(Object e, Object legendPath) {
    return 'Failed to load legend data: $legendPath, error: $e';
  }

  @override
  String legendDataParseFailed_7285(Object e) {
    return 'Failed to parse legend group data: $e';
  }

  @override
  String legendDataStatus_4821(Object status) {
    return 'Legend data: $status';
  }

  @override
  String get legendDeletedSuccessfully => 'Legend deleted successfully';

  @override
  String legendDirectoryNotExist_7284(Object absolutePath) {
    return 'Legend directory does not exist: $absolutePath';
  }

  @override
  String legendExistsConfirmation(Object legendTitle) {
    return 'The legend \"$legendTitle\" already exists. Do you want to overwrite the existing legend?';
  }

  @override
  String legendFilesFound_7281(Object count, Object path) {
    return '$count legend files found in path $path';
  }

  @override
  String legendFromAbsolutePath(Object absolutePath, Object title) {
    return 'Get legend from absolute path: \"$title\", path: $absolutePath';
  }

  @override
  String legendGroupAdded_7421(Object name) {
    return 'Legend group \"$name\" has been added';
  }

  @override
  String get legendGroupCleared_4281 => 'Legend group labels cleared';

  @override
  String legendGroupCount(Object count) {
    return 'Legend group count: $count';
  }

  @override
  String legendGroupDeleted(Object name) {
    return 'Legend group \"$name\" has been deleted';
  }

  @override
  String legendGroupDrawerUpdate(Object reason) {
    return 'Legend group management drawer updated: $reason';
  }

  @override
  String get legendGroupEmpty_7281 => 'The legend group has no legend items';

  @override
  String legendGroupHiddenStatusSaved(
    Object enabled,
    Object legendGroupId,
    Object mapId,
  ) {
    return 'Legend group auto-hide status saved: $mapId/$legendGroupId = $enabled';
  }

  @override
  String legendGroupIdChanged(Object newId, Object oldId) {
    return '[CachedLegendsDisplay] Legend group ID changed: $oldId -> $newId, refreshing cached display';
  }

  @override
  String legendGroupInfo(
    Object index,
    Object isVisible,
    Object length,
    Object name,
  ) {
    return 'Legend group $index: $name, visible: $isVisible, legend items: $length';
  }

  @override
  String get legendGroupInvisible_7281 =>
      'Legend group is invisible, returning an empty Widget';

  @override
  String legendGroupItemCount(Object count) {
    return 'Legend group: $count items';
  }

  @override
  String legendGroupItemsLoaded(Object count) {
    return 'Legend group items loaded: $count items in total';
  }

  @override
  String get legendGroupLabel_4912 => 'Legend Group Label';

  @override
  String legendGroupLoadFailed(Object e, Object mapTitle, Object version) {
    return 'Failed to load legend group [$mapTitle:$version]: $e';
  }

  @override
  String legendGroupManagementStatusSynced(Object name) {
    return 'Legend group management status synced: $name';
  }

  @override
  String legendGroupName(Object count) {
    return 'Legend group $count';
  }

  @override
  String get legendGroupName_4821 => 'Legend group name';

  @override
  String legendGroupNotFound(Object groupId) {
    return 'Legend group $groupId not found';
  }

  @override
  String get legendGroupNotVisibleError_4821 =>
      'Cannot select legend: the legend group is currently not visible, please show the legend group first';

  @override
  String legendGroupSerializationFailed_4821(Object e) {
    return 'Legend group data serialization failed: $e';
  }

  @override
  String legendGroupSerializationFailed_7285(Object e) {
    return 'Legend group data serialization failed: $e';
  }

  @override
  String legendGroupSerializationSuccess(Object length) {
    return 'Legend group data serialized successfully, length: $length';
  }

  @override
  String legendGroupSmartHideInitialized(Object _legendGroupSmartHideStates) {
    return 'Legend group smart hide state initialized: $_legendGroupSmartHideStates';
  }

  @override
  String legendGroupSmartHideStatusUpdated(
    Object enabled,
    Object legendGroupId,
  ) {
    return 'The smart hide status of legend group $legendGroupId has been updated: $enabled';
  }

  @override
  String legendGroupSmartHideStatus_7421(
    Object isEnabled,
    Object legendGroupId,
  ) {
    return 'Legend group $legendGroupId smart hide status: $isEnabled';
  }

  @override
  String get legendGroupTooltip_7281 =>
      'Left-click: Open legend group management  \nRight-click: Select legend group';

  @override
  String get legendGroupUnavailable_5421 => 'Legend group unavailable';

  @override
  String legendGroupUpdated(Object count) {
    return 'Legend group labels updated ($count labels)';
  }

  @override
  String legendGroupVisibility(Object isVisible) {
    return 'Legend group visibility: $isVisible';
  }

  @override
  String legendGroupZoomFactorInitialized(Object _legendGroupZoomFactors) {
    return 'Legend group zoom factor state initialized: $_legendGroupZoomFactors';
  }

  @override
  String legendGroupZoomFactorSaved(
    Object legendGroupId,
    Object mapId,
    Object zoomFactor,
  ) {
    return 'Legend group zoom factor saved: $mapId/$legendGroupId = $zoomFactor';
  }

  @override
  String legendGroupZoomUpdated_7281(Object legendGroupId, Object zoomFactor) {
    return 'The zoom factor for legend group $legendGroupId has been updated: $zoomFactor';
  }

  @override
  String legendGroup_7421(Object key, Object value) {
    return 'Legend group $key: $value';
  }

  @override
  String legendHasImageData(Object hasImageData) {
    return 'Legend has image data: $hasImageData';
  }

  @override
  String legendId_4821(Object id) {
    return 'Legend ID: $id';
  }

  @override
  String get legendImportSuccess_7421 => 'Legend imported successfully';

  @override
  String get legendInvisibleWidget_4821 =>
      'Legend is invisible, returning empty Widget';

  @override
  String legendItemCount(Object count) {
    return 'Legend item count: $count';
  }

  @override
  String legendItemCountChanged(Object newCount, Object oldCount) {
    return 'Legend item count changed: $oldCount -> $newCount';
  }

  @override
  String legendItemDeletionFailed_4827(
    Object e,
    Object groupId,
    Object itemId,
    Object mapTitle,
    Object version,
  ) {
    return 'Failed to delete legend item [$mapTitle/$groupId/$itemId:$version]: $e';
  }

  @override
  String legendItemFilePath(Object itemPath) {
    return 'Legend item file path: $itemPath';
  }

  @override
  String legendItemInfo(
    Object dx,
    Object dy,
    Object id,
    Object index,
    Object path,
  ) {
    return 'Legend item $index: $id, path: $path, position: ($dx, $dy)';
  }

  @override
  String legendItemJsonContent(Object itemJson) {
    return 'Legend item JSON content: $itemJson';
  }

  @override
  String legendItemJsonSize(Object length) {
    return 'Legend item JSON data size: $length bytes';
  }

  @override
  String get legendItemLabel_4521 => 'Legend item label';

  @override
  String legendItemLoadFailed(
    Object e,
    Object groupId,
    Object itemId,
    Object mapTitle,
    Object version,
  ) {
    return 'Failed to load legend item [$mapTitle/$groupId/$itemId:$version]: $e';
  }

  @override
  String legendItemLoaded(Object itemId, Object legendId, Object legendPath) {
    return 'Legend item loaded successfully: $itemId, legendPath=$legendPath, legendId=$legendId';
  }

  @override
  String legendItemNotFound(Object itemPath) {
    return 'Legend item file does not exist: $itemPath';
  }

  @override
  String legendItemNotFound_7285(Object itemId) {
    return 'Legend item $itemId not found';
  }

  @override
  String legendItemParsedSuccessfully(
    Object id,
    Object legendId,
    Object legendPath,
  ) {
    return 'Legend item parsed successfully: id=$id, legendPath=$legendPath, legendId=$legendId';
  }

  @override
  String legendItemSaveFailed(
    Object error,
    Object groupId,
    Object itemId,
    Object mapTitle,
    Object version,
  ) {
    return 'Failed to save legend item [$mapTitle/$groupId/$itemId:$version]: $error';
  }

  @override
  String get legendItemsCleared_4281 => 'Legend item labels cleared';

  @override
  String legendItemsPath_7285(Object itemsPath) {
    return 'Legend item path: $itemsPath';
  }

  @override
  String legendLabelsUpdated(Object count) {
    return 'Legend item labels updated ($count labels)';
  }

  @override
  String get legendLinkOptional_4821 => 'Legend Link (Optional)';

  @override
  String get legendLinkOptional_4822 => 'Legend Link (Optional)';

  @override
  String legendListTitle(Object count) {
    return 'Legend List ($count)';
  }

  @override
  String legendLoadError_7285(Object error, Object title) {
    return 'Legend \"$title\" loading error: $error';
  }

  @override
  String legendLoadFailed_7281(Object e, Object legendPath) {
    return 'Failed to load legend: $legendPath, error: $e';
  }

  @override
  String legendLoadingFailed_7421(Object e) {
    return 'Failed to load legend: $e';
  }

  @override
  String legendLoadingInfo(Object actualPath, Object folderPath, Object title) {
    return 'Loading legend: title=$title, folderPath=$folderPath, relativePath=$actualPath';
  }

  @override
  String legendLoadingPath_7421(Object actualPath) {
    return 'Loading legend: Absolute path=$actualPath';
  }

  @override
  String legendLoadingStatus(Object isLoading) {
    return '- Legend not loaded, is loading: $isLoading';
  }

  @override
  String get legendManagement_4821 => 'Legend Management';

  @override
  String get legendManager => 'Legend Management';

  @override
  String get legendManagerEmpty => 'No legends available';

  @override
  String legendMetadataReadFailed_7421(Object e) {
    return 'Failed to read legend metadata: $e';
  }

  @override
  String get legendNoImageData_4821 =>
      'The legend has no image data and is not loading, returning an empty Widget';

  @override
  String legendOperationDisabled(Object name) {
    return 'Unable to operate legend: the legend group \"$name\" is currently not visible';
  }

  @override
  String get legendOperations_4821 => 'Legend Operations';

  @override
  String get legendPanel_9012 => 'Legend panel';

  @override
  String get legendPathConversion => 'Legend path conversion';

  @override
  String legendPathConversion_7281(Object actualPath, Object legendPath) {
    return 'Legend Session Manager: Path conversion $legendPath -> $actualPath';
  }

  @override
  String legendPathDebug(Object legendPath) {
    return 'Legend path: $legendPath';
  }

  @override
  String get legendPathHint_4821 => 'Select or enter the .legend file path';

  @override
  String get legendPathLabel_4821 => 'Legend path (.legend)';

  @override
  String legendPosition(Object dx, Object dy) {
    return 'Legend position: ($dx, $dy)';
  }

  @override
  String legendReloadFailed_7421(Object title) {
    return 'The legend \"$title\" failed to reload';
  }

  @override
  String legendRenderOrderDebug_7421(Object legendRenderOrder) {
    return 'Calculated legendRenderOrder: $legendRenderOrder';
  }

  @override
  String get legendScaleDescription_4856 =>
      'Newly dragged legends will automatically adjust their size based on this zoom factor and the current canvas zoom level';

  @override
  String legendSessionInitialized(Object count) {
    return 'Legend session initialized successfully, number of legends: $count';
  }

  @override
  String get legendSessionInitialized_4821 =>
      'Legend session initialized for existing map data';

  @override
  String legendSessionManagerBatchPreloadComplete(Object count) {
    return 'Legend Session Manager: Batch preload completed, count: $count';
  }

  @override
  String legendSessionManagerError(Object e, Object legendPath) {
    return 'Legend Session Manager: Loading exception $legendPath, error: $e';
  }

  @override
  String legendSessionManagerExists_7281(Object value) {
    return 'Legend session manager exists: $value';
  }

  @override
  String legendSessionManagerInitialized(Object count) {
    return 'Legend Session Manager: Initialization completed, preloaded legends count: $count';
  }

  @override
  String legendSessionManagerLoadFailed(Object legendPath) {
    return 'Legend Session Manager: Failed to load $legendPath';
  }

  @override
  String legendSessionManagerLoaded(Object legendPath) {
    return 'Legend Session Manager: Successfully loaded $legendPath';
  }

  @override
  String legendSessionManagerPathConversion(
    Object actualPath,
    Object legendPath,
  ) {
    return 'Legend Session Manager: Path Conversion $legendPath -> $actualPath';
  }

  @override
  String legendSessionManagerRemoveLegend_7281(Object legendPath) {
    return 'Legend Session Manager: Remove legend $legendPath';
  }

  @override
  String legendSessionManagerRetryCount(Object count) {
    return 'Legend Session Manager: Retry failed legends, count: $count';
  }

  @override
  String get legendSessionManagerStatus_7281 =>
      'Legend session manager status:';

  @override
  String legendSizeValue_4821(Object value) {
    return '$value';
  }

  @override
  String get legendSize_4821 => 'Legend size';

  @override
  String legendTitle(Object count) {
    return 'Legend: $count';
  }

  @override
  String get legendTitleEmpty_7281 => 'Legend title is empty';

  @override
  String get legendTitle_4821 => 'Legend';

  @override
  String get legendUpdateSuccess_7284 => 'Legend updated successfully';

  @override
  String get legendVersion => 'Legend version';

  @override
  String get legendVersionHintText_4821 => 'Enter legend version number';

  @override
  String get legendVersionHint_4821 => 'Enter legend version number';

  @override
  String legendVisibility(Object isVisible) {
    return 'Legend visibility: $isVisible';
  }

  @override
  String legendVisibilityStatus(Object isVisible) {
    return 'Legend visibility: $isVisible';
  }

  @override
  String get length_8921 => 'Length';

  @override
  String get licenseCopiedToClipboard_4821 =>
      'License text has been copied to clipboard';

  @override
  String get licenseDescription_4907 =>
      'Open source license that guarantees software freedom';

  @override
  String get licenseLegalese_7281 =>
      '© 2024 R6BOX Team  \nReleased under GPL v3 license';

  @override
  String get licenseSection_4905 => 'License';

  @override
  String get lightMode => 'Light mode';

  @override
  String get lightTheme_4821 => 'Light theme';

  @override
  String get lightTheme_5421 => 'Light theme';

  @override
  String get line => 'Line';

  @override
  String lineCountText(Object lineCount) {
    return 'Lines: $lineCount';
  }

  @override
  String get lineThickness_4521 => 'Line thickness';

  @override
  String get lineToolLabel_4521 => 'Line';

  @override
  String get lineTool_9012 => 'Line';

  @override
  String lineWidthAdded(Object width) {
    return 'Line width ${width}px added';
  }

  @override
  String get lineWidthExists_4821 => 'This line width already exists';

  @override
  String get line_4821 => 'Straight line';

  @override
  String linkCount_7281(Object linkCount) {
    return 'Links: $linkCount';
  }

  @override
  String get linkSettings_4821 => 'Link Settings';

  @override
  String get linuxFeatures => 'Linux Features:';

  @override
  String get linuxPlatform => 'Linux platform';

  @override
  String get linuxSpecificFeatures =>
      'Linux-specific features can be implemented here.';

  @override
  String linuxXclipCopyFailed(Object resultStderr) {
    return 'Linux xclip copy failed: $resultStderr';
  }

  @override
  String get linuxXclipReadFailed_7281 =>
      'Linux xclip read failed or no image in clipboard';

  @override
  String get listItemContextMenu_4821 => 'List item context menu';

  @override
  String listItemTitle(Object itemNumber) {
    return 'List item $itemNumber';
  }

  @override
  String get listView_4968 => 'List View';

  @override
  String get lithuanianLT_4871 => 'Lithuanian (Lithuania)';

  @override
  String get lithuanian_4870 => 'Lithuanian';

  @override
  String loadConfigFailed(Object e) {
    return 'Failed to load configuration: $e';
  }

  @override
  String loadConfigFailed_4821(Object configError) {
    return 'Failed to load configuration: $configError';
  }

  @override
  String get loadFailed_4821 => 'Failed to load';

  @override
  String get loadFailed_7281 => 'Load failed';

  @override
  String loadFolderFailed_7285(Object e) {
    return 'Failed to load folder: $e';
  }

  @override
  String loadLegendFailed(Object directoryPath, Object e) {
    return 'Failed to load legend from directory: $directoryPath, error: $e';
  }

  @override
  String loadMapsFailed(Object error) {
    return 'Failed to load maps: $error';
  }

  @override
  String loadNoteDataFailed(Object e, Object mapTitle, Object version) {
    return 'Failed to load note data [$mapTitle:$version]: $e';
  }

  @override
  String loadPathToCacheFailed(Object e, Object path) {
    return 'Failed to load path into cache: $path, error: $e';
  }

  @override
  String loadStickyNoteError_4827(
    Object e,
    Object mapTitle,
    Object stickyNoteId,
    Object version,
  ) {
    return 'Failed to load sticky note data [$mapTitle/$stickyNoteId:$version]: $e';
  }

  @override
  String loadTextFileFailed_7421(Object e) {
    return 'Failed to load text file: $e';
  }

  @override
  String loadUserPreferencesFailed(Object e) {
    return 'Failed to load current user preferences: $e';
  }

  @override
  String loadVersionDataFailed_7421(Object error, Object versionId) {
    return 'Failed to load version $versionId data: $error, using base data';
  }

  @override
  String loadVersionDataToReactiveSystem(Object versionId) {
    return 'Loading version data [$versionId] from VFS to the reactive system';
  }

  @override
  String get loadedButUnselected_7281 => 'Loaded but not selected';

  @override
  String loadedToCache_7281(Object legendPath) {
    return 'Loaded to cache: $legendPath';
  }

  @override
  String get loaded_4821 => 'Loaded';

  @override
  String get loadingAudio_7281 => 'Loading audio...';

  @override
  String get loadingAudio_7421 => 'Loading audio...';

  @override
  String get loadingConfiguration_7281 => 'Loading configuration';

  @override
  String get loadingConfiguration_7421 => 'Loading configuration';

  @override
  String get loadingImage_7281 => 'Loading image...';

  @override
  String loadingLegendItem(Object itemId) {
    return 'Loading legend item: $itemId';
  }

  @override
  String loadingMapDetails(Object folderPath, Object mapTitle, Object version) {
    return 'Loading map: $mapTitle, version: $version, folder: $folderPath';
  }

  @override
  String loadingMapToReactiveSystem(Object title) {
    return 'Loading map to reactive system: $title';
  }

  @override
  String get loadingMarkdownFile_7421 => 'Loading Markdown file...';

  @override
  String loadingNoteWithElements(Object count, Object i, Object title) {
    return 'Loading note [$i] $title: $count drawing elements';
  }

  @override
  String loadingPathToCache(Object legendGroupId, Object path) {
    return 'Loading path to cache: $legendGroupId -> $path';
  }

  @override
  String loadingPathToCache_7281(Object path) {
    return 'Loading path to cache: $path';
  }

  @override
  String loadingStateMessage_5421(Object loadingState) {
    return '- Loading state: $loadingState';
  }

  @override
  String loadingStatusCheck(Object isLoading) {
    return 'Is loading: $isLoading';
  }

  @override
  String get loadingStoredVersionFromVfs_4821 =>
      'Starting to load the stored version from VFS...';

  @override
  String get loadingSvgFiles_5421 => 'Loading SVG files...';

  @override
  String get loadingTextFile_7281 => 'Loading text file...';

  @override
  String get loadingText_4821 => 'Loading...';

  @override
  String get loadingText_7281 => 'Loading...';

  @override
  String loadingVersionData_7281(
    Object layerCount,
    Object noteCount,
    Object versionId,
  ) {
    return 'Loading version $versionId data from VFS, layers: $layerCount, notes: $noteCount';
  }

  @override
  String get loadingVfsDirectory_7421 => 'Loading VFS directory structure...';

  @override
  String get loadingVideo_7281 => 'Loading video...';

  @override
  String get loadingVideo_7421 => 'Loading video...';

  @override
  String get loading_5421 => 'Loading...';

  @override
  String localImageSize_7421(Object size) {
    return 'Local image ($size KB)';
  }

  @override
  String get localImport_4974 => 'Local Import';

  @override
  String get localizationFileUploadSuccess_4821 =>
      'Localization file uploaded successfully';

  @override
  String localizationVersionNotHigher(Object currentVersion, Object version) {
    return 'Localization file version $version is not higher than the current version $currentVersion, skipping import';
  }

  @override
  String get localizationVersionTooLowOrUploadCancelled_7281 =>
      'Localization file version is too low or upload was canceled';

  @override
  String lockConflictDescription(Object userName) {
    return 'User $userName attempted to lock an element that was already locked';
  }

  @override
  String get lockConflict_4828 => 'Lock conflict';

  @override
  String get logCleanupComplete_7281 => 'Log file cleanup completed';

  @override
  String logCleanupError_5421(Object e) {
    return 'An error occurred while cleaning up log files: $e';
  }

  @override
  String logCleanupTime(Object elapsedMilliseconds) {
    return 'Log file cleanup time: ${elapsedMilliseconds}ms';
  }

  @override
  String get logCleared_7281 => 'Log has been cleared';

  @override
  String logDeletionFailed_7421(Object error, Object path) {
    return 'Failed to delete log file: $path, error: $error';
  }

  @override
  String get lowPriorityTag_0123 => 'Low priority';

  @override
  String get low_7284 => 'Low';

  @override
  String get macOSFeatures => 'macOS Features:';

  @override
  String get macOSNotifications => 'macOS Notifications';

  @override
  String get macOSPlatform => 'macOS Platform';

  @override
  String get macOSSpecificFeatures =>
      'macOS-specific features can be implemented here.';

  @override
  String macOsCopyFailed_7421(Object error) {
    return 'macOS osascript copy failed: $error';
  }

  @override
  String get macOsScriptReadFailed_7281 =>
      'macOS osascript read failed or no image in clipboard';

  @override
  String get malayMY_4879 => 'Malay (Malaysia)';

  @override
  String get malay_4878 => 'Malay';

  @override
  String get manageCustomTags_4271 => 'Manage Custom Tags';

  @override
  String get manageCustomTags_7421 => 'Manage Custom Tags';

  @override
  String manageLayerTagsTitle(Object name) {
    return 'Manage Layer Tags - $name';
  }

  @override
  String get manageLegendGroupLegends_4821 =>
      'Manage legends in the legend group';

  @override
  String manageLegendGroupTagsTitle(Object name) {
    return 'Manage Legend Group Tags - $name';
  }

  @override
  String get manageLegendGroup_7421 => 'Manage Legend Group';

  @override
  String get manageLegendTagsTitle_4821 => 'Manage Legend Item Labels';

  @override
  String get manageLineWidths_4821 => 'Manage common line widths';

  @override
  String manageNoteTagsTitle(Object title) {
    return 'Manage Note Tags - $title';
  }

  @override
  String get manageStrokeWidths_4821 => 'Manage common stroke widths';

  @override
  String get manageTagsTitle_4821 => 'Manage Tags';

  @override
  String manageTagsTitle_7421(Object type) {
    return 'Manage $type Tags';
  }

  @override
  String get manageTags_4271 => 'Manage Tags';

  @override
  String get manageTags_4821 => 'Manage Tags';

  @override
  String get manageTimers_4821 => 'Manage Timers';

  @override
  String get manage_4915 => 'Manage';

  @override
  String get management_4821 => 'Management';

  @override
  String get management_7281 => 'Management';

  @override
  String get manualWindowSizeSetting_4821 =>
      'Manually set the default window size';

  @override
  String get mapAddedSuccessfully => 'Map added successfully';

  @override
  String get mapAlreadyExists_4271 => 'Map already exists';

  @override
  String mapAndResponsiveSystemInitFailed(Object e) {
    return 'Map and responsive system initialization failed: $e';
  }

  @override
  String mapAreaCopiedToClipboard(Object height, Object width) {
    return 'Web: The selected map area has been successfully copied to the clipboard: ${width}x$height';
  }

  @override
  String get mapAtlas => 'Atlas';

  @override
  String get mapAtlasEmpty => 'No maps available';

  @override
  String get mapAtlas_4821 => 'Atlas';

  @override
  String mapBackupCreated(Object backupPath, Object length, Object mapId) {
    return 'Map backup created: $mapId -> $backupPath ($length bytes)';
  }

  @override
  String mapBackupFailed_7285(Object e) {
    return 'Failed to create map backup: $e';
  }

  @override
  String get mapClearedMessage_4827 => 'Map information has been cleared';

  @override
  String get mapContentArea_7281 => 'Map content area';

  @override
  String get mapCoverCompressionFailed_4821 =>
      'Map cover compression failed, cover information will not be synchronized';

  @override
  String get mapCoverCompressionFailed_7281 => 'Map cover compression failed';

  @override
  String mapCoverLoadFailed_7285(Object e) {
    return 'Failed to load map cover: $e';
  }

  @override
  String mapCoverRecompressed(Object newSize, Object oldSize) {
    return 'Map cover recompressed: ${oldSize}KB -> ${newSize}KB';
  }

  @override
  String mapCoverUpdateFailed(Object arg0, Object arg1) {
    return 'Failed to update map cover [$arg0]: $arg1';
  }

  @override
  String mapCoverUpdatedSuccessfully(Object mapTitle) {
    return 'Map cover updated successfully: $mapTitle';
  }

  @override
  String get mapCoverUpdatedSuccessfully_4849 =>
      'Map cover updated successfully';

  @override
  String mapDataInitializationFailed_7421(Object error) {
    return 'Failed to initialize map data: $error';
  }

  @override
  String mapDataLoadFailed_7284(Object e) {
    return 'Failed to load map data: $e';
  }

  @override
  String mapDataLoadFailed_7421(Object error) {
    return 'Failed to load map data: $error';
  }

  @override
  String get mapDataLoadedEvent_4821 =>
      '=== Responsive listener received MapDataLoaded event ===';

  @override
  String mapDataLoadedToReactiveSystem(Object title) {
    return 'Map data has been loaded into the reactive system: $title';
  }

  @override
  String mapDataLoaded_7421(Object title) {
    return 'Map data loaded: $title';
  }

  @override
  String mapDataSaveFailed_7421(Object error) {
    return 'Failed to save map data: $error';
  }

  @override
  String mapDatabaseCloseFailed(Object e) {
    return 'Failed to close map database: $e';
  }

  @override
  String get mapDatabaseServiceError_4821 =>
      'MapDatabaseService.updateMap error:';

  @override
  String get mapDatabaseServiceUpdateMapStart_7281 =>
      'MapDatabaseService.updateMap execution started';

  @override
  String get mapDeletedSuccessfully => 'Map deleted successfully';

  @override
  String mapDeletionFailed_7421(Object e, Object mapTitle) {
    return 'Failed to delete map [$mapTitle]: $e';
  }

  @override
  String get mapEditor => 'Map Editor';

  @override
  String get mapEditorCallComplete_7421 => 'Call completed';

  @override
  String get mapEditorExitCleanup_4821 =>
      'Map Editor Exit: All legend caches have been cleared';

  @override
  String get mapEditorExitMessage_4821 =>
      'Map Editor Exit: All color filters have been cleared';

  @override
  String get mapEditorSettings_7421 => 'Map Editor Settings';

  @override
  String mapEditorUpdateFailed(Object error) {
    return 'Failed to update map editor settings: $error';
  }

  @override
  String mapEditorUpdateLegendGroup(Object name) {
    return 'Map Editor: Update Legend Group $name';
  }

  @override
  String mapExistsConfirmation(Object mapTitle) {
    return 'The map \"$mapTitle\" already exists. Do you want to overwrite it?';
  }

  @override
  String mapFetchFailed_7284(Object e) {
    return 'Failed to fetch map count: $e';
  }

  @override
  String mapIdChanged(Object oldMapId, Object newMapId) {
    return 'Map ID changed: $oldMapId -> $newMapId';
  }

  @override
  String mapIdDebug(Object id) {
    return 'Map ID: $id';
  }

  @override
  String mapIdLookupFailed_7421(Object id) {
    return 'Failed to look up map by ID, VFS system uses title-based storage: $id';
  }

  @override
  String get mapImportFailed_4728 => 'Failed to import map';

  @override
  String mapImportSuccess(Object title) {
    return 'Map imported successfully: $title';
  }

  @override
  String mapInfoChangedBroadcast(Object mapId, Object mapTitle) {
    return 'Map information has changed, preparing to broadcast: mapId=$mapId, mapTitle=$mapTitle';
  }

  @override
  String get mapInfoSyncComplete_7281 =>
      'Map information synchronization completed';

  @override
  String get mapInfoUnchangedSkipBroadcast_4821 =>
      'Map info unchanged, skipping broadcast';

  @override
  String get mapInfo_7281 => 'Map Info';

  @override
  String get mapInfo_7421 => 'Map Info';

  @override
  String mapInitialization(Object title) {
    return 'Initializing map: $title';
  }

  @override
  String mapInitializationFailed_7421(Object error) {
    return 'Failed to initialize map: $error';
  }

  @override
  String mapInsertFailed_7285(Object e) {
    return 'Failed to insert sample map directly: $e';
  }

  @override
  String get mapItemAndTitleEmpty_9274 => 'Both mapItem and mapTitle are empty';

  @override
  String mapLayerPresetSet(Object layerId, Object mapId, Object presets) {
    return 'Extended settings: Transparency presets for layer $layerId on map $mapId have been set: $presets';
  }

  @override
  String mapLegendAutoHideStatus(
    Object isHidden,
    Object legendGroupId,
    Object mapId,
  ) {
    return 'Extended settings: The auto-hide status of legend group $legendGroupId on map $mapId has been set to $isHidden';
  }

  @override
  String mapLegendAutoHideStatusSaved(Object title) {
    return 'The auto-hide status of the $title map legend group has been saved';
  }

  @override
  String mapLegendScaleSaved(Object title) {
    return 'The legend group scale factor status for map $title has been saved';
  }

  @override
  String mapLegendZoomFactorLog_4821(
    Object legendGroupId,
    Object mapId,
    Object zoomFactor,
  ) {
    return 'Extended settings: The zoom factor for legend group $legendGroupId on map $mapId has been set to $zoomFactor';
  }

  @override
  String mapLoadFailed(Object e, Object title) {
    return 'Failed to load map [$title]: $e';
  }

  @override
  String mapLoadFailedById(Object e, Object id) {
    return 'Failed to load map by ID [$id]: $e';
  }

  @override
  String mapLocalizationDbCloseFailed(Object e) {
    return 'Failed to close the map localization database: $e';
  }

  @override
  String mapLocalizationFailed_7421(Object e, Object mapTitle) {
    return 'Failed to save map localization [$mapTitle]: $e';
  }

  @override
  String mapMigrationComplete(Object mapId, Object title) {
    return 'Map migration completed: $title -> $mapId';
  }

  @override
  String mapMigrationFailed(Object error, Object title) {
    return 'Map migration failed: $title - $error';
  }

  @override
  String mapMoveFailed(Object arg0, Object arg1) {
    return 'Failed to move map [$arg0]: $arg1';
  }

  @override
  String get mapName_4821 => 'Map name';

  @override
  String mapNotFoundError(Object mapTitle) {
    return 'Map not found: $mapTitle';
  }

  @override
  String mapNotFoundError_7285(Object oldTitle) {
    return 'Map not found: $oldTitle';
  }

  @override
  String mapNotFoundWithTitle(Object mapTitle) {
    return 'Map with title \"$mapTitle\" not found';
  }

  @override
  String get mapNotFound_7281 => 'Map does not exist';

  @override
  String mapNotFound_7425(Object mapId) {
    return 'Map does not exist: $mapId';
  }

  @override
  String mapPackageExportComplete(Object exportPath, Object mapId) {
    return 'Map package export completed: $mapId -> $exportPath';
  }

  @override
  String get mapPreferencesDescription_4821 =>
      'Used to store temporary map-related preferences, such as legend group auto-hide states. These settings do not affect the map data itself.';

  @override
  String get mapPreview => 'Map Preview';

  @override
  String mapRecordNotFoundWithId(Object id) {
    return 'The map record to update was not found, ID: $id';
  }

  @override
  String mapRenameSuccess_7285(Object newTitle, Object oldTitle) {
    return 'Map renamed successfully: $oldTitle -> $newTitle';
  }

  @override
  String get mapRenamedSuccessfully_4848 => 'Map renamed successfully';

  @override
  String mapRestoreFailed_7285(Object e) {
    return 'Failed to restore map from backup: $e';
  }

  @override
  String mapSaveFailed(Object error, Object title) {
    return 'Failed to save map [$title]: $error';
  }

  @override
  String mapSaveFailed_7285(Object e) {
    return 'Failed to save map: $e';
  }

  @override
  String get mapSavedSuccessfully_7281 => 'Map saved successfully';

  @override
  String mapScriptsLoaded(Object mapTitle, Object scriptCount) {
    return '$scriptCount scripts loaded for map $mapTitle';
  }

  @override
  String mapSelectionSavedWithSize(
    Object height,
    Object platformHint,
    Object width,
  ) {
    return 'The selected map area has been saved (${width}x$height) - Image clipboard feature is unavailable on $platformHint';
  }

  @override
  String mapSessionSummary_1589(
    Object currentVersionId,
    Object mapTitle,
    Object totalVersions,
    Object unsavedCount,
  ) {
    return 'Map: $mapTitle, Version: $totalVersions, Unsaved: $unsavedCount, Current: $currentVersionId';
  }

  @override
  String mapSummaryError_4821(Object e, Object mapPath) {
    return 'Failed to get map summary from path [$mapPath]: $e';
  }

  @override
  String mapSummaryLoadFailed(Object desanitizedTitle, Object e) {
    return 'Failed to load map summary [$desanitizedTitle]: $e';
  }

  @override
  String get mapSyncDemoTitle_7281 => 'Map Information Synchronization Demo:';

  @override
  String mapSyncFailed_7285(Object e) {
    return 'Failed to sync map information: $e';
  }

  @override
  String get mapTitle => 'Map Title';

  @override
  String get mapTitleUpdated_7281 => 'Map title updated';

  @override
  String get mapTitle_7421 => 'Map Title';

  @override
  String mapUpdateMessage(Object newVersion, Object oldVersion, Object title) {
    return 'Update map: $title (version $oldVersion -> $newVersion)';
  }

  @override
  String mapVersionCreationFailed_7421(
    Object e,
    Object mapTitle,
    Object version,
  ) {
    return 'Failed to create map version [$mapTitle:$version]: $e';
  }

  @override
  String mapVersionDeletionFailed_7421(
    Object e,
    Object mapTitle,
    Object version,
  ) {
    return 'Failed to delete map version [$mapTitle:$version]: $e';
  }

  @override
  String mapVersionFetchFailed(Object e, Object mapTitle) {
    return 'Failed to fetch map version [$mapTitle]: $e';
  }

  @override
  String get mapVersion_4821 => 'Map version';

  @override
  String mapZoomLevelRecord(Object mapId, Object zoomLevel) {
    return 'Extended settings: Map $mapId added zoom level record $zoomLevel';
  }

  @override
  String get maps_4823 => 'Maps';

  @override
  String get marginLabel_7281 => 'Page margin';

  @override
  String markRemovedWithPath(Object path) {
    return 'Marked as removed: path=\"$path';
  }

  @override
  String get markTag_2345 => 'Mark';

  @override
  String get markdownFileEmpty_7281 => 'The Markdown file is empty';

  @override
  String markdownGeneratorCreation(
    Object generatorsLength,
    Object syntaxesLength,
  ) {
    return '🔧 _buildMarkdownContent: Creating MarkdownGenerator - generators: $generatorsLength, syntaxes: $syntaxesLength';
  }

  @override
  String markdownLoadFailed_7421(Object error) {
    return 'Failed to load Markdown file: $error';
  }

  @override
  String get markdownReadError_4821 => 'Failed to read the Markdown file';

  @override
  String get markdownRendererDemo_4821 => 'Markdown Renderer Component Demo';

  @override
  String get markdownRendererDemo_7421 => 'Markdown Renderer Demo';

  @override
  String get markedTag_5678 => 'Marked';

  @override
  String get marker_4827 => 'Marker';

  @override
  String get materialDesign => 'Material Design';

  @override
  String maxConcurrentScriptsReached(Object maxExecutors) {
    return 'Maximum concurrent scripts limit reached ($maxExecutors)';
  }

  @override
  String get maxLimitReached_5421 => 'Maximum limit reached (5)';

  @override
  String get maxLineWidthLimit_4821 =>
      'You can add up to 5 frequently used line widths';

  @override
  String get maxTagsLimit => 'Maximum of 10 tags allowed';

  @override
  String get maxTagsLimitComment => 'Maximum of 10 tags allowed';

  @override
  String get maximizeOrRestore_7281 => 'Maximize/Restore';

  @override
  String get maximizeRestore_7281 => 'Maximize/Restore';

  @override
  String get meIndicator_7281 => '(Me)';

  @override
  String get mediumBrush_4821 => 'Medium brush';

  @override
  String get menuBarIntegration => 'Menu Bar Integration';

  @override
  String get menuRadius_4271 => 'Menu radius';

  @override
  String menuSelection_7281(Object label) {
    return 'Menu selection: $label';
  }

  @override
  String get mergeExpand_4281 => 'Merge & Expand';

  @override
  String get mergeFolderPrompt_4821 =>
      'Merge folder contents, will prompt again if subfile conflicts occur';

  @override
  String get mergeLayers_7281 => 'Merge Layers';

  @override
  String get mergeText_4821 => 'Merge';

  @override
  String get mergeText_7421 => 'Merge';

  @override
  String get messageContent_7281 => 'Message content';

  @override
  String get messageSignedSuccessfully_7281 => 'Message signed successfully';

  @override
  String get messageType_7281 => 'Message type';

  @override
  String messageWithIndexAndType_7421(Object index, Object type) {
    return 'Message $index - $type';
  }

  @override
  String metadataFileFormatError_7285(Object e) {
    return 'Metadata file format error: $e';
  }

  @override
  String get metadataFileMissing_7285 =>
      'Metadata file does not exist: meta.json';

  @override
  String metadataFormatError_7281(Object e) {
    return 'Metadata file format error: $e';
  }

  @override
  String get metadataFormatExample_4980 => 'metadata.json format example:';

  @override
  String get metadataFormat_4979 => 'Metadata Format';

  @override
  String get metadataInfo_4932 => 'Metadata Information';

  @override
  String get metadataJsonNotFoundInZipRoot_7281 =>
      'The metadata.json file was not found in the ZIP root directory.';

  @override
  String get metadataLabel_7281 => 'Metadata:';

  @override
  String get metadataTableCreated_7281 => 'Metadata table created successfully';

  @override
  String get metadataTitle_4821 => 'Metadata';

  @override
  String get metadata_4821 => 'Metadata';

  @override
  String get middleButton_7281 => 'Middle button';

  @override
  String middleKeyPressedShowRadialMenu(Object localPosition) {
    return 'Middle button pressed, showing radial menu at position: $localPosition';
  }

  @override
  String migrateLegacyPreferences(Object displayName) {
    return 'Migrate legacy user preferences: $displayName';
  }

  @override
  String migrateUserConfig(Object displayName) {
    return 'Migrating user configuration: $displayName';
  }

  @override
  String migratedWindowControlsMode(Object userId) {
    return 'The enableMergedWindowControls setting has been migrated to windowControlsMode for user $userId';
  }

  @override
  String migrationCheckFailed_4821(Object e) {
    return 'Migration status check failed: $e';
  }

  @override
  String migrationError_7425(Object e) {
    return 'Migration validation error: $e';
  }

  @override
  String migrationFailed_7285(Object e) {
    return 'Migration of legacy user preferences failed: $e';
  }

  @override
  String migrationStatsFailed_5421(Object e) {
    return 'Failed to get migration statistics: $e';
  }

  @override
  String get migrationStatusReset_7281 => 'Migration status has been reset';

  @override
  String migrationValidationFailed(Object originalCount, Object vfsCount) {
    return 'Migration validation failed: Map count mismatch (Original: $originalCount, VFS: $vfsCount)';
  }

  @override
  String get migrationValidationSuccess_7281 =>
      'Migration validation successful: All map data intact';

  @override
  String mimeTypeLabel(Object mimeType) {
    return 'MIME type: $mimeType';
  }

  @override
  String get mimeTypeLabel_4721 => 'MIME type';

  @override
  String get mimeType_4821 => 'MIME type';

  @override
  String get minimizeButton_4821 => 'Minimize';

  @override
  String get minimizeButton_7281 => 'Minimize';

  @override
  String get minimizePlayer_4821 => 'Minimize player';

  @override
  String get minimizeTooltip_7281 => 'Minimize';

  @override
  String minutesAgo_7421(Object minutes) {
    return '$minutes minutes ago';
  }

  @override
  String get minutesLabel_7281 => 'minutes';

  @override
  String get missingMetadataFields_4821 =>
      'The target_path or file_mappings are not specified in the metadata.';

  @override
  String missingRequiredField_4827(Object field) {
    return 'Missing required field in metadata: $field';
  }

  @override
  String mobileGroupLayerDebug(Object layers) {
    return 'Mobile group layer: $layers';
  }

  @override
  String mobileGroupSize(Object length) {
    return 'Mobile group size: $length';
  }

  @override
  String get mobileGroupTitle_7281 => '=== Mobile Group ===';

  @override
  String get mode => 'Mode';

  @override
  String modifiedAtText_7281(Object date) {
    return 'Modified on $date';
  }

  @override
  String modifiedAtTime_7281(Object time) {
    return 'Modified at $time';
  }

  @override
  String get modifiedTimeLabel_4821 => 'Modified time';

  @override
  String get modifiedTimeLabel_5421 => 'Modified time';

  @override
  String get modifiedTimeLabel_7421 => 'Modified time';

  @override
  String get modifiedTimeLabel_8532 => 'Modified time';

  @override
  String get modifiedTime_4821 => 'Modified time';

  @override
  String get modified_4963 => 'Modified';

  @override
  String get modified_5732 => 'Modified';

  @override
  String mouseStopAndEnterSubmenu(Object label) {
    return 'Mouse stops moving, delay before entering submenu: $label';
  }

  @override
  String get moveElementFailedJsonError_4821 =>
      'Failed to move element: JSON parsing error';

  @override
  String moveItem_7421(Object item) {
    return 'Move $item';
  }

  @override
  String moveLayerElementOffset(
    Object deltaX,
    Object deltaY,
    Object elementId,
    Object layerId,
  ) {
    return 'Move element $elementId in layer $layerId by offset ($deltaX, $deltaY)';
  }

  @override
  String moveNoteElementOffset_4821(
    Object deltaX,
    Object deltaY,
    Object elementId,
    Object noteId,
  ) {
    return 'Move element $elementId in note $noteId by offset ($deltaX, $deltaY)';
  }

  @override
  String get moveToTop_7281 => 'Move to top';

  @override
  String movedLayersName_4821(Object layers) {
    return 'Moved layers name: $layers';
  }

  @override
  String movingLayerDebug_7281(Object isMovingLastElement, Object name) {
    return 'Moving layer: $name, is the last element in group: $isMovingLastElement';
  }

  @override
  String get muteToggleFailed_7281 => 'Failed to toggle mute';

  @override
  String get mute_4821 => 'Mute';

  @override
  String get mute_5422 => 'Mute';

  @override
  String get mute_5832 => 'Mute';

  @override
  String get mutedStatusOff => 'Unmute';

  @override
  String get mutedStatusOn => 'Muted';

  @override
  String get nameCannotBeEmpty_4821 => 'Name cannot be empty';

  @override
  String get nameLabel_4821 => 'Name';

  @override
  String get nameLengthExceedLimit_4829 =>
      'Name length cannot exceed 255 characters';

  @override
  String get nameLengthExceeded_4821 =>
      'Name length cannot exceed 255 characters';

  @override
  String nameUpdatedTo_7421(Object newName) {
    return 'Display name has been updated to \"$newName';
  }

  @override
  String get name_4951 => 'Name';

  @override
  String get name_4961 => 'Name';

  @override
  String get nativeContextMenuStyle_4821 =>
      '• Use the system\'s native context menu style';

  @override
  String get nativeCopyHint_3456 => 'This platform';

  @override
  String get nativeGtkIntegration => 'Native GTK integration';

  @override
  String nativeImageCopyFailed_4821(Object e) {
    return 'Failed to copy image on native platform: $e';
  }

  @override
  String get nativeInteractionExperience_4821 =>
      '• Maintain the native interaction experience of the platform';

  @override
  String get nativeMacOSUI => 'Native macOS UI';

  @override
  String get nativeWindowsUI => 'Native Windows UI';

  @override
  String navigatedToFile_4821(Object name) {
    return 'Navigated to file: $name';
  }

  @override
  String navigatedToFolder_4821(Object name) {
    return 'Navigated to folder: $name';
  }

  @override
  String navigationFailed_4821(Object error) {
    return 'Navigation failed: $error';
  }

  @override
  String get networkError_4825 => 'Network error';

  @override
  String get networkUrlLabel_4823 => 'Network URL';

  @override
  String get newButton_4821 => 'New';

  @override
  String get newFolderName_4842 => 'New Folder Name';

  @override
  String get newFolderTitle_4821 => 'New Folder';

  @override
  String newImageElementsDetected_7281(Object count) {
    return '$count new image elements detected, starting preload';
  }

  @override
  String get newLabel_4821 => 'New name:';

  @override
  String newLegendGroupItemCount(Object count) {
    return 'The new legend group has $count legend items';
  }

  @override
  String get newMapName_4847 => 'New Map Name';

  @override
  String get newNameLabel_4521 => 'New name';

  @override
  String newNoteTitle(Object count) {
    return 'New note $count';
  }

  @override
  String get newScript_7281 => 'New Script';

  @override
  String newVersionCreated_7281(Object versionId) {
    return 'New version created: $versionId';
  }

  @override
  String get nextLayerGroup_4825 => 'Next layer group';

  @override
  String get nextLayer_4823 => 'Next layer';

  @override
  String get nextLegendGroup_4823 => 'Next legend group';

  @override
  String get nextSong_7281 => 'Next song';

  @override
  String get nextVersion_4823 => 'Next version';

  @override
  String get ninePerPage_4825 => 'Nine per page';

  @override
  String get no => 'No';

  @override
  String get noActiveClientConfig_7281 =>
      'No active client configuration found';

  @override
  String get noActiveMap_7421 => 'No active map';

  @override
  String get noActiveWebSocketConfigFound_7281 =>
      'No active WebSocket configuration found, creating default configuration';

  @override
  String get noAudioSourceSpecified_7281 => 'No audio source specified';

  @override
  String get noAuthenticatedAccount_7421 => 'No authenticated account';

  @override
  String get noAvailableLayers => 'No available layers';

  @override
  String get noAvailableLayers_4721 => 'No available layers';

  @override
  String get noAvailableLayers_4821 => 'No available layers';

  @override
  String get noAvailableLayers_7281 => 'No layers available';

  @override
  String get noAvailableLegend_4821 => 'No available legend';

  @override
  String get noAvailableScripts_7281 => 'No available enabled scripts';

  @override
  String get noAvatar_4821 => 'No Avatar';

  @override
  String get noBackgroundImage_7421 => 'No background image';

  @override
  String get noBoundLegend_4821 => 'No bound legend';

  @override
  String get noCachedLegend => 'No cached legend available';

  @override
  String get noCommonLineWidthAdded_4821 => 'No common line width added yet';

  @override
  String get noConfigurableProperties_7421 =>
      'This tool has no configurable properties';

  @override
  String get noConnectionConfig_4521 => 'No connection configuration';

  @override
  String get noCustomTagsMessage_7421 =>
      'No custom tags yet  \nTap the input field above to add a new tag';

  @override
  String get noCustomTags_7281 => 'No custom tags';

  @override
  String get noCut_4821 => 'No cut';

  @override
  String get noDataSkipSync_4821 =>
      'The current reactive system has no data, skipping synchronization';

  @override
  String get noData_6943 => 'No data';

  @override
  String get noEditingVersionSkipSync_4821 =>
      'No version is being edited, skipping data synchronization';

  @override
  String get noEditingVersionSkipSync_7281 =>
      'No version being edited, skipping data sync to version system';

  @override
  String get noEditingVersionToSave_4821 =>
      'No version is being edited, no need to save';

  @override
  String get noExecutionLogs_7421 => 'No execution logs';

  @override
  String get noExecutionRecords_4521 => 'No execution records yet';

  @override
  String get noExportItems_7281 => 'No export items available';

  @override
  String get noExtensionSettingsData_7421 =>
      'No extension settings data available';

  @override
  String get noExtension_7281 => 'No extension';

  @override
  String get noFilterApplied_4821 => 'No filter is currently applied.';

  @override
  String get noFilter_1234 => 'No filter';

  @override
  String get noFilter_4821 => 'No filter';

  @override
  String get noImageDataInClipboard_4821 => 'No image data in clipboard';

  @override
  String get noLayerGroups_4521 => 'No layer groups';

  @override
  String get noLayerSelected_4821 => 'No layer selected';

  @override
  String get noLayersAvailable_4271 => 'No layers available';

  @override
  String get noLayersAvailable_7281 => 'No layers available';

  @override
  String get noLayersBoundWarning_4821 =>
      'No layers are bound to the current legend group';

  @override
  String get noLegendAvailable_4251 => 'No legend available';

  @override
  String get noLegendAvailable_4821 => 'No legend available';

  @override
  String get noLegendGroupBoundToLayerGroup_4821 =>
      'The currently selected layer group has no legend group bound to it';

  @override
  String get noLegendGroupBound_7281 =>
      'The currently selected layer is not bound to a legend group.';

  @override
  String get noLegendGroupInCurrentMap_4821 =>
      'There is no legend group in the current map';

  @override
  String get noLegendGroupSelected_4821 =>
      'The currently selected layer or layer group is not bound to any legend group.';

  @override
  String get noLegendGroup_4521 => 'No legend group';

  @override
  String get noLegendGroupsAvailable_4821 =>
      'No legend groups available to switch';

  @override
  String get noLogsAvailable_7421 => 'No logs available';

  @override
  String get noMapDataToSave_4821 => 'No map data to save';

  @override
  String get noMatchingFiles_4821 => 'No matching files found';

  @override
  String get noMatchingResults_4828 => 'No matching results found';

  @override
  String noNeedComparePathDiff(Object previousVersionId, Object versionId) {
    return 'No need to compare path differences: previousVersionId=$previousVersionId, versionId=$versionId';
  }

  @override
  String get noOnlineUsers_4271 => 'No online users';

  @override
  String get noOnlineUsers_7421 => 'No online users';

  @override
  String get noPreferencesToSave_7281 =>
      'There are no preferences to save currently.';

  @override
  String get noRecentColors_4821 => 'No recent colors';

  @override
  String get noRunningScripts_7421 => 'No scripts are currently running';

  @override
  String get noSavedConfigs_7281 => 'No saved configurations';

  @override
  String noScriptsAvailable_7421(Object type) {
    return 'No $type scripts available';
  }

  @override
  String get noTagsAvailable_7281 => 'No tags available';

  @override
  String get noTagsAvailable_7421 => 'No tags available';

  @override
  String get noTimerAvailable_7281 => 'No timer available';

  @override
  String get noToolSelected_4728 => 'No tool selected';

  @override
  String get noUpdatablePreferences_4821 => 'No updatable preferences';

  @override
  String get noValidImageToExport_4821 => 'No valid images to export';

  @override
  String get noValidImageToExport_7281 => 'No valid images to export';

  @override
  String get noValidMetadataDirectoryFound_5024 =>
      'No directory containing valid metadata.json found';

  @override
  String get noVersionAvailable_7281 => 'No version available';

  @override
  String get noVisibleLayersDisabled_4723 =>
      'No visible layers, drawing tools disabled';

  @override
  String get noWebDAVConfig_5019 =>
      'No available WebDAV configuration, please add configuration in WebDAV management page first';

  @override
  String get noWebDAVConfig_7281 => 'No WebDAV configuration';

  @override
  String get noWebDavConfigAvailable_7281 =>
      'No WebDAV configuration available. Please add a configuration in the WebDAV management page first.';

  @override
  String get noZipFileFoundInDirectory_5035 => 'No ZIP file found in directory';

  @override
  String get no_4287 => 'No';

  @override
  String get no_4821 => 'No';

  @override
  String nonGroupLayersOrderDebug(Object layers) {
    return 'Order of ungrouped layers after separation: $layers';
  }

  @override
  String get none_4821 => 'None';

  @override
  String get none_5729 => 'None';

  @override
  String normalPositionAdjustment(Object adjustedNewIndex) {
    return 'Normal position adjustment: $adjustedNewIndex';
  }

  @override
  String get norwegianNO_4847 => 'Norwegian (Norway)';

  @override
  String get norwegian_4846 => 'Norwegian';

  @override
  String get notLoaded_4821 => 'Not loaded';

  @override
  String get notModified_6843 => 'Not modified';

  @override
  String get notSet_4821 => 'Not set';

  @override
  String get notSet_7281 => 'Not set';

  @override
  String get notSet_7421 => 'Not set';

  @override
  String get notSet_8921 => 'Not set';

  @override
  String get notZipFileError_4821 => 'The selected file is not a ZIP file';

  @override
  String noteBackgroundImageHashRef(Object backgroundImageHash) {
    return 'The note background image contains only a VFS hash reference: $backgroundImageHash';
  }

  @override
  String get noteBackgroundImageHint_4821 =>
      'Hint: The note background image should have been restored to direct data upon loading.';

  @override
  String noteBackgroundImageUploaded(Object length) {
    return 'The note background image has been uploaded and will be saved to the asset system when the map is saved ($length bytes)';
  }

  @override
  String noteBackgroundLoadFailed(Object error) {
    return 'Failed to load note background image (direct data): $error';
  }

  @override
  String noteDebugInfo(Object arg0, Object arg1, Object arg2) {
    return 'Note[$arg0] $arg1: $arg2 drawing elements';
  }

  @override
  String noteDrawingElementLoaded(Object imageHash, Object length) {
    return 'Note drawing element image loaded from asset system, hash: $imageHash ($length bytes)';
  }

  @override
  String noteDrawingElementSaved(Object hash, Object length) {
    return 'The note drawing element image has been saved to the asset system, hash: $hash ($length bytes)';
  }

  @override
  String noteDrawingStats(Object elementCount, Object imageCacheCount) {
    return 'Note drawing: elements=$elementCount, image cache=$imageCacheCount';
  }

  @override
  String get noteElementDeleted_7281 => 'Note element deleted';

  @override
  String get noteElementInspectorEmpty_1589 => 'Note Element Inspector (Empty)';

  @override
  String noteElementInspectorWithCount_7421(Object count) {
    return 'Note Element Inspector ($count elements)';
  }

  @override
  String noteImagePreloadComplete(Object height, Object id, Object width) {
    return 'Note image preload complete: element.id=$id, image size=${width}x$height';
  }

  @override
  String noteImagePreloadFailed_7421(Object elementId, Object error) {
    return 'Note image preload failed: element.id=$elementId, error=$error';
  }

  @override
  String noteImageSelectionDebug_7421(Object value) {
    return 'Note creation image selection: buffer data=$value';
  }

  @override
  String get noteItem_4821 => 'Note';

  @override
  String get noteLayerHint_8421 =>
      'Notes are displayed above layers and legends using a very high rendering order to ensure they always stay on top.';

  @override
  String get noteMovedToTop1234 => 'Note moved to top';

  @override
  String get notePreviewRemoved_7421 => 'Note preview removed';

  @override
  String noteProcessing(
    Object isVisible,
    Object noteIndex,
    Object title,
    Object zIndex,
  ) {
    return 'Processing note: $title(zIndex=$zIndex), index=$noteIndex, visible=$isVisible';
  }

  @override
  String noteQueueDebugPrint(Object noteId, Object queueLength) {
    return 'Note queue rendering: note ID=$noteId, queue items=$queueLength';
  }

  @override
  String noteRendererElementCount(Object count) {
    return 'Note Renderer: Element Count=$count';
  }

  @override
  String get noteTagUpdated_4821 => 'Note element tag updated';

  @override
  String get noteTag_7890 => 'Note';

  @override
  String noteTagsUpdated(Object count) {
    return 'Note tags updated ($count tags)';
  }

  @override
  String get noteTitleHint_4821 => 'Note title';

  @override
  String get note_8901 => 'Note';

  @override
  String get notesTagsCleared_7281 => 'Note tags cleared';

  @override
  String get notificationClicked_4821 =>
      'The persistent notification was clicked';

  @override
  String notificationClosed(Object message) {
    return 'Notification closed: $message';
  }

  @override
  String get notificationSystemTest_4271 => 'Notification system test';

  @override
  String get notificationTestPageTitle_4821 => 'Notification Test';

  @override
  String get notificationUpdated_7281 =>
      '✨ Message updated! Note: animation won\'t replay';

  @override
  String get notificationWillBeUpdated_7281 =>
      '🔄 This notification will be updated (without replaying the animation)';

  @override
  String get notifications_4821 => 'Notification';

  @override
  String get nullContextThemeInfo_4821 =>
      'The context is null, unable to retrieve theme information';

  @override
  String get numberType_9012 => 'Number';

  @override
  String get objectOpacity_4271 => 'Object opacity';

  @override
  String occurrenceTime_4821(Object timestamp) {
    return 'Occurrence time: $timestamp';
  }

  @override
  String get offlineStatus_3087 => 'Offline';

  @override
  String get offlineStatus_5732 => 'Offline';

  @override
  String get offlineStatus_7154 => 'Offline';

  @override
  String get offlineStatus_7845 => 'Offline';

  @override
  String offlineStickyNotePreviewHandled_7421(Object stickyNoteId) {
    return 'User offline, sticky note preview directly processed and added to note $stickyNoteId';
  }

  @override
  String get offline_4821 => 'Offline';

  @override
  String get oldDataCleanedUp_7281 => 'Old data cleanup completed';

  @override
  String get onePerPage_4821 => 'One per page';

  @override
  String get oneSecond_7281 => '1 second';

  @override
  String get onlineStatusInitComplete_4821 =>
      'Online status management initialization completed';

  @override
  String onlineStatusProcessed(Object count) {
    return 'Successfully processed online status list, $count users in total';
  }

  @override
  String get onlineStatus_4821 => 'Online';

  @override
  String onlineUsersCount(Object count) {
    return 'Users ($count)';
  }

  @override
  String get onlineUsers_4271 => 'Online users';

  @override
  String get onlineUsers_4821 => 'Online users';

  @override
  String get onlineUsers_7421 => 'Online users';

  @override
  String get onlyFilesAndFoldersNavigable_7281 =>
      'Only files • folders are navigable';

  @override
  String get opacity => 'Opacity';

  @override
  String get opacityLabel_4821 => 'Opacity';

  @override
  String get opacityLabel_7281 => 'Opacity:';

  @override
  String opacityPercentage(Object percentage) {
    return 'Opacity: $percentage%';
  }

  @override
  String get openEditorMessage_4521 => 'Open editor';

  @override
  String get openFile_7282 => 'Open file';

  @override
  String get openInWindowHint_7281 =>
      'Opening in a window requires importing the window component';

  @override
  String get openInWindowTooltip_4271 => 'Open in window';

  @override
  String get openInWindow_4281 => 'Open in window';

  @override
  String get openInWindow_7281 => 'Open in window';

  @override
  String get openLegendDrawer_4824 => 'Open legend group binding drawer';

  @override
  String get openLegendGroupDrawer_3827 => 'Open legend group binding drawer';

  @override
  String get openLink => 'Open Link';

  @override
  String openLinkFailed_4821(Object e) {
    return 'Failed to open link: $e';
  }

  @override
  String openLinkFailed_7285(Object e) {
    return 'Failed to open link: $e';
  }

  @override
  String get openNextLegendGroup_3826 => 'Open next legend group';

  @override
  String get openPreviousLegendGroup_3825 => 'Open previous legend group';

  @override
  String openRelativePathFailed_7285(Object e) {
    return 'Failed to open relative path link: $e';
  }

  @override
  String get openSourceAcknowledgement_7281 => 'Open Source Acknowledgments';

  @override
  String get openSourceProjectsIntro_4821 =>
      'This project utilizes the following outstanding open-source projects and resources:';

  @override
  String openTextEditorFailed_7281(Object e) {
    return 'Failed to open text editor: $e';
  }

  @override
  String openVideoInWindow(Object vfsPath) {
    return 'Open video in window: $vfsPath';
  }

  @override
  String get openWithTextEditor_7421 => 'Open with text editor';

  @override
  String get openZElementInspector_3858 => 'Open Z Element Inspector';

  @override
  String get openZInspector_4823 => 'Open Z-Level Inspector';

  @override
  String get open_4821 => 'Open';

  @override
  String get open_7281 => 'Open';

  @override
  String get operationCanBeUndone_8245 => 'This operation can be undone.';

  @override
  String get operationCompletedSuccessfully_7281 =>
      'Your operation has been completed successfully';

  @override
  String operationFailedWithError(Object error) {
    return 'Operation failed: $error';
  }

  @override
  String get operationSuccess_4821 => 'Operation successful';

  @override
  String get operation_4821 => 'Operation';

  @override
  String get originalJsonMissing_4821 =>
      'The original title JSON file does not exist, attempting sanitized title';

  @override
  String get otherGroupSelectedPaths_7425 => 'Other group selected paths';

  @override
  String otherLayersDebug_7421(Object layers) {
    return '- Other layers: $layers';
  }

  @override
  String get otherPermissions_7281 => 'Other permissions';

  @override
  String get otherSelectedGroup_4821 => 'Other group selected';

  @override
  String get otherSettings_7421 => 'Other Settings';

  @override
  String get overlayText_4821 => 'Overlay';

  @override
  String get overwrite_4929 => 'Overwrite';

  @override
  String get ownSelectedHeader_5421 => 'Own selection';

  @override
  String get ownSelectedPaths_7425 => 'Self-selected paths';

  @override
  String get packageManagement => 'Package Management';

  @override
  String get pageConfiguration => 'Page Configuration';

  @override
  String get pageLayout_7281 => 'Page Layout';

  @override
  String get pageModeDescription_4821 =>
      'Full-screen Markdown display, ideal for in-depth reading';

  @override
  String get pageModeTitle_4821 => '2. Page Mode';

  @override
  String pageNotFound(Object uri) {
    return 'Page not found: $uri';
  }

  @override
  String get pageOrientation_3632 => 'Orientation';

  @override
  String get panelAutoClose_4821 => 'Panel auto-close';

  @override
  String get panelCollapseStatus_4821 => 'Panel collapse status';

  @override
  String panelDefaultState_7428(Object state) {
    return 'Panel default $state state';
  }

  @override
  String get panelStateSavedOnExit_4821 => 'Panel state saved on exit';

  @override
  String get panelStatusChanged_7281 => 'Panel status has changed';

  @override
  String panelUpdateFailed_7285(Object error) {
    return 'Failed to update panel status: $error';
  }

  @override
  String get paperSettings_4821 => 'Paper Settings';

  @override
  String paperSizeAndOrientation(Object orientation, Object paperSize) {
    return 'Paper: $paperSize ($orientation)';
  }

  @override
  String get paperSize_7281 => 'Paper size';

  @override
  String get parameters_4821 => 'Parameters';

  @override
  String parseAttributesLog_7281(Object attributes) {
    return 'Parsing attributes - $attributes';
  }

  @override
  String parseExtensionSettingsFailed(Object error) {
    return 'Failed to parse extension settings JSON: $error';
  }

  @override
  String parseMessageFailed_7285(Object e) {
    return 'Failed to parse message: $e';
  }

  @override
  String parseNoteDataFailed(Object error, Object filePath) {
    return 'Failed to parse note data [$filePath]: $error';
  }

  @override
  String parseNoteDataFailed_7284(Object e) {
    return 'Failed to parse note data: $e';
  }

  @override
  String parseParamFailed(Object e, Object line) {
    return 'Failed to parse parameter definition: $line, error: $e';
  }

  @override
  String parseUserLayoutFailed(Object e, Object userId) {
    return 'Failed to parse layout_data for user $userId: $e';
  }

  @override
  String get passwordKeepEmpty_1234 =>
      'Password (leave empty to keep unchanged)';

  @override
  String get password_5678 => 'Password';

  @override
  String pasteCompleteSuccessfully(Object successCount) {
    return 'Paste completed, successfully processed $successCount items';
  }

  @override
  String pasteFailed_7285(Object e) {
    return 'Paste failed: $e';
  }

  @override
  String pasteImageFailed_4821(Object e) {
    return 'Failed to paste image from clipboard: $e';
  }

  @override
  String get pasteJsonConfig_7281 =>
      'Please paste the configuration JSON data:';

  @override
  String get paste_3833 => 'Paste';

  @override
  String get paste_4821 => 'Paste';

  @override
  String get pastedMessage_4821 => 'Pasted';

  @override
  String get pasted_4822 => 'Pasted';

  @override
  String pathCheckFailed(Object e, Object remotePath) {
    return 'Path check failed: $remotePath - $e';
  }

  @override
  String get pathDiffAnalysisComplete_7281 =>
      'Path difference analysis completed:';

  @override
  String pathExists_4821(Object fullRemotePath) {
    return 'Path exists: $fullRemotePath';
  }

  @override
  String pathIssuesDetected_7281(Object count) {
    return '$count path issues detected, please expand the list to fix them';
  }

  @override
  String get pathLabel_4821 => 'Path';

  @override
  String get pathLabel_5421 => 'Path';

  @override
  String get pathLabel_7421 => 'Path';

  @override
  String pathLoadedComplete_728(Object path) {
    return 'Path loaded successfully: $path';
  }

  @override
  String pathMismatch_7284(Object folderPath, Object path) {
    return 'Path mismatch: path=\"$path\", does not start with \"$folderPath/';
  }

  @override
  String get pathNoChineseChars_4821 =>
      'The storage path cannot contain Chinese characters';

  @override
  String pathSelectionFailed_7421(Object e) {
    return 'Path selection failed: $e';
  }

  @override
  String pathStillInUse(Object path) {
    return 'The path is still in use by other legend groups, skipping cleanup: $path';
  }

  @override
  String get path_4826 => 'Path';

  @override
  String get patternDensity_7281 => 'Pattern Density';

  @override
  String get pauseButton_4821 => 'Pause';

  @override
  String get pauseFailed_7281 => 'Pause failed';

  @override
  String pauseFailed_7285(Object e) {
    return 'Pause failed: $e';
  }

  @override
  String get pauseOperationTooltip_7281 => 'Pause operation';

  @override
  String pauseTimerFailed(Object e) {
    return 'Failed to pause timer: $e';
  }

  @override
  String pauseTimerName(Object name) {
    return 'Pause $name';
  }

  @override
  String pdfExportFailed_7281(Object e) {
    return 'PDF export failed: $e';
  }

  @override
  String get pdfExportSuccess_4821 => 'PDF exported successfully';

  @override
  String pdfGenerationFailed_7281(Object e) {
    return 'Failed to generate PDF document: $e';
  }

  @override
  String pdfPreviewFailed_7285(Object e) {
    return 'PDF preview generation failed: $e';
  }

  @override
  String get pdfPreview_4521 => 'PDF Preview';

  @override
  String get pdfPrintDialogOpened_4821 => 'PDF print dialog has been opened';

  @override
  String get pdfPrintDialogOpened_7281 => 'PDF print dialog has been opened';

  @override
  String get pdfPrintFailed_4821 => 'PDF printing failed, please try again';

  @override
  String pdfPrintFailed_7285(Object e) {
    return 'PDF printing failed: $e';
  }

  @override
  String pdfSavedToPath_7281(Object path) {
    return 'PDF saved to: $path';
  }

  @override
  String get penTool_1234 => 'Pen';

  @override
  String get performanceOptimizationInfo_7281 =>
      '🎯 Performance Optimization Info:';

  @override
  String get performanceSettings_7281 => 'Performance Settings';

  @override
  String get permissionConflict_4830 => 'Permission conflict';

  @override
  String get permissionDenied_4824 => 'Permission denied';

  @override
  String get permissionDetails_7281 => 'Permission Details';

  @override
  String permissionFailed_7284(Object e) {
    return 'Permission management failed: $e';
  }

  @override
  String get permissionManagement_4821 => 'Permission Management';

  @override
  String get permissionManagement_7421 => 'Permission Management';

  @override
  String get permissionSaved_7421 => 'Permissions saved';

  @override
  String get permissionSettings_7281 => 'Permission Settings';

  @override
  String get permissionUpdated_4821 => 'Permissions updated';

  @override
  String get permissionUpdated_7281 => 'Permissions updated';

  @override
  String permissionViewError_4821(Object error) {
    return 'Failed to view permissions: $error';
  }

  @override
  String get persistentNotificationDemo_7281 =>
      '🔥 Persistent Notification Demo (SnackBar Replacement)';

  @override
  String get personalSettingsManagement_4821 =>
      'Manage personal settings such as themes, map editor, and interface layout';

  @override
  String perspectiveBufferFactorDebug(Object factor) {
    return '- Perspective buffer adjustment factor: ${factor}x';
  }

  @override
  String perspectiveBufferFactorLabel(Object factor) {
    return 'Perspective buffer adjustment factor: ${factor}x';
  }

  @override
  String perspectiveStrengthDebug(Object value) {
    return '- Current perspective strength: $value (0~1)';
  }

  @override
  String pinyinConversionFailed_4821(Object e) {
    return 'Pinyin conversion failed: $e';
  }

  @override
  String pitchLog_7287(Object pitch) {
    return ', pitch: $pitch';
  }

  @override
  String get pixelPenTool_1245 => 'Pixel Pen';

  @override
  String get pixelPen_2079 => 'Pixel Pen';

  @override
  String get pixelPen_4829 => 'Pixel Pen';

  @override
  String get planTag_4567 => 'Plan';

  @override
  String get plan_6789 => 'Plan';

  @override
  String platformCopyFailed_7285(Object e) {
    return 'Platform-specific copy implementation failed: $e';
  }

  @override
  String get playButton_4821 => 'Play';

  @override
  String get playOurAudioPrompt_4821 => 'Would you like to play our audio';

  @override
  String playPauseFailed_4821(Object e) {
    return 'Play/Pause operation failed: $e';
  }

  @override
  String playPauseFailed_7285(Object e) {
    return 'Play/Pause operation failed: $e';
  }

  @override
  String get playQueueEmpty_4821 => 'Play queue is empty';

  @override
  String get playQueueEmpty_7281 => 'Play queue is empty';

  @override
  String playbackFailed_4821(Object e) {
    return 'Playback failed - $e';
  }

  @override
  String playbackFailed_7285(Object e) {
    return 'Playback failed: $e';
  }

  @override
  String playbackModeSetTo(Object playbackMode) {
    return 'Playback mode set to $playbackMode';
  }

  @override
  String get playbackMode_1234 => 'Playback mode';

  @override
  String playbackProgress(Object currentPosition, Object totalDuration) {
    return 'Playback progress: $currentPosition/$totalDuration';
  }

  @override
  String playbackRateSetTo(Object _playbackRate) {
    return 'Playback speed set to ${_playbackRate}x';
  }

  @override
  String get playbackSpeed_4821 => 'Playback speed';

  @override
  String get playbackSpeed_7421 => 'Playback speed';

  @override
  String get playbackStatus_7421 => 'Playback status';

  @override
  String playerConnectionFailed(Object e) {
    return 'Failed to connect to player: $e';
  }

  @override
  String playerConnectionFailed_7285(Object e) {
    return '🎵 Failed to connect to player: $e';
  }

  @override
  String playerInitFailed(Object e) {
    return 'Player initialization failed: $e';
  }

  @override
  String playerInitFailed_4821(Object e) {
    return 'Failed to initialize player: $e';
  }

  @override
  String get playlistEmpty_7281 => 'Playlist is empty';

  @override
  String get playlistIndexOutOfRange_7281 => 'Playlist index out of range';

  @override
  String playlistLength(Object length) {
    return 'Playlist length: $length';
  }

  @override
  String get playlistTitle_4821 => 'Playlist';

  @override
  String get playlistTooltip_4271 => 'Playlist';

  @override
  String get pleaseEnterExportName_4961 => 'Please enter export name';

  @override
  String get pleaseSelectDatabaseAndCollection_4821 =>
      'Please select database and collection';

  @override
  String get pleaseSelectSourcePath_4958 => 'Please select source path';

  @override
  String pointsCount(Object count) {
    return 'Points: $count';
  }

  @override
  String get polishPL_4851 => 'Polish (Poland)';

  @override
  String get polish_4850 => 'Polish';

  @override
  String get portraitOrientation_1234 => 'Portrait';

  @override
  String get portugueseBrazil_4834 => 'Portuguese (Brazil)';

  @override
  String get portuguesePT_4888 => 'Portuguese (Portugal)';

  @override
  String get portuguese_4833 => 'Portuguese';

  @override
  String positionCoordinates_7421(Object dx, Object dy) {
    return 'Position: ($dx, $dy)';
  }

  @override
  String get powershellReadError_4821 =>
      'Failed to read Windows PowerShell or no image in clipboard';

  @override
  String preferencesInitialized(Object displayName) {
    return 'User preferences initialized: $displayName';
  }

  @override
  String get preparingDownload_5033 => 'Preparing download...';

  @override
  String get preparingExport_7281 => 'Preparing export...';

  @override
  String get preparingFileMappingPreview_4821 =>
      'Preparing file mapping preview...';

  @override
  String get preparingPreview_5040 => 'Preparing preview...';

  @override
  String get preparingToPrint_7281 => 'Preparing to print...';

  @override
  String get preprocessAudioContent_7281 =>
      '🎵 _loadMarkdownFile: Preprocessing audio content';

  @override
  String get preprocessHtmlContent_7281 =>
      '🔧 _loadMarkdownFile: Preprocessing HTML content';

  @override
  String get preprocessLatexContent_7281 =>
      '🔧 _loadMarkdownFile: Preprocessing LaTeX content';

  @override
  String get preprocessVideoContent_7281 =>
      '🎥 _loadMarkdownFile: Preprocessing video content';

  @override
  String get pressKeyCombination_4821 => 'Please press the key combination...';

  @override
  String get pressShortcutFirst_4821 =>
      'Please press the shortcut combination first';

  @override
  String previewGenerationFailed_7421(Object e) {
    return 'Preview generation failed: $e';
  }

  @override
  String previewImmediatelyProcessedAndAddedToLayer(Object targetLayerId) {
    return 'Preview has been processed immediately and added to layer $targetLayerId';
  }

  @override
  String get previewMode_4822 => 'Preview Mode';

  @override
  String previewQueueCleared(Object stickyNoteId, Object totalItems) {
    return '[PreviewQueueManager] Queue for sticky note $stickyNoteId has been cleared, all $totalItems items processed';
  }

  @override
  String get previewQueueCleared_7281 => 'Preview queue cleared';

  @override
  String get previewQueueCleared_7421 =>
      'The note preview queue has been cleared';

  @override
  String previewQueueItemProcessed_7281(
    Object currentItem,
    Object itemId,
    Object stickyNoteId,
    Object totalItems,
  ) {
    return '[PreviewQueueManager] Sticky note $stickyNoteId queue item $currentItem/$totalItems processed: $itemId';
  }

  @override
  String previewQueueLockFailed(Object queueLength, Object stickyNoteId) {
    return '[PreviewQueueManager] Failed to lock sticky note $stickyNoteId, preview has been added to queue. Current queue length: $queueLength';
  }

  @override
  String previewQueueProcessed(Object itemId, Object layerId, Object zIndex) {
    return '[PreviewQueueManager] Preview in layer $layerId queue processed: $itemId, z-index: $zIndex';
  }

  @override
  String get previewRemoved_7425 => 'Preview removed';

  @override
  String previewSubmitted_7285(Object itemId) {
    return 'Preview submitted: $itemId';
  }

  @override
  String get previousLayerGroup_4824 => 'Previous layer group';

  @override
  String get previousLayer_4822 => 'Previous layer';

  @override
  String get previousLegendGroup_4822 => 'Previous legend group';

  @override
  String get previousTrack_7281 => 'Previous track';

  @override
  String get previousVersion_4822 => 'Previous version';

  @override
  String get primaryColor => 'Primary color';

  @override
  String get primaryColor_7285 => 'Primary color';

  @override
  String get printConfigInfo => 'Print configuration info';

  @override
  String get printLabel_4271 => 'Print';

  @override
  String get printPdf_1234 => 'Print PDF';

  @override
  String get prioritizeLayerGroupEnd_7281 =>
      '=== _prioritizeLayerGroup end ===';

  @override
  String get prioritizeLayerGroupStart_7281 =>
      '=== _prioritizeLayerGroup Start ===';

  @override
  String get priorityLayerGroupCombination_7281 =>
      'Priority display of layer and layer group combinations';

  @override
  String priorityLayerGroupDisplay(Object groupNames) {
    return 'Priority display layer group: $groupNames';
  }

  @override
  String priorityLayersDebug_7421(Object layers) {
    return '- Priority layers: $layers';
  }

  @override
  String privateKeyDecryptionFailed_4821(Object e) {
    return 'Failed to decrypt with private key: $e';
  }

  @override
  String privateKeyDeleted_7281(Object privateKeyId) {
    return 'Private key deleted: $privateKeyId';
  }

  @override
  String privateKeyFetchFailed(Object e) {
    return 'Failed to fetch private key: $e';
  }

  @override
  String privateKeyNotFound_7281(Object privateKeyId) {
    return 'Private key not found: $privateKeyId';
  }

  @override
  String privateKeyNotFound_7285(Object privateKeyId) {
    return 'Private key not found: $privateKeyId';
  }

  @override
  String privateKeyObtainedSuccessfully(Object privateKeyId) {
    return 'Private key obtained successfully: $privateKeyId';
  }

  @override
  String privateKeyRemovedLog(Object platform, Object privateKeyId) {
    return 'Private key removed from SharedPreferences $platform: $privateKeyId';
  }

  @override
  String privateKeyRetrievedSuccessfully_7281(
    Object platform,
    Object privateKeyId,
  ) {
    return 'Private key retrieved successfully from SharedPreferences $platform: $privateKeyId';
  }

  @override
  String privateKeySignFailed_7285(Object e) {
    return 'Failed to sign with private key: $e';
  }

  @override
  String privateKeyStoredMessage(Object platform, Object privateKeyId) {
    return 'Private key has been stored in SharedPreferences $platform: $privateKeyId';
  }

  @override
  String privateKeyStoredSafely_4821(Object privateKeyId) {
    return 'Private key securely stored: $privateKeyId';
  }

  @override
  String get problem_0123 => 'Problem';

  @override
  String get processFolderMappingFailed_5015 =>
      'Failed to process folder mapping';

  @override
  String get processZipFileFailed_5042 => 'Failed to process ZIP file';

  @override
  String get processingExternalResourceFile_4987 =>
      'Processing external resource file...';

  @override
  String get processingFlowDescription_4982 =>
      'The system will create temporary folders in VFS fs collection for processing';

  @override
  String get processingFlow_4981 => 'Processing Flow';

  @override
  String processingQueueElement_7421(Object elementId, Object layerId) {
    return 'Processing queue element: $elementId added to layer: $layerId';
  }

  @override
  String get processingRequired_4821 => 'Processing required';

  @override
  String get processingZipFile_5038 => 'Processing ZIP file...';

  @override
  String get processing_4972 => 'Processing...';

  @override
  String get processing_5421 => 'Processing...';

  @override
  String get profileNameLabel_4821 => 'Profile name';

  @override
  String get programWorking_1234 => 'Program is working';

  @override
  String progressBarDragFail_4821(Object e) {
    return 'Failed to drag and jump on progress bar: $e';
  }

  @override
  String progressBarDraggedTo(Object currentPosition, Object totalDuration) {
    return '🎵 Progress bar dragged to: $currentPosition / $totalDuration';
  }

  @override
  String get progressNotification_4271 => 'Progress Notification';

  @override
  String get progressiveWebApp => 'Progressive Web App';

  @override
  String get projectCopied_4821 => 'Project copied';

  @override
  String get projectDeleted_7281 => 'Project deleted';

  @override
  String get projectDocumentation_4911 => 'Project Documentation';

  @override
  String projectItem(Object index) {
    return 'Project $index';
  }

  @override
  String get projectLinksSection_4908 => 'Project Links';

  @override
  String get propertiesPanel_6789 => 'Properties Panel';

  @override
  String get properties_4281 => 'Properties';

  @override
  String get properties_4821 => 'Properties';

  @override
  String get publicKeyConversionComplete_4821 =>
      'Public key format conversion completed';

  @override
  String publicKeyConversionFailed_7285(Object e) {
    return 'Public key format conversion failed: $e';
  }

  @override
  String get publicKeyFormatConversionSuccess_7281 =>
      'Public key format conversion successful: RSA PUBLIC KEY → PUBLIC KEY';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get pushNotifications_4821 => 'Push notifications';

  @override
  String get quickCreate_7421 => 'Quick Create';

  @override
  String get quickSelectLayerCategory_4821 => 'Quick Select (Layer)';

  @override
  String get quickSelectLayerGroup => 'Quick Select (Layer Group)';

  @override
  String get quickTest_7421 => 'Quick Test';

  @override
  String get r6OperatorSvgTest_4271 => 'R6 Operator SVG Test';

  @override
  String get r6OperatorsAssetsDescription_4821 =>
      'Rainbow Six Siege operator avatars and icon assets';

  @override
  String get r6OperatorsAssetsSubtitle_7539 =>
      'Operator assets provided by the marcopixel/r6operators repository';

  @override
  String get radialGestureDemoTitle_4721 => 'Radial Gesture Menu Demo';

  @override
  String get radialMenuInstructions_7281 =>
      '1. Press and hold the middle button or two fingers on the touchpad to bring up the menu  \n2. Drag to a menu item to automatically enter the submenu  \n3. Drag back to the center area to return to the main menu  \n4. Release the mouse/finger to execute the selected action  \n5. Enable debug mode to view connection and angle information';

  @override
  String get radianUnit_7421 => 'Radian';

  @override
  String radianValue(Object value) {
    return 'Radian: $value';
  }

  @override
  String get randomPlay_4271 => 'Shuffle';

  @override
  String rawResponseContent(Object responseBody) {
    return 'Raw response content: $responseBody';
  }

  @override
  String get readDirectoryContentFailed_5023 =>
      'Failed to read directory content';

  @override
  String get readFileFailed_4985 => 'Failed to read file';

  @override
  String get readOnlyMode_4821 => 'Read-only mode';

  @override
  String get readOnlyMode_5421 => 'Read-only mode';

  @override
  String get readOnlyMode_6732 => 'Read-only mode';

  @override
  String get readOnlyMode_7421 => 'Read-only mode';

  @override
  String get readPermission_4821 => 'Read';

  @override
  String get readPermission_5421 => 'Read';

  @override
  String get readWebDAVDirectoryFailed_5026 =>
      'Failed to read WebDAV directory';

  @override
  String get readingImageFromClipboard_4721 =>
      'Reading image from clipboard...';

  @override
  String readingJsonFile_7421(Object path) {
    return 'Reading JSON file: $path';
  }

  @override
  String get readingWebDAVDirectory_5020 => 'Reading WebDAV directory...';

  @override
  String get reapplyThemeFilter_7281 => 'Reapply theme filter';

  @override
  String get rearrangedOrder_4281 => 'Rearranged display order:';

  @override
  String receivedMessage(Object data, Object type) {
    return 'Received: $type - $data';
  }

  @override
  String get recentColors => 'Recently used colors';

  @override
  String get recentColors_7281 => 'Recent colors';

  @override
  String get recentExecutionRecords_4821 => 'Recent Execution Records';

  @override
  String get recentlyUsedColors_4821 => 'Recently used colors';

  @override
  String get recentlyUsed_7421 => 'Recently Used';

  @override
  String get reconnecting_7845 => 'Reconnecting';

  @override
  String get reconnecting_8265 => 'Reconnecting';

  @override
  String get rectangle => 'Rectangle';

  @override
  String get rectangleLabel_4521 => 'Rectangle';

  @override
  String recursivelyDeletedOldAssets(Object assetsPath) {
    return 'The old assets directory and all its contents have been recursively deleted: $assetsPath';
  }

  @override
  String recursivelyDeletedOldDataDir(Object dataPath) {
    return 'The old data directory and all its contents have been recursively deleted: $dataPath';
  }

  @override
  String get redoOperation_7421 => 'Perform redo operation';

  @override
  String get redoWithReactiveSystem_4821 => 'Redo with reactive system';

  @override
  String get redo_3830 => 'Redo';

  @override
  String get redo_4823 => 'Redo';

  @override
  String get redo_7281 => 'Redo';

  @override
  String get reduceSpacingForSmallScreen_7281 =>
      'Reduce element spacing for small screens';

  @override
  String get referenceLayer_1234 => 'Reference Layer';

  @override
  String get referenceTag_1235 => 'Reference';

  @override
  String get refreshButton_7421 => 'Refresh';

  @override
  String refreshConfigFailed_5421(Object e) {
    return 'Failed to refresh active configuration: $e';
  }

  @override
  String refreshConfigFailed_7284(Object e) {
    return 'Failed to refresh configuration list: $e';
  }

  @override
  String get refreshDirectoryTree_7281 => 'Refresh directory tree';

  @override
  String get refreshFileList_4821 => 'Refresh file list';

  @override
  String get refreshLabel_7421 => 'Refresh';

  @override
  String get refreshOperation_7284 => 'Refresh operation';

  @override
  String get refreshStatus_4821 => 'Refresh status';

  @override
  String get refreshTooltip_7281 => 'Refresh';

  @override
  String get refresh_4821 => 'Refresh';

  @override
  String get refresh_4822 => 'Refresh';

  @override
  String get refresh_4976 => 'Refresh';

  @override
  String get releaseMapEditorAdapter_4821 =>
      'Release map editor integration adapter resources';

  @override
  String get releaseMapEditorResources_7281 =>
      'Release map editor responsive system resources';

  @override
  String get releaseMouseToCompleteMove_7281 =>
      '• Release the mouse to complete the move';

  @override
  String get releaseResourceManager_4821 =>
      'Release new responsive script manager resources';

  @override
  String get releaseScriptEngineResources_4821 =>
      'Release new reactive script engine resources';

  @override
  String get releaseToAddLegend_4821 =>
      'Release to add legend to this location';

  @override
  String get reloadTooltip_7281 => 'Reload';

  @override
  String remainingAudiosCount(Object count) {
    return '... $count audios remaining';
  }

  @override
  String remainingConflictsToResolve(Object remainingConflicts) {
    return 'There are $remainingConflicts conflicts remaining to resolve';
  }

  @override
  String get remainingLegendBlocked_4821 => 'Remaining legend blocked';

  @override
  String get remarkTag_7890 => 'Remark';

  @override
  String get rememberMaximizeState_4821 => 'Remember maximize state';

  @override
  String get reminder_7890 => 'Reminder';

  @override
  String get remoteConflictError_7285 => 'Failed to resolve remote conflict';

  @override
  String remoteDataProcessingFailed_7421(Object error) {
    return 'Failed to process remote data: $error';
  }

  @override
  String get remoteElementLockFailure_4821 =>
      'Failed to process remote element lock';

  @override
  String get remotePointerError_4821 => 'Failed to process remote user pointer';

  @override
  String get remoteUserJoinFailure_4821 =>
      'Failed to process remote user joining';

  @override
  String get remoteUserLeaveError_4728 =>
      'Failed to handle remote user departure';

  @override
  String get remoteUserSelectionFailed_7421 =>
      'Failed to process remote user selection';

  @override
  String get remoteUser_4521 => 'Remote user';

  @override
  String get removeAvatar_4271 => 'Remove avatar';

  @override
  String get removeBackgroundImage_4271 => 'Remove background image';

  @override
  String removeCustomColorFailed_7421(Object error) {
    return 'Failed to remove custom color: $error';
  }

  @override
  String removeCustomTagFailed_7421(Object error) {
    return 'Failed to remove custom tag: $error';
  }

  @override
  String removeFailedMessage_7421(Object error) {
    return 'Removal failed: $error';
  }

  @override
  String get removeImage_7421 => 'Remove image';

  @override
  String get remove_4821 => 'Remove';

  @override
  String get removedFromQueue_7421 => 'Removed from queue';

  @override
  String removedPathsCount_7421(Object count) {
    return 'Removed paths: $count';
  }

  @override
  String get renameFailed_4821 => 'Rename failed';

  @override
  String get renameFailed_4845 => 'Rename failed';

  @override
  String renameFailed_7284(Object e) {
    return 'Rename failed: $e';
  }

  @override
  String renameFailed_7285(Object e) {
    return 'Rename failed: $e';
  }

  @override
  String renameFileOrFolder_7421(String isDirectory) {
    String _temp0 = intl.Intl.selectLogic(isDirectory, {
      'true': 'Rename Folder',
      'false': 'Rename File',
      'other': 'Rename',
    });
    return '$_temp0';
  }

  @override
  String renameFolderFailed(Object error, Object newPath, Object oldPath) {
    return 'Failed to rename folder [$oldPath -> $newPath]: $error';
  }

  @override
  String get renameFolder_4271 => 'Rename folder';

  @override
  String get renameFolder_4841 => 'Rename Folder';

  @override
  String get renameGroup_4821 => 'Rename Group';

  @override
  String get renameLayerGroup_7539 => 'Rename layer group';

  @override
  String renameMapFailed(Object error, Object newTitle, Object oldTitle) {
    return 'Failed to rename map [$oldTitle -> $newTitle]: $error';
  }

  @override
  String get renameMap_4846 => 'Rename Map';

  @override
  String get renameSuccess_4821 => 'Rename successful';

  @override
  String get rename_4821 => 'Rename';

  @override
  String get rename_4852 => 'Rename';

  @override
  String get rename_7421 => 'Rename';

  @override
  String renamedDemoMap(Object timestamp) {
    return 'Demo Map - Renamed $timestamp';
  }

  @override
  String get renamedSuccessfully_7281 => 'Renamed successfully';

  @override
  String get renderBoxWarning_4721 =>
      'Warning: Unable to obtain RenderBox, using default position for drag handling';

  @override
  String get rendererAudioUuidMap_4821 => 'Renderer: _audioUuidMap';

  @override
  String reorderLayerFailed(Object error) {
    return 'Failed to reorder layer: $error';
  }

  @override
  String reorderLayerLog(Object newIndex, Object oldIndex) {
    return 'Reorder layer: oldIndex=$oldIndex, newIndex=$newIndex';
  }

  @override
  String get reorderLayersCall_7284 => '=== reorderLayersReactive call ===';

  @override
  String get reorderLayersComplete_7281 =>
      '=== Reorder Layers in Group Reactive Completed ===';

  @override
  String get reorderLayersInGroupReactiveCall_7281 =>
      '=== reorderLayersInGroupReactive call ===';

  @override
  String reorderNoteLog(Object newIndex, Object oldIndex) {
    return 'Responsive Version Manager: Reordered note $oldIndex -> $newIndex';
  }

  @override
  String reorderNotesFailed(Object e) {
    return 'Failed to reorder notes: $e';
  }

  @override
  String reorderNotesFailed_4821(Object e) {
    return 'Failed to reorder notes: $e';
  }

  @override
  String reorderStickyNote(Object newIndex, Object oldIndex) {
    return 'Reorder sticky note: $oldIndex -> $newIndex';
  }

  @override
  String reorderStickyNotesCount(Object count) {
    return 'Reorder sticky notes by dragging, count: $count';
  }

  @override
  String get replaceExistingFileWithNew_7281 =>
      'Replace existing file with new file';

  @override
  String get reportBugOrFeatureSuggestion_7281 =>
      'Report a Bug or Suggest a Feature';

  @override
  String requestOnlineStatusFailed(Object error) {
    return 'Failed to request online status list: $error';
  }

  @override
  String requestUrl_4821(Object url) {
    return 'Request URL: $url';
  }

  @override
  String requiredParamError_7421(Object name) {
    return '$name is a required parameter';
  }

  @override
  String requiredParameter(Object name) {
    return '$name is a required parameter';
  }

  @override
  String get reservedNameError_4821 => 'Cannot use a system reserved name';

  @override
  String get resetAllSettings_4821 => 'Reset all settings';

  @override
  String get resetButton_4521 => 'Reset';

  @override
  String get resetButton_5421 => 'Reset';

  @override
  String get resetButton_7421 => 'Reset';

  @override
  String resetFailedWithError(Object error) {
    return 'Reset failed: $error';
  }

  @override
  String get resetLayoutSettings_4271 => 'Reset layout settings';

  @override
  String get resetMapData_7421 => 'Reset map data';

  @override
  String resetMigrationFailed_4821(Object e) {
    return 'Failed to reset migration status: $e';
  }

  @override
  String get resetReactiveScriptEngine_4821 =>
      'Reset new reactive script engine';

  @override
  String get resetScriptEngine_7281 => 'Reset script engine';

  @override
  String get resetSettings => 'Reset to default';

  @override
  String resetSettingsFailed_7421(Object error) {
    return 'Failed to reset settings: $error';
  }

  @override
  String get resetShortcutsConfirmation_4821 =>
      'Are you sure you want to reset all shortcuts to default settings? This action will overwrite your custom shortcut configurations.';

  @override
  String resetTimerFailed(Object error) {
    return 'Failed to reset timer: $error';
  }

  @override
  String resetTimerName(Object name) {
    return 'Reset $name';
  }

  @override
  String get resetToAutoSettings_4821 => 'Reset to Auto Settings';

  @override
  String get resetToDefault_4271 => 'Reset to default';

  @override
  String get resetToDefault_4855 => 'Reset to Default (1.0)';

  @override
  String get resetToolSettingsConfirmation_4821 =>
      'Are you sure you want to reset the tool settings to default? This action cannot be undone.';

  @override
  String get resetToolSettings_4271 => 'Reset tool settings';

  @override
  String get resetTtsSettings_4271 => 'Reset TTS Settings';

  @override
  String resetVersionLegendSelection(Object legendGroupId, Object versionId) {
    return 'Reset selection for version $versionId legend group $legendGroupId';
  }

  @override
  String resetWindowSizeFailed_4829(Object e) {
    return 'Failed to reset window size: $e';
  }

  @override
  String get resetWindowSize_4271 => 'Reset window size';

  @override
  String get resetZoomTooltip_4821 => 'Reset zoom';

  @override
  String get residentNotificationClosed_7281 =>
      'Resident notification was closed';

  @override
  String get resourceManagement => 'Resource Management';

  @override
  String get resourcePackInfo_4950 => 'Resource Pack Information';

  @override
  String get resourcePackName_4933 => 'Resource Pack Name *';

  @override
  String get resourcePackageTag_4826 => 'Resource package';

  @override
  String get resourceReleaseComplete_4821 =>
      'GlobalCollaborationService resource release completed';

  @override
  String resourceReleaseFailed_4821(Object e) {
    return 'GlobalCollaborationService resource release failed: $e';
  }

  @override
  String get resourceReleased_4821 =>
      'Online status management resources have been released';

  @override
  String responsiveDataLayerOrder(Object layers) {
    return 'Responsive data layer order: $layers';
  }

  @override
  String responsiveLayerManagerReorder(Object newIndex, Object oldIndex) {
    return 'Responsive Layout Manager: Reorder layer $oldIndex -> $newIndex';
  }

  @override
  String responsiveNoteManagerDeleteNote_7421(Object noteId) {
    return 'Responsive Note Manager: Delete note $noteId';
  }

  @override
  String responsiveNoteManager_7281(Object count) {
    return 'Responsive Note Manager: Drag to reorder notes, count: $count';
  }

  @override
  String get responsiveScriptDescription_4521 =>
      'The responsive script automatically adapts to map data changes, ensuring real-time data consistency.';

  @override
  String get responsiveScriptManagerAccessMapData_4821 =>
      'The new responsive script manager automatically accesses map data via MapDataBloc';

  @override
  String responsiveSystemAddLayerFailed(Object e) {
    return 'Failed to add layer to responsive system: $e';
  }

  @override
  String responsiveSystemDeleteFailed_4821(Object e) {
    return 'Failed to delete element in responsive system: $e';
  }

  @override
  String responsiveSystemDeleteLayerFailed(Object e) {
    return 'Responsive system failed to delete layer: $e';
  }

  @override
  String responsiveSystemDeleteLegendGroupFailed(Object e) {
    return 'Responsive system failed to delete legend group: $e';
  }

  @override
  String responsiveSystemDeleteNoteFailed(Object e) {
    return 'Failed to delete note element in responsive system: $e';
  }

  @override
  String responsiveSystemGroupReorderFailed_4821(Object e) {
    return 'Failed to reorder layers within responsive system group: $e';
  }

  @override
  String get responsiveSystemInitialized_7281 =>
      'Responsive system initialization completed';

  @override
  String get responsiveSystemInitialized_7421 =>
      'Responsive system initialization completed';

  @override
  String responsiveSystemRedoFailed_7421(Object e) {
    return 'Responsive system redo failed: $e';
  }

  @override
  String responsiveSystemReorderFailed(Object e) {
    return 'Responsive system failed to reorder layers: $e';
  }

  @override
  String responsiveSystemUndoFailed_7421(Object e) {
    return 'Responsive system undo failed: $e';
  }

  @override
  String responsiveSystemUpdateFailed_5421(Object e) {
    return 'Responsive system failed to update element: $e';
  }

  @override
  String responsiveSystemUpdateFailed_7285(Object e) {
    return 'Responsive system update legend group failed: $e';
  }

  @override
  String responsiveVersionInitFailed(Object e) {
    return 'Responsive version management initialization failed: $e';
  }

  @override
  String get responsiveVersionManagerAdapterReleased_7421 =>
      'Responsive version manager adapter has released resources';

  @override
  String responsiveVersionManagerAddLayer(Object name) {
    return 'Responsive Version Manager: Add Layer $name';
  }

  @override
  String responsiveVersionManagerAddLegendGroup_7421(Object name) {
    return 'Responsive Version Manager: Add Legend Group $name';
  }

  @override
  String responsiveVersionManagerAddNote(Object title) {
    return 'Responsive Version Manager: Add Note $title';
  }

  @override
  String responsiveVersionManagerBatchUpdate(Object count) {
    return 'Responsive Version Manager: Batch update layers, count: $count';
  }

  @override
  String get responsiveVersionManagerCreated_4821 =>
      'Responsive version manager has been created';

  @override
  String responsiveVersionManagerDeleteLayer(Object layerId) {
    return 'Responsive Version Manager: Delete Layer $layerId';
  }

  @override
  String responsiveVersionManagerDeleteLegendGroup(Object legendGroupId) {
    return 'Responsive Version Manager: Delete legend group $legendGroupId';
  }

  @override
  String responsiveVersionManagerReorder(
    Object length,
    Object newIndex,
    Object oldIndex,
  ) {
    return 'Responsive Version Manager: Reorder layers within group $oldIndex -> $newIndex, updated layer count: $length';
  }

  @override
  String responsiveVersionManagerSetOpacity(Object layerId, Object opacity) {
    return 'Responsive Version Manager: Set layer opacity $layerId = $opacity';
  }

  @override
  String responsiveVersionManagerSetVisibility(
    Object groupId,
    Object isVisible,
  ) {
    return 'Responsive Version Manager: Set legend group visibility $groupId = $isVisible';
  }

  @override
  String responsiveVersionManagerUpdateLayer(Object name) {
    return 'Responsive Version Manager: Update Layer $name';
  }

  @override
  String responsiveVersionManagerUpdateLegendGroup(Object name) {
    return 'Responsive Version Manager: Update legend group $name';
  }

  @override
  String responsiveVersionManagerUpdateNote(Object title) {
    return 'Responsive Version Manager: Update note $title';
  }

  @override
  String responsiveVersionTabDebug(
    Object currentVersion,
    Object hasUnsavedVersions,
    Object versionCount,
  ) {
    return 'Responsive version tab build: version count=$versionCount, current version=$currentVersion, unsaved versions=$hasUnsavedVersions';
  }

  @override
  String get restoreDefaultShortcuts_4821 => 'Restore default shortcuts';

  @override
  String get restoreDefaults_7421 => 'Restore defaults';

  @override
  String get restoreMaximizedStateOnStartup_4281 =>
      'Restore window maximized state on startup';

  @override
  String get restrictedChoice_7281 => 'Restricted choice';

  @override
  String get retryButton_7281 => 'Retry';

  @override
  String get retryButton_7284 => 'Retry';

  @override
  String get retryTooltip_7281 => 'Retry operation';

  @override
  String get retry_4281 => 'Retry';

  @override
  String get retry_4821 => 'Retry';

  @override
  String get retry_7281 => 'Retry';

  @override
  String get retry_7284 => 'Retry';

  @override
  String returnValue_4821(Object result) {
    return 'Return value: $result';
  }

  @override
  String get reuploadText_4821 => 'Reupload';

  @override
  String get reuploadText_7281 => 'Reupload';

  @override
  String get rewind10Seconds_7539 => 'Rewind 10 seconds';

  @override
  String rewindFailed_4821(Object error) {
    return 'Rewind operation failed: $error';
  }

  @override
  String get rgbColorDescription_7281 => '• RGB: FF0000 (Red)';

  @override
  String get rightClickHereHint_4821 => 'Right-click here to try';

  @override
  String get rightClickHere_7281 => 'Right-click here';

  @override
  String rightClickOptionsWithMode_7421(Object mode) {
    return 'Right-click for options - $mode';
  }

  @override
  String get rightClickOptions_4821 => 'Right-click to view options';

  @override
  String get rightClickToViewProperties_7421 =>
      'Right-click to view properties';

  @override
  String get rightClick_4271 => 'Right-click';

  @override
  String get rightDirection_4821 => 'Right';

  @override
  String get rightVerticalNavigation_4271 => 'Right vertical navigation';

  @override
  String get romanianRO_4857 => 'Romanian (Romania)';

  @override
  String get romanian_4856 => 'Romanian';

  @override
  String get room_4822 => 'Room';

  @override
  String rootDirectoryCheck(
    Object containsSlash,
    Object path,
    Object shouldRemove,
  ) {
    return 'Root directory check: path=\"$path\", contains /=$containsSlash, should remove=$shouldRemove';
  }

  @override
  String get rootDirectoryName_4721 => 'Root directory';

  @override
  String get rootDirectory_4721 => 'Root directory';

  @override
  String get rootDirectory_4821 => 'Root Directory';

  @override
  String get rootDirectory_4905 => 'Root Directory';

  @override
  String get rootDirectory_5421 => 'Root directory';

  @override
  String get rootDirectory_5732 => 'Root directory';

  @override
  String get rootDirectory_5832 => 'Root directory';

  @override
  String get rootDirectory_7281 => 'Root directory';

  @override
  String get rootDirectory_7421 => 'Root directory';

  @override
  String get rotate_4822 => 'Rotate';

  @override
  String get rotationAngle_4521 => 'Rotation angle';

  @override
  String get rotationAngle_4721 => 'Rotation angle';

  @override
  String get rotationLabel_4821 => 'Rotate';

  @override
  String get rouletteGestureMenuExample_4271 => 'Roulette gesture menu example';

  @override
  String get rouletteMenuSettings_4821 => 'Roulette Menu Settings';

  @override
  String get rsaKeyGenerationStep1_4821 =>
      'Step 1: Starting RSA key pair generation...';

  @override
  String get rsaKeyPairGenerated_4821 =>
      'Step 1: RSA key pair generation completed';

  @override
  String get rsaKeyPairGenerated_7281 =>
      'RSA key pair generation completed, starting to convert public key format...';

  @override
  String rsaKeyPairGenerationFailed(Object e) {
    return 'Failed to generate RSA key pair: $e';
  }

  @override
  String get runButton_7421 => 'Run';

  @override
  String get runText_4821 => 'Run';

  @override
  String runningScriptsCount(Object count) {
    return 'Running scripts ($count)';
  }

  @override
  String get runningStatus_4821 => 'Running';

  @override
  String get runningStatus_5421 => 'Running';

  @override
  String get russianRU_4889 => 'Russian (Russia)';

  @override
  String get russian_4835 => 'Russian';

  @override
  String get sampleDataCleaned_7421 => 'Sample data cleaned successfully';

  @override
  String sampleDataCleanupFailed_7421(Object e) {
    return 'Sample data cleanup failed: $e';
  }

  @override
  String get sampleDataCreated_7421 =>
      'WebDatabaseImporter: Sample data creation completed';

  @override
  String sampleDataInitFailed_7421(Object e) {
    return 'Sample data initialization failed: $e';
  }

  @override
  String get sampleDataInitialized_7281 => 'Sample data initialized';

  @override
  String get sampleLayerName_4821 => 'Sample Layer';

  @override
  String get sampleMapTitle_7281 => 'Sample Map';

  @override
  String get saturationLabel_4821 => 'Saturation';

  @override
  String saturationPercentage(Object percentage) {
    return 'Saturation: $percentage%';
  }

  @override
  String get saturation_4827 => 'Saturation';

  @override
  String get saturation_6789 => 'Saturation';

  @override
  String get saveAndClose_7281 => 'Save and Close';

  @override
  String get saveAndExit_4271 => 'Save and Exit';

  @override
  String get saveAsNewConfig_7281 =>
      'Save current settings as new configuration';

  @override
  String get saveAs_7421 => 'Save As';

  @override
  String saveAssetFailed_7281(Object e) {
    return 'Failed to save asset: $e';
  }

  @override
  String get saveButton_5421 => 'Save';

  @override
  String get saveButton_7281 => 'Save';

  @override
  String get saveButton_7284 => 'Save';

  @override
  String get saveButton_7421 => 'Save';

  @override
  String get saveConfig => 'Save Configuration';

  @override
  String saveConfigFailed(Object error) {
    return 'Failed to save configuration: $error';
  }

  @override
  String get saveCurrentConfig_4271 => 'Save current configuration';

  @override
  String get saveCurrentMapId_7425 => 'Save current map ID';

  @override
  String saveDrawingElementError_7281(Object error, Object location) {
    return 'Failed to save drawing element [$location]: $error';
  }

  @override
  String get saveExportFileTitle_4821 => 'Save Export File';

  @override
  String saveFailedError_7281(Object error) {
    return 'Save failed: $error';
  }

  @override
  String saveFailedMessage(Object e) {
    return 'Save failed: $e';
  }

  @override
  String get saveFileTooltip_4521 => 'Save file';

  @override
  String saveImageAssetToMap(Object filename, Object length, Object mapTitle) {
    return 'Save new image asset to map [$mapTitle]: $filename ($length bytes)';
  }

  @override
  String get saveImageTitle_4821 => 'Save Image';

  @override
  String saveLegendGroupFailed(
    Object error,
    Object groupId,
    Object mapTitle,
    Object version,
  ) {
    return 'Failed to save legend group [$mapTitle/$groupId:$version]: $error';
  }

  @override
  String saveLegendGroupStateFailed(Object e) {
    return 'Failed to save legend group smart hide state: $e';
  }

  @override
  String saveLegendScaleFactorFailed(Object e) {
    return 'Failed to save legend group scale factor state: $e';
  }

  @override
  String get saveMap => 'Save Map';

  @override
  String get saveMapDataComplete_7281 => '=== saveMapDataReactive Complete ===';

  @override
  String get saveMapDataStart_7281 => '=== saveMapDataReactive start ===';

  @override
  String saveMapDataWithForceUpdate(Object forceUpdate) {
    return 'Save map data, force update: $forceUpdate';
  }

  @override
  String get saveMapDatabaseTitle_4821 => 'Save Map Database';

  @override
  String get saveMaximizeStatusEnabled_4821 =>
      'Save maximize status: Enabled to remember maximize settings';

  @override
  String get savePanelStateChange_4821 => 'Save panel state changes';

  @override
  String savePanelStateFailed_7285(Object e) {
    return 'Failed to save panel state: $e';
  }

  @override
  String savePanelStateFailed_7421(Object e) {
    return 'Failed to save panel state in dispose: $e';
  }

  @override
  String get savePdfDialogTitle_4821 => 'Save PDF File';

  @override
  String savePermissionFailed(Object e) {
    return 'Failed to save permission: $e';
  }

  @override
  String saveScaleFactorFailed_7285(Object e) {
    return 'Failed to save scale factor state in dispose: $e';
  }

  @override
  String get saveScriptTooltip_4821 => 'Save script';

  @override
  String saveSmartHideStateFailed_7285(Object e) {
    return 'Failed to save smart hide state in dispose: $e';
  }

  @override
  String saveStickyNoteError(
    Object error,
    Object id,
    Object mapTitle,
    Object version,
  ) {
    return 'Failed to save sticky note data [$mapTitle/$id:$version]: $error';
  }

  @override
  String saveTagPreferenceFailed(Object e) {
    return 'Failed to save tag to preferences: $e';
  }

  @override
  String saveUserPreferenceFailed(Object e) {
    return 'Failed to save user preferences: $e';
  }

  @override
  String saveVersionToVfs(Object title, Object versionId) {
    return 'Save version data to VFS: $title/$versionId';
  }

  @override
  String saveVersion_7281(Object versionId, Object versionName) {
    return 'Save version: $versionId ($versionName)';
  }

  @override
  String saveWindowSizeFailed_7284(Object e) {
    return 'Failed to save window size: $e';
  }

  @override
  String saveWindowSizeFailed_7285(Object e) {
    return 'Failed to save window size manually: $e';
  }

  @override
  String get saveWindowSizeNotMaximized_4821 =>
      'Save window size: currently not maximized';

  @override
  String get saveZipFileTitle_4721 => 'Save Zip File';

  @override
  String get saveZipFileTitle_4821 => 'Save Zip File';

  @override
  String get save_3831 => 'Save';

  @override
  String get save_4824 => 'Save';

  @override
  String get save_73 => 'Save';

  @override
  String savedConfigsCount(Object count) {
    return 'Saved configurations ($count)';
  }

  @override
  String get savingFile_5007 => 'Saving file...';

  @override
  String get savingInProgress_42 => 'Saving...';

  @override
  String get savingMap_7281 => 'Saving map...';

  @override
  String scaleLevelErrorWithDefault(Object defaultValue, Object e) {
    return 'Failed to get scale level: $e, returning default value $defaultValue';
  }

  @override
  String get scanningDirectories_5022 => 'Scanning directories...';

  @override
  String get scriptBound => 'Script bound';

  @override
  String scriptCount(Object count) {
    return '$count scripts';
  }

  @override
  String scriptCreatedSuccessfully(Object name) {
    return 'Responsive script \"$name\" created successfully';
  }

  @override
  String scriptEngineDataUpdater(
    Object layersCount,
    Object notesCount,
    Object groupsCount,
  ) {
    return 'Updating script engine data accessor, layers count: $layersCount, notes count: $notesCount, legend groups count: $groupsCount';
  }

  @override
  String get scriptEngineReinitialized_4821 =>
      'New script engine reinitialization completed';

  @override
  String get scriptEngineResetDone_7281 => 'Script engine reset completed';

  @override
  String scriptEngineResetFailed_7285(Object e) {
    return 'Script engine reset failed: $e';
  }

  @override
  String get scriptEngineStatusMonitoring_7281 =>
      'Script Engine Status Monitoring';

  @override
  String get scriptEngine_4521 => 'Script Engine';

  @override
  String scriptError_7284(Object error) {
    return 'Script error: $error';
  }

  @override
  String scriptExecutionError_7284(Object e) {
    return 'Script execution error: $e';
  }

  @override
  String scriptExecutionFailed_7281(Object error) {
    return 'Script execution failed: $error';
  }

  @override
  String get scriptExecutionLog_4821 => 'Script Execution Log';

  @override
  String get scriptExecutionLogs_4521 =>
      'The logs from script execution will be displayed here.';

  @override
  String get scriptExecutionResult_7421 => 'Script execution result';

  @override
  String scriptExecutionTime(Object elapsedMilliseconds) {
    return 'Script executor stop time: ${elapsedMilliseconds}ms';
  }

  @override
  String scriptExecutorCleanup_7421(Object scriptId) {
    return 'Clean up script executor: $scriptId';
  }

  @override
  String scriptExecutorCreation_7281(Object poolSize, Object scriptId) {
    return 'Create a new executor and function handler for script $scriptId (current pool size: $poolSize)';
  }

  @override
  String scriptExecutorError_7425(Object e) {
    return 'An error occurred while stopping the script executor: $e';
  }

  @override
  String scriptExecutorFailure_4829(Object e) {
    return 'Failed to stop script executor: $e';
  }

  @override
  String get scriptExecutorStopped_7281 =>
      'Script executor stopped successfully';

  @override
  String get scriptManagement_4821 => 'Script Management';

  @override
  String get scriptManagerNotInitializedError_42 =>
      'Script manager not initialized, unable to execute script';

  @override
  String get scriptName_4521 => 'Script name';

  @override
  String scriptName_7421(Object scriptName) {
    return 'Script: $scriptName';
  }

  @override
  String scriptNoParamsRequired(Object name) {
    return 'The script $name requires no parameters';
  }

  @override
  String scriptNotFoundError(Object scriptId) {
    return 'Bound script not found: $scriptId';
  }

  @override
  String get scriptPanel_7890 => 'Script Panel';

  @override
  String get scriptParameterSettings_4821 => 'Script Parameter Settings';

  @override
  String scriptParamsUpdated_7421(Object name) {
    return 'Script parameters updated: $name';
  }

  @override
  String get scriptSaved_4821 => 'Script saved';

  @override
  String scriptTtsFailed_4821(Object e) {
    return 'Failed to stop script TTS: $e';
  }

  @override
  String scriptTtsFailure_4829(Object e) {
    return 'Failed to stop script TTS: $e';
  }

  @override
  String get scriptType_4521 => 'Script Type';

  @override
  String get scrollToBottom_4821 => 'Jump to bottom';

  @override
  String get scrollToTop_4821 => 'Scroll to top';

  @override
  String get searchMapsAndFolders_4824 => 'Search maps and folders...';

  @override
  String searchResults_4821(Object query) {
    return 'Search results: \"$query\"';
  }

  @override
  String get search_4821 => 'Search';

  @override
  String get secondsCount_4821 => '6 seconds';

  @override
  String get secondsLabel_4821 => 'seconds';

  @override
  String get seekFailed_4821 => 'Seek failed';

  @override
  String seekToPosition(Object seconds) {
    return 'Jump to ${seconds}s';
  }

  @override
  String selectAllWithCount(Object count) {
    return 'Select All ($count items)';
  }

  @override
  String get selectAndUploadZip_4973 => 'Select and Upload ZIP File';

  @override
  String get selectAuthAccount_4821 =>
      'Please select an authentication account';

  @override
  String get selectCenterPoint => 'Select center point:';

  @override
  String get selectCollection_5033 => 'Select Collection';

  @override
  String get selectColor_4821 => 'Select color';

  @override
  String get selectColor_7281 => 'Select color';

  @override
  String get selectDatabaseAndCollectionFirst_7281 =>
      'Please select a database and collection first';

  @override
  String get selectDatabaseAndCollection_7281 =>
      'Please select a database and collection';

  @override
  String get selectDatabaseAndCollection_7421 =>
      'Please select a database and collection';

  @override
  String get selectDatabaseFirst_4281 => 'Please select a database first';

  @override
  String get selectDatabaseFirst_4821 => 'Please select a database first';

  @override
  String get selectDatabaseFirst_7281 =>
      'Please select a database and collection first';

  @override
  String get selectDatabase_5032 => 'Select Database';

  @override
  String get selectExportDirectory_4821 => 'Select export directory';

  @override
  String get selectFileOrFolderFirst_7281 =>
      'Please select a file or folder to download first';

  @override
  String get selectFileToViewMetadata_4821 => 'Select a file to view metadata';

  @override
  String get selectFileToViewMetadata_7281 => 'Select a file to view metadata';

  @override
  String get selectFiles_4821 => 'Select Files';

  @override
  String get selectLanguage_4821 => 'Select Language';

  @override
  String get selectLayer10_3854 => 'Select Layer 10';

  @override
  String get selectLayer10_4831 => 'Select Layer 10';

  @override
  String get selectLayer11_3855 => 'Select Layer 11';

  @override
  String get selectLayer11_4832 => 'Select Layer 11';

  @override
  String get selectLayer12_3856 => 'Select Layer 12';

  @override
  String get selectLayer12_4833 => 'Select Layer 12';

  @override
  String get selectLayer1_3845 => 'Select Layer 1';

  @override
  String get selectLayer1_4822 => 'Select Layer 1';

  @override
  String get selectLayer2_3846 => 'Select Layer 2';

  @override
  String get selectLayer2_4823 => 'Select Layer 2';

  @override
  String get selectLayer3_3847 => 'Select Layer 3';

  @override
  String get selectLayer3_4824 => 'Select Layer 3';

  @override
  String get selectLayer4_3848 => 'Select Layer 4';

  @override
  String get selectLayer4_4825 => 'Select Layer 4';

  @override
  String get selectLayer5_3849 => 'Select Layer 5';

  @override
  String get selectLayer5_4826 => 'Select Layer 5';

  @override
  String get selectLayer6_3850 => 'Select Layer 6';

  @override
  String get selectLayer6_4827 => 'Select Layer 6';

  @override
  String get selectLayer7_3851 => 'Select Layer 7';

  @override
  String get selectLayer7_4828 => 'Select Layer 7';

  @override
  String get selectLayer8_3852 => 'Select Layer 8';

  @override
  String get selectLayer8_4829 => 'Select Layer 8';

  @override
  String get selectLayer9_3853 => 'Select Layer 9';

  @override
  String get selectLayer9_4830 => 'Select Layer 9';

  @override
  String get selectLayerFirst_4281 => 'Please select a layer first';

  @override
  String get selectLayerGroup1 => 'Select Layer Group 1';

  @override
  String get selectLayerGroup10 => 'Select Layer Group 10';

  @override
  String get selectLayerGroup10_3844 => 'Select layer group 10';

  @override
  String get selectLayerGroup1_3835 => 'Select layer group 1';

  @override
  String get selectLayerGroup2 => 'Select Layer Group 2';

  @override
  String get selectLayerGroup2_3836 => 'Select Layer Group 2';

  @override
  String get selectLayerGroup3 => 'Select Layer Group 3';

  @override
  String get selectLayerGroup3_3837 => 'Select layer group 3';

  @override
  String get selectLayerGroup4 => 'Select Layer Group 4';

  @override
  String get selectLayerGroup4_3838 => 'Select layer group 4';

  @override
  String get selectLayerGroup5 => 'Select layer group 5';

  @override
  String get selectLayerGroup5_3839 => 'Select layer group 5';

  @override
  String get selectLayerGroup6 => 'Select Layer Group 6';

  @override
  String get selectLayerGroup6_3840 => 'Select Layer Group 6';

  @override
  String get selectLayerGroup7 => 'Select Layer Group 7';

  @override
  String get selectLayerGroup7_3841 => 'Select Layer Group 7';

  @override
  String get selectLayerGroup8 => 'Select Layer Group 8';

  @override
  String get selectLayerGroup8_3842 => 'Select Layer Group 8';

  @override
  String get selectLayerGroup9 => 'Select layer group 9';

  @override
  String get selectLayerGroup9_3843 => 'Select Layer Group 9';

  @override
  String get selectLayersForLegendGroup_4821 =>
      'Select layers to bind to this legend group';

  @override
  String get selectLegendFileError_4821 => 'Please select a .legend file';

  @override
  String get selectLegendFileTooltip_4821 => 'Select legend file';

  @override
  String get selectLegendGroupToBind_7281 =>
      'Select the legend group to bind to this layer';

  @override
  String get selectNextLayerGroup_3824 => 'Select the next layer group';

  @override
  String get selectNextLayer_3822 => 'Select next layer';

  @override
  String get selectNoteColor_7281 => 'Select note color';

  @override
  String get selectOption_4271 => 'Select';

  @override
  String selectParamPrompt(Object name) {
    return 'Please select $name';
  }

  @override
  String selectPathFailed_4931(Object error) {
    return 'Failed to select path: $error';
  }

  @override
  String get selectPath_4959 => 'Select path';

  @override
  String get selectPreviousLayerGroup_3823 => 'Select previous layer group';

  @override
  String get selectPreviousLayer_3821 => 'Select previous layer';

  @override
  String get selectProcessingMethod_4821 =>
      'Please select a processing method:';

  @override
  String get selectRegionBeforeCopy_7281 =>
      'Please select a region first before copying';

  @override
  String get selectScriptToBind_4271 => 'Select script to bind';

  @override
  String get selectSourceFileOrFolder_4956 => 'Select source file or folder';

  @override
  String get selectTargetFolderTitle_4930 => 'Select Target Folder';

  @override
  String get selectTargetFolder_4916 => 'Select target folder';

  @override
  String get selectTriangulation_4271 => 'Select triangulation';

  @override
  String get selectVfsDirectoryHint_4821 =>
      'Select a VFS directory to load the legend into cache';

  @override
  String get selectVfsFile => 'Select VFS File';

  @override
  String get selectVfsFileTooltip_4821 => 'Select VFS file';

  @override
  String get selectWebDavConfig_7281 => 'Select WebDAV Configuration';

  @override
  String get selectableLayers_7281 => 'Selectable layers';

  @override
  String selectedAction_7421(Object action) {
    return 'Selected: $action';
  }

  @override
  String get selectedCount_7284 => 'Selected count';

  @override
  String selectedDirectoriesCount(Object count) {
    return 'Selected: $count directories';
  }

  @override
  String selectedElementsUpdated(Object count) {
    return '[CollaborationStateManager] User selection updated: $count elements';
  }

  @override
  String selectedFile(Object name) {
    return 'Selected: $name';
  }

  @override
  String get selectedFile_7281 => 'Selected file';

  @override
  String get selectedGroup_4821 => 'Selected group';

  @override
  String selectedItemLabel(Object label) {
    return 'Selected item: $label';
  }

  @override
  String selectedItemsCount(Object selectedCount, Object totalCount) {
    return 'Selected $selectedCount / $totalCount items';
  }

  @override
  String selectedItems_4821(Object count) {
    return 'Selected $count items';
  }

  @override
  String selectedLayerAndGroup_7281(Object groupNames, Object layerName) {
    return 'Layer: $layerName | Group: $groupNames';
  }

  @override
  String selectedLayerGroup(Object count) {
    return 'Selected layer group ($count layers)';
  }

  @override
  String selectedLayerGroupMessage(Object layers) {
    return 'Layer group: $layers';
  }

  @override
  String get selectedLayerGroupUpdated_4821 =>
      'The selected layer group reference has been updated';

  @override
  String selectedLayerGroupWithCount_4821(Object count) {
    return 'Selected layer group ($count layers), allowing simultaneous operations on both layers and layer groups';
  }

  @override
  String selectedLayerGroup_4727(Object count) {
    return 'Selected layer group ($count layers)';
  }

  @override
  String get selectedLayerLabel_4821 => 'Selected layer';

  @override
  String selectedLayerUpdated_7421(Object name) {
    return 'Selected layer reference updated: $name';
  }

  @override
  String selectedLayersInfo_4821(Object count, Object names) {
    return '$count layers: $names';
  }

  @override
  String selectedLegendItem_7421(Object count, Object currentIndex) {
    return 'Currently selected: $currentIndex/$count';
  }

  @override
  String selectedPathsCount_7421(Object otherCount, Object selectedCount) {
    return 'Selected paths in current group: $selectedCount, in other groups: $otherCount';
  }

  @override
  String get selectedText_7421 => 'Selected';

  @override
  String get selectedWithMultiple_4827 => 'Multiple selected';

  @override
  String get selected_3632 => 'Selected';

  @override
  String get selectingImage_4821 => 'Selecting image...';

  @override
  String get selectingImage_7421 => '📸 Selecting image...';

  @override
  String get selectionCopiedToClipboard_4821 => 'Selection copied to clipboard';

  @override
  String get sendDataToRemote_7428 => 'Send data to remote';

  @override
  String get separate_7281 => 'Separate';

  @override
  String separatedGroupLayersOrder_7284(Object layers) {
    return 'Order of layers within the separated group: $layers';
  }

  @override
  String get sepia_4823 => 'Sepia';

  @override
  String get sepia_9012 => 'Sepia';

  @override
  String get sequentialPlayback_4271 => 'Sequential playback';

  @override
  String serializedResultDebug_7281(Object serializedResult) {
    return 'Serialized result: $serializedResult';
  }

  @override
  String get serializedResultDebug_7425 => 'Serialized result';

  @override
  String get serverChallengeReceived_4289 => 'serverChallengeReceived';

  @override
  String serverErrorResponse(Object error) {
    return 'serverErrorResponse: $error';
  }

  @override
  String serverErrorWithDetails_7421(Object body, Object statusCode) {
    return 'Server returned error status code: $statusCode Response content: $body';
  }

  @override
  String serverInfo(Object host, Object port) {
    return 'Server: $host:$port';
  }

  @override
  String serverInfoLabel_7281(Object serverInfo) {
    return 'Server: $serverInfo';
  }

  @override
  String serverInfo_4827(Object host, Object port) {
    return 'Server: $host:$port';
  }

  @override
  String get serverLabel_4821 => 'Server';

  @override
  String get serverUrlHint_4821 => 'https://example.com/webdav';

  @override
  String get serverUrlLabel_4821 => 'Server URL';

  @override
  String get serverUrlRequired_4821 => 'Please enter the server URL';

  @override
  String get serviceInitialized_7421 => 'Service initialized';

  @override
  String get serviceNotInitializedError_4821 =>
      'GlobalCollaborationService is not initialized, please call initialize() first';

  @override
  String get serviceNotInitializedError_7281 =>
      'GlobalCollaborationService is not initialized, please call initialize() first';

  @override
  String get serviceNotInitializedIgnoreData_7283 =>
      'Service not initialized, ignoring remote data';

  @override
  String get sessionManagerClearData_7281 =>
      'Legend Session Manager: Clear Session Data';

  @override
  String setActiveClientFailed_7285(Object e) {
    return 'Failed to set active client: $e';
  }

  @override
  String setActiveClient_7421(Object clientId) {
    return 'Set active client: $clientId';
  }

  @override
  String setActiveConfig(Object clientId, Object displayName) {
    return 'Set active config: $displayName ($clientId)';
  }

  @override
  String setActiveConfigFailed(Object e) {
    return 'Failed to set active configuration: $e';
  }

  @override
  String get setAsActive_7281 => 'Set as active';

  @override
  String setAudioBalanceFailed_4821(Object e) {
    return 'Failed to set audio balance - $e';
  }

  @override
  String setCurrentUser_7421(Object currentUserId) {
    return 'Set current user: $currentUserId';
  }

  @override
  String setLayerOpacity(Object layerId, Object opacity) {
    return 'Set layer opacity: $layerId = $opacity';
  }

  @override
  String setLayerVisibility(Object isVisible, Object layerId) {
    return 'Set layer visibility: $layerId = $isVisible';
  }

  @override
  String setLegendGroupOpacityLog_7421(Object groupId, Object opacity) {
    return 'Set legend group $groupId opacity to: $opacity';
  }

  @override
  String setLegendGroupVisibility(Object groupId, Object isVisible) {
    return 'Set legend group $groupId visibility to: $isVisible';
  }

  @override
  String get setParametersPrompt_4821 => 'Please set the following parameters:';

  @override
  String get setPlaybackSpeedFailed_7281 => 'Failed to set playback speed';

  @override
  String setPlaybackSpeedFailed_7285(Object e) {
    return 'Failed to set playback speed: $e';
  }

  @override
  String setShortcutForAction(Object action) {
    return 'Set shortcut for $action';
  }

  @override
  String setThemeFilterForLayer(Object id) {
    return 'Set theme adaptation filter for layer $id';
  }

  @override
  String get setValidTimeError_4821 => 'Please set a valid time';

  @override
  String setVfsAccessorWithMapTitle(Object mapTitle) {
    return 'Set VFS accessor, map title: $mapTitle';
  }

  @override
  String get setVolumeFailed_7281 => 'Failed to set volume';

  @override
  String get settings => 'Settings';

  @override
  String get settingsDisplayName_4821 => 'Settings';

  @override
  String get settingsExported => 'Settings exported successfully';

  @override
  String get settingsImported => 'Settings imported successfully';

  @override
  String get settingsManagement_4821 => 'Settings Management';

  @override
  String get settingsOperation_4251 => 'Settings operation';

  @override
  String get settingsOption_7421 => 'Settings option';

  @override
  String get settingsReset => 'Settings have been reset to default values';

  @override
  String get settingsWindow_4271 => 'Settings window';

  @override
  String get settings_4821 => 'Settings';

  @override
  String get settings_7281 => 'Settings';

  @override
  String get shareFeatureInDevelopment_7281 =>
      'Share feature in development...';

  @override
  String shareProject(Object index) {
    return 'Share project $index';
  }

  @override
  String get share_4821 => 'Share';

  @override
  String get share_7281 => 'Share';

  @override
  String get shelter_4825 => 'Shelter';

  @override
  String shortcutCheckResult(
    Object keyMatch,
    Object modifierMatch,
    Object result,
    Object shortcut,
  ) {
    return 'Shortcut check: $shortcut, primary key match: $keyMatch, modifier key match: $modifierMatch, final result: $result';
  }

  @override
  String shortcutConflictMessage(Object conflictName, Object shortcut) {
    return 'Shortcut conflict: $shortcut is already used by \"$conflictName';
  }

  @override
  String shortcutConflict_4827(Object conflictName, Object shortcut) {
    return 'Shortcut conflict: $shortcut is already used by \"$conflictName';
  }

  @override
  String get shortcutEditHint_7281 =>
      'Click the edit button to modify the shortcut for the corresponding function';

  @override
  String get shortcutInstruction_4821 =>
      'Click the area below, then press the shortcut combination you want to add';

  @override
  String get shortcutList_4821 => 'Shortcut List';

  @override
  String get shortcutManagement_4821 => 'Shortcut Management';

  @override
  String get shortcutSettings_4821 => 'Shortcut Settings';

  @override
  String get shortcutVersion_4821 => 'Shortcut version';

  @override
  String get shortcutsResetToDefault_4821 =>
      'All shortcuts have been reset to default settings';

  @override
  String get showAdvancedTools => 'Show advanced tools';

  @override
  String get showAdvancedTools_4271 => 'Show advanced tools';

  @override
  String get showAllLayersInGroup_7281 =>
      'All layers in the group are displayed';

  @override
  String get showAllLayers_7281 => 'Show all layers';

  @override
  String get showCloseButton_4271 => 'Show close button:';

  @override
  String get showCurrentLayerGroup_3863 => 'Show current layer group';

  @override
  String get showCurrentLayerGroup_4829 => 'Show current layer group';

  @override
  String get showCurrentLayer_3862 => 'Show current layer';

  @override
  String get showCurrentLayer_4828 => 'Show current layer';

  @override
  String get showCurrentLegendGroup_3865 => 'Show current legend group';

  @override
  String get showCurrentLegendGroup_4826 => 'Show current legend group';

  @override
  String showMenuAtPosition(Object position) {
    return 'Show menu at position: $position';
  }

  @override
  String get showMultipleNotifications_4271 => 'Show multiple notifications';

  @override
  String get showNotification_1234 => 'Show notification';

  @override
  String get showPersistentNotification_7281 => 'Show persistent notification';

  @override
  String get showProToolsInToolbar_4271 =>
      'Show professional tools in the toolbar';

  @override
  String get showProperties_4281 => 'Show Properties';

  @override
  String get showProperties_4821 => 'Show Properties';

  @override
  String get showShortcutList_3866 => 'Show shortcut list';

  @override
  String get showShortcutsList_7281 => 'Show shortcuts list';

  @override
  String get showToc_7532 => 'Show Table of Contents';

  @override
  String get showTooltip_4271 => 'Show tooltip';

  @override
  String get showTooltips => 'Show tooltips';

  @override
  String get show_4822 => 'Show';

  @override
  String get sidebarWidth_4271 => 'Sidebar width';

  @override
  String get sidebar_1235 => 'Sidebar';

  @override
  String signatureFailed_7285(Object e) {
    return 'Message signing failed: $e';
  }

  @override
  String signatureVerificationFailed(Object e) {
    return 'Failed to verify message signature: $e';
  }

  @override
  String signatureVerificationFailed_4829(Object e) {
    return 'Signature verification failed: $e';
  }

  @override
  String signatureVerificationResult_7425(Object result) {
    return 'Signature verification result: $result';
  }

  @override
  String get simpleRightClickMenu_7281 => 'Simple right-click menu';

  @override
  String get simpleWindow_7421 => 'Simple Window';

  @override
  String get simplifiedChinese_4821 => 'Simplified Chinese';

  @override
  String get simplifiedChinese_7281 => 'Simplified Chinese';

  @override
  String get simulateCheckUserOfflineStatus_4821 =>
      'Simulate checking user offline status';

  @override
  String get simultaneousEditConflict_4822 => 'Simultaneous edit conflict';

  @override
  String get singleCycleMode_4271 => 'Single Cycle';

  @override
  String get singleDiagonalLine_4826 => 'Single diagonal line';

  @override
  String get singleDiagonalLine_9746 => 'Single diagonal line';

  @override
  String get singleFileSelectionModeWarning_4827 =>
      'Only one file can be selected in single selection mode';

  @override
  String singleSelectionModeWithCount(Object count) {
    return 'Single selection mode ($count items)';
  }

  @override
  String get singleSelectionOnly_4821 => 'Single selection only';

  @override
  String get siriShortcuts => 'Siri Shortcuts';

  @override
  String get sixPerPage_4824 => 'Six per page';

  @override
  String sizeInBytes_7285(Object bytes) {
    return 'Size: $bytes bytes';
  }

  @override
  String get sizeLabel_4521 => 'Size';

  @override
  String get sizeLabel_4821 => 'Size';

  @override
  String get size_4962 => 'Size';

  @override
  String get skipDuplicateExecution_4821 =>
      'Cleanup is already in progress, skipping duplicate execution';

  @override
  String get skipExampleDataInitialization_7281 =>
      'Existing map data found, skipping example data initialization';

  @override
  String skipFailedMigrationMap(Object title) {
    return 'Skip failed migration map: $title';
  }

  @override
  String get skipFileKeepExisting_7281 =>
      'Skip this file and keep the existing one';

  @override
  String skipInvisibleLayer(Object name) {
    return 'Skip invisible layer: $name';
  }

  @override
  String get skipMapCoverUpdate_7421 =>
      'Skip updating map cover: not in editor or mapId is empty';

  @override
  String skipMapMessage(
    Object existingVersion,
    Object importedVersion,
    Object title,
  ) {
    return 'Skip map: $title (current version $existingVersion >= import version $importedVersion)';
  }

  @override
  String get skipSameIndexAdjustment_7281 =>
      'Adjusted index is the same, skipping';

  @override
  String get skipSameIndex_7281 => 'Index identical, skipping';

  @override
  String get skipSameIndex_7421 => 'Same index, skip';

  @override
  String get skipSameSourceAd_7285 =>
      '🎵 Ad request matches current playback source, skipping ad.';

  @override
  String get skipSaveMaximizedState => 'Skip saving: currently maximized';

  @override
  String get skipSaveMaximizedStateNotEnabled_4821 =>
      'Skip saving: window is maximized but \"Remember maximized state\" setting is not enabled';

  @override
  String get skipSaveMaximizedState_4821 => 'Skip saving: currently maximized';

  @override
  String get skipUpdateMapTitle_7421 =>
      'Skip updating map title: not in editor or mapId is empty';

  @override
  String get skip_4821 => 'Skip';

  @override
  String skippingInvisibleLegendGroup(Object name) {
    return 'Skipping invisible legend group: $name';
  }

  @override
  String skippingInvisibleNote(Object title) {
    return 'Skipping invisible note: $title';
  }

  @override
  String skippingNonJsonFile(Object fileName) {
    return 'Skipping non-JSON file: $fileName';
  }

  @override
  String get sleepTimer_4271 => 'Sleep Timer';

  @override
  String get slovakSK_4863 => 'Slovak (Slovakia)';

  @override
  String get slovak_4862 => 'Slovak';

  @override
  String get slovenianSI_4865 => 'Slovenian (Slovenia)';

  @override
  String get slovenian_4864 => 'Slovenian';

  @override
  String get slow_7284 => 'Slow';

  @override
  String get smallBrush_4821 => 'Small brush';

  @override
  String get smallDialogTitle_4821 => 'Small Dialog';

  @override
  String get smartDynamicDisplayInfo_7284 =>
      '📏 Smart Dynamic Display Area Info:';

  @override
  String smartHideStatusSaved(Object enabled) {
    return 'Smart hide status saved: $enabled';
  }

  @override
  String get smartHiding_4854 => 'Smart Hiding';

  @override
  String get snackBarDemoDescription_7281 =>
      'Demonstrates how to replace the persistent display feature of the default SnackBar';

  @override
  String get snackBarDemo_4271 => 'SnackBar Compatibility Demo';

  @override
  String get softwareInfoLicenseAcknowledgements_4821 =>
      'Software Information, Licenses, and Open Source Acknowledgments';

  @override
  String get solidLine_4821 => 'Solid line';

  @override
  String get solidRectangleTool_1235 => 'Solid Rectangle';

  @override
  String get solidRectangle_4824 => 'Solid rectangle';

  @override
  String get solidRectangle_7524 => 'Solid Rectangle';

  @override
  String get solution_4567 => 'Solution';

  @override
  String get solve_7421 => 'Solve';

  @override
  String get songsSuffix_8153 => 'songs';

  @override
  String get sort_4821 => 'Sort';

  @override
  String sourceDirectoryNotExist_7285(Object sourcePath) {
    return 'Source directory does not exist: $sourcePath';
  }

  @override
  String get sourceFile_7281 => 'Source file';

  @override
  String sourceFolderNotExist_7285(Object oldPath) {
    return 'Source folder does not exist: $oldPath';
  }

  @override
  String get sourceGroupEmpty_7281 => 'Source group is empty';

  @override
  String get sourceLabel_4821 => 'Source';

  @override
  String get sourcePathNotExists_5014 => 'Source path does not exist';

  @override
  String get sourcePath_4954 => 'Source Path';

  @override
  String sourceVersionNotFound_4821(Object sourceVersionId) {
    return 'Source version not found: $sourceVersionId';
  }

  @override
  String sourceVersionPathSelection_7281(Object versionId) {
    return 'Source version $versionId path selection:';
  }

  @override
  String get spacingSettings_4821 => 'Spacing Settings';

  @override
  String get spanishES_4885 => 'Spanish (Spain)';

  @override
  String get spanishMX_4886 => 'Spanish (Mexico)';

  @override
  String get spanish_4831 => 'Spanish';

  @override
  String speechRateLog_7285(Object rate) {
    return ', rate: $rate';
  }

  @override
  String speechSynthesisFailed_7285(Object e) {
    return 'Speech synthesis failed: $e';
  }

  @override
  String stackTraceMessage_7421(Object stackTrace) {
    return 'Stack: $stackTrace';
  }

  @override
  String get stairs_4822 => 'Stairs';

  @override
  String startBatchLoadingDirectoryToCache(Object directoryPath) {
    return 'Start batch loading directory to cache: $directoryPath';
  }

  @override
  String get startCachingSvgFiles_7281 => '🎨 Starting to cache SVG files...';

  @override
  String get startCleaningExpiredData_1234 => 'Start cleaning expired data';

  @override
  String startCleaningTempFolder_4821(Object fullTempPath) {
    return '🗑️ Start cleaning temp folder: $fullTempPath';
  }

  @override
  String get startCleanupOperation_7281 =>
      'Starting application cleanup operation...';

  @override
  String get startCreatingClientConfigWithWebApiKey_4821 =>
      'Start creating client configuration with Web API Key...';

  @override
  String get startDeletingVersionData_7281 =>
      'Starting to delete version storage data...';

  @override
  String get startEditingDefaultVersion_7281 =>
      'Start editing the default version to ensure proper data synchronization';

  @override
  String startEditingFirstVersion_7281(Object firstVersionId) {
    return 'Start editing the first available version: $firstVersionId';
  }

  @override
  String startEditingVersion(Object mapTitle, Object versionId) {
    return 'Start editing version [$mapTitle/$versionId]';
  }

  @override
  String startLoadingLegendGroup(
    Object folderPath,
    Object groupId,
    Object mapTitle,
    Object version,
  ) {
    return 'Start loading legend group items: mapTitle=$mapTitle, groupId=$groupId, version=$version, folderPath=$folderPath';
  }

  @override
  String startLoadingLegendItems_7421(
    Object folderPath,
    Object groupId,
    Object itemId,
    Object mapTitle,
    Object version,
  ) {
    return 'Start loading legend items: mapTitle=$mapTitle, groupId=$groupId, itemId=$itemId, version=$version, folderPath=$folderPath';
  }

  @override
  String startLoadingLegendsToCache(Object directoryPath) {
    return 'Loading legends from directory to cache: $directoryPath';
  }

  @override
  String startLoadingVersionDataToSession(Object versionId) {
    return 'Loading version data into session: $versionId';
  }

  @override
  String get startLooping_5422 => 'Loop playback';

  @override
  String startMigrationMap_7421(Object title) {
    return 'Start migration map: $title';
  }

  @override
  String startProcessingQueue(Object stickyNoteId, Object totalItems) {
    return 'Start processing sticky note $stickyNoteId queue with $totalItems items in total';
  }

  @override
  String startSavingResponsiveVersionData(Object mapTitle) {
    return 'Start saving responsive version data [Map: $mapTitle]';
  }

  @override
  String startSwitchingVersion_7281(Object versionId) {
    return 'Start switching version: $versionId';
  }

  @override
  String startTimerName_7281(Object name) {
    return 'Start $name';
  }

  @override
  String startWebSocketAuthFlow(Object clientId) {
    return 'Start WebSocket authentication flow (using external flow): $clientId';
  }

  @override
  String startWebSocketAuthProcess(Object clientId) {
    return 'Starting WebSocket authentication process: $clientId';
  }

  @override
  String startWebSocketConnection_7281(Object clientId) {
    return 'Starting WebSocket server connection: $clientId';
  }

  @override
  String get statisticsScriptExample_9303 => 'Statistics Script Example';

  @override
  String get statistics_3456 => 'Statistics';

  @override
  String get statistics_4821 => 'Statistics';

  @override
  String step2PrivateKeyStored(Object privateKeyId) {
    return 'Step 2: Private key stored successfully, ID: $privateKeyId';
  }

  @override
  String get step2StorePrivateKey_7281 =>
      'Step 2: Start storing private key to secure storage...';

  @override
  String get stepSelectionModeHint_4821 =>
      'Step selection mode: Only selects the current directory without recursively including subdirectories.';

  @override
  String steppedCacheCleanStart(Object folderPath) {
    return 'Stepped cache cleanup started: target directory=\"$folderPath';
  }

  @override
  String steppedCleanupLog(Object folderPath) {
    return 'Stepped cleanup: Clearing cache for path $folderPath';
  }

  @override
  String steppedCleanupSkip_4827(Object folderPath) {
    return 'Stepped cleanup: Path $folderPath is still in use, skipping cleanup';
  }

  @override
  String stepperCancelLog(Object path) {
    return 'Stepper cancel: Deselect directory $path';
  }

  @override
  String stepperSelection_4821(Object path) {
    return 'Stepper selection: Selected directory $path';
  }

  @override
  String stickyNoteBackgroundLoaded(Object backgroundImageHash, Object length) {
    return 'Sticky note background image loaded from assets, hash: $backgroundImageHash ($length bytes)';
  }

  @override
  String stickyNoteBackgroundSaved(Object hash, Object length) {
    return 'The sticky note background image has been saved to the asset system, hash: $hash ($length bytes)';
  }

  @override
  String stickyNoteDeleted(
    Object mapTitle,
    Object stickyNoteId,
    Object version,
  ) {
    return 'Sticky note data deleted [$mapTitle/$stickyNoteId:$version]';
  }

  @override
  String stickyNoteInspectorTitle_7421(Object title) {
    return 'Sticky Note Inspector - $title';
  }

  @override
  String stickyNoteInspectorWithCount(Object count) {
    return 'Sticky Note Inspector ($count)';
  }

  @override
  String get stickyNoteLabel_4281 => 'Sticky Note';

  @override
  String get stickyNoteLabel_4821 => 'Sticky Note';

  @override
  String stickyNoteLockedPreviewQueued_7281(
    Object queueLength,
    Object stickyNoteId,
  ) {
    return '[PreviewQueueManager] Sticky note $stickyNoteId is locked, preview has been queued. Current queue length: $queueLength';
  }

  @override
  String get stickyNoteNoElements_4821 =>
      'The sticky note has no drawn elements';

  @override
  String get stickyNotePanel_3456 => 'Sticky Note Panel';

  @override
  String get stickyNotePreviewProcessed_7421 =>
      'The sticky note preview has been processed immediately and added to the notes';

  @override
  String stickyNotePreviewQueueCleared(Object stickyNoteId) {
    return 'The preview queue for sticky note $stickyNoteId has been cleared';
  }

  @override
  String stickyNoteSaved(Object id, Object mapTitle, Object version) {
    return 'Sticky note data saved [$mapTitle/$id:$version]';
  }

  @override
  String get stickyNoteTitle_7421 => 'Sticky Note';

  @override
  String stopEditingVersion(Object arg0, Object arg1) {
    return 'Stop editing version [$arg0/$arg1]';
  }

  @override
  String get stopExecution_7421 => 'Stop Execution';

  @override
  String stopFailedError(Object e) {
    return 'Failed to stop: $e';
  }

  @override
  String get stopLooping_5421 => 'Stop looping';

  @override
  String stopScript_7285(Object scriptId) {
    return 'Stop script: $scriptId';
  }

  @override
  String get stopScript_7421 => 'Stop script';

  @override
  String stopTimerFailed(Object e) {
    return 'Failed to stop timer: $e';
  }

  @override
  String stopTimerName(Object name) {
    return 'Stop $name';
  }

  @override
  String stoppedScriptTtsPlayback_7421(Object _scriptId) {
    return 'Stopped all TTS playback for script $_scriptId';
  }

  @override
  String stoppedTtsRequests(Object count, Object sourceId) {
    return 'Stopped $count TTS requests from source $sourceId';
  }

  @override
  String get stoppingAudioService_7421 => 'Stopping audio service...';

  @override
  String get stoppingScriptExecutor_7421 => 'Stopping script executor...';

  @override
  String get stopwatchDescription_7532 => 'Count up from zero';

  @override
  String get stopwatchMode_7532 => 'Stopwatch';

  @override
  String get storageFolderLabel_4821 => 'Storage folder';

  @override
  String get storageInfo_7281 => 'Storage Info';

  @override
  String get storagePathLengthExceeded_4821 =>
      'The storage path length cannot exceed 100 characters';

  @override
  String get storagePath_7281 => 'Storage Path';

  @override
  String storageStatsError_4821(Object e) {
    return 'Failed to get storage statistics: $e';
  }

  @override
  String storageStats_7281(Object count, Object size) {
    return 'Storage size: $size KB | Key-value pairs: $count';
  }

  @override
  String storePrivateKeyFailed_7285(Object e) {
    return 'Failed to store private key: $e';
  }

  @override
  String get streamClosed_8251 => 'Stream is closed';

  @override
  String streamError_7284(Object error) {
    return 'Stream error: $error';
  }

  @override
  String get strokeWidth => 'Stroke width';

  @override
  String strokeWidthLabel(Object width) {
    return 'Stroke width: ${width}px';
  }

  @override
  String get strokeWidth_4821 => 'Stroke width';

  @override
  String subMenuInitialHoverItem(Object label) {
    return 'Submenu initial hover item: $label';
  }

  @override
  String subdirectoryCheck(
    Object containsSlash,
    Object path,
    Object relativePath,
    Object shouldRemove,
  ) {
    return 'Subdirectory check: path=\"$path\", relative path=\"$relativePath\", contains /=$containsSlash, should remove=$shouldRemove';
  }

  @override
  String submenuDelayTimer(Object label) {
    return 'Set submenu delay timer: $label';
  }

  @override
  String get submenuDelay_4821 => 'Submenu delay';

  @override
  String get successMessage_4821 => 'Success message';

  @override
  String get successUploadMetadataToWebDAV_5013 =>
      'Successfully uploaded metadata.json to WebDAV';

  @override
  String successWithLayerCount_4592(Object count) {
    return 'Success (Layers: $count)';
  }

  @override
  String get success_4821 => 'Success';

  @override
  String get success_7422 => 'Success';

  @override
  String get success_8421 => 'Success';

  @override
  String get suggestedTagsLabel_4821 => 'Suggested tags:';

  @override
  String get summary_7892 => 'Summary';

  @override
  String superClipboardReadError_7425(Object e) {
    return 'super_clipboard read failed: $e, falling back to platform-specific implementation';
  }

  @override
  String get supportMultipleSelection_7281 => 'Support multiple selection';

  @override
  String get supportedFileTypes_4821 => 'Supported file types:';

  @override
  String get supportedFormats_7281 => 'Supported formats:';

  @override
  String get supportedHtmlTags_7281 => 'Supported HTML tags';

  @override
  String get supportedImageFormats_4821 => 'Supported formats: JPG, PNG, GIF';

  @override
  String get supportedImageFormats_5732 =>
      'Supports image formats such as JPG, PNG, GIF';

  @override
  String get supportedImageFormats_7281 =>
      '• Images: png, jpg, jpeg, gif, bmp, webp, svg';

  @override
  String get supportedModesDescription_4821 =>
      'Currently, three different usage modes are supported:';

  @override
  String get supportedTextFormats_7281 => '• Text: txt, log, csv, json';

  @override
  String get surveillance_4832 => 'Surveillance';

  @override
  String svgDistributionRecordCount(Object recentSvgHistorySize) {
    return 'SVG distribution record count: $recentSvgHistorySize';
  }

  @override
  String get svgFileNotFound_4821 => 'SVG file not found';

  @override
  String svgLoadError(Object e) {
    return 'Error loading SVG file: $e';
  }

  @override
  String svgLoadFailed_4821(Object e, Object svgPath) {
    return 'Failed to load SVG: $svgPath - $e';
  }

  @override
  String get svgLoadFailed_7421 => 'Failed to load SVG file';

  @override
  String get svgTestPageTitle_4821 => 'SVG Test';

  @override
  String get svgThumbnailLoadFailed => 'SVG thumbnail loading failed';

  @override
  String svgThumbnailLoadFailed_4821(Object e) {
    return 'SVG thumbnail loading failed: $e';
  }

  @override
  String svgThumbnailLoadFailed_7285(Object e) {
    return 'SVG thumbnail failed to load: $e';
  }

  @override
  String get swedishSE_4843 => 'Swedish (Sweden)';

  @override
  String get swedish_4842 => 'Swedish';

  @override
  String switchAndLoadVersionData(
    Object layersCount,
    Object notesCount,
    Object versionId,
  ) {
    return 'Switch and load version data [$versionId] into the reactive system, layers: $layersCount, notes: $notesCount';
  }

  @override
  String get switchToDarkThemeTooltip_8532 => 'Switch to dark theme';

  @override
  String get switchToLightThemeTooltip_7421 => 'Switch to light theme';

  @override
  String get switchToNextVersion_3868 => 'Switch to the next version';

  @override
  String get switchToPreviousVersion_3867 => 'Switch to the previous version';

  @override
  String switchUserFailed_7421(Object error) {
    return 'Failed to switch user: $error';
  }

  @override
  String get switchView_4821 => 'Switch view';

  @override
  String switchedToVersion_7281(Object versionId) {
    return 'Switched to version: $versionId';
  }

  @override
  String syncDataFailed_7285(Object e) {
    return 'Failed to sync current data to version control system: $e';
  }

  @override
  String get syncDisabled_7421 => 'Sync is disabled';

  @override
  String get syncEnabled_7421 => 'Sync enabled';

  @override
  String syncExternalFunctionDebug_7421(
    Object functionName,
    Object runtimeType,
  ) {
    return 'Processing sync external function: $functionName, result type: $runtimeType';
  }

  @override
  String get syncLegendGroupDrawerStatus_4821 =>
      'Synchronize the status of the legend group management drawer';

  @override
  String get syncMap1_1234 => 'Sync Map 1';

  @override
  String get syncMap2_7421 => 'Sync Map 2';

  @override
  String syncMapDataToVersion(
    Object layersCount,
    Object legendsCount,
    Object stickiesCount,
    Object versionId,
  ) {
    return 'Sync map data to version [$versionId], layers: $layersCount, stickies: $stickiesCount, legend groups: $legendsCount';
  }

  @override
  String get syncMapInfoToPresenceBloc_7421 => 'Sync map info to PresenceBloc';

  @override
  String syncNoteDebug_7421(Object count, Object index, Object title) {
    return 'Syncing note [$index] $title: $count drawing elements';
  }

  @override
  String get syncServiceCleanedUp_7421 => 'Sync service has been cleaned up';

  @override
  String syncServiceInitFailed(Object error) {
    return 'Failed to initialize sync service: $error';
  }

  @override
  String get syncServiceInitialized => 'Synchronization service initialized';

  @override
  String get syncServiceNotInitialized_7281 => 'Sync service not initialized';

  @override
  String syncTreeStatusLegendGroup(Object legendGroupId) {
    return 'Sync Tree Status (Stepped) - Current Legend Group: $legendGroupId';
  }

  @override
  String syncUnsavedStateToUI(Object hasUnsavedChanges) {
    return 'The unsaved state of the reactive system has been synchronized to the UI: $hasUnsavedChanges';
  }

  @override
  String get systemMetrics_4521 => 'System Metrics';

  @override
  String get systemMode => 'Follow system';

  @override
  String get systemProtectedFileWarning_4821 =>
      'System Protected File - This file is protected by the system and cannot be deleted or modified';

  @override
  String get systemProtectedFile_4821 => 'System protected file';

  @override
  String get systemTrayIntegration => 'System Tray Integration';

  @override
  String get systemTraySupport => 'System Tray Support';

  @override
  String get tactic_4828 => 'Tactic';

  @override
  String get tagAlreadyExists_7281 => 'Tag already exists';

  @override
  String get tagCannotBeEmpty_4821 => 'Tag cannot be empty';

  @override
  String tagCount(Object count) {
    return '$count tags';
  }

  @override
  String tagCountWithMax_7281(Object count, Object max) {
    return '$count / $max tags';
  }

  @override
  String get tagFilterFailedJsonError_4821 =>
      'Tag filtering failed: JSON parsing error';

  @override
  String get tagLengthExceeded_4821 => 'Tag length cannot exceed 20 characters';

  @override
  String get tagManagement_7281 => 'Tag Management';

  @override
  String get tagNoSpacesAllowed_7281 => 'Tags cannot contain spaces';

  @override
  String targetFolderExists(Object newPath) {
    return 'Target folder already exists: $newPath';
  }

  @override
  String get targetPath_4821 => 'Target path';

  @override
  String targetPositionAdjustedToGroupEnd(Object adjustedNewIndex) {
    return 'Target position adjusted to the end of the group: $adjustedNewIndex';
  }

  @override
  String targetPositionInGroup_7281(Object adjustedNewIndex) {
    return 'Target position in group: $adjustedNewIndex';
  }

  @override
  String targetVersionExists_4821(Object newVersionId) {
    return 'Target version already exists: $newVersionId';
  }

  @override
  String get tempFileCleaned_7281 => 'Temporary files cleaned up';

  @override
  String tempFileCleanupError_4821(Object e) {
    return 'An error occurred while cleaning up temporary files: $e';
  }

  @override
  String get tempFileCleanupFailed_4821 => 'Failed to clean up temporary files';

  @override
  String get tempFileCleanupFailed_7421 => 'Failed to clean up temporary files';

  @override
  String tempFileCleanupTime(Object elapsedMilliseconds) {
    return 'Temporary file cleanup time: ${elapsedMilliseconds}ms';
  }

  @override
  String get tempFileCreated_7285 => 'Temporary file created successfully';

  @override
  String tempFileDeletionWarning(Object e) {
    return 'Warning: Failed to delete temporary file: $e';
  }

  @override
  String tempFileDeletionWarning_4821(Object e) {
    return 'Warning: Failed to delete temporary file: $e';
  }

  @override
  String tempFileDeletionWarning_7284(Object e) {
    return 'Warning: Failed to delete temporary file: $e';
  }

  @override
  String get tempFileExists_4821 =>
      '🔗 VfsPlatformIO: Temporary file already exists, returning path directly';

  @override
  String get tempFileGenerationFailed_4821 =>
      'Failed to generate temporary file';

  @override
  String get tempFileGenerationFailed_7281 =>
      'Failed to generate temporary file';

  @override
  String tempFolderCleanedSuccessfully(Object fullTempPath) {
    return '🗑️ Temporary folder cleaned successfully: $fullTempPath';
  }

  @override
  String tempFolderCleanupFailed(Object fullTempPath) {
    return '🗑️ Failed to clean up temp folder: $fullTempPath';
  }

  @override
  String tempFolderNotExist(Object fullTempPath) {
    return '🗑️ Temp folder does not exist, no need to clean: $fullTempPath';
  }

  @override
  String tempQueuePlayFailed_4829(Object e) {
    return 'Failed to play temporary queue - $e';
  }

  @override
  String temporaryQueuePlaybackFailed_4829(Object e) {
    return 'Failed to play temporary queue: $e';
  }

  @override
  String get temporaryTag_3456 => 'Temporary';

  @override
  String get temporaryTag_9012 => 'Temporary';

  @override
  String get temporary_3456 => 'Temporary';

  @override
  String get tenSeconds_4821 => '10 seconds';

  @override
  String get testConnection_4821 => 'Test connection';

  @override
  String testFailedMessage(Object e) {
    return 'Test failed: $e';
  }

  @override
  String get testMessage_4721 => 'This is a test message';

  @override
  String get testResourcePackageDescription_4822 =>
      'Sample resource package for testing external resource upload functionality';

  @override
  String get testResourcePackageName_4821 => 'Test resource package';

  @override
  String get testTag_4824 => 'Test';

  @override
  String get testUser_4823 => 'Test User';

  @override
  String get testVoice_7281 => 'Test Voice';

  @override
  String get testingInProgress_4821 => 'Testing in progress...';

  @override
  String get textBox_3180 => 'Text box';

  @override
  String get textContentLabel_4821 => 'Text content';

  @override
  String get textContent_4521 => 'Text content';

  @override
  String get textContent_4821 => 'Text content';

  @override
  String get textLabel_4821 => 'Text';

  @override
  String textModeCopyFailed_4821(Object e) {
    return 'Text mode copy also failed: $e';
  }

  @override
  String get textNoteLabel_4821 => 'Text Note';

  @override
  String get textTool_9034 => 'Text';

  @override
  String get textType_1234 => 'Text';

  @override
  String get text_4830 => 'Text';

  @override
  String get text_4831 => 'Text';

  @override
  String get thaiTH_4891 => 'Thai (Thailand)';

  @override
  String get thai_4837 => 'Thai';

  @override
  String get theme => 'Theme';

  @override
  String themeUpdateFailed(Object error) {
    return 'Failed to update theme settings: $error';
  }

  @override
  String throttleErrorImmediate(Object e, Object key) {
    return 'Throttle immediate execution error [$key]: $e';
  }

  @override
  String throttleError_7425(Object arg0, Object arg1) {
    return 'Throttle execution error [$arg0]: $arg1';
  }

  @override
  String get throttleLayerUpdate_7281 =>
      '=== Throttle Layer Update Execution ===';

  @override
  String throttleManagerReleased(Object count) {
    return 'ThrottleManager released, cleaned up $count timers';
  }

  @override
  String get timeSettings_7284 => 'Time Settings';

  @override
  String get timerCannotPauseCurrentState_7281 =>
      'The timer cannot be paused in its current state';

  @override
  String get timerCannotStartInCurrentState_4287 =>
      'Timer cannot start in current state';

  @override
  String get timerCannotStopCurrentState_4821 =>
      'The timer cannot be stopped in its current state';

  @override
  String get timerCompleted_4824 => 'Completed';

  @override
  String timerCompleted_7281(Object timerId) {
    return 'Timer completed: $timerId';
  }

  @override
  String timerCreated(Object id) {
    return 'Timer created: $id';
  }

  @override
  String timerCreationFailed(Object e) {
    return 'Failed to create timer: $e';
  }

  @override
  String timerDeleted(Object timerId) {
    return 'Timer deleted: $timerId';
  }

  @override
  String get timerIdExistsError_4821 => 'Timer ID already exists';

  @override
  String get timerInDevelopment_7421 => 'Timer feature is under development...';

  @override
  String get timerManagement_4271 => 'Timer Management';

  @override
  String get timerManagerCleaned_7281 => 'Timer manager has been cleaned';

  @override
  String get timerNameHint_4821 => 'Please enter the timer name';

  @override
  String get timerNameLabel_4821 => 'Timer name';

  @override
  String get timerNotExist_7281 => 'Timer does not exist';

  @override
  String get timerNotExist_7283 => 'Timer does not exist';

  @override
  String get timerNotExist_7284 => 'Timer does not exist';

  @override
  String timerPauseFailed_7285(Object e) {
    return 'Failed to pause timer: $e';
  }

  @override
  String get timerPaused_4823 => 'Paused';

  @override
  String timerPaused_7285(Object timerId) {
    return 'Timer paused: $timerId';
  }

  @override
  String get timerRunning_4822 => 'Running';

  @override
  String timerStartFailed(Object e) {
    return 'Failed to start timer: $e';
  }

  @override
  String timerStartFailed_7285(Object e) {
    return 'Failed to start timer: $e';
  }

  @override
  String timerStarted_7281(Object timerId) {
    return 'Timer started: $timerId';
  }

  @override
  String timerStopFailed_4821(Object e) {
    return 'Failed to stop timer: $e';
  }

  @override
  String get timerStopped_4821 => 'Stopped';

  @override
  String get timerStopped_7285 => 'Timer stopped';

  @override
  String get timerTypeLabel_7281 => 'Timer type';

  @override
  String timerUpdateFailed(Object e) {
    return 'Failed to update timer: $e';
  }

  @override
  String timerUpdateFailed_7284(Object e) {
    return 'Timer update failed: $e';
  }

  @override
  String titleFontSizeMultiplierText(Object value) {
    return 'Title font size multiplier: $value%';
  }

  @override
  String get titleHint_4821 => 'Enter home page title text';

  @override
  String get titleLabel_4521 => 'Title';

  @override
  String get titleLabel_4821 => 'Title text';

  @override
  String get titleSetting_1234 => 'Title Settings';

  @override
  String get title_5421 => 'Title';

  @override
  String get todo_5678 => 'To-do';

  @override
  String get toggleDebugMode_4721 => 'Toggle debug mode';

  @override
  String get toggleLeftSidebar_3857 => 'Toggle left sidebar';

  @override
  String get toggleLegendGroupDrawer_4824 => 'Toggle legend group drawer';

  @override
  String get toggleLegendManagementDrawer_3859 =>
      'Toggle legend management drawer';

  @override
  String toggleMuteFailed_7284(Object error) {
    return 'Failed to toggle mute: $error';
  }

  @override
  String get toggleSidebar_4822 => 'Toggle sidebar';

  @override
  String get tokenValidationFailedTimestampMissing_4821 =>
      'Token validation failed: timestamp missing';

  @override
  String get tokenValidationFailed_7281 =>
      'Token validation failed: Token has expired';

  @override
  String tokenValidationSuccess(Object clientId) {
    return 'Token validation successful: $clientId';
  }

  @override
  String tokenVerificationFailed_7421(Object e) {
    return 'Token verification failed: $e';
  }

  @override
  String get toneTitle_4821 => 'Tone';

  @override
  String get toolLabel_4821 => 'Tool';

  @override
  String toolPropertiesTitle_7421(Object toolName) {
    return '$toolName Properties';
  }

  @override
  String get toolSettingsReset_4821 => 'Tool settings have been reset';

  @override
  String toolSettingsUpdateFailed(Object error) {
    return 'Failed to update tool settings: $error';
  }

  @override
  String get toolSettings_4821 => 'Tool Settings';

  @override
  String get tool_6413 => 'Tool';

  @override
  String get toolbarLayout_4521 => 'Toolbar layout';

  @override
  String toolbarPositionSaved(Object toolbarId, Object x, Object y) {
    return 'Toolbar $toolbarId position saved: ($x, $y)';
  }

  @override
  String toolbarPositionSet(Object toolbarId, Object x, Object y) {
    return 'Extended settings: Toolbar $toolbarId position has been set to ($x, $y)';
  }

  @override
  String get toolbar_0123 => 'Toolbar';

  @override
  String get toolsTitle_7281 => 'Tools';

  @override
  String get topCenter_5678 => 'Top Center';

  @override
  String get topLeftCut_4822 => 'Top-left cut';

  @override
  String get topLeftTriangle_4821 => 'Top-left triangle';

  @override
  String get topLeft_1234 => 'Top left';

  @override
  String get topLeft_5723 => 'Top left';

  @override
  String get topRightCut_4823 => 'Top right cut';

  @override
  String get topRightTriangle_4821 => 'Top right triangle';

  @override
  String get topRight_6934 => 'Top right';

  @override
  String get topRight_9012 => 'Top right';

  @override
  String totalAccountsCount(Object count) {
    return '$count accounts in total';
  }

  @override
  String totalConfigsCount(Object count) {
    return '$count configurations in total';
  }

  @override
  String get totalCountLabel_4821 => 'Total';

  @override
  String get totalCount_7281 => 'Total quantity';

  @override
  String get totalCount_7421 => 'Total quantity';

  @override
  String get totalFilesCount_7284 => 'Total files';

  @override
  String get totalFiles_4821 => 'Total files';

  @override
  String totalImageCount(Object count) {
    return 'Total images: $count';
  }

  @override
  String get totalItemsCount_1345 => 'Total items count';

  @override
  String get totalLayers_5678 => 'Total';

  @override
  String totalLogsCount_7421(Object count) {
    return 'Total $count logs';
  }

  @override
  String get totalScriptsLabel_4821 => 'Total scripts';

  @override
  String get totalSize_4821 => 'Total size';

  @override
  String get total_5363 => 'Total';

  @override
  String get total_7284 => 'Total';

  @override
  String get touchBarSupport => 'Touch Bar support';

  @override
  String transformInfo(
    Object scaleX,
    Object scaleY,
    Object translateX,
    Object translateY,
  ) {
    return 'Transformation Info: Scale($scaleX, $scaleY), Translate($translateX, $translateY)';
  }

  @override
  String get transparencyLabel_4821 => 'Transparency';

  @override
  String get transparentLayer_7285 => 'Transparent Layer';

  @override
  String get trap_4830 => 'Trap';

  @override
  String get trap_4831 => 'Trap';

  @override
  String get triangleDivision_4821 => 'Triangle Division';

  @override
  String triangleHeightInfo(Object value) {
    return '- Triangle height: ${value}px (line spacing)';
  }

  @override
  String get triggerButton_7421 => 'Trigger button';

  @override
  String get tryDifferentKeywords_4829 =>
      'Try searching with different keywords';

  @override
  String get tryRightClickMenu_4821 => 'Try the right-click menu feature';

  @override
  String get ttsDisabledSkipPlayRequest_4821 =>
      'TTS is disabled, skipping playback request';

  @override
  String get ttsEmptySkipPlay_4821 => 'TTS text is empty, skipping playback';

  @override
  String ttsError_7285(Object msg) {
    return 'TTS error: $msg';
  }

  @override
  String get ttsInitializationComplete_7281 =>
      'TTS service initialization complete';

  @override
  String ttsInitializationFailed(Object e) {
    return 'TTS service initialization failed: $e';
  }

  @override
  String get ttsInitializationSuccess_7281 =>
      'TTS service initialized successfully';

  @override
  String ttsLanguageListError_4821(Object e) {
    return 'Failed to get TTS language list: $e';
  }

  @override
  String ttsLanguageListObtained(Object count) {
    return 'TTS languages obtained: $count languages';
  }

  @override
  String ttsListFetchFailed(Object e) {
    return 'Failed to fetch TTS voice list: $e';
  }

  @override
  String ttsListFetchFailed_7285(Object e) {
    return 'Failed to fetch TTS voice list: $e';
  }

  @override
  String ttsLoadFailed_7285(Object e) {
    return 'Failed to load TTS options: $e';
  }

  @override
  String get ttsNotInitialized_7281 => 'TTS not initialized, unable to play';

  @override
  String get ttsPlaybackCancelled_7421 => 'TTS playback canceled';

  @override
  String get ttsPlaybackComplete_7281 => 'TTS playback completed';

  @override
  String ttsPlaybackStart(Object sourceId, Object text) {
    return 'TTS started playing text: $text (source: $sourceId)';
  }

  @override
  String ttsRequestFailed_7421(Object e) {
    return 'Failed to process TTS request: $e';
  }

  @override
  String ttsRequestQueued(Object length, Object source, Object text) {
    return 'TTS request queued: \"$text\" (source: $source, queue length: $length)';
  }

  @override
  String ttsServiceFailed(Object e) {
    return 'Failed to stop TTS service: $e';
  }

  @override
  String get ttsSettingsReset_4821 => 'TTS settings have been reset';

  @override
  String get ttsSettingsTitle_4821 => 'TTS Speech Synthesis Settings';

  @override
  String ttsSpeedRangeLog(Object range) {
    return 'Get TTS speech speed range: $range';
  }

  @override
  String get ttsStartPlaying_7281 => 'TTS playback started';

  @override
  String get ttsStoppedQueueCleared_4821 => 'TTS stopped, queue cleared';

  @override
  String ttsTestFailed(Object error) {
    return 'TTS test failed: $error';
  }

  @override
  String ttsTestStartedPlaying(Object languageName) {
    return 'TTS test has started playing ($languageName)';
  }

  @override
  String get ttsTestText_4821 =>
      'This is a text-to-speech test, the current settings have been applied.';

  @override
  String ttsVoiceListCount(Object count) {
    return 'Fetch TTS voice list: $count voices';
  }

  @override
  String get turkishTR_4873 => 'Turkish (Turkey)';

  @override
  String get turkish_4872 => 'Turkish';

  @override
  String get twoPerPage_4822 => 'Two per page';

  @override
  String get twoSeconds_4271 => '2 seconds';

  @override
  String get typeLabel_4821 => 'Type';

  @override
  String get typeLabel_5421 => 'Type';

  @override
  String get type_4964 => 'Type';

  @override
  String get type_5161 => 'Type';

  @override
  String get uiControl_4821 => 'UI Control';

  @override
  String uiStateSyncedWithUnsavedChanges(Object _hasUnsavedChanges) {
    return 'UI state synced with reactive data, unsaved changes: $_hasUnsavedChanges';
  }

  @override
  String unableToOpenLink_7285(Object url) {
    return 'Unable to open link: $url';
  }

  @override
  String unableToOpenUrl(Object url) {
    return 'Unable to open link: $url';
  }

  @override
  String get undoAction_7421 => 'Undo';

  @override
  String get undoHistoryCount_4821 => 'Undo history count';

  @override
  String get undoOperation_7281 => 'Perform undo operation';

  @override
  String undoStepsLabel(Object count) {
    return '$count steps';
  }

  @override
  String get undo_3829 => 'Undo';

  @override
  String get undo_4822 => 'Undo';

  @override
  String unexpectedContentTypeWithResponse(
    Object contentType,
    Object responseBody,
  ) {
    return 'Unexpected content type: $contentType Response body: $responseBody';
  }

  @override
  String get ungroupAction_4821 => 'Ungroup';

  @override
  String get unknown => 'Unknown';

  @override
  String get unknownAccount_4821 => 'Unknown account';

  @override
  String get unknownClient_7281 => 'Unknown client';

  @override
  String get unknownClient_7284 => 'Unknown client';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get unknownError_7421 => 'Unknown error';

  @override
  String get unknownLabel_4721 => 'Unknown';

  @override
  String get unknownLegend_4821 => 'Unknown legend';

  @override
  String get unknownLegend_7632 => 'Unknown legend';

  @override
  String get unknownMap_4821 => 'Unknown map';

  @override
  String get unknownReason_7421 => 'Unknown reason';

  @override
  String unknownRemoteDataType_4721(Object type) {
    return 'Unknown remote data type: $type';
  }

  @override
  String get unknownSource_3632 => 'Unknown';

  @override
  String get unknownTask_7421 => 'Unknown task';

  @override
  String get unknownTime_4821 => 'Unknown';

  @override
  String get unknownToolLabel_4821 => 'Unknown tool';

  @override
  String get unknownTool_4833 => 'Unknown tool';

  @override
  String get unknownTooltip_4821 => 'Unknown tool';

  @override
  String get unknownVoice_4821 => 'Unknown voice';

  @override
  String get unknown_4822 => 'Unknown';

  @override
  String get unknown_9367 => 'Unknown';

  @override
  String get unlockElement_4271 => 'Unlock Element';

  @override
  String get unmute_4721 => 'Unmute';

  @override
  String get unmute_4821 => 'Unmute';

  @override
  String get unmute_5421 => 'Unmute';

  @override
  String get unnamedLayer_4821 => 'Unnamed layer';

  @override
  String get unnamedLegendGroup_4821 => 'Unnamed legend group';

  @override
  String get unsavedChangesPrompt_7421 => 'Are there any unsaved changes';

  @override
  String get unsavedChangesWarning_4821 =>
      'You have unsaved changes. Are you sure you want to close?';

  @override
  String get unsavedChangesWarning_7284 =>
      'You have unsaved changes. Are you sure you want to exit?';

  @override
  String get unsavedChanges_4271 => 'Unsaved changes';

  @override
  String get unsavedChanges_4821 => 'Unsaved changes';

  @override
  String get unsavedText_7421 => 'Unsaved';

  @override
  String get unselected_3633 => 'Unselected';

  @override
  String unsupportedFileType(Object extension) {
    return 'Unsupported file type: .$extension';
  }

  @override
  String get unsupportedFileType_4271 => 'Unsupported file type';

  @override
  String get unsupportedImageFormatError_4821 =>
      'Unsupported image format. Please select an image in JPG, PNG, GIF, or WebP format.';

  @override
  String unsupportedKey_7425(Object key) {
    return 'Unsupported key: $key';
  }

  @override
  String get unsupportedOrCorruptedImage_7281 =>
      'Unsupported or corrupted image format';

  @override
  String unsupportedProperty_7285(Object property) {
    return 'Unsupported property: $property';
  }

  @override
  String unsupportedUrlFormat(Object url) {
    return 'Unsupported link format: $url';
  }

  @override
  String get untitledNote_4721 => 'Untitled Note';

  @override
  String get untitledNote_4821 => 'Untitled Note';

  @override
  String get untitledNote_7281 => 'Untitled Note';

  @override
  String get upText_4821 => 'Up';

  @override
  String updateClientConfigFailed_7421(Object e) {
    return 'Failed to update client configuration: $e';
  }

  @override
  String get updateCompleteMessage_4821 =>
      '🎉 Update complete! This is the power of updateNotification';

  @override
  String updateConfigFailed_7421(Object error) {
    return 'Failed to update configuration: $error';
  }

  @override
  String get updateCoverFailed_4850 => 'Failed to update cover';

  @override
  String get updateCover_4853 => 'Update Cover';

  @override
  String updateCustomTagFailed(Object error) {
    return 'Failed to update custom tag: $error';
  }

  @override
  String updateDisplayOrderLog(Object layers) {
    return '_updateDisplayOrderAfterLayerChange() completed, _displayOrderLayers: $layers';
  }

  @override
  String get updateDisplayOrderLog_7281 =>
      'Calling _updateDisplayOrderAfterLayerChange()';

  @override
  String updateDrawingElement_7281(Object elementId, Object layerId) {
    return 'Update drawing element: $layerId/$elementId';
  }

  @override
  String updateElementFailed(Object e) {
    return 'Failed to update element: $e';
  }

  @override
  String updateElementSizeLog(Object elementId, Object newSize) {
    return 'Updated text size for element $elementId: $newSize';
  }

  @override
  String updateElementTextLog(Object elementId, Object newText) {
    return 'Update the text content of element $elementId to: \"$newText';
  }

  @override
  String updateExtensionSettingsFailed(Object error) {
    return 'Failed to update extension settings: $error';
  }

  @override
  String get updateExternalResources_4970 => 'Update External Resources';

  @override
  String updateFailedWithError(Object error) {
    return 'Update failed: $error';
  }

  @override
  String updateFailed_4925(Object error) {
    return 'Update failed: $error';
  }

  @override
  String get updateFailed_4988 => 'Update failed';

  @override
  String updateHomeSettingsFailed(Object error) {
    return 'Failed to update home settings: $error';
  }

  @override
  String updateLayerDebug(Object id, Object name) {
    return 'Update layer: $name, ID: $id';
  }

  @override
  String updateLayerElementProperty_7421(
    Object elementId,
    Object layerId,
    Object property,
  ) {
    return 'Update property $property of element $elementId in layer $layerId';
  }

  @override
  String updateLayerElementWithReactiveSystem(
    Object layerId,
    Object elementId,
  ) {
    return 'Update layer drawing element with reactive system: $layerId/$elementId';
  }

  @override
  String updateLayerLog(Object isLinkedToNext, Object name) {
    return 'Updating layer: $name, isLinkedToNext: $isLinkedToNext';
  }

  @override
  String get updateLayerReactiveCall_7281 => '=== updateLayerReactive call ===';

  @override
  String get updateLayerReactiveComplete_7281 =>
      '=== updateLayerReactive complete ===';

  @override
  String updateLayoutFailed(Object error) {
    return 'Failed to update layout settings: $error';
  }

  @override
  String updateLegendDataFailed_7284(Object e) {
    return 'Failed to update legend data: $e';
  }

  @override
  String updateLegendFailed(Object error) {
    return 'Failed to update legend: $error';
  }

  @override
  String updateLegendGroupFailed(Object error) {
    return 'Failed to update legend group: $error';
  }

  @override
  String updateLegendGroupLog(Object groupId) {
    return 'Update legend group $groupId';
  }

  @override
  String updateLegendGroupWithReactiveSystem(Object name) {
    return 'Update legend group with reactive system: $name';
  }

  @override
  String updateLegendGroup_7421(Object name) {
    return 'Integration Adapter: Update Legend Group $name';
  }

  @override
  String updateLegendItem_7425(Object itemId) {
    return 'Update legend item $itemId';
  }

  @override
  String updateMapTitleFailed(Object e) {
    return 'Failed to update map title: $e';
  }

  @override
  String updateMetadata_4829(Object metadata) {
    return 'Update metadata: $metadata';
  }

  @override
  String updateNoteDebug(Object id) {
    return 'Update note: $id';
  }

  @override
  String updateNoteElementProperty(
    Object elementId,
    Object noteId,
    Object property,
  ) {
    return 'Update property $property of element $elementId in note $noteId';
  }

  @override
  String updateNoteFailed(Object e) {
    return 'Failed to update note: $e';
  }

  @override
  String updateNoteFailed_7284(Object e) {
    return 'Failed to update note: $e';
  }

  @override
  String updateRecentColorsFailed(Object e) {
    return 'Failed to update recent colors: $e';
  }

  @override
  String updateShortcutFailed_7421(Object error) {
    return 'Failed to update map editor shortcut: $error';
  }

  @override
  String updateStickyNoteElement(Object elementId, Object noteId) {
    return 'Update sticky note drawing element using responsive system: $noteId/$elementId';
  }

  @override
  String get updateTimeChanged_4821 => 'Update time changed';

  @override
  String get updateTitle_4271 => 'Update Title';

  @override
  String updateUserInfoFailed_7421(Object error) {
    return 'Failed to update user information: $error';
  }

  @override
  String updateVersionMetadata_7421(Object mapTitle, Object versionId) {
    return 'Update version metadata [$mapTitle/$versionId]';
  }

  @override
  String updateVersionName(Object arg0, Object arg1, Object arg2) {
    return 'Update version name [$arg0/$arg1]: $arg2';
  }

  @override
  String updateVersionSessionData_4821(
    Object isModified,
    Object layerCount,
    Object mapTitle,
    Object versionId,
  ) {
    return 'Update version session data [$mapTitle/$versionId], marked as $isModified, layer count: $layerCount';
  }

  @override
  String updatedLayerLabels_7281(Object labels) {
    return 'Updated layer labels: $labels';
  }

  @override
  String updatedLegendCount(Object length) {
    return 'Updated legend count: $length';
  }

  @override
  String updatedLegendItemsCount(Object count) {
    return 'Updated legend items count: $count';
  }

  @override
  String updatingCachedLegendsList(Object currentLegendGroupId) {
    return '[CachedLegendsDisplay] Starting to update cached legends list. Current legend group ID: $currentLegendGroupId';
  }

  @override
  String get uploadBackgroundImage_5421 => 'Upload background image';

  @override
  String get uploadButton_7284 => 'Upload';

  @override
  String get uploadDescription_4971 =>
      'Upload a ZIP file containing external resources. The system will automatically extract and copy resources to specified locations based on the metadata file.';

  @override
  String uploadFailedWithError(Object error) {
    return 'Upload failed: $error';
  }

  @override
  String get uploadFiles_4821 => 'Upload Files';

  @override
  String get uploadFiles_4971 => 'Upload Files';

  @override
  String uploadFolderFailed_4821(Object error) {
    return 'Upload folder failed: $error';
  }

  @override
  String uploadFolderSuccess_4821(Object count, Object folderName) {
    return 'Successfully uploaded folder \"$folderName\" with $count files';
  }

  @override
  String get uploadFolder_4821 => 'Upload Folder';

  @override
  String get uploadFolder_4972 => 'Upload Folder';

  @override
  String get uploadImageToBuffer_4521 => 'Click to upload image to buffer';

  @override
  String get uploadImageToBuffer_5421 => 'Click to upload image to buffer';

  @override
  String get uploadImage_5739 => 'Upload Image';

  @override
  String get uploadImage_7421 => 'Upload image';

  @override
  String get uploadLocalImage_4271 => 'Upload local image';

  @override
  String uploadLocalizationFailed_7421(Object error) {
    return 'Failed to upload localization file: $error';
  }

  @override
  String get uploadToWebDAV_4969 => 'Upload to WebDAV';

  @override
  String get upload_4821 => 'Upload';

  @override
  String get uploadingToWebDAV_5008 => 'Uploading to WebDAV...';

  @override
  String get uploading_4968 => 'Uploading...';

  @override
  String get urgentTag_5678 => 'Urgent';

  @override
  String urlOpenFailed_7285(Object e) {
    return 'Failed to open the link: $e';
  }

  @override
  String get urlRouting => 'URL Routing';

  @override
  String get usageHint_4521 => 'Usage hint:';

  @override
  String get usageInstructions_4521 => 'Usage Instructions';

  @override
  String get usageInstructions_4821 => 'Usage Instructions';

  @override
  String get usageInstructions_4976 => 'Usage Instructions';

  @override
  String get usageRequirementsHint_4940 =>
      'e.g.: No unauthorized redistribution, for educational use only, attribution required, etc.';

  @override
  String get usageRequirements_4939 => 'Usage Requirements';

  @override
  String get useGetAllUsersAsyncMethod =>
      'Please use the getAllUsersAsync() method';

  @override
  String get useLegacyReorderMethod_4821 => 'Use legacy reorder method';

  @override
  String get useLoadedLegendData_7281 => '- Use loaded legend data';

  @override
  String get useNetworkImageUrl_4821 => 'Use network image URL';

  @override
  String get useReactiveSystemUndo_7281 => 'Undo using reactive system';

  @override
  String get useSystemColorTheme_4821 => 'Use system color theme';

  @override
  String get useToolbarToCreateFolder_4821 =>
      'Use toolbar button to create folder';

  @override
  String get userCanceledSaveOperation_9274 =>
      'The user canceled the save operation';

  @override
  String userConfigDeleted(Object userId) {
    return 'User configuration deleted: $userId';
  }

  @override
  String userCreationFailed_7421(Object error) {
    return 'Failed to create user: $error';
  }

  @override
  String userFieldAdded(Object userId) {
    return 'The windowControlsMode field has been added for user $userId';
  }

  @override
  String get userFile_4521 => 'User File';

  @override
  String get userFile_4821 => 'User File';

  @override
  String get userInfoSetSkipped_7281 =>
      'User info already set, skipping duplicate setup';

  @override
  String get userInfoUpdated_7421 => 'User information has been updated';

  @override
  String userJoined_7425(Object displayName, Object userId) {
    return 'User $displayName ($userId)';
  }

  @override
  String userLeft_7421(Object userId) {
    return 'User $userId left';
  }

  @override
  String get userManagement_4521 => 'User Management';

  @override
  String get userName_7284 => 'Username';

  @override
  String userOfflinePreviewAddedToLayer(Object targetLayerId) {
    return 'User offline, preview processed directly and added to layer $targetLayerId';
  }

  @override
  String get userPermissionsTitle_7281 => 'User Permissions';

  @override
  String get userPermissions_7281 => 'User Permissions';

  @override
  String userPreferenceCloseFailed(Object e) {
    return 'Failed to close user preference service: $e';
  }

  @override
  String userPreferenceDbUpgrade_7421(Object newVersion, Object oldVersion) {
    return 'User preferences database upgraded from version $oldVersion to $newVersion';
  }

  @override
  String userPreferenceInitFailed_7421(Object e) {
    return 'User preference service initialization failed: $e';
  }

  @override
  String get userPreferences => 'User Preferences';

  @override
  String get userPreferencesInitComplete_4821 =>
      'User preferences configuration management system initialization completed';

  @override
  String get userPreferencesInitialized_7281 =>
      'User preferences service initialization completed';

  @override
  String userPreferencesMigrationComplete(Object migratedUsersCount) {
    return 'User preferences migration completed, $migratedUsersCount users migrated';
  }

  @override
  String get userPreferencesMigration_7281 =>
      'Performing user preferences data migration...';

  @override
  String userPreferencesSavedToDatabase(Object displayName) {
    return 'User preferences saved to database: $displayName';
  }

  @override
  String userPreferencesSaved_7281(Object displayName) {
    return 'User preferences saved: $displayName';
  }

  @override
  String get userPreferencesTableCreated_7281 =>
      'User preferences database table created successfully';

  @override
  String get userPreferences_4821 => 'User Preferences';

  @override
  String userPrefsInitFailed_4829(Object e) {
    return 'Failed to initialize user preferences: $e';
  }

  @override
  String get userStateInitFailed_4821 => 'Failed to initialize user state';

  @override
  String get userStateRemoved_4821 => 'User state removed';

  @override
  String userStatusBroadcastError_4821(Object error) {
    return 'Error processing user status broadcast: $error';
  }

  @override
  String userStatusBroadcast_7421(
    Object activityStatus,
    Object onlineStatus,
    Object spaceId,
    Object userId,
  ) {
    return 'User status broadcast: user=$userId, online status=$onlineStatus, activity status=$activityStatus, space=$spaceId';
  }

  @override
  String userStatusChangeBroadcast(Object currentStatus, Object newStatus) {
    return 'User status changed, preparing to broadcast: $currentStatus -> $newStatus';
  }

  @override
  String get userStatusUnchangedSkipBroadcast_4821 =>
      'User status unchanged, skipping broadcast';

  @override
  String userStatusWithName(Object statusText) {
    return 'Me: $statusText';
  }

  @override
  String get user_4821 => 'User';

  @override
  String get usernameLabel_4521 => 'Username';

  @override
  String get usernameLabel_5421 => 'Username';

  @override
  String get usernameRequired_4821 => 'Please enter your username';

  @override
  String usersEditingCount(Object count) {
    return '$count people editing';
  }

  @override
  String get valid_4821 => 'Valid';

  @override
  String get valid_8421 => 'Valid';

  @override
  String get validatingFilePaths_4919 => 'Validating file paths...';

  @override
  String get validatingMetadataFile_4821 => 'Validating metadata file...';

  @override
  String validationError_7285(Object error) {
    return 'Validation error: $error';
  }

  @override
  String get verifiedAccountTitle_4821 => 'Verified Account';

  @override
  String get verifiedAccount_7281 => 'Verified account';

  @override
  String versionAdapterExists_7281(Object condition) {
    return 'Version adapter exists: $condition';
  }

  @override
  String versionCount_7281(Object count) {
    return 'Version count: $count';
  }

  @override
  String versionCreatedAndSwitched_7281(Object versionId) {
    return 'New version created and switched: $versionId';
  }

  @override
  String versionCreatedMessage_7421(
    Object sessionDataStatus,
    Object versionId,
  ) {
    return 'New version created: $versionId, session data=$sessionDataStatus';
  }

  @override
  String versionCreated_7421(Object name) {
    return 'Version \"$name\" has been created';
  }

  @override
  String versionCreationFailed(Object error) {
    return 'Version creation failed: $error';
  }

  @override
  String versionCreationFailed_7285(Object e) {
    return 'Failed to create version: $e';
  }

  @override
  String versionCreationStart(Object sourceVersionId, Object versionId) {
    return 'Start creating new version: $versionId, source version: $sourceVersionId';
  }

  @override
  String versionCreationStatus(Object currentVersionId, Object layerCount) {
    return 'Pre-version creation status: Current version=$currentVersionId, Current map layers=$layerCount';
  }

  @override
  String versionDataLoaded(
    Object layerCount,
    Object legendGroupCount,
    Object stickyNoteCount,
    Object versionId,
  ) {
    return 'Version $versionId data has been loaded into the session, layers: $layerCount, legend groups: $legendGroupCount, sticky notes: $stickyNoteCount';
  }

  @override
  String versionDataSaved_7281(Object activeVersionId) {
    return 'Version data saved [$activeVersionId] successfully';
  }

  @override
  String versionDataTitleEmpty_7281(Object versionId) {
    return 'Version data title is empty: $versionId';
  }

  @override
  String versionDeletedComplete(Object versionId) {
    return 'Version deleted successfully: $versionId';
  }

  @override
  String versionDeletedLog(Object versionId) {
    return 'Version deleted successfully [$versionId]';
  }

  @override
  String get versionDeletedSuccessfully_7281 =>
      'The version has been completely deleted';

  @override
  String versionExistsInReactiveSystem_7421(Object versionId) {
    return 'Version $versionId already exists in the reactive system, but data loading needs to be confirmed';
  }

  @override
  String versionExists_7284(Object version) {
    return 'Version already exists: $version';
  }

  @override
  String versionExists_7285(Object versionId) {
    return 'Version already exists: $versionId';
  }

  @override
  String versionFetchFailed(Object e, Object mapTitle, Object versionId) {
    return 'Failed to fetch version name [$mapTitle:$versionId]: $e';
  }

  @override
  String get versionHint_4936 => 'e.g.: 1.0.0';

  @override
  String versionLegendGroupStatusPath(
    Object legendGroupId,
    Object path,
    Object status,
    Object versionId,
  ) {
    return 'Version $versionId Legend Group $legendGroupId $status Path: $path';
  }

  @override
  String versionLoadFailed_7281(Object e, Object versionId) {
    return 'Failed to load version $versionId: $e';
  }

  @override
  String versionLoadFailure_7285(Object e) {
    return 'Failed to load version from VFS: $e';
  }

  @override
  String versionLoadedFromVfs_7281(Object length) {
    return 'Completed loading versions from VFS, $length versions in total in the reactive system';
  }

  @override
  String versionLoadedToReactiveSystem(Object versionId, Object versionName) {
    return 'Version loaded to reactive system: $versionId ($versionName)';
  }

  @override
  String get versionManagement_4821 => 'Version Management';

  @override
  String versionManagerStatusChanged_7281(Object summary) {
    return 'Version manager status changed: $summary';
  }

  @override
  String versionMetadataDeletedSuccessfully(Object arg0) {
    return 'Version metadata deleted successfully [$arg0]';
  }

  @override
  String versionMetadataReadFailed(Object e) {
    return 'Failed to read version metadata, a new file will be created: $e';
  }

  @override
  String versionMetadataSaveFailed(
    Object e,
    Object mapTitle,
    Object versionId,
  ) {
    return 'Failed to save version metadata [$mapTitle:$versionId]: $e';
  }

  @override
  String versionMetadataSaveFailed_7421(Object e) {
    return 'Failed to save version metadata: $e';
  }

  @override
  String versionMetadataSaved_7281(
    Object mapTitle,
    Object versionId,
    Object versionName,
  ) {
    return 'Version metadata saved successfully [$mapTitle:$versionId -> $versionName]';
  }

  @override
  String get versionMismatch_4823 => 'Version mismatch';

  @override
  String get versionNameHint_4822 => 'Enter version name';

  @override
  String get versionNameLabel_4821 => 'Version name';

  @override
  String versionNameMapping_7281(Object versionNames) {
    return 'Version name mapping: $versionNames';
  }

  @override
  String versionNoSessionDataToSave(Object activeVersionId) {
    return 'Version [$activeVersionId] has no session data to save';
  }

  @override
  String versionNoSessionData_7281(Object versionId) {
    return 'Version $versionId has no session data, attempting to load from VFS';
  }

  @override
  String versionNotExistNeedDelete(Object versionId) {
    return 'Version does not exist, no need to delete: $versionId';
  }

  @override
  String versionNotFoundCannotUpdate(Object versionId) {
    return 'Version does not exist, cannot update data: $versionId';
  }

  @override
  String versionNotFoundError(Object versionId) {
    return 'Version does not exist: $versionId';
  }

  @override
  String versionNotFoundError_4821(Object versionId) {
    return 'Version does not exist: $versionId';
  }

  @override
  String versionNotFoundError_7284(Object versionId) {
    return 'Version does not exist: $versionId';
  }

  @override
  String versionNotFoundUsingDefault_7281(Object versionId) {
    return 'Version $versionId does not exist, using base data as initial data';
  }

  @override
  String versionOrSessionNotFound(Object versionId) {
    return 'Version or session data not found, unable to update legend group: $versionId';
  }

  @override
  String versionPathSelection_7281(Object versionId) {
    return 'Target version $versionId path selection:';
  }

  @override
  String versionSaveFailed_7281(Object error, Object versionId) {
    return 'Failed to save version data [$versionId]: $error';
  }

  @override
  String versionSavedLog(Object arg0, Object arg1) {
    return 'Version marked as saved [$arg0/$arg1]';
  }

  @override
  String versionSavedToMetadata(Object name, Object versionId) {
    return 'Version name saved to metadata: $name (ID: $versionId)';
  }

  @override
  String versionSessionCacheMissing_7421(Object key) {
    return 'Warning: Session data cache missing for version $key';
  }

  @override
  String versionSessionDataMissing_7281(Object versionId) {
    return 'Version session data does not exist: $versionId';
  }

  @override
  String versionSessionUsage_7281(Object layersCount, Object versionId) {
    return 'Version $versionId session usage data, layers count: $layersCount';
  }

  @override
  String versionStatusDebug(Object hasSessionData, Object hasUnsavedChanges) {
    return 'Version status: has session data=$hasSessionData, has unsaved changes=$hasUnsavedChanges';
  }

  @override
  String versionStatusNotFound(Object versionId) {
    return 'Version status does not exist: $versionId';
  }

  @override
  String versionStatusUpdated_7281(Object count) {
    return 'Version status updated, version count: $count';
  }

  @override
  String versionSwitchCleanPath(Object legendGroupId, Object path) {
    return 'Version Switch - Clean Path: [$legendGroupId] $path';
  }

  @override
  String versionSwitchComplete(Object previousVersionId, Object versionId) {
    return 'Smart version switch completed: $previousVersionId -> $versionId';
  }

  @override
  String versionSwitchCompleteResetFlag(Object versionId) {
    return 'Version switch completed, reset update flag [$versionId]';
  }

  @override
  String versionSwitchFailed(Object e) {
    return 'Version switch failed: $e';
  }

  @override
  String versionSwitchLog_7421(
    Object mapTitle,
    Object previousVersionId,
    Object versionId,
  ) {
    return 'Version switched [$mapTitle]: $previousVersionId -> $versionId';
  }

  @override
  String versionSwitchPath_4821(Object legendGroupId, Object path) {
    return 'Version Switch - Loading Path: [$legendGroupId] $path';
  }

  @override
  String versionSwitchStart(Object previousVersionId, Object versionId) {
    return 'Start smart version switching: $previousVersionId -> $versionId';
  }

  @override
  String versionSystemInitialized(Object currentVersionId) {
    return 'Responsive version management system initialized, current version: $currentVersionId';
  }

  @override
  String get versionWarning_4821 =>
      'Warning: Neither version has path selection data';

  @override
  String versionWarning_7284(Object versionId) {
    return 'Warning: New version [$versionId] has no initial data';
  }

  @override
  String get version_4935 => 'Version *';

  @override
  String get version_5027 => 'Version';

  @override
  String get verticalLayoutNavBar_4821 =>
      'Display the navigation bar on the right side of the screen (vertical layout)';

  @override
  String get vfsCleanupComplete_7281 => 'VFS data cleanup completed';

  @override
  String vfsCleanupFailed_7281(Object e) {
    return 'VFS cleanup failed: $e';
  }

  @override
  String vfsDatabaseCloseFailure(Object e) {
    return 'Failed to close VFS storage database: $e';
  }

  @override
  String vfsDatabaseExportSuccess(Object dbVersion, Object mapCount) {
    return 'VFS map database exported successfully (Version: $dbVersion, Map count: $mapCount)';
  }

  @override
  String vfsDirectoryLoadFailed_7421(Object e) {
    return 'VFS directory tree: failed to load $e';
  }

  @override
  String vfsDirectoryTreeBuilt_7281(Object count) {
    return 'VFS directory tree: Built successfully, root node contains $count child nodes';
  }

  @override
  String vfsDirectoryTreeCreateNode(
    Object currentPath,
    Object parentName,
    Object parentPath,
    Object segment,
  ) {
    return 'VFS directory tree: Create node \"$segment\" (path: $currentPath), add to parent node \"$parentName\" (path: $parentPath)';
  }

  @override
  String vfsDirectoryTreeLoaded(Object count) {
    return 'VFS directory tree: loaded successfully, root node contains $count subdirectories';
  }

  @override
  String vfsDirectoryTreeProcessingPath(
    Object folderPath,
    Object pathSegments,
  ) {
    return 'VFS directory tree: Processing path \"$folderPath\", segments: $pathSegments';
  }

  @override
  String vfsDirectoryTreeStartBuilding(Object count) {
    return 'VFS directory tree: Start building, number of input folders: $count';
  }

  @override
  String vfsEntryCount(Object count) {
    return 'Number of entries returned by VFS: $count';
  }

  @override
  String vfsErrorClosing_5421(Object e) {
    return 'An error occurred while closing the VFS system: $e';
  }

  @override
  String vfsFileInfoError(Object e) {
    return 'Failed to get VFS file info: $e';
  }

  @override
  String vfsFileInfoError_4821(Object e) {
    return 'Failed to get VFS file info: $e';
  }

  @override
  String get vfsFileLabel_4822 => 'VFS File';

  @override
  String get vfsFileManager_4821 => 'VFS File Manager';

  @override
  String get vfsFilePickerStyle_4821 => 'VFS file picker style';

  @override
  String vfsImageLoadFailed(Object e) {
    return 'Failed to load VFS image: $e';
  }

  @override
  String vfsInitFailed_7281(Object e) {
    return 'VFS system initialization failed: $e';
  }

  @override
  String get vfsInitializationComplete_7281 =>
      'App VFS system initialization complete';

  @override
  String vfsInitializationFailed_7421(Object e) {
    return 'Failed to initialize the application VFS system: $e';
  }

  @override
  String get vfsInitializationSkipped_7281 =>
      'VFS permission system already initialized, skipping duplicate initialization';

  @override
  String get vfsInitializationStart_7281 =>
      'Starting VFS root filesystem initialization...';

  @override
  String get vfsInitializationSuccess_7281 =>
      'VFS system initialized successfully';

  @override
  String get vfsInitializedSkipDb_4821 =>
      'The VFS system has been initialized globally, skipping default database initialization';

  @override
  String get vfsInitialized_7281 =>
      'VFS system initialized, skipping duplicate initialization';

  @override
  String get vfsLegendDirectory_4821 => 'VFS legend directory';

  @override
  String get vfsLegendDirectory_7421 => 'VFS Legend Directory';

  @override
  String vfsLinkOpenFailed(Object e) {
    return 'Failed to open VFS link: $e';
  }

  @override
  String vfsMapDbImportFailed(Object e) {
    return 'VFS map database import failed: $e';
  }

  @override
  String get vfsMapDbImportNotImplemented_7281 =>
      'VFS map database import feature is not yet implemented';

  @override
  String vfsMapExportFailed(Object e) {
    return 'VFS map database export failed: $e';
  }

  @override
  String get vfsMarkdownRendererCleanedTempFiles_7281 =>
      '🔗 VfsMarkdownRenderer: Temporary files cleaned up';

  @override
  String vfsNodeExists_7281(Object currentPath) {
    return 'VFS directory tree: Node already exists: $currentPath';
  }

  @override
  String get vfsPlatformIOCleanedTempFiles_7281 =>
      '🔗 VfsPlatformIO: Temporary files cleaned';

  @override
  String get vfsPlatformIOCreatingTempFile_4821 =>
      '🔗 VfsPlatformIO: Creating temporary file';

  @override
  String vfsProviderCloseFailed(Object e) {
    return 'Failed to close VFS service provider: $e';
  }

  @override
  String get vfsRootExists_7281 =>
      'VFS root filesystem already exists, skipping initialization';

  @override
  String vfsRootInitFailed(Object e) {
    return 'VFS root filesystem initialization failed: $e';
  }

  @override
  String get vfsRootInitialized_7281 =>
      'VFS root filesystem initialization completed';

  @override
  String get vfsServiceNoNeedToClose_7281 =>
      'VFS service does not need to be explicitly closed';

  @override
  String get vfsShutdownComplete_7281 => 'VFS system shutdown completed';

  @override
  String vfsShutdownTime(Object elapsedMilliseconds) {
    return 'VFS system shutdown time: ${elapsedMilliseconds}ms';
  }

  @override
  String vfsTreeWarningParentNotFound(Object parentPath) {
    return 'VFS tree: Warning - Parent node not found: $parentPath';
  }

  @override
  String vfsVersionDeletedSuccessfully(Object versionId) {
    return 'VFS version data deleted successfully: $versionId';
  }

  @override
  String get vfsVersionNotImplemented_7281 =>
      'VFS version management is not yet implemented';

  @override
  String get videoConversionComplete_7281 =>
      '🎥 VideoProcessor.convertMarkdownVideos: Conversion complete';

  @override
  String videoCountLabel_7281(Object videoCount) {
    return 'Videos: $videoCount';
  }

  @override
  String videoElementCreationLog(Object attributes, Object tag) {
    return '🎥 VideoSyntax.onMatch: Creating video element - tag: $tag, attributes: $attributes';
  }

  @override
  String get videoFile_4821 => 'Video file';

  @override
  String get videoFile_5732 => 'Video file';

  @override
  String get videoFile_7421 => 'Video file';

  @override
  String get videoFormats_7281 => '• Video: mp4, avi, mov, wmv';

  @override
  String videoInfoLoadFailed(Object e) {
    return 'Failed to load video info: $e';
  }

  @override
  String get videoInfo_4271 => 'Video Info';

  @override
  String get videoInfo_4821 => 'Video Info';

  @override
  String get videoInfo_7421 => 'Video Info';

  @override
  String get videoLinkCopiedToClipboard_4821 =>
      'Video link copied to clipboard';

  @override
  String get videoLoadFailed_4821 => 'Video failed to load';

  @override
  String get videoLoadFailed_7281 => 'Video failed to load';

  @override
  String get videoNodeAddedToParent_7281 =>
      '🎥 HtmlToSpanVisitor: VideoNode has been added to the parent node';

  @override
  String videoNodeBuildLog(Object src) {
    return '🎥 VideoNode.build: Returns WidgetSpan - MediaKitVideoPlayer(url: $src)';
  }

  @override
  String videoNodeBuildStart(Object src) {
    return 'Start building - src: $src';
  }

  @override
  String videoNodeCreationLog(Object attributes, Object textContent) {
    return '🎥 VideoNode: Creating node - attributes: $attributes, textContent: $textContent';
  }

  @override
  String videoNodeGenerationLog(
    Object attributes,
    Object tag,
    Object textContent,
  ) {
    return '🎥 VideoProcessor: Generating VideoNode - tag: $tag, attributes: $attributes, textContent: $textContent';
  }

  @override
  String videoProcessorConvertMarkdownVideos_7425(Object src) {
    return 'VideoProcessor.convertMarkdownVideos: Convert $src';
  }

  @override
  String get videoProcessorCreated_4821 =>
      '🎥 VideoProcessor: Video generator created';

  @override
  String videoProcessorDebug(Object result, Object textLength) {
    return '🎥 VideoProcessor.containsVideo: text length=$textLength, contains video=$result';
  }

  @override
  String get videoProcessorStartConversion_7281 =>
      '🎥 VideoProcessor.convertMarkdownVideos: Starting conversion';

  @override
  String videoStatusLabel_4829(Object status) {
    return 'Video $status';
  }

  @override
  String get videoSyntaxParserAdded_7281 =>
      '🎥 _buildMarkdownContent: Added video syntax parser and generator';

  @override
  String get videoTagDetected_7281 =>
      '🎥 HtmlToSpanVisitor: Video tag detected, creating VideoNode';

  @override
  String videoTagMatched(Object matchValue) {
    return 'Video tag matched - $matchValue';
  }

  @override
  String get vietnameseVN_4892 => 'Vietnamese (Vietnam)';

  @override
  String get vietnamese_4838 => 'Vietnamese';

  @override
  String get viewDetails_4821 => 'View Details';

  @override
  String get viewEditShortcutSettings_4821 =>
      'Click to view and edit all shortcut settings';

  @override
  String get viewExecutionLogs_4821 => 'View execution logs';

  @override
  String get viewFolderPermissions_4821 => 'View Folder Permissions';

  @override
  String get viewFullLicenseList_7281 => 'View full license list';

  @override
  String viewItemDetails_7421(Object item) {
    return 'View $item details';
  }

  @override
  String viewProjectDetails(Object index) {
    return 'View project $index details';
  }

  @override
  String get viewShortcutList_7281 => 'View shortcut list';

  @override
  String get view_4821 => 'View';

  @override
  String get view_4822 => 'View';

  @override
  String get viewingStatus_5723 => 'Viewing';

  @override
  String get viewingStatus_5732 => 'Viewing';

  @override
  String get viewingStatus_6943 => 'Viewing';

  @override
  String get viewingStatus_7532 => 'Viewing';

  @override
  String get visualEffectsSettings_4821 => 'Visual Effects Settings';

  @override
  String voiceLog_7288(Object voice) {
    return ', voice: $voice';
  }

  @override
  String get voiceNoteLabel_7281 => 'Voice Note';

  @override
  String get voiceNote_7281 => 'Voice note';

  @override
  String get voiceSpeed_4251 => 'Voice speed';

  @override
  String get voiceSynthesisEmptyText_7281 =>
      'Voice synthesis: Text is empty, skipping';

  @override
  String voiceSynthesisFailed_7281(Object e) {
    return 'Voice synthesis failed: $e';
  }

  @override
  String voiceSynthesisLog_7283(Object text) {
    return 'Voice synthesis: \"$text';
  }

  @override
  String voiceSynthesisLog_7285(Object text) {
    return 'Processing voice synthesis: text=\"$text';
  }

  @override
  String get voiceTitle_4271 => 'Voice';

  @override
  String get volumeControl_4821 => 'Volume Control';

  @override
  String get volumeControl_7281 => 'Volume Control';

  @override
  String get volumeLabel_4821 => 'Volume';

  @override
  String get volumeLabel_8472 => 'Volume';

  @override
  String volumeLog_7286(Object volume) {
    return ', volume: $volume';
  }

  @override
  String volumePercentage(Object percentage) {
    return 'Volume: $percentage%';
  }

  @override
  String volumeSetTo(Object percentage) {
    return 'Volume set to $percentage%';
  }

  @override
  String volumeSettingFailed_7285(Object e) {
    return 'Failed to set volume: $e';
  }

  @override
  String get volumeTitle_4821 => 'Volume';

  @override
  String get waitingUserConfirmImport_5041 =>
      'Waiting for user to confirm import...';

  @override
  String get waitingUserSelectImport_5025 =>
      'Waiting for user to select import items...';

  @override
  String get wall_4826 => 'Wall';

  @override
  String warningCannotLoadStickerImage(Object imageHash) {
    return 'Warning: Unable to load sticker drawing element image from asset system, hash: $imageHash';
  }

  @override
  String warningCannotLoadStickyNoteBackground(Object backgroundImageHash) {
    return 'Warning: Failed to load sticky note background image from assets system, hash: $backgroundImageHash';
  }

  @override
  String warningFailedToLoadNoteDrawingElement(Object imageHash) {
    return 'Warning: Failed to load note drawing element image from asset system, hash: $imageHash';
  }

  @override
  String warningFailedToLoadStickyNoteBackground_7285(
    Object backgroundImageHash,
  ) {
    return 'Warning: Failed to load sticky note background image from asset system, hash: $backgroundImageHash';
  }

  @override
  String warningLayerBackgroundLoadFailed(Object hash) {
    return 'Warning: Failed to load layer background image from asset system, hash: $hash';
  }

  @override
  String get warningMessage_7284 => 'Warning message';

  @override
  String get warningSourcePathNotExists_5003 =>
      'Warning: Source path does not exist, skipping';

  @override
  String get warning_6643 => 'Warning';

  @override
  String get warning_7281 => 'Warning';

  @override
  String webApiKeyClientConfigFailed(Object e) {
    return 'Failed to create client configuration using Web API Key: $e';
  }

  @override
  String get webApiKeyHint_7532 => 'Enter Web API Key';

  @override
  String get webApiKeyLabel_4821 => 'Web API Key';

  @override
  String get webApis => 'Web API';

  @override
  String get webBrowser_5732 => 'Web Browser';

  @override
  String get webClipboardNotSupported_7281 =>
      'The web platform does not support platform-specific clipboard reading implementations.';

  @override
  String get webContextMenuDemoTitle_4721 => 'Web Context Menu Demo';

  @override
  String get webContextMenuExample_7281 =>
      'Web-compatible right-click menu example';

  @override
  String get webCopyHint_9012 => 'Web platform';

  @override
  String get webDatabaseImportComplete_4821 =>
      'WebDatabaseImporter: Data import completed';

  @override
  String get webDatabaseImporterWebOnly_7281 =>
      'WebDatabaseImporter: Only available on the Web platform';

  @override
  String webDavAccountCreated(Object authAccountId) {
    return 'WebDAV authentication account created: $authAccountId';
  }

  @override
  String webDavAccountUpdated(Object authAccountId) {
    return 'WebDAV authenticated account updated: $authAccountId';
  }

  @override
  String webDavAuthAccountDeleted(Object authAccountId) {
    return 'WebDAV authentication account deleted: $authAccountId';
  }

  @override
  String webDavAuthAccountNotFound(Object authAccountId) {
    return 'WebDAV authentication account not found: $authAccountId';
  }

  @override
  String get webDavAuthFailed_7281 =>
      'WebDAV authentication failed: password not found';

  @override
  String webDavAuthFailed_7285(Object e) {
    return 'WebDAV authentication failed: $e';
  }

  @override
  String get webDavClientCreationError_4821 =>
      'Failed to create WebDAV client, please check the configuration';

  @override
  String webDavClientCreationFailed(Object e) {
    return 'Failed to create WebDAV client: $e';
  }

  @override
  String get webDavClientInitialized_7281 =>
      'WebDAV client service initialization completed';

  @override
  String webDavConfigCreated(Object configId) {
    return 'WebDAV configuration created: $configId';
  }

  @override
  String webDavConfigDeleted(Object configId) {
    return 'WebDAV configuration deleted: $configId';
  }

  @override
  String webDavConfigNotFound(Object configId) {
    return 'WebDAV configuration not found: $configId';
  }

  @override
  String get webDavConfigTitle_7281 =>
      'Configure and manage WebDAV cloud storage connections';

  @override
  String webDavConfigUpdated(Object configId) {
    return 'WebDAV configuration updated: $configId';
  }

  @override
  String get webDavConfig_7281 => 'WebDAV Configuration';

  @override
  String get webDavInitializationComplete_7281 =>
      'WebDAV secure storage service initialization completed';

  @override
  String get webDavInitialized_7281 =>
      'WebDAV database service initialization completed';

  @override
  String get webDavManagement_4271 => 'WebDAV Management';

  @override
  String get webDavManagement_4821 => 'WebDAV Management';

  @override
  String get webDavManagement_7421 => 'WebDAV Management';

  @override
  String webDavPasswordDeleted(Object authAccountId) {
    return 'WebDAV password deleted: $authAccountId';
  }

  @override
  String webDavPasswordDeletionFailed(Object e) {
    return 'Failed to delete WebDAV password: $e';
  }

  @override
  String webDavPasswordError(Object e) {
    return 'Failed to get WebDAV password: $e';
  }

  @override
  String webDavPasswordNotFound(Object authAccountId) {
    return 'WebDAV password not found: $authAccountId';
  }

  @override
  String webDavPasswordRemoved(Object authAccountId) {
    return 'WebDAV password has been removed from SharedPreferences (macOS): $authAccountId';
  }

  @override
  String webDavPasswordRetrievedMacos(Object authAccountId) {
    return 'WebDAV password retrieved successfully from SharedPreferences (macOS): $authAccountId';
  }

  @override
  String webDavPasswordSaveFailed(Object e) {
    return 'Failed to save WebDAV password: $e';
  }

  @override
  String webDavPasswordStored(Object authAccountId) {
    return 'WebDAV password securely stored: $authAccountId';
  }

  @override
  String webDavPasswordSuccess_7285(Object authAccountId) {
    return 'WebDAV password retrieved successfully: $authAccountId';
  }

  @override
  String get webDavPasswordsClearedMacOs =>
      'All WebDAV passwords have been cleared from SharedPreferences (macOS)';

  @override
  String webDavStatsError_4821(Object e) {
    return 'Failed to fetch WebDAV storage statistics: $e';
  }

  @override
  String webDavStorageCreated(Object storagePath) {
    return 'WebDAV storage directory created: $storagePath';
  }

  @override
  String get webDavTempFilesCleaned =>
      '🔗 VfsPlatformIO: WebDAV import temp files cleaned';

  @override
  String get webDavUploadFailed_7281 => 'WebDAV upload failed';

  @override
  String webDavUploadFailed_7421(Object e) {
    return 'WebDAV upload failed: $e';
  }

  @override
  String webDavUploadSuccess(Object remotePath) {
    return 'Successfully uploaded to WebDAV: $remotePath';
  }

  @override
  String webDownloadFailed_4821(Object error) {
    return 'Web platform download failed: $error';
  }

  @override
  String webDownloadFailed_7285(Object e) {
    return 'Web package download failed: $e';
  }

  @override
  String get webDownloadHelperWebOnly_7281 =>
      'WebDownloadHelper is only available on the Web platform';

  @override
  String get webDownloadUtilsWebOnly_7281 =>
      'WebDownloadUtils is only available on the Web platform';

  @override
  String webExportImageFailed(Object e) {
    return 'Failed to export image on Web platform: $e';
  }

  @override
  String webExportSingleImageFailed(Object e) {
    return 'Failed to export single image on Web platform: $e';
  }

  @override
  String get webFeatures => 'Web Features:';

  @override
  String webFileDownloadFailed_7285(Object e) {
    return 'Web file download failed: $e';
  }

  @override
  String webImageCopyFailed(Object e) {
    return 'Failed to copy image on web platform: $e';
  }

  @override
  String get webMode_1589 => 'Web Mode';

  @override
  String get webPdfDialogOpened_7281 =>
      'The PDF print dialog is open on the web platform';

  @override
  String get webPlatform => 'Web platform';

  @override
  String get webPlatformExportPdf_4728 =>
      'The web platform will use the print function to export PDF';

  @override
  String get webPlatformFeatures_4821 => 'On the Web platform:';

  @override
  String get webPlatformMenuDescription_4821 =>
      'On the Web platform, browsers display their own context menu by default. With our solution, you can disable the default browser menu and use a Flutter custom menu instead.';

  @override
  String get webPlatformNoNeedCleanTempFiles_4821 =>
      '🔗 VfsPlatformWeb: No need to clean temporary files on the Web platform';

  @override
  String get webPlatformNotSupportTempFile_4821 =>
      'The web platform does not support generating temporary files. Please use Data URI or Blob URL instead.';

  @override
  String get webPlatformNotSupported_7281 =>
      'File creation is not supported on the web platform';

  @override
  String get webPlatformRightClickMenuDescription_4821 =>
      'Web platform right-click menu description';

  @override
  String get webPlatformUnsupportedDirectoryCreation_4821 =>
      'Directory creation is not supported on the web platform';

  @override
  String get webPlatform_1234 => 'Web platform';

  @override
  String webReadOnlyModeWithOperation_7421(Object operation) {
    return 'The web version is in read-only mode and cannot perform the \"$operation\" operation.  \n\nFor editing features, please use the desktop version.';
  }

  @override
  String get webRightClickDemo_4821 => 'Web right-click menu demo';

  @override
  String get webSocketConnectionManager_4821 =>
      'WebSocket Connection Management';

  @override
  String get webSocketConnectionStart_7281 =>
      'GlobalCollaborationService starts connecting to WebSocket';

  @override
  String get webSocketInitComplete_4821 =>
      'WebSocket secure storage service initialization completed';

  @override
  String webSocketInitFailed(Object e) {
    return 'WebSocket client manager initialization failed: $e';
  }

  @override
  String get webSocketManagerInitialized_7281 =>
      'WebSocket connection manager initialized successfully';

  @override
  String get webSpecificFeatures =>
      'Web-specific features can be implemented here.';

  @override
  String get webTempDirUnsupported_7281 =>
      'The web platform does not support accessing temporary directories.';

  @override
  String get webdavDownloadCancelled_5045 => 'WebDAV download cancelled';

  @override
  String get webdavImportCancelled_5043 => 'WebDAV import cancelled';

  @override
  String get webdavImportFailed_5046 => 'WebDAV import failed';

  @override
  String get webdavImportList_5044 => 'WebDAV Import List';

  @override
  String get webdavImport_4975 => 'WebDAV Import';

  @override
  String websocketClientConfigDeleted(Object clientId) {
    return 'WebSocket client configuration deleted: $clientId';
  }

  @override
  String get websocketClientConfig_4821 =>
      'Manage WebSocket client connection configurations';

  @override
  String get websocketClientDbInitComplete_7281 =>
      'WebSocket client database service initialization completed';

  @override
  String websocketConfigSaved(Object displayName) {
    return 'WebSocket client configuration saved: $displayName';
  }

  @override
  String get websocketConnectedStatusRequest_4821 =>
      'WebSocket connected, requesting online status list';

  @override
  String get websocketConnectedSuccess_4821 =>
      'WebSocket connected successfully, requesting online status list';

  @override
  String websocketConnectionFailed(Object e) {
    return 'Failed to connect to WebSocket server: $e';
  }

  @override
  String get websocketConnectionFailed_4821 =>
      'GlobalCollaborationService WebSocket connection failed';

  @override
  String get websocketConnectionManagement_4821 =>
      'WebSocket Connection Management';

  @override
  String websocketDbUpgradeMessage(Object newVersion, Object oldVersion) {
    return 'The WebSocket client configuration database has been upgraded from version $oldVersion to $newVersion';
  }

  @override
  String websocketDisconnectFailed(Object e) {
    return 'Failed to disconnect WebSocket: $e';
  }

  @override
  String get websocketDisconnected_7281 =>
      'GlobalCollaborationService WebSocket connection disconnected';

  @override
  String websocketError_4829(Object error) {
    return 'Error processing WebSocket message: $error';
  }

  @override
  String get websocketManagerInitializedSuccess_4821 =>
      'WebSocket client manager initialized successfully';

  @override
  String get websocketManagerInitialized_7281 =>
      'WebSocket client manager initialization completed';

  @override
  String get websocketNotConnectedSkipBroadcast_7281 =>
      'WebSocket not connected, skipping broadcast of user status update (offline mode)';

  @override
  String get websocketNotInitializedError_7281 =>
      'WebSocket client manager is not initialized, please call initialize() first';

  @override
  String get websocketTableCreated_7281 =>
      'WebSocket client configuration database table creation completed';

  @override
  String get welcomeFloatingWidget_7421 => 'Welcome to the floating widget!';

  @override
  String get wheelMenuInstruction_4521 =>
      'Press the middle button or two fingers on the touchpad  \nto bring up the wheel menu';

  @override
  String widthWithPx_7421(Object value) {
    return 'Width: ${value}px';
  }

  @override
  String get windowAutoSnapHint_4721 =>
      'The window will automatically stay within the visible screen area.';

  @override
  String get windowBoundaryHint_4821 =>
      'The window will automatically stay within screen boundaries but allows partial content to extend beyond the edges.';

  @override
  String get windowConfigChainCall_7284 =>
      'Configure window properties using chain calls';

  @override
  String get windowContentDescription_4821 => 'Window content description';

  @override
  String get windowControlDisplayMode_4821 =>
      'Select the display mode for window control buttons';

  @override
  String get windowControlMode_4821 => 'Window control mode';

  @override
  String get windowDragHint_4721 =>
      'You can move this window by dragging the title bar.';

  @override
  String get windowDragHint_4821 => 'Drag the title bar to move the window';

  @override
  String get windowHeight_4271 => 'Window height';

  @override
  String get windowModeDescription_4821 =>
      'Display Markdown in a floating window, ideal for quick preview';

  @override
  String get windowModeTitle_4821 => '1. Window Mode';

  @override
  String windowScalingFactorDebug(Object factor) {
    return '- Window scaling factor: $factor (affects content scaling)';
  }

  @override
  String windowScalingFactorLabel(Object value) {
    return 'Window scaling factor: $value';
  }

  @override
  String get windowSettings_4821 => 'Window Settings';

  @override
  String windowSizeApplied(
    Object isMaximized,
    Object windowHeight,
    Object windowWidth,
  ) {
    return 'Window size applied: ${windowWidth}x$windowHeight, position determined by system, maximized: $isMaximized';
  }

  @override
  String get windowSizeDescription_5739 => 'Window size description';

  @override
  String windowSizeError_7425(Object e) {
    return 'Failed to resize application window: $e';
  }

  @override
  String get windowSizeResetToDefault_4821 =>
      'Window size settings have been reset to default';

  @override
  String get windowSizeSaveFailed_7281 => 'Window size save failed';

  @override
  String get windowSizeSaveRequestSent_7281 =>
      'Window size save request sent (non-maximized state)';

  @override
  String windowSizeSaved(Object height, Object maximized, Object width) {
    return 'Window size saved: ${width}x$height, maximized: $maximized (position determined by system)';
  }

  @override
  String windowSizeUpdateFailed(Object e) {
    return 'Failed to update window size: $e';
  }

  @override
  String windowStateOnExit(Object height, Object maximized, Object width) {
    return 'Read window state on exit: ${width}x$height, maximized: $maximized';
  }

  @override
  String windowStateSaveError(Object e) {
    return 'Failed to save window state on exit: $e';
  }

  @override
  String get windowStateSaveFailed_7281 =>
      'Failed to save window state on exit';

  @override
  String get windowStateSavedSuccessfully_7281 =>
      'Window state saved successfully on exit';

  @override
  String get windowStayVisibleArea_4821 =>
      'The window will stay within the visible screen area';

  @override
  String get windowTitle_7281 => 'Window Title';

  @override
  String get windowTitle_7421 => 'Window Title';

  @override
  String get windowWidth_4821 => 'Window width';

  @override
  String get window_4824 => 'Window';

  @override
  String windowsClipboardImageReadSuccess(Object bytesLength) {
    return 'Windows: Image successfully read from clipboard, size: $bytesLength bytes';
  }

  @override
  String get windowsFeatures => 'Windows Features:';

  @override
  String get windowsNotifications => 'Windows Notifications';

  @override
  String get windowsPlatform => 'Windows platform';

  @override
  String windowsPowerShellCopyFailed(Object resultStderr) {
    return 'Windows PowerShell copy failed: $resultStderr';
  }

  @override
  String get windowsSpecificFeatures =>
      'Windows-specific features can be implemented here.';

  @override
  String wordCountLabel(Object wordCount) {
    return 'Word count: $wordCount';
  }

  @override
  String get workStatusEnded_7281 => 'Work status ended';

  @override
  String workStatusStart_7285(Object description) {
    return 'Work status started: $description';
  }

  @override
  String get writePermission_4821 => 'Write';

  @override
  String get writePermission_7421 => 'Write';

  @override
  String writeTextFileLog_7421(Object length, Object path) {
    return 'Write text file: $path, content length: $length';
  }

  @override
  String get xAxisLabel_7281 => 'X-axis:';

  @override
  String xAxisOffset(Object percentage) {
    return 'X-axis offset: $percentage%';
  }

  @override
  String get xCoordinateLabel_4521 => 'X coordinate';

  @override
  String get xOffsetLabel_4821 => 'X offset';

  @override
  String xPerspectiveFactor(Object factor) {
    return '- X-axis perspective factor: $factor';
  }

  @override
  String get yAxisLabel_7284 => 'Y-axis:';

  @override
  String yAxisOffset(Object percentage) {
    return 'Y-axis offset: $percentage%';
  }

  @override
  String get yCoordinateLabel_4821 => 'Y coordinate';

  @override
  String get yOffsetLabel_4821 => 'Y offset';

  @override
  String yPerspectiveFactor(Object factor) {
    return '- Y-axis perspective factor: $factor';
  }

  @override
  String get yes => 'Yes';

  @override
  String get yes_4287 => 'Yes';

  @override
  String get yes_4821 => 'Yes';

  @override
  String zIndexLabel(Object zIndex) {
    return 'Z level: $zIndex';
  }

  @override
  String zLayerInspectorWithCount(Object count) {
    return 'Z Layer Inspector ($count)';
  }

  @override
  String get zLevelInspector_1589 => 'Z-Level Inspector';

  @override
  String get zLevelLabel_4521 => 'Z-level';

  @override
  String get zLevel_4821 => 'Z-level';

  @override
  String get zipFileDescription_4978 =>
      'ZIP file should contain a metadata.json file to specify resource target locations';

  @override
  String get zipFileStructure_4977 => 'ZIP File Structure';

  @override
  String get zipReadError_7281 => 'Failed to read ZIP file contents';

  @override
  String get zoomFactor_4911 => 'Zoom Factor';

  @override
  String get zoomImage_4821 => 'Zoom image';

  @override
  String get zoomInTooltip_4821 => 'Zoom in';

  @override
  String get zoomLabel_4821 => 'Zoom';

  @override
  String zoomLevelRecorded(Object zoomLevel) {
    return 'Zoom level recorded: $zoomLevel';
  }

  @override
  String get zoomOutTooltip_7281 => 'Zoom out';

  @override
  String zoomPercentage(Object percentage) {
    return 'Zoom: $percentage%';
  }

  @override
  String get zoomSensitivity_4271 => 'Zoom sensitivity';

  @override
  String get zoom_4821 => 'Zoom';
}
