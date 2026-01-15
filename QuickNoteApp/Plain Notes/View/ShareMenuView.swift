import UIKit

final class ShareMenuView: UIView {

    // MARK: - Views
    private let dimmedView = UIView()
    private let containerView = UIView()
    private let grabberView = UIView()
    private let stackView = UIStackView()

    private let sheetHeight: CGFloat = 300
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup
    private func setup() {
        setupDimmedView()
        setupContainerView()
        setupTopBar()
        setupStackView()
    }

    // MARK: - Dimmed Background
    private func setupDimmedView() {
        dimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        addSubview(dimmedView)

        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dimmedView.topAnchor.constraint(equalTo: topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

       
    }

    // MARK: - Container
    private func setupContainerView() {
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 20
        containerView.layer.masksToBounds = true
        containerView.clipsToBounds = true

        addSubview(containerView)
        bringSubviewToFront(grabberView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor , constant: 18 ),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor , constant: -18 ),
            containerView.heightAnchor.constraint(equalToConstant: sheetHeight),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 300)
        ])
    }


    // MARK: - Grabber (Top Bar)
    private func setupTopBar() {
        grabberView.backgroundColor = .white
        grabberView.layer.cornerRadius = 3
        grabberView.isUserInteractionEnabled = true

        addSubview(grabberView)

        grabberView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            grabberView.centerXAnchor.constraint(equalTo: centerXAnchor),
            grabberView.widthAnchor.constraint(equalToConstant: 100),
            grabberView.heightAnchor.constraint(equalToConstant: 6),
            grabberView.bottomAnchor.constraint(
                equalTo: containerView.topAnchor,
                constant: -8
            )
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(hide))
        grabberView.addGestureRecognizer(tap)
    }


    // MARK: - StackView
    private func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.alignment = .leading

        containerView.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 44),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24)
        ])

        addAction(title: "Share note", icon: "share")
        addAction(title: "Add tag", icon: "save")
        addAction(title: "Copy link", icon: "link")
        addAction(title: "Print note", icon: "printer.")
        addAction(title: "Duplicate note", icon: "copy")
    }

    private func addAction(title: String, icon: String) {
        // Load asset image
        let image = UIImage(named: icon)?
            .withRenderingMode(.alwaysTemplate) // allows tint color if needed

        var config = UIButton.Configuration.plain()
        config.title = title
        config.image = image
        config.imagePadding = 15
        config.baseForegroundColor = .black

        // Control icon size
        config.preferredSymbolConfigurationForImage = nil
        config.imagePlacement = .leading

        // Padding
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 8,
            leading: 12,
            bottom: 8,
            trailing: 12
        )

        let button = UIButton(configuration: config)
        button.contentHorizontalAlignment = .leading

        // Title font
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)

        // Resize asset image
        button.configurationUpdateHandler = { button in
            guard let image = button.configuration?.image else { return }

            let resized = image.resized(to: CGSize(width: 25, height: 25))
            button.configuration?.image = resized
        }

        stackView.addArrangedSubview(button)
    }


    // MARK: - Show / Hide
    func show(in parentView: UIView) {
        frame = parentView.bounds
        parentView.addSubview(self)
        layoutIfNeeded()

        let translateY = sheetHeight + 16

        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.6
        ) {
            let transform = CGAffineTransform(translationX: 0, y: -translateY)
            self.containerView.transform = transform
            self.grabberView.transform = transform
        }
    }




    @objc func hide() {
        UIView.animate(withDuration: 0.25, animations: {
            self.containerView.transform = .identity
            self.grabberView.transform = .identity
            self.dimmedView.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }

}
extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
