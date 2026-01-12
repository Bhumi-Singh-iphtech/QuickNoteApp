



import UIKit

final class PlainNoteViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var editButtonView: EditButtonView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!

    // MARK: - Properties
    private let editMenuView = EditMenuView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDate()
        setupEditMenu()

        editButtonView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? CustomTabBarController)?.setCustomTabBar(hidden: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        (tabBarController as? CustomTabBarController)?.setCustomTabBar(hidden: false)
    }

    // MARK: - Setup UI
    private func setupUI() {
        textView.delegate = self
        textView.font = .systemFont(ofSize: 15)
        textView.textColor = .white
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 8, bottom: 0, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        placeholderLabel.isHidden = !textView.text.isEmpty
    }

    private func setupDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        dateLabel.text = formatter.string(from: Date())
    }

    private func setupEditMenu() {
        editMenuView.delegate = self
        editMenuView.isHidden = true
        view.addSubview(editMenuView)

        editMenuView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            editMenuView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 95),
            editMenuView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            editMenuView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            editMenuView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }

    // MARK: - Actions
    @IBAction func closeTapped(_ sender: UIButton) {
        editMenuView.hide()
        editButtonView.reset()
        navigationController?.popViewController(animated: true)
    }
}
extension PlainNoteViewController: EditButtonViewDelegate {

    func didTapEditButton() {
        editButtonView.toggle()

        if editButtonView.isExpanded {
            editMenuView.show()
        } else {
            editMenuView.hide()
        }
    }
}
extension PlainNoteViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        editMenuView.hide()
        editButtonView.reset()
    }
}
extension PlainNoteViewController: EditMenuViewDelegate {

    func didTapImage() {
        print("Image tapped")
    }

    func didTapAttachment() {
        print("Attachment tapped")
    }

    func didTapChart() {
        print("Chart tapped")
    }

    func didTapLink() {
        print("Link tapped")
    }

    func didTapAudio() {
        print("Audio tapped")
    }

    func didTapSketch() {
        print("Sketch tapped")
    }
}
