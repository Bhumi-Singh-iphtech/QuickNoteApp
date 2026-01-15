//
//  EditMenuView.swift
//  QuickNoteApp
//
//  Created by iPHTech 22 on 08/01/26.
//

import UIKit

protocol EditMenuViewDelegate: AnyObject {
    func didTapImage()
    func didTapAttachment()
    func didTapChart()
    func didTapLink()
    func didTapAudio()
    func didTapSketch()
}

final class EditMenuView: UIView {

    weak var delegate: EditMenuViewDelegate?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - UI
    private func setupUI() {
     
        backgroundColor = UIColor(hex: "#2F2F34")
        layer.cornerRadius = 16
        clipsToBounds = true
        layer.borderWidth = 0.5

        
        let buttons = [
            createButton(title: "Image", icon: "photo", action: #selector(imageTapped)),
            createButton(title: "Attachment", icon: "paperclip", action: #selector(attachmentTapped)),
            createButton(title: "Chart", icon: "chart.bar", action: #selector(chartTapped)),
            createButton(title: "Link", icon: "link", action: #selector(linkTapped)),
            createButton(title: "Audio", icon: "mic", action: #selector(audioTapped)),
            createButton(title: "Sketch", icon: "pencil.tip", action: #selector(sketchTapped))
        ]

        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 12

        for i in stride(from: 0, to: buttons.count, by: 2) {
            let row = UIStackView(arrangedSubviews: [buttons[i], buttons[i+1]])
            row.axis = .horizontal
            row.distribution = .fillEqually
            row.spacing = 12
            grid.addArrangedSubview(row)
        }

        addSubview(grid)
        grid.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            grid.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            grid.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            grid.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            grid.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    private func createButton(title: String, icon: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        
        // Create stack view for icon and label
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = false
        
        // Create icon
        let iconImageView = UIImageView(image: UIImage(systemName: icon))
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.widthAnchor.constraint(equalToConstant: 14).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 14 ).isActive = true
        
        // Create title label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 12)
        
        // Add to stack
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        
        // Add stack to button
        button.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Center the stack view
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16)
        ])
        
      
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        // Add border/box around the button
        button.backgroundColor = UIColor(hex: "#242529")
   

        button.layer.borderColor = UIColor(hex: "#3E3E44").cgColor
        button.layer.cornerRadius = 5
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    // MARK: - Actions
    @objc private func imageTapped() { delegate?.didTapImage() }
    @objc private func attachmentTapped() { delegate?.didTapAttachment() }
    @objc private func chartTapped() { delegate?.didTapChart() }
    @objc private func linkTapped() { delegate?.didTapLink() }
    @objc private func audioTapped() { delegate?.didTapAudio() }
    @objc private func sketchTapped() { delegate?.didTapSketch() }

    // MARK: - Animation
    func show() {
        alpha = 0
        isHidden = false
        transform = CGAffineTransform(translationX: 0, y: 20)

        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
            self.transform = .identity
        }
    }

    func hide() {
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0
            self.transform = CGAffineTransform(translationX: 0, y: 20)
        } completion: { _ in
            self.isHidden = true
        }
    }
}
