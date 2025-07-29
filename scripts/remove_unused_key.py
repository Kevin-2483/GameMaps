import json

ARB_FILE = "lib/l10n/app_zh.arb"
TO_DELETE_KEYS = [
    "exportLegendDatabase",
    "profileCreated",
    "comprehensiveFramework",
    "editProfile",
    "updateFailed",
    "aboutDialogContent",
    "legendUpdateFailed",
    "previewModeOnly",
    "localizationFileUploadFailed",
    "legendAddedSuccessfully",
    "showGrid",
    "generalSettings",
    "defaultStrokeWidth",
    "noLegendGroups",
    "updateSuccessful",
    "toolSettings",
    "importSuccessful",
    "legendDatabaseImportedSuccessfully",
    "confirmDeleteProfile",
    "exportSuccessful",
    "nativeAndroidUI",
    "mapEditorInDevelopment",
    "defaultColor",
    "appStoreIntegration",
    "androidPermissions",
    "deleteProfile",
    "mapSaveFailed",
    "updateLegendExternalResourcesDescription",
    "editMode",
    "previewMode",
    "defaultDrawingTool",
    "addLegendFailed",
    "loadLegendsFailed",
    "editModeEnabled",
    "userManagement",
    "snapToGrid",
    "mapSaved",
    "appTitle",
    "iOSNotifications",
    "autoSaveInterval",
    "nativeIOSUI",
    "legendUpdateSuccessful",
    "importLegendDatabase",
    "profileDeleted",
    "localizationFileUploaded",
    "switchProfile",
    "androidNotifications",
    "legendDatabaseExportedSuccessfully",
    "updateLegendExternalResources",
    "systemLanguage",
    "localizationFileVersionLow",
    "exportFailed",
    "confirmDeleteLegendGroup",
    "createProfile",
    "layoutSettings",
    "noLayers",
    "enableFeaturesInSettings",
    "platformIntegration",
    "confirmDeleteLayer",
    "mapEditorSettings",
    "noFeaturesEnabled",
    "themeSettings",
    "profileName",
    "mapInformation"
]

def main():
    with open(ARB_FILE, "r", encoding="utf-8") as f:
        data = json.load(f)

    removed_count = 0
    for key in TO_DELETE_KEYS:
        if key in data:
            del data[key]
            # 也删除对应注释
            annotation_key = "@" + key
            if annotation_key in data:
                del data[annotation_key]
            removed_count += 1

    with open(ARB_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"已删除 {removed_count} 个本地化键。")

if __name__ == "__main__":
    main()
