import CoreText
import Flutter
import UIKit

/// Flutter `NativeTabBar`(lib/shared/widgets/native_tab_bar.dart)가 쓰는 네이티브 탭 바.
/// iOS 26 이상에서 시스템이 Liquid Glass로 그린다. 아이콘 이미지, 라벨, 색, 글꼴은 모두
/// Flutter(테마 상수)에서 받아 오고, 여기서는 값을 정하지 않는다.
final class NativeTabBarFactory: NSObject, FlutterPlatformViewFactory {
  static let viewType = "reborn/native_tab_bar"

  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    NativeTabBarView(
      frame: frame,
      viewId: viewId,
      params: args as? [String: Any] ?? [:],
      messenger: messenger
    )
  }
}

final class NativeTabBarView: NSObject, FlutterPlatformView, UITabBarDelegate {
  private let container: UIView
  private let tabBar = UITabBar()
  private let channel: FlutterMethodChannel
  private var items: [UITabBarItem] = []

  init(
    frame: CGRect,
    viewId: Int64,
    params: [String: Any],
    messenger: FlutterBinaryMessenger
  ) {
    container = UIView(frame: frame)
    channel = FlutterMethodChannel(
      name: "reborn/native_tab_bar_\(viewId)",
      binaryMessenger: messenger
    )
    super.init()

    container.backgroundColor = .clear
    configureItems(params)

    tabBar.delegate = self
    tabBar.frame = container.bounds
    tabBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    tabBar.tintColor = Self.color(params["selectedColor"])
    tabBar.unselectedItemTintColor = Self.color(params["normalColor"])
    container.addSubview(tabBar)
    select(params["selectedIndex"] as? Int ?? 0)

    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "setSelectedIndex":
        self?.select(call.arguments as? Int ?? 0)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func view() -> UIView { container }

  func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    channel.invokeMethod("onTap", arguments: item.tag)
  }

  private func select(_ index: Int) {
    guard items.indices.contains(index) else { return }
    tabBar.selectedItem = items[index]
  }

  private func configureItems(_ params: [String: Any]) {
    let labels = params["labels"] as? [String] ?? []
    let icons = params["icons"] as? [FlutterStandardTypedData] ?? []
    let selectedIcons = params["selectedIcons"] as? [FlutterStandardTypedData] ?? []
    let scale = CGFloat(params["pixelRatio"] as? Double ?? 3)

    let font = Self.font(params)
    let kern = params["letterSpacing"] as? Double ?? 0
    let normalColor = Self.color(params["normalColor"])
    let selectedColor = Self.color(params["selectedColor"])

    items = labels.enumerated().map { index, label in
      let item = UITabBarItem(
        title: label,
        image: Self.image(icons, index, scale),
        selectedImage: Self.image(selectedIcons, index, scale)
      )
      item.tag = index
      // 시스템 기본 배경(Liquid Glass)을 그대로 쓰려고 UITabBarAppearance는 건드리지 않고
      // 글자 속성만 바꾼다.
      item.setTitleTextAttributes(
        [.font: font, .foregroundColor: normalColor, .kern: kern], for: .normal)
      item.setTitleTextAttributes(
        [.font: font, .foregroundColor: selectedColor, .kern: kern], for: .selected)
      return item
    }
    tabBar.items = items
  }

  private static func image(
    _ images: [FlutterStandardTypedData], _ index: Int, _ scale: CGFloat
  ) -> UIImage? {
    guard images.indices.contains(index) else { return nil }
    return UIImage(data: images[index].data, scale: scale)?
      .withRenderingMode(.alwaysOriginal)
  }

  /// Dart가 넘긴 ARGB 정수(0xAARRGGBB)를 UIColor로 바꾼다.
  private static func color(_ value: Any?) -> UIColor {
    let argb = (value as? NSNumber)?.uint32Value ?? 0xFF00_0000
    return UIColor(
      red: CGFloat((argb >> 16) & 0xFF) / 255,
      green: CGFloat((argb >> 8) & 0xFF) / 255,
      blue: CGFloat(argb & 0xFF) / 255,
      alpha: CGFloat((argb >> 24) & 0xFF) / 255
    )
  }

  /// Flutter 번들 안의 Pretendard를 UIKit에 등록하고 라벨 글꼴을 만든다.
  private static func font(_ params: [String: Any]) -> UIFont {
    let size = CGFloat(params["fontSize"] as? Double ?? 10)
    if let asset = params["fontAsset"] as? String,
      let name = params["fontName"] as? String
    {
      let key = FlutterDartProject.lookupKey(forAsset: asset)
      if UIFont(name: name, size: size) == nil,
        let path = Bundle.main.path(forResource: key, ofType: nil)
      {
        CTFontManagerRegisterFontsForURL(URL(fileURLWithPath: path) as CFURL, .process, nil)
      }
      if let font = UIFont(name: name, size: size) { return font }
    }
    return .systemFont(ofSize: size, weight: .bold)
  }
}
