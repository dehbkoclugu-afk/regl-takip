import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var privacyCover: UIView?

  override func applicationWillResignActive(_ application: UIApplication) {
    super.applicationWillResignActive(application)
    guard let window = window else { return }
    let cover = UIView(frame: window.bounds)
    cover.backgroundColor = UIColor.systemBackground
    cover.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    window.addSubview(cover)
    privacyCover = cover
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    privacyCover?.removeFromSuperview()
    privacyCover = nil
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
