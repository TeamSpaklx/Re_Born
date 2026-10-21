import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // 하단 탭 바: iOS 26 이상에서 네이티브 UITabBar(Liquid Glass)를 쓴다.
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "NativeTabBar") {
      registrar.register(
        NativeTabBarFactory(messenger: registrar.messenger()),
        withId: NativeTabBarFactory.viewType
      )
    }
  }
}
