import Foundation
import UIKit

struct HighlightItem {

  let identifier: String

  let shapeConfig: ShapeConfig
  let messageConfig: MessageConfig

  let skipButtonText: String?

}

// MARK: - ShapeConfig

extension HighlightItem {

  struct ShapeConfig {

    let type: ShapeType
    let insets: UIEdgeInsets

  }

}

extension HighlightItem.ShapeConfig {

  enum ShapeType {
    case circle
    case rectangle
  }

}

// MARK: - MessageConfig

extension HighlightItem {

  struct MessageConfig {

    let position: PositionType

    let title: String?
    let subtitle: String?
    let hint: String?

    var hasText: Bool {
      self.title?.nilIfEmpty != nil || self.subtitle != nil || self.hint?.nilIfEmpty != nil
    }

  }

}

extension HighlightItem.MessageConfig {

  enum PositionType {
    case onTop
    case below
  }

}
