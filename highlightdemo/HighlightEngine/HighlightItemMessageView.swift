import Foundation
import UIKit

class HighlightItemMessageView: UIView {

  enum Constants {
    static var arrowSize: CGSize { .init(width: 20.0, height: 16.0) }
    static var contentInsets: CGFloat { 16.0 }
  }

  private let containerView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = 8.0
    view.layer.masksToBounds = true
    return view
  }()

  private let upArrowImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleToFill
    imageView.image = .init(named: "highlight_arrow_up")?.withRenderingMode(.alwaysTemplate)
    return imageView
  }()

  private let downArrowImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleToFill
    imageView.image = .init(named: "highlight_arrow_down")?.withRenderingMode(.alwaysTemplate)
    return imageView
  }()

  private let textLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.numberOfLines = 0
    label.textAlignment = .center
    label.textColor = .white
    return label
  }()

  private var upArrowImageViewLeftConstraint: NSLayoutConstraint?
  private var downArrowImageViewLeftConstraint: NSLayoutConstraint?

  override var backgroundColor: UIColor? {
    get {
      self.containerView.backgroundColor
    }
    set {
      super.backgroundColor = .clear
      self.containerView.backgroundColor = newValue
      self.upArrowImageView.tintColor = newValue
      self.downArrowImageView.tintColor = newValue
    }
  }

  var titleText: String? {
    didSet {
      self.updateText()
    }
  }

  var subtitleText: String? {
    didSet {
      self.updateText()
    }
  }

  var hintText: String? {
    didSet {
      self.updateText()
    }
  }

  var position: HighlightItem.MessageConfig.PositionType = .below {
    didSet {
      self.upArrowImageView.isHidden = self.position == .onTop
      self.downArrowImageView.isHidden = self.position == .below
    }
  }

  var arrowOffset: CGFloat = 0.0 {
    didSet {
      self.upArrowImageViewLeftConstraint?.constant = self.arrowOffset
      self.downArrowImageViewLeftConstraint?.constant = self.arrowOffset
    }
  }

  var height: CGFloat {
    [
      Constants.arrowSize.height,
      Constants.contentInsets,
      self.textLabel.attributedText?.height(width: self.bounds.width - Constants.contentInsets * 2.0) ?? 0.0,
      Constants.contentInsets,
      Constants.arrowSize.height,
    ]
      .reduce(into: 0.0, { $0 += $1 })
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

private extension HighlightItemMessageView {

  func setupLayout() {
    self.addSubview(self.upArrowImageView)
    self.addSubview(self.downArrowImageView)
    self.addSubview(self.containerView)
    self.containerView.addSubview(self.textLabel)

    let upArrowImageViewLeftConstraint = self.upArrowImageView.leftAnchor.constraint(equalTo: self.containerView.leftAnchor)
    self.upArrowImageViewLeftConstraint = upArrowImageViewLeftConstraint

    let downArrowImageViewLeftConstraint = self.downArrowImageView.leftAnchor.constraint(equalTo: self.containerView.leftAnchor)
    self.downArrowImageViewLeftConstraint = downArrowImageViewLeftConstraint

    self.addConstraints([
      self.upArrowImageView.topAnchor.constraint(equalTo: self.topAnchor),
      upArrowImageViewLeftConstraint,
      self.upArrowImageView.heightAnchor.constraint(equalToConstant: Constants.arrowSize.height),
      self.upArrowImageView.widthAnchor.constraint(equalToConstant: Constants.arrowSize.width),

      self.containerView.topAnchor.constraint(equalTo: self.upArrowImageView.bottomAnchor, constant: -2.0),
      self.containerView.leftAnchor.constraint(equalTo: self.leftAnchor),
      self.containerView.rightAnchor.constraint(equalTo: self.rightAnchor),

      self.textLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: Constants.contentInsets),
      self.textLabel.leftAnchor.constraint(equalTo: self.containerView.leftAnchor, constant: Constants.contentInsets),
      self.textLabel.rightAnchor.constraint(equalTo: self.containerView.rightAnchor, constant: -Constants.contentInsets),
      self.textLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -Constants.contentInsets),

      self.downArrowImageView.topAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -2.0),
      downArrowImageViewLeftConstraint,
      self.downArrowImageView.heightAnchor.constraint(equalToConstant: Constants.arrowSize.height),
      self.downArrowImageView.widthAnchor.constraint(equalToConstant: Constants.arrowSize.width),

    ])
  }

  func updateText() {
    let text = NSMutableAttributedString()
    if let titleText = self.titleText?.nilIfEmpty {
      text.append(.init(
        string: titleText,
        attributes: [
          .font: UIFont.systemFont(ofSize: 24.0, weight: .semibold),
          .foregroundColor: UIColor.white
        ]
      ))
    }
    if let subtitleText = self.subtitleText?.nilIfEmpty {
      if !text.string.isEmpty {
        text.append(.init(string: "\n"))
      }
      text.append(.init(
        string: subtitleText,
        attributes: [
          .font: UIFont.systemFont(ofSize: 15.0, weight: .medium),
          .foregroundColor: UIColor.white
        ]
      ))
    }
    if let hintText = self.hintText?.nilIfEmpty {
      if !text.string.isEmpty {
        text.append(.init(string: "\n"))
      }
      text.append(.init(
        string: hintText,
        attributes: [
          .font: UIFont.systemFont(ofSize: 15.0, weight: .regular),
          .foregroundColor: UIColor.white.withAlphaComponent(0.5)
        ]
      ))
    }

    self.textLabel.attributedText = text
  }

}
