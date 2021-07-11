import Cocoa
import FlutterMacOS

// bitsdojo_window_macos
import FlutterMacOS
import bitsdojo_window_macos

// bitsdojo_window_macos
class MainFlutterWindow: BitsdojoWindow {

  // bitsdojo_window_macos
  override func bitsdojo_window_configure() -> UInt {
    return BDW_CUSTOM_FRAME | BDW_HIDE_ON_STARTUP
  }

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
