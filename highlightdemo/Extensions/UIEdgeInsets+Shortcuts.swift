import Foundation
import UIKit

extension UIEdgeInsets {

  static func make(top: CGFloat = 0.0, left: CGFloat = 0.0, right: CGFloat = 0.0, bottom: CGFloat = 0.0) -> UIEdgeInsets {
    UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
  }

  static func make(horizontal: CGFloat = 0.0, vertical: CGFloat = 0.0) -> UIEdgeInsets {
    UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
  }

  static func make(allSides side: CGFloat) -> UIEdgeInsets {
    UIEdgeInsets(top: side, left: side, bottom: side, right: side)
  }

  var vertical: CGFloat {
    self.top + self.bottom
  }

  var horizontal: CGFloat {
    self.left + self.right
  }

}
