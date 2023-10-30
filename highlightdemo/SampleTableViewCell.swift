import Foundation
import UIKit

class SampleTableViewCell: UITableViewCell {

  private let leftIconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    imageView.image = .init(named: "icon_skull")
    return imageView
  }()

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .black
    return label
  }()

  private let rightIconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    imageView.image = .init(named: "icon_skull")
    return imageView
  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func update(index: Int) {
    self.titleLabel.text = "Row \(index)"

    self.leftIconImageView.accessibilityIdentifier = "row_\(index)_left_icon"
    self.titleLabel.accessibilityIdentifier = "row_\(index)_label"
    self.rightIconImageView.accessibilityIdentifier = "row_\(index)_right_icon"
  }

}

private extension SampleTableViewCell {

  func setupLayout() {
    self.contentView.addSubview(self.leftIconImageView)
    self.contentView.addSubview(self.titleLabel)
    self.contentView.addSubview(self.rightIconImageView)

    self.contentView.addConstraints([
      self.contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50.0),

      self.leftIconImageView.topAnchor.constraint(greaterThanOrEqualTo: self.contentView.topAnchor, constant: 8.0),
      self.leftIconImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 16.0),
      self.leftIconImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
      self.leftIconImageView.heightAnchor.constraint(equalToConstant: 24.0),
      self.leftIconImageView.widthAnchor.constraint(equalToConstant: 24.0),

      self.titleLabel.topAnchor.constraint(greaterThanOrEqualTo: self.contentView.topAnchor, constant: 8.0),
      self.titleLabel.leftAnchor.constraint(equalTo: self.leftIconImageView.rightAnchor, constant: 8.0),
      self.titleLabel.rightAnchor.constraint(equalTo: self.rightIconImageView.leftAnchor, constant: -8.0),
      self.titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),

      self.rightIconImageView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -16.0),
      self.rightIconImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
      self.rightIconImageView.heightAnchor.constraint(equalToConstant: 16.0),
      self.rightIconImageView.widthAnchor.constraint(equalToConstant: 16.0)
    ])
  }

}
