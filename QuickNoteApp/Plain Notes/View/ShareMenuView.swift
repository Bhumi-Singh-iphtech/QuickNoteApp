import UIKit

final class ShareMenuView: UIView {

    // MARK: - Data Properties
    var noteContent: String = ""
    var existingFolders: [String] = []
    
    // 🔥 NEW: Check if this note was already saved in CoreData
    var isExistingNote: Bool = false

    // MARK: - Callbacks
    var onSaveRequest: (() -> Void)?
    var onCreateNewFolder: ((String) -> Void)?
    var onMoveToFolder: ((String) -> Void)?
    
    // 🔥 NEW: Callback for Delete
    var onDeleteRequest: (() -> Void)?

    // MARK: - Enums
    enum MenuAction {
        case share
        case addToFolder
        case save
        case delete // 👈 Added Delete case
    }

    // MARK: - UI Components
    private let dimmedView = UIView()
    private let containerView = UIView()
    private let grabberView = UIView()
    private let stackView = UIStackView()

    // Height calculation: 3 items
    private let sheetHeight: CGFloat = 180
    
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
        // Note: setupStackView is called later or logic inside needs to run after properties set?
        // Ideally, call setupStackView inside show() or ensure properties are set before init.
        // However, since we set properties after init, we need to rebuild the stack in show()
        // OR simply call setupStackView() here and rely on defaults, but for the conditional logic to work,
        // we usually configure the view *before* showing.
        
        setupStackView()
    }

    // MARK: - 1. Dimmed Background
    private func setupDimmedView() {
        dimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        dimmedView.alpha = 0
        addSubview(dimmedView)

        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dimmedView.topAnchor.constraint(equalTo: topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hide))
        dimmedView.addGestureRecognizer(tap)
    }

    // MARK: - 2. Container
    private func setupContainerView() {
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 24
        containerView.layer.masksToBounds = true
        
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: sheetHeight),
            containerView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        containerView.transform = CGAffineTransform(translationX: 0, y: sheetHeight + 100)
    }

    // MARK: - 3. Grabber
    private func setupTopBar() {
        grabberView.backgroundColor = .white.withAlphaComponent(0.8)
        grabberView.layer.cornerRadius = 2.5
        
        addSubview(grabberView)

        grabberView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            grabberView.centerXAnchor.constraint(equalTo: centerXAnchor),
            grabberView.widthAnchor.constraint(equalToConstant: 40),
            grabberView.heightAnchor.constraint(equalToConstant: 5),
            grabberView.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: -12)
        ])
        
        grabberView.transform = CGAffineTransform(translationX: 0, y: sheetHeight + 100)
    }

    // MARK: - 4. Stack & Buttons
    // 🔥 UPDATED: This now needs to be called AFTER isExistingNote is set.
    // We will call this in show() to ensure data is ready.
    private func setupStackView() {
        // Clear previous buttons if any
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .fillEqually

        containerView.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 25),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -25),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24)
        ])

        // 1. Share
        addAction(title: "Share note", icon: "share", type: .share)
        
        // 2. Folder
        addAction(title: "Add to folder", icon: "folder 1", type: .addToFolder)
        
        // 3. 🔥 CONDITIONAL LOGIC 🔥
        if isExistingNote {
            // Show DELETE
            // Ensure you have a "trash" icon, or use systemName "trash" fallback
            addAction(title: "Delete note", icon: "trash", type: .delete)
        } else {
            // Show SAVE
            addAction(title: "Save note", icon: "download", type: .save)
        }
    }

    private func addAction(title: String, icon: String, type: MenuAction) {
        // Try named asset first, fallback to system SF Symbol
        let image = UIImage(named: icon)?.withRenderingMode(.alwaysTemplate)
                    ?? UIImage(systemName: icon)
                    ?? UIImage(systemName: "star")

        var config = UIButton.Configuration.plain()
        config.title = title
        config.image = image
        config.imagePadding = 16
        config.baseForegroundColor = .black
        config.imagePlacement = .leading
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        let button = ButtonWithAction(type: type, configuration: config)
        button.contentHorizontalAlignment = .leading
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)

        // Ensure icon resizing
        button.configurationUpdateHandler = { btn in
            guard let img = btn.configuration?.image else { return }
            let resized = img.resized(to: CGSize(width: 24, height: 24))
            btn.configuration?.image = resized
        }

        button.addTarget(self, action: #selector(handleButtonTap(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(button)
    }

    // MARK: - Logic
     @objc private func handleButtonTap(_ sender: ButtonWithAction) {
         guard let parentVC = self.parentViewController else { return }

         switch sender.actionType {
         case .share:
             self.hide()
             let itemsToShare: [Any] = [self.noteContent]
             let activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
             
             if let popover = activityVC.popoverPresentationController {
                 popover.sourceView = parentVC.view
                 popover.sourceRect = CGRect(x: parentVC.view.bounds.midX, y: parentVC.view.bounds.midY, width: 0, height: 0)
                 popover.permittedArrowDirections = []
             }

             DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                 parentVC.present(activityVC, animated: true)
             }
             
         case .addToFolder:
             showFolderSelection()
             
         case .save:
             self.hide()
             onSaveRequest?()
             
         case .delete:
             self.hide()
             onDeleteRequest?()
         }
     }
     
    // MARK: - Folder Logic
    private func showFolderSelection() {
        guard let parent = self.parentViewController else { return }

        let actionSheet = UIAlertController(title: "Move to Folder", message: "Choose a destination", preferredStyle: .actionSheet)

        // Helper
        let handleSelection: (String) -> Void = { folderName in
            print("Moved to: \(folderName)")
            // 🔥 Tell Controller to update DB
            self.onMoveToFolder?(folderName)
            self.hide()
        }

        if existingFolders.isEmpty {
            let defaults = ["Personal", "Work", "Ideas"]
            for folderName in defaults {
                let action = UIAlertAction(title: folderName, style: .default) { _ in
                    handleSelection(folderName)
                }
                actionSheet.addAction(action)
            }
        } else {
            for folderName in existingFolders {
                let action = UIAlertAction(title: folderName, style: .default) { _ in
                    handleSelection(folderName)
                }
                actionSheet.addAction(action)
            }
        }

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = actionSheet.popoverPresentationController {
            popover.sourceView = parent.view
            popover.sourceRect = CGRect(x: parent.view.bounds.midX, y: parent.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        self.hide()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            parent.present(actionSheet, animated: true)
        }
    }

    // MARK: - Animations
    func show(in parentView: UIView) {
        // 🔥 Re-run setupStackView to check 'isExistingNote'
        setupStackView()
        
        frame = parentView.bounds
        parentView.addSubview(self)
        layoutIfNeeded()

        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5
        ) {
            self.dimmedView.alpha = 1
            self.containerView.transform = .identity
            self.grabberView.transform = .identity
        }
    }

    @objc func hide() {
        UIView.animate(withDuration: 0.25, animations: {
            self.dimmedView.alpha = 0
            let transform = CGAffineTransform(translationX: 0, y: self.sheetHeight + 100)
            self.containerView.transform = transform
            self.grabberView.transform = transform
        }) { _ in
            self.removeFromSuperview()
        }
    }
}

// MARK: - Helpers
class ButtonWithAction: UIButton {
    var actionType: ShareMenuView.MenuAction
    init(type: ShareMenuView.MenuAction, configuration: UIButton.Configuration) {
        self.actionType = type
        super.init(frame: .zero)
        self.configuration = configuration
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController { return viewController }
        }
        return nil
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
