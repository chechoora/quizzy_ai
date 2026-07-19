import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Set up the OnDeviceAiApi with Foundation Models implementation
    let controller = window?.rootViewController as! FlutterViewController
    let implementation = OnDeviceAiApiImplementation()
    OnDeviceAiApiSetup.setUp(binaryMessenger: controller.binaryMessenger, api: implementation)

    // Set up the CloudKit backup implementation
    let cloudKitBackup = CloudKitBackupApiImplementation()
    CloudKitBackupApiSetup.setUp(binaryMessenger: controller.binaryMessenger, api: cloudKitBackup)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
