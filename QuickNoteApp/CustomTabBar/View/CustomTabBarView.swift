import UIKit

protocol CustomTabBarDelegate: AnyObject {
    func didSelectTab(index: Int)
}

class CustomTabBarView: UIView {

    weak var delegate: CustomTabBarDelegate?

    private let stackView = UIStackView()
    private var tabItems: [UIStackView] = []
    private var models: [TabBarItemModel] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    func configure(with models: [TabBarItemModel]) {
        self.models = models
        setupTabs()
        updateSelection(index: 0)
    }

    private func setupUI() {
        backgroundColor = UIColor(hex: "#2F2F34")



        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupTabs() {
        models.enumerated().forEach { index, model in

            let config = UIImage.SymbolConfiguration(pointSize: 21, weight: .bold)
            let image = UIImage(systemName: model.icon, withConfiguration: config)

            let iconView = UIImageView(image: image)
            iconView.tintColor = UIColor(hex: "#A7A8A9")
            iconView.contentMode = .center

            iconView.translatesAutoresizingMaskIntoConstraints = false
            iconView.heightAnchor.constraint(equalToConstant: 30).isActive = true
            iconView.widthAnchor.constraint(equalToConstant: 30).isActive = true

            
            let titleLabel = UILabel()
            titleLabel.text = model.title
            titleLabel.font = .systemFont(ofSize: 14)
            titleLabel.textColor = UIColor(hex: "#A7A8A9")

            let verticalStack = UIStackView(arrangedSubviews: [iconView, titleLabel])
            verticalStack.axis = .vertical
            verticalStack.alignment = .center
            verticalStack.spacing = 4
            verticalStack.tag = index
            verticalStack.isUserInteractionEnabled = true

            let tap = UITapGestureRecognizer(target: self, action: #selector(tabTapped(_:)))
            verticalStack.addGestureRecognizer(tap)

            tabItems.append(verticalStack)
            stackView.addArrangedSubview(verticalStack)
        }
    }

    @objc private func tabTapped(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag else { return }
        updateSelection(index: index)
        delegate?.didSelectTab(index: index)
    }

    func updateSelection(index: Int) {
        tabItems.enumerated().forEach { i, item in
            let color: UIColor = (i == index)
                ? UIColor(hex: "#A6ABFF")   // selected color
                : UIColor(hex: "#A7A8A9")

            (item.arrangedSubviews[0] as? UIImageView)?.tintColor = color
            (item.arrangedSubviews[1] as? UILabel)?.textColor = color
        }
    }
}
