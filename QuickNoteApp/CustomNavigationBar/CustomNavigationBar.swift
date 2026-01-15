//
//  CustomNavigationBar.swift
//  QuickNoteApp
//
//  Created by iPHTech 22 on 13/01/26.
//

import UIKit

final class CustomNavigationBar: UIView {

    // MARK: - UI
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()

    // MARK: - Callback
    var onBackTap: (() -> Void)?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup
    private func setupUI() {
        backgroundColor = UIColor(hex: "#2B2D33")
        layer.cornerRadius = 18
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

        setupBackButton()
        setupTitleLabel()
    }

    private func setupBackButton() {
        backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backButton.tintColor = .white
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        addSubview(backButton)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            backButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    private func setupTitleLabel() {
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            // Title starts after back button
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),

            // Vertically centered with back button
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor)
        ])
    }


    // MARK: - Actions
    @objc private func backTapped() {
        onBackTap?()
    }

    // MARK: - Public
    func setTitle(_ text: String) {
        titleLabel.text = text
    }
}
