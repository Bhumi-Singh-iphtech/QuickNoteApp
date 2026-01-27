import UIKit
import CoreData
final class PlainNoteViewController: UIViewController, UIGestureRecognizerDelegate {
    var currentNote: PlainNoteEntity?
    private var selectedCategory: String = "Personal"
    // MARK: - Outlets
    @IBOutlet weak var editButtonView: EditButtonView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UITextField!
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
        loadNoteData()
    }
    private func loadNoteData() {
            if let note = currentNote {
             
                titleLabel.text = note.title
                textView.text = note.content
                self.selectedCategory = note.category ?? "Personal"
                if let date = note.date {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
                    dateLabel.text = formatter.string(from: date)
                }
                
          
                placeholderLabel.isHidden = !textView.text.isEmpty
            }
        }
    // MARK: - Keyboard & Gestures
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
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
        
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.attributedPlaceholder = NSAttributedString(
            string: "Note Title",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
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
    
    // MARK: - SHARE MENU ACTION
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        let bottomSheet = ShareMenuView(frame: self.view.bounds)
        
        // 1. Pass Note Content
        let currentTitle = titleLabel.text ?? "Untitled Note"
        let currentBody = textView.text ?? ""
        bottomSheet.noteContent = "\(currentTitle)\n\n\(currentBody)"
        
        // 2. Load Folders (Default + CoreData)
        let defaultFolders = ["Personal", "Work", "School", "Travel"]
        let savedFolderObjects = CoreDataManager.shared.fetchAllFolders()
        let savedFolderNames = savedFolderObjects.compactMap { $0.title }
        let uniqueSavedFolders = savedFolderNames.filter { !defaultFolders.contains($0) }
        bottomSheet.existingFolders = defaultFolders + uniqueSavedFolders
        
        
        bottomSheet.isExistingNote = (self.currentNote != nil)
        
        
        bottomSheet.onCreateNewFolder = { newName in
            CoreDataManager.shared.createFolder(name: newName)
            print("Created folder: \(newName)")
        }
        
       
        bottomSheet.onSaveRequest = { [weak self] in
            self?.showSaveConfirmationAlert()
        }
        
        
        bottomSheet.onMoveToFolder = { [weak self] folderName in
            guard let self = self else { return }
            self.selectedCategory = folderName
           
            if let existingNote = self.currentNote {
                existingNote.category = folderName
                CoreDataManager.shared.saveContext()
                print("Updated existing note category to: \(folderName)")
            }
           
            else {
                let title = self.titleLabel.text ?? "Untitled"
                let body = self.textView.text ?? ""
                
                let newNote = CoreDataManager.shared.createPlainNote(
                    title: title,
                    content: body,
                    category: folderName
                )
                self.currentNote = newNote
                print("Created NEW note in category: \(folderName)")
            }
            
            // Visual Feedback using the new constants
            let alert = UIAlertController(
                title: AlertMessages.Title.moved,
                message: AlertMessages.Message.movedToFolder(folderName),
                preferredStyle: .alert
            )

            self.present(alert, animated: true)

            // Auto-dismiss after 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                alert.dismiss(animated: true)
            }
        }
        
       
        bottomSheet.onDeleteRequest = { [weak self] in
            guard let self = self else { return }
            
            let alert = UIAlertController(
                title: AlertMessages.Title.deleteNote,
                message: AlertMessages.Message.deleteNoteConfirmation,
                preferredStyle: .alert
            )
            let deleteAction = UIAlertAction(title: AlertMessages.Action.delete, style: .destructive) { _ in
                //  Delete from DB
                if let noteToDelete = self.currentNote {
                    CoreDataManager.shared.deletePlainNote(noteToDelete)
                }
                
                // 2. Refresh Home Screen
                NotificationCenter.default.post(name: .refreshHomeNotes, object: nil)
                
                
                self.navigateBack()
            }
            
                            let cancelAction = UIAlertAction(title: AlertMessages.Action.cancel, style: .cancel)
                                
                                // 4. Actions add karein aur present karein
                                alert.addAction(deleteAction)
                                alert.addAction(cancelAction)
                                
                                self.present(alert, animated: true)
        }
        
        bottomSheet.show(in: view)
    }
    
    // MARK: - Save Alert Logic
    private func showSaveConfirmationAlert() {
        print("Presenting Save Confirmation Alert...")
        
        // 1. Alert Controller with Constants
        let alert = UIAlertController(
            title: AlertMessages.Title.saveNote,
            message: AlertMessages.Message.saveNoteConfirmation,
            preferredStyle: .alert
        )

        // 2. Save Action with Constant
        let saveAction = UIAlertAction(title: AlertMessages.Action.save, style: .default) { [weak self] _ in
            self?.saveNoteAndExit()
        }
        
        // 3. Cancel Action with Constant
        let cancelAction = UIAlertAction(title: AlertMessages.Action.cancel, style: .cancel)
        
        // 4. Add Actions and Present
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
    // MARK: - Save Logic
    private func saveNoteAndExit() {
        // 1. Get Data
        let noteTitle = titleLabel.text?.isEmpty == false ? titleLabel.text! : "Untitled Note"
        let noteContent = textView.text ?? ""
        
        // Safety Check: Don't save completely empty notes
        if noteContent.isEmpty && (noteTitle == "Untitled Note" || noteTitle.isEmpty) {
            navigateBack()
            return
        }
        
        // Check if we are updating a note (or one created via Share Menu)
        if let existingNote = self.currentNote {
            
            // OPTION A: Updating Existing Note (or one moved via Menu)
            print("Updating existing note. Current Folder: \(existingNote.category ?? "Nil")")
            
            existingNote.title = noteTitle
            existingNote.content = noteContent
            existingNote.date = Date()
            
          
            
            CoreDataManager.shared.saveContext()
            
        } else {
            
        
            print("Creating new default note (Personal)")
            
            CoreDataManager.shared.savePlainNote(
                content: noteContent,
                title: noteTitle,
                category: self.selectedCategory
            )
        }
        
        // 3. Notify Home Screen to reload
        NotificationCenter.default.post(name: .refreshHomeNotes, object: nil)
        
       
    }

    private func navigateBack() {
        // Send signal to change tab to Home
        NotificationCenter.default.post(name: .navigateToHome, object: nil)
        
        //  FORCE CLOSE THE SCREEN
        if let navigationController = self.navigationController {
            // If we are in a navigation stack, pop to root AND don't animate (instant switch)
            navigationController.popToRootViewController(animated: false)
        }
        
   
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - Custom NavBar
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
}

// MARK: - Extensions
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
    func didTapImage() { print("Image tapped") }
    func didTapAttachment() { print("Attachment tapped") }
    func didTapChart() { print("Chart tapped") }
    func didTapLink() { print("Link tapped") }
    func didTapAudio() { print("Audio tapped") }
    func didTapSketch() { print("Sketch tapped") }
}
