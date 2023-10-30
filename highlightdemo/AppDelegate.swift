import Foundation
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  private var highlightEngine: HighlightEngine!

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    let window = UIWindow()
    window.rootViewController = UINavigationController(rootViewController: FirstViewController())
    window.makeKeyAndVisible()

    let highlightEngine = HighlightEngine(window: window, isLoggingEnabled: true)
    self.highlightEngine = highlightEngine
    HighlightEngine.setShared(highlightEngine)

    self.window = window

    return true
  }

}

