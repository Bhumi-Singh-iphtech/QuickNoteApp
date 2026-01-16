



import UIKit

final class PlainNoteViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var editButtonView: EditButtonView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!

    @IBOutlet weak var FontBarView: UIView!
    // MARK: - Properties
    private let editMenuView = EditMenuView()
    private let customNavBar = CustomNavigationBar()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        hideKeyboardWhenTappedAround()
        setupDate()
        setupEditMenu()
        setupCustomNavBar() 
        editButtonView.delegate = self
        
    }
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }


    @objc func dismissKeyboard() {
        view.endEditing(true)
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
            editMenuView.bottomAnchor.constraint(equalTo: FontBarView.topAnchor, constant: -16),
            editMenuView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        let bottomSheet = ShareMenuView()
        bottomSheet.show(in: view)
    }
    private func setupCustomNavBar() {
        customNavBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customNavBar)

        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 110)
        ])

        customNavBar.setTitle("My Notes")

        customNavBar.onBackTap = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
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
