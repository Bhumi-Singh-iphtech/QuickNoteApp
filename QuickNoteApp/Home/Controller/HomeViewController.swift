import UIKit
import AVFoundation

enum HomeNoteItem {
    case plain(PlainNoteEntity)
    case voice(VoiceNoteEntity)
}

class HomeViewController: UIViewController {
    
    // MARK: - Outlets & Properties
    let miniPlayer = MiniPlayerView()
    var miniPlayerBottomConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var collectionView: UICollectionView! // Folders
    @IBOutlet weak var recentNotesCollectionView: UICollectionView! // Notes
    
    private var displayItems: [HomeNoteItem] = []
    private var folders: [FolderModel] = []
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // 1. Initialize Folders in DB
        CoreDataManager.shared.ensureDefaultFolders()
        
        // 2. Setup UI
        setupCollectionView()
        setupMiniPlayer()
        
        collectionView.backgroundColor = .clear
        recentNotesCollectionView.backgroundColor = .clear
        
        // CALL DATA FETCHING FUNCTIONS
        loadFolders()
        combineData()
        
        // 4. 🔥 REGISTER FOR NOTIFICATIONS 🔥
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNotes), name: .refreshHomeNotes, object: nil)
        // If you have a separate notification for folders, add it here too
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideMiniPlayer()
    }

    // MARK: - Refresh Logic
    @objc private func refreshNotes() {
        combineData()
    }
    
    @objc private func refreshFolders() {
        loadFolders()
    }

    // MARK: - Data Loading
    private func combineData() {
     
        let savedVoiceNotes = CoreDataManager.shared.fetchAllNotes()
        
        let savedPlainNotes = CoreDataManager.shared.fetchAllPlainNotes()

        let voiceItems = savedVoiceNotes.map { HomeNoteItem.voice($0) }
        let plainItems = savedPlainNotes.map { HomeNoteItem.plain($0) }
        
    
        let allItems = voiceItems + plainItems
        


        displayItems = allItems.sorted { item1, item2 in
            let date1: Date
            let date2: Date
            
            switch item1 {
            case .voice(let v): date1 = v.createdAt ?? Date.distantPast
            case .plain(let p): date1 = p.date ?? Date.distantPast
            }
            
            switch item2 {
            case .voice(let v): date2 = v.createdAt ?? Date.distantPast
            case .plain(let p): date2 = p.date ?? Date.distantPast
            }
            
            return date1 > date2
        }
        
       
        recentNotesCollectionView.reloadData()
    }
    
    private func loadFolders() {
       
        let defaultFolders = [
            FolderModel(title: "Personal", category: .personal),
            FolderModel(title: "Work", category: .work),
            FolderModel(title: "School", category: .school),
            FolderModel(title: "Travel", category: .travel)
        ]
        
 
        let savedFolderEntities = CoreDataManager.shared.fetchAllFolders()
        
     
        let savedFolders = savedFolderEntities.compactMap { entity -> FolderModel? in
            guard let title = entity.title else { return nil }
            // Avoid duplicates
            if defaultFolders.contains(where: { $0.title == title }) { return nil }
            
            return FolderModel(title: title, category: .other)
        }
        
      
        self.folders = defaultFolders + savedFolders
        self.collectionView.reloadData()
        self.updateFoldersBackgroundView()
    }
    

    @IBAction func addFolderTapped(_ sender: UIButton) {
        showAddFolderAlert()
    }
    
    private func showAddFolderAlert() {
        let alert = UIAlertController(title: "Add Folder", message: "Select a category", preferredStyle: .actionSheet)

        FolderCategory.allCases.forEach { category in
            if category != .other {
                alert.addAction(UIAlertAction(title: category.rawValue, style: .default) { _ in
                    self.createNewFolder(title: category.rawValue, category: category)
                })
            }
        }

        alert.addAction(UIAlertAction(title: "Other", style: .default) { _ in
            self.showNewCategoryTextField()
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showNewCategoryTextField() {
        let alert = UIAlertController(title: "New Category", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            if let name = alert.textFields?.first?.text, !name.isEmpty {
                self.createNewFolder(title: name, category: .other)
            }
        })
        present(alert, animated: true)
    }

    private func createNewFolder(title: String, category: FolderCategory) {
        // Save to CoreData
        CoreDataManager.shared.createFolder(name: title)
        // Refresh UI
        refreshFolders()
    }

    // MARK: - Navigation Helper
    private func navigateToFolder(_ folder: FolderModel) {
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         if let vc = storyboard.instantiateViewController(withIdentifier: "FolderDetailViewController") as? FolderDetailViewController {
             vc.folderModel = folder
             self.navigationController?.pushViewController(vc, animated: true)
         }
     }
    
    private func updateFoldersBackgroundView() {
        if folders.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "Add new folder"
            emptyLabel.textColor = .lightGray
            emptyLabel.textAlignment = .center
            emptyLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            collectionView.backgroundView = emptyLabel
        } else {
            collectionView.backgroundView = nil
        }
    }
    
    // MARK: - Mini Player
    private func setupMiniPlayer() {
        view.addSubview(miniPlayer)
        miniPlayer.translatesAutoresizingMaskIntoConstraints = false
        
        miniPlayerBottomConstraint = miniPlayer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 150)
        
        NSLayoutConstraint.activate([
            miniPlayer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            miniPlayer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            miniPlayer.heightAnchor.constraint(equalToConstant: 100),
            miniPlayerBottomConstraint!
        ])

        miniPlayer.onDismiss = { [weak self] in
            self?.hideMiniPlayer()
        }

        AudioManager.shared.onProgressUpdate = { [weak self] progress in
               guard let self = self, let player = AudioManager.shared.player else { return }
               self.miniPlayer.progressSlider.value = Float(progress)
               let currentSeconds = Int(player.currentTime)
               self.miniPlayer.currentTimeLabel.text = String(format: "%d:%02d", currentSeconds / 60, currentSeconds % 60)
               let totalSeconds = Int(player.duration)
               self.miniPlayer.totalTimeLabel.text = String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
           }
        AudioManager.shared.onPlaybackStatusChange = { [weak self] isPlaying in
            let icon = isPlaying ? "pause.fill" : "play.fill"
            self?.miniPlayer.playPauseButton.setImage(UIImage(systemName: icon), for: .normal)
        }
    }

    func showMiniPlayer() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.miniPlayerBottomConstraint?.constant = -83
            self.view.layoutIfNeeded()
        }
    }
    
    func hideMiniPlayer() {
        AudioManager.shared.stop()
        UIView.animate(withDuration: 0.3) {
            self.miniPlayerBottomConstraint?.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        recentNotesCollectionView.dataSource = self
        recentNotesCollectionView.delegate = self
    }
}

// MARK: - Collection View DataSource
extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == self.collectionView ? folders.count : displayItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.collectionView {
     
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FolderCollectionViewCell", for: indexPath) as! FolderCollectionViewCell
            let folder = folders[indexPath.item]
            cell.configure(with: folder)
            
           
            cell.onDeleteRequest = { [weak self] in
                guard let self = self else { return }
                
                let alert = UIAlertController(title: "Delete Folder", message: "Do you want to delete '\(folder.title)'?", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let okAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                    
                    //  Delete from CoreData
                    CoreDataManager.shared.deleteFolder(name: folder.title)
                    
                 
                    self.folders.remove(at: indexPath.item)
                    self.collectionView.reloadData()
                    self.updateFoldersBackgroundView()
                }
                alert.addAction(cancelAction)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
            return cell
            
        } else {
         
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentNotesCollectionViewCell", for: indexPath) as! RecentNotesCollectionViewCell
            let item = displayItems[indexPath.item]
            cell.configure(with: item)
            
            cell.onPlayTapped = { [weak self] in
                if case .voice(let note) = item {
                    AudioManager.shared.play(note)
                    self?.showMiniPlayer()
                }
            }
            
            cell.onDeleteTapped = { [weak self] in
                guard let self = self else { return }
                
                let alert = UIAlertController(title: "Delete Note", message: "Are you sure you want to delete this note?", preferredStyle: .alert)
                
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                    switch item {
                    case .voice(let voiceNote):
                        CoreDataManager.shared.deleteVoiceNote(note: voiceNote)
                    case .plain(let plainNote):
                        CoreDataManager.shared.deletePlainNote(plainNote)
                    }
                    
                    self.refreshNotes()
                }
                
                alert.addAction(deleteAction)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alert, animated: true)
            }
            
            cell.onArrowTapped = { [weak self] in
                var categoryName = "General"
                
                switch item {
                case .plain(let n):
            
                    if let cat = n.category, !cat.isEmpty {
                        categoryName = cat
                    }
                    
                case .voice(let n):
                    if let title = n.title, !title.isEmpty {
                        categoryName = title
                    }
                }
                
                print("Navigating to folder: \(categoryName)") // Debug print
                
                let folder = FolderModel(title: categoryName, category: .other)
                self?.navigateToFolder(folder)
            }
            return cell
        }
    }
}
      
// MARK: - Collection View Delegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.collectionView {
            // Folder Navigation
            let selectedFolder = folders[indexPath.item]
            self.navigateToFolder(selectedFolder)
            
        } else if collectionView == self.recentNotesCollectionView {
            // Note Navigation
            let item = displayItems[indexPath.item]
            
            switch item {
            case .plain(let note):
                //FIX: Navigate to Edit Screen
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "PlainNoteViewController") as? PlainNoteViewController {
                    
                    // Pass the note object so we edit this specific one
                    vc.currentNote = note
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            case .voice(let voiceNote):
                // FIX: Navigate to Voice Note Screen
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "VoiceNoteViewController") as? VoiceNoteViewController {
                    
                    // Pass the voice object
                    vc.currentVoiceNote = voiceNote
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}
// MARK: - Flow Layout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionView {
            return CGSize(width: collectionView.bounds.width / 4, height: 149)
        } else {
            return CGSize(width: collectionView.bounds.width, height: 120)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView == self.collectionView ? 0 : 12
    }
}
