import UIKit
import AVFoundation

class FolderDetailViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var DownArrowButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var sortLabel: UILabel!
    
    
    @IBOutlet weak var notesCollectionView: UICollectionView!
    
    
    private let customNavBar = CustomNavigationBar()
    var folderModel: FolderModel?
    private let editMenuView = EditMenuView()
    
   
    private var folderNotes: [HomeNoteItem] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let themeColor = UIColor(red: 27/255, green: 27/255, blue: 27/255, alpha: 1.0)
        self.view.backgroundColor = themeColor
        self.navigationController?.view.backgroundColor = themeColor
        
        dropDownView.layer.cornerRadius = 10
        DownArrowButton.setTitle("", for: .normal)
       
        setupCustomNavBar()
        hideKeyboardWhenTappedAround()
        setupUI()
        setupSortMenu()
        
        // Setup Collection View
        setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        (tabBarController as? CustomTabBarController)?.setCustomTabBar(hidden: true)
        
 
        loadNotesForThisFolder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        (tabBarController as? CustomTabBarController)?.setCustomTabBar(hidden: false)
        
 
        AudioManager.shared.stop()
    }
    

    private func loadNotesForThisFolder() {
        guard let currentCategory = folderModel?.title else { return }
        
        // 1. Fetch All Notes
        let allVoice = CoreDataManager.shared.fetchAllNotes()
        let allPlain = CoreDataManager.shared.fetchAllPlainNotes()
        
        // 2. Filter for THIS folder
        let filteredVoice = allVoice.filter { $0.title == currentCategory }
        let filteredPlain = allPlain.filter { $0.category == currentCategory }
        
     
        let voiceItems = filteredVoice.map { HomeNoteItem.voice($0) }
        let plainItems = filteredPlain.map { HomeNoteItem.plain($0) }
        
        // 4. Combine and Reload
        self.folderNotes = voiceItems + plainItems
        self.notesCollectionView.reloadData()
        
        // Set text to just the Category Name (removed the count)
        self.titleLabel.text = currentCategory
    }

    // MARK: - Setup UI
    private func setupCollectionView() {
        notesCollectionView.delegate = self
        notesCollectionView.dataSource = self
        notesCollectionView.backgroundColor = .clear
        
       
    }

    // MARK: - Actions
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        let bottomSheet = ShareMenuView(frame: self.view.bounds)
        
   
        bottomSheet.noteContent = "Folder: \(folderModel?.title ?? "")"
        
      
        let savedFolders = CoreDataManager.shared.fetchAllFolders()
        bottomSheet.existingFolders = savedFolders.compactMap { $0.title }
        
        bottomSheet.onCreateNewFolder = { newName in
            CoreDataManager.shared.createFolder(name: newName)
        }
        
        bottomSheet.show(in: view)
    }

    // MARK: - Sort Menu Logic
    private func setupSortMenu() {
        let titles = ["Last edited", "Alphabetically A-Z", "Alphabetically Z-A", "Newest first"]
        let actions = titles.map { title in
            return UIAction(title: title, image: nil, state: title == sortLabel.text ? .on : .off) { _ in
                self.updateSort(title: title)
            }
        }

        let menu = UIMenu(children: actions)

        let overlayButton = UIButton(type: .custom)
        overlayButton.translatesAutoresizingMaskIntoConstraints = false
        overlayButton.menu = menu
        overlayButton.showsMenuAsPrimaryAction = true
        
        dropDownView.subviews.filter({ $0.tag == 999 }).forEach({ $0.removeFromSuperview() })
        overlayButton.tag = 999
        dropDownView.addSubview(overlayButton)
        
        NSLayoutConstraint.activate([
            overlayButton.topAnchor.constraint(equalTo: dropDownView.topAnchor),
            overlayButton.bottomAnchor.constraint(equalTo: dropDownView.bottomAnchor),
            overlayButton.leadingAnchor.constraint(equalTo: dropDownView.leadingAnchor),
            overlayButton.trailingAnchor.constraint(equalTo: dropDownView.trailingAnchor)
        ])
        
        DownArrowButton.menu = menu
        DownArrowButton.showsMenuAsPrimaryAction = true
    }

    private func updateSort(title: String) {
        self.sortLabel.text = title
       
        self.setupSortMenu()
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
        customNavBar.setTitle(folderModel?.title ?? "My Folder")
        customNavBar.onBackTap = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        view.bringSubviewToFront(customNavBar)
    }

    private func setupUI() {
        guard let folder = folderModel else { return }
        titleLabel.text = folder.title
    }

    // MARK: - Keyboard & Gestures
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - CollectionView DataSource & Delegate
extension FolderDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return folderNotes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentNotesCollectionViewCell", for: indexPath) as! RecentNotesCollectionViewCell
        
        let item = folderNotes[indexPath.item]
        cell.configure(with: item)
        
        // Play Button Logic
        cell.onPlayTapped = {
            if case .voice(let note) = item {
                AudioManager.shared.play(note)
               
            }
        }
        
   
        cell.onDeleteTapped = { [weak self] in
            self?.showDeleteAlert(for: item)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
        return CGSize(width: collectionView.bounds.width - 24, height: 120)
    }
    
    // MARK: - Delete Helper
    private func showDeleteAlert(for item: HomeNoteItem) {
        let alert = UIAlertController(
            title: AlertMessages.Title.deleteNote,
            message: AlertMessages.Message.deleteNoteConfirmation,
            preferredStyle: .alert
        )
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            switch item {
            case .voice(let voiceNote):
                CoreDataManager.shared.deleteVoiceNote(note: voiceNote)
            case .plain(let plainNote):
                CoreDataManager.shared.deletePlainNote(plainNote)
            }
            
            // Refresh list
            self.loadNotesForThisFolder()
        }
        
        alert.addAction(deleteAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
}

// MARK: - EditMenuViewDelegate
extension FolderDetailViewController: EditMenuViewDelegate {
    func didTapImage() { print("Image tapped") }
    func didTapAttachment() { print("Attachment tapped") }
    func didTapChart() { print("Chart tapped") }
    func didTapLink() { print("Link tapped") }
    func didTapAudio() { print("Audio tapped") }
    func didTapSketch() { print("Sketch tapped") }
}
