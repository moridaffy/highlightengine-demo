import Foundation
import UIKit

class FirstViewController: UIViewController {

  private let tableView: UITableView = {
    let tableView = UITableView()
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.register(SampleTableViewCell.self, forCellReuseIdentifier: "cell")
    return tableView
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    self.setupLayout()
    self.setupTableView()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.setupNavigationBar()
  }

}

private extension FirstViewController {

  func setupLayout() {
    self.view.addSubview(self.tableView)

    self.view.addConstraints([
      self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    ])
  }

  func setupTableView() {
    self.tableView.delegate = self
    self.tableView.dataSource = self

    self.tableView.reloadData()
  }

  func setupNavigationBar() {
    if self.navigationItem.rightBarButtonItem == nil {
      let button = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(startButtonTapped))
      button.accessibilityIdentifier = "navbar_start_button"
      self.navigationItem.rightBarButtonItem = button
    }
  }

  @objc
  func startButtonTapped() {
    guard let engine = HighlightEngine.shared else { fatalError() }
    if !engine.isPresenting && engine.items.isEmpty {
      engine.setItems([
        .init(
          identifier: "navbar_start_button",
          shapeConfig: .init(type: .circle, insets: .make(allSides: 8.0)),
          messageConfig: .init(position: .below, title: "title", subtitle: "subtitle", hint: "Step 1 of 5"),
          skipButtonText: "Not now, thanks"
        ),
        .init(
          identifier: "row_5_label",
          shapeConfig: .init(type: .rectangle, insets: .make(allSides: 8.0)),
          messageConfig: .init(position: .onTop, title: "title", subtitle: "subtitle", hint: "Step 2 of 5"),
          skipButtonText: "Not now, thanks"
        ),
        .init(
          identifier: "row_3_left_icon",
          shapeConfig: .init(type: .rectangle, insets: .make(allSides: 8.0)),
          messageConfig: .init(position: .onTop, title: "title", subtitle: "subtitle", hint: "Step 3 of 5"),
          skipButtonText: "Not now, thanks"
        ),
        .init(
          identifier: "row_13_label",
          shapeConfig: .init(type: .rectangle, insets: .make(allSides: 8.0)),
          messageConfig: .init(position: .onTop, title: "title", subtitle: "subtitle", hint: "Step 4 of 5"),
          skipButtonText: "Not now, thanks"
        ),
        .init(
          identifier: "row_0_right_icon",
          shapeConfig: .init(type: .rectangle, insets: .make(allSides: 16.0)),
          messageConfig: .init(position: .below, title: "title", subtitle: "subtitle", hint: "Step 5 of 5"),
          skipButtonText: "Not now, thanks"
        ),
      ])
    }

    engine.start()
  }

}

extension FirstViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

extension FirstViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    100
  }
  

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? SampleTableViewCell else { fatalError() }
    cell.update(index: indexPath.row)
    return cell
  }

}

