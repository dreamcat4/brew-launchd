
require 'plist4r/plist_type'

module Plist4r
  # For documentation on the Info.plist keys, and their values, see:
  # http://developer.apple.com/mac/library/documentation/General/Reference/InfoPlistKeyReference
  class PlistType::Info < PlistType

    ValidKeysCoreFoundation =
    {
      :string => %w[
        CFAppleHelpAnchor
        CFBundleDevelopmentRegion
        CFBundleDisplayName
        CFBundleExecutable
        CFBundleGetInfoString
        CFBundleHelpBookFolder
        CFBundleHelpBookName
        CFBundleIconFile
        CFBundleIdentifier
        CFBundleInfoDictionaryVersion
        CFBundleName
        CFBundlePackageType
        CFBundleShortVersionString
        CFBundleSignature
        CFBundleVersion
        CFPlugInDynamicRegistration
        CFPlugInDynamicRegisterFunction
        CFPlugInUnloadFunction
        ],
      :bool => %w[
        CFBundleAllowMixedLocalizations
        ],
      :array_of_strings => %w[
        CFBundleIconFiles
        CFBundleLocalizations
        ],
      :array_of_hashes => %w[
        CFBundleDocumentTypes
        ],
      :array => %w[
        CFBundleDocumentTypes
        CFBundleURLTypes
        ],
      :hash_of_strings => %w[
        CFPlugInFactories
        ],
      :hash_of_arrays_of_strings => %w[
        CFPlugInTypes
        ],
    }

    ValidKeysLaunchServices =
    {
      :string => %w[
        LSMinimumSystemVersion
        LSUIElement
        LSVisibleInClassic
        MinimumOSVersion
        ],
      :bool => %w[
        LSBackgroundOnly
        LSFileQuarantineEnabled
        LSGetAppDiedEvents
        LSMultipleInstancesProhibited
        LSRequiresIPhoneOS
        LSRequiresNativeExecution
        ],
      :integer => %w[
        LSUIPresentationMode
        ],
      :array_of_strings => %w[
        LSArchitecturePriority
        LSFileQuarantineExcludedPathPatterns
        ],
      :hash_of_strings => %w[
        LSEnvironment
        LSMinimumSystemVersionByArchitecture
        ],
    }

    ValidKeysCocoa =
    {
      :string => %w[
        NSDockTilePlugIn
        NSHumanReadableCopyright
        NSJavaRoot
        NSMainNibFile
        NSPersistentStoreTypeKey
        NSPrefPaneIconFile
        NSPrefPaneIconLabel
        NSPrincipalClass
        ],
      :bool => %w[
        NSSupportsSuddenTermination
        ],
      :bool_or_string => %w[
        NSAppleScriptEnabled
        NSJavaNeeded
        ],
      :array_of_strings => %w[
        NSJavaPath
        ],
      :array_of_hashes => %w[
        NSServices
        UTExportedTypeDeclarations
        UTImportedTypeDeclarations
        ],
    }

    ValidKeysMacOsx =
    {
      :string => %w[ APInstallerURL ATSApplicationFontsPath ],
      :bool => %w[ CSResourcesFileMapped QuartzGLEnable ],
      :array_of_strings => %w[ APFiles ]
    }

    ValidKeysUiKit =
    {
      :string => %w[
        UIInterfaceOrientation
        UILaunchImageFile
        UIStatusBarStyle
        ],
      :bool => %w[
        UIApplicationExitsOnSuspend
        UIFileSharingEnabled
        UIPrerenderedIcon
        UIRequiresPersistentWiFi
        UIStatusBarHidden
        UIViewEdgeAntialiasing
        UIViewGroupOpacity
        ],
      :array_of_strings => %w[
        UIAppFonts
        UIBackgroundModes
        UISupportedExternalAccessoryProtocols
        UISupportedInterfaceOrientations
        ],
      :array_or_integer => %w[
        UIDeviceFamily
        ],
      :array_or_hash => %w[
        UIRequiredDeviceCapabilities
        ],
    }


    # A Hash Array of the supported plist keys for this type. These are plist keys which belong to the
    # PlistType for Info plists. Each CamelCased key name has a corresponding set_or_return method call.
    # For example "CFBundleIdentifier" => c_f_bundle_identifier(value). For more information please see {file:PlistKeyNames}
    # @see Plist4r::DataMethods
    ValidKeys = {}.merge_array_of_hashes_of_arrays [
      ValidKeysCoreFoundation,
      ValidKeysLaunchServices,
      ValidKeysCocoa,
      ValidKeysMacOsx,
      ValidKeysUiKit
      ]

  end
end





