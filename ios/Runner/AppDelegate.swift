import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // With the UIScene lifecycle (required from the iOS 27 SDK) the window and
  // FlutterViewController don't exist yet in didFinishLaunching, so plugins and
  // platform channels are registered once the implicit engine is created.
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let messenger = engineBridge.applicationRegistrar.messenger()

    // Set up the OnDeviceAiApi with Foundation Models implementation
    let implementation = OnDeviceAiApiImplementation()
    OnDeviceAiApiSetup.setUp(binaryMessenger: messenger, api: implementation)

    // Set up the CloudKit backup implementation
    let cloudKitBackup = CloudKitBackupApiImplementation()
    CloudKitBackupApiSetup.setUp(binaryMessenger: messenger, api: cloudKitBackup)
  }
}
