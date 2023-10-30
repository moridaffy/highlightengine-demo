import Foundation
import UIKit

class HighlightEngine {

  private enum Constants {
    static var overlayViewIdentifier: String { "highlight_engine_overlay" }
    static var messageViewIdentifier: String { "highlight_engine_message" }
    static var skipButtonViewIdentifier: String { "highlight_engine_skip_button" }

    static var messageViewInsets: CGFloat { 8.0 }
  }

  static private(set) var shared: HighlightEngine?

  static func setShared(_ value: HighlightEngine) {
    guard Self.shared == nil else {
      assertionFailure("Can't create more than one HighlightEngine")
      return
    }

    Self.shared = value
  }

  private let window: UIWindow
  private let isLoggingEnabled: Bool

  private var topViewController: UIViewController {
    guard var viewController = self.window.rootViewController else {
      fatalError()
    }

    while let presentedViewController = viewController.presentedViewController {
      viewController = presentedViewController
    }

    return viewController
  }

  private var tapRecognizer: UITapGestureRecognizer?
  private var overlayView: UIView? {
    self.window.subviews.first(where: { $0.accessibilityIdentifier == Constants.overlayViewIdentifier })
  }
  private var messageView: HighlightItemMessageView? {
    self.overlayView?.subviews.first(where: { $0.accessibilityIdentifier == Constants.messageViewIdentifier }) as? HighlightItemMessageView
  }
  private var skipButton: UIButton? {
    self.overlayView?.subviews.first(where: { $0.accessibilityIdentifier == Constants.skipButtonViewIdentifier }) as? UIButton
  }

  private var messageViewTopConstraint: NSLayoutConstraint?

  private(set) var isPresenting: Bool = false
  private(set) var items: [HighlightItem] = []

  private var currentPresentingItemIndex: Int = -1
  private var currentHighlightedFrame: CGRect = .zero

  init(window: UIWindow, isLoggingEnabled: Bool) {
    self.window = window
    self.isLoggingEnabled = isLoggingEnabled

    self.log("Initialized")
  }

  func setItems(_ items: [HighlightItem]) {
    if !self.items.isEmpty && self.isPresenting {
      self.log("Can't replace active items during presentation, aborting items update")
      return
    }

    self.log("Updated with \(items.count) items")
    self.items = items
  }

  func start() {
    if self.isPresenting {
      self.log("Already presenting, aborting start")
      return
    }
    self.displayOverlayView()
    self.currentPresentingItemIndex = 0
    self.isPresenting = true
    self.presentItem()
  }

  func finish() {
    self.removeOverlayView()
    self.items.removeAll()
    self.currentPresentingItemIndex = -1
    self.isPresenting = false
  }

  func presentItem() {
    let index = self.currentPresentingItemIndex
    if index == self.items.count {
      self.finish()
      return
    }

    let item = self.items[index]
    self.log("Will present item \(item.identifier)")

    guard let view = self.findView(with: item.identifier, in: self.topViewController) else {
      self.log("Failed to find view with identifier \(item.identifier), will move to next one")
      self.presentNextItem()
      return
    }
    self.log("Did find view with identifier \(item.identifier)")

    self.highlightView(view, item: item)
  }

}

// MARK: Highlighting view

private extension HighlightEngine {

  func displayOverlayView() {
    guard self.overlayView == nil else {
      self.log("Overlay view is already presented, aborting overlay displaying")
      return
    }

    self.log("Displaying overlay")
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .black.withAlphaComponent(0.5)
    view.accessibilityIdentifier = Constants.overlayViewIdentifier
    window.addSubview(view)
    window.addConstraints([
      view.topAnchor.constraint(equalTo: window.topAnchor),
      view.leftAnchor.constraint(equalTo: window.leftAnchor),
      view.rightAnchor.constraint(equalTo: window.rightAnchor),
      view.bottomAnchor.constraint(equalTo: window.bottomAnchor)
    ])

    let messageView = HighlightItemMessageView()
    messageView.translatesAutoresizingMaskIntoConstraints = false
    messageView.accessibilityIdentifier = Constants.messageViewIdentifier
    messageView.backgroundColor = .blue
    view.addSubview(messageView)

    let messageViewTopConstraint = messageView.topAnchor.constraint(equalTo: view.topAnchor)
    self.messageViewTopConstraint = messageViewTopConstraint

    view.addConstraints([
      messageViewTopConstraint,
      messageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Constants.messageViewInsets),
      messageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Constants.messageViewInsets),
    ])

    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
    button.setTitleColor(.white, for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 20.0, weight: .regular)
    button.accessibilityIdentifier = Constants.skipButtonViewIdentifier
    view.addSubview(button)
    view.addConstraints([
      button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: window.safeAreaInsets.bottom == 0.0 ? -8.0 : 0.0),
      button.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    ])

    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(overlayViewTapRecognizerTapped(_:)))
    view.addGestureRecognizer(tapRecognizer)
    self.tapRecognizer = tapRecognizer
  }

  func removeOverlayView() {
    self.log("Removing overlay")
    self.overlayView?.removeFromSuperview()
  }

  func highlightView(_ view: UIView, item: HighlightItem) {
    guard let overlayView = self.overlayView else {
      self.log("Failed to highlight item, overlay is missing")
      return
    }

    let originalFrame = view.bounds
    self.log("Will highlight view \(item.identifier) with original frame \(originalFrame.text)")

    let origin = view.convert(originalFrame.origin, to: window)
    let size = view.frame.size
    var highlightedFrame = CGRect(origin: origin, size: size)

    self.log("Will highlight view \(item.identifier) with converted frame \(highlightedFrame.text)")
    highlightedFrame = highlightedFrame.extend(with: item.shapeConfig.insets)

    self.currentHighlightedFrame = highlightedFrame

    let path = UIBezierPath(rect: window.bounds)

    let highlightPath = self.getHighlightPath(for: item, frame: highlightedFrame)
    path.append(highlightPath.reversing())

    let mask = CAShapeLayer()
    mask.path = path.cgPath
    overlayView.layer.mask = mask

    self.updateSkipButton(with: item.skipButtonText)
    self.updateMessageView(with: item.messageConfig, frame: highlightedFrame)
  }

  func getHighlightPath(for item: HighlightItem, frame: CGRect) -> UIBezierPath {
    switch item.shapeConfig.type {
    case .circle:
      if frame.width > frame.height {
        let difference = frame.height - frame.width
        let fixedFrame = CGRect(
          x: frame.origin.x,
          y: frame.origin.y - difference / 2.0,
          width: frame.size.width,
          height: frame.size.height + difference
        )
        return UIBezierPath(roundedRect: fixedFrame, cornerRadius: fixedFrame.width / 2.0)

      } else if frame.height > frame.width {
        let difference = frame.height - frame.width
        let fixedFrame = CGRect(
          x: frame.origin.x - difference / 2.0,
          y: frame.origin.y,
          width: frame.size.width + difference,
          height: frame.size.height
        )
        return UIBezierPath(roundedRect: fixedFrame, cornerRadius: fixedFrame.height / 2.0)

      } else if frame.height == frame.width {
        return UIBezierPath(roundedRect: frame, cornerRadius: frame.width / 2.0)

      } else {
        fallthrough
      }

    case .rectangle:
      return UIBezierPath(roundedRect: frame, cornerRadius: min(6.0, min(frame.width, frame.height) / 2.0))
    }
  }

  func updateSkipButton(with text: String?) {
    if let text = text?.nilIfEmpty {
      self.skipButton?.isHidden = false
      self.skipButton?.setTitle(text, for: .normal)
    } else {
      self.skipButton?.isHidden = true
    }
  }

  func updateMessageView(with messageConfig: HighlightItem.MessageConfig, frame: CGRect) {
    guard messageConfig.hasText else {
      self.messageView?.isHidden = true
      return
    }

    self.messageView?.isHidden = false
    self.messageView?.titleText = messageConfig.title
    self.messageView?.subtitleText = messageConfig.subtitle
    self.messageView?.hintText = messageConfig.hint
    self.messageView?.position = messageConfig.position
    self.messageView?.arrowOffset = min(max(frame.midX - Constants.messageViewInsets, 0.0), UIScreen.main.bounds.width - Constants.messageViewInsets * 2.0 - HighlightItemMessageView.Constants.arrowSize.width)

    switch messageConfig.position {
    case .onTop:
      self.messageViewTopConstraint?.constant = [
        Constants.messageViewInsets,
        self.messageView?.height ?? 0.0
      ]
        .reduce(into: frame.origin.y, { $0 -= $1 })

    case .below:
      self.messageViewTopConstraint?.constant = [
        frame.origin.y,
        frame.size.height,
        Constants.messageViewInsets,
        HighlightItemMessageView.Constants.arrowSize.height
      ].reduce(into: 0.0, { $0 += $1 })
    }
  }

}

// MARK; - Handling user interaction

private extension HighlightEngine {

  func presentNextItem() {
    self.currentPresentingItemIndex += 1
    self.presentItem()
  }

  @objc
  func overlayViewTapRecognizerTapped(_ sender: UITapGestureRecognizer) {
    guard let overlayView = self.overlayView else {
      self.log("Failed to handle user tap, overlay is missing")
      return
    }

    let tapLocation = sender.location(in: overlayView)

    self.log("User did tap at \(tapLocation.text)")

    if self.currentHighlightedFrame.contains(tapLocation) {
      self.presentNextItem()
    }
  }

  @objc
  func skipButtonTapped() {
    self.presentNextItem()
  }

}

// MARK: - Finding subview

private extension HighlightEngine {

  func findView(with identifier: String, in viewController: UIViewController) -> UIView? {
    if let navigationController = viewController as? UINavigationController,
       let embeddedViewController = navigationController.viewControllers.last,
       let frame = self.findView(with: identifier, in: embeddedViewController) {
      return frame
    }

    let items: [UIAccessibilityIdentification?] = [
      viewController.navigationItem.leftBarButtonItem,
      viewController.navigationItem.titleView,
      viewController.navigationItem.rightBarButtonItem
    ]
    + (viewController.navigationItem.leftBarButtonItems ?? [])
    + (viewController.navigationItem.rightBarButtonItems ?? [])
      .compactMap { $0 }

    if let item = items.first(where: { $0?.accessibilityIdentifier == identifier }),
       let object = item as? NSObject,
       let view = object.value(forKey: "view") as? UIView {
      return view
    }

    return self.findView(with: identifier, in: viewController.view)
  }

  func findView(with identifier: String, in view: UIView) -> UIView? {
    if view.subviews.isEmpty {
      return view.accessibilityIdentifier == identifier ? view : nil
    }

    for subview in view.subviews {
      if let view = self.findView(with: identifier, in: subview) {
        return view
      }
    }

    return nil
  }

}

// MARK: - Helpers

private extension HighlightEngine {

  func log(_ text: String) {
    guard self.isLoggingEnabled else { return }

    print("🔍 HE: \(text)")
  }

}

private extension CGRect {

  var text: String {
    [
      "X: \(self.origin.x.int)",
      "Y: \(self.origin.y.int)",
      "W: \(self.size.width.int)",
      "H: \(self.size.height.int)"
    ]
      .joined(separator: " ")
  }

  func extend(with insets: UIEdgeInsets) -> CGRect {
    var origin = self.origin
    var size = self.size

    if insets.top > 0.0 {
      origin.y -= insets.top
      size.height += insets.top
    }
    if insets.left > 0.0 {
      origin.x -= insets.left
      size.width += insets.left
    }
    if insets.right > 0.0 {
      size.width += insets.right
    }
    if insets.bottom > 0.0 {
      size.height += insets.bottom
    }

    return .init(origin: origin, size: size)
  }

}

private extension CGPoint {

  var text: String {
    [
      "X: \(self.x.int)",
      "Y: \(self.y.int)"
    ]
      .joined(separator: " ")
  }

}

private extension CGFloat {

  var int: Int {
    Int(self)
  }

}
