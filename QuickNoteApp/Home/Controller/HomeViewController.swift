import UIKit
import AVFoundation // Added this to fix the stop() error

enum HomeNoteItem {
    case plain(RecentNote)
    case voice(VoiceNoteEntity)
}

class HomeViewController: UIViewController {
    
    let miniPlayer = MiniPlayerView()
    var miniPlayerBottomConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var recentNotesCollectionView: UICollectionView!
    
    private var displayItems: [HomeNoteItem] = []
    private var folders: [FolderModel] = [
        FolderModel(title: "Personal", category: .personal),
        FolderModel(title: "Work", category: .work),
        FolderModel(title: "School", category: .school),
        FolderModel(title: "Travel", category: .travel)
    ]

    
    private let recentNotes: [RecentNote] = [
        RecentNote(
            date: "September 14, 2023",
            category: "TRAVEL",
            title: "France travel itinerary",
            description: "Remember to check the opening hours and availability..."
        ),
        RecentNote(
            date: "September 11, 2023",
            category: "WORK",
            title: "Q2 Research preparation",
            description: "Define research objectives and gather financial data..."
        ),
        RecentNote(
            date: "September 14, 2023",
            category: "TRAVEL",
            title: "France travel itinerary",
            description: "Remember to check the opening hours and availability..."
        ),
        RecentNote(
            date: "September 11, 2023",
            category: "WORK",
            title: "Q2 Research preparation",
            description: "Define research objectives and gather financial data..."
        ),
        RecentNote(
            date: "September 14, 2023",
            category: "TRAVEL",
            title: "France travel itinerary",
            description: "Remember to check the opening hours and availability..."
        ),
        RecentNote(
            date: "September 11, 2023",
            category: "WORK",
            title: "Q2 Research preparation",
            description: "Define research objectives and gather financial data..."
        )
    ]
    
    @IBAction func addFolderTapped(_ sender: UIButton) {
        showAddFolderAlert()
    }
    private func showAddFolderAlert() {
        let alert = UIAlertController(title: "Add Folder", message: "Select a category", preferredStyle: .actionSheet)

        // 1. Show Standard Categories (excluding .other)
        FolderCategory.allCases.forEach { category in
            if category != .other {
                alert.addAction(UIAlertAction(title: category.rawValue, style: .default) { _ in
                    self.createNewFolder(title: category.rawValue, category: category)
                })
            }
        }

        // 2. The "Other" option that triggers the dropdown menu
        alert.addAction(UIAlertAction(title: "Other ", style: .default) { _ in
            self.showOthersSubMenu() // Call the submenu
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // 3. The "Dropdown" Menu for Others
    private func showOthersSubMenu() {
        let subMenu = UIAlertController(title: "Other Categories", message: "Add a category to add in a list of options.", preferredStyle: .actionSheet)

        // A. Show categories the user added previously
        let savedCategories = CustomCategoryManager.shared.fetchCategories()
        savedCategories.forEach { name in
            subMenu.addAction(UIAlertAction(title: name, style: .default) { _ in
         
                self.createNewFolder(title: name, category: .other)
            })
        }

        // B. Option to just add a name to the list (No folder created)
        subMenu.addAction(UIAlertAction(title: "Add new Category", style: .destructive) { _ in
            self.showNewCategoryTextField()
        })

        subMenu.addAction(UIAlertAction(title: "Back", style: .cancel))

        present(subMenu, animated: true)
    }
    // 4. The TextField Alert to type a new category
    private func showNewCategoryTextField() {
        let alert = UIAlertController(title: "New Category"  , message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
 
            textField.autocapitalizationType = .words
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Add to List", style: .default) { _ in
            if let name = alert.textFields?.first?.text, !name.isEmpty {
                // 1. SAVE to UserDefaults only
                CustomCategoryManager.shared.saveCategory(name)
                
                // 2. DO NOT create folder. Instead, show the submenu again
                // so the user can see the new item and click it if they want.
                self.showOthersSubMenu()
            }
        })
        
        present(alert, animated: true)
    }

    // Helper to update UI
    private func createNewFolder(title: String, category: FolderCategory) {
        let newFolder = FolderModel(title: title, category: category)
        self.folders.append(newFolder)
        self.collectionView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupCollectionView()
        setupMiniPlayer()
        
        collectionView.backgroundColor = .clear
        recentNotesCollectionView.backgroundColor = .clear
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        combineData()
    }
    override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
          // DISMISS when changing screen
          hideMiniPlayer()
      }

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
               
               // 1. Update Slider Value
               self.miniPlayer.progressSlider.value = Float(progress)
               
               // 2. Update Current Time Label (e.g., 0:15)
               let currentSeconds = Int(player.currentTime)
               self.miniPlayer.currentTimeLabel.text = String(format: "%d:%02d", currentSeconds / 60, currentSeconds % 60)
               
               // 3. Update Total Duration Label (e.g., 0:28)
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
            self.miniPlayerBottomConstraint?.constant = -83 // Adjust based on TabBar
            self.view.layoutIfNeeded()
        }
    }
    
    private func combineData() {
        let savedVoiceNotes = CoreDataManager.shared.fetchAllNotes()
        let voiceItems = savedVoiceNotes.map { HomeNoteItem.voice($0) }
        let plainItems = recentNotes.map { HomeNoteItem.plain($0) }
        displayItems = voiceItems + plainItems
        recentNotesCollectionView.reloadData()
    }
    func hideMiniPlayer() {
            // Stop the audio
            AudioManager.shared.stop()
            
            // Animate the view sliding down
            UIView.animate(withDuration: 0.3) {
                self.miniPlayerBottomConstraint?.constant = 50 // Move below screen
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

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == self.collectionView ? folders.count : displayItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FolderCollectionViewCell", for: indexPath) as! FolderCollectionViewCell
            
            let folder = folders[indexPath.item]
            cell.configure(with: folder)
            
            // HANDLE THE CLICK HERE
            cell.onDeleteRequest = { [weak self] in
                guard let self = self else { return }
                
                // 1. Setup the Alert Controller
                let alert = UIAlertController(
                    title: "Delete Folder",
                    message: "Do you want to delete this?",
                    preferredStyle: .alert
                )
                
                // 2. Add the "Cancel" Button
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                // 3. Add the "OK" Button
                let okAction = UIAlertAction(title: "OK", style: .destructive) { _ in
                    // Logic to delete from the array and update UI
                    self.folders.remove(at: indexPath.item)
                    self.collectionView.reloadData()
                }
                
                alert.addAction(cancelAction)
                alert.addAction(okAction)
                
                // 4. Present the alert (Works on all iPhones and iPads)
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
                if case .voice(let note) = item {
                    // Show an alert to confirm deletion
                    let alert = UIAlertController(title: "Delete", message: "Delete this recording?", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                        CoreDataManager.shared.deleteVoiceNote(note: note) // You need to add this method to CoreDataManager
                        self?.combineData() // Refresh the list
                    }))
                    self?.present(alert, animated: true)
                }
            }
            return cell
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.recentNotesCollectionView {
            let item = displayItems[indexPath.item]
            switch item {
            case .plain(let note):
                print("Tapped plain note: \(note.title)")
            case .voice(let voiceNote):
                // Stop mini player before moving to full screen
                AudioManager.shared.player?.stop()
                AudioManager.shared.timer?.invalidate()
                
                // Navigate to the PLAYBACK Controller (Separate Screen)
//                if let vc = storyboard?.instantiateViewController(withIdentifier: "VoiceNotePlaybackViewController") as? VoiceNotePlaybackViewController {
//                    vc.voiceNote = voiceNote
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }
            }
        } else {
            print("Tapped folder: \(folders[indexPath.item].title)")
        }
    }
}

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
