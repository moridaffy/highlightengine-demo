import Foundation
import UIKit

extension String {

  var nilIfEmpty: String? {
    self.isEmpty ? nil : self
  }

}

extension NSAttributedString {

  func height(width: CGFloat) -> CGFloat {
    let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
    let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
    return ceil(boundingBox.height)
  }

  func width(height: CGFloat) -> CGFloat {
    let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
    let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
    return ceil(boundingBox.width)
  }
  
}
