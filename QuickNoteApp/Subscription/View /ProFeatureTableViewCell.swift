//
//  ProFeatureTableViewCell.swift
//  QuickNoteApp
//
//  Created by iPHTech 22 on 06/01/26.
//

import UIKit

class ProFeatureTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        titleLabel.text = nil
    }

    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40)
        ])

        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit

        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.numberOfLines = 1
    }

    // MARK: - Configure
    func configure(iconName: String, title: String) {
        iconImageView.image = UIImage(named: iconName)
        titleLabel.text = title
    }
}
