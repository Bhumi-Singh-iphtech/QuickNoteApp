


import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var recentNotesCollectionView: UICollectionView!
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

        let alert = UIAlertController(
            title: "Add Folder",
            message: "Select a category",
            preferredStyle: .actionSheet
        )

        FolderCategory.allCases.forEach { category in
            let action = UIAlertAction(title: category.rawValue, style: .default) { _ in
                let newFolder = FolderModel(
                    title: category.rawValue,
                    category: category
                )
                self.folders.append(newFolder)
                self.collectionView.reloadData()
            }
            alert.addAction(action)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)

        // 🎨 Change Cancel button color
        alert.view.tintColor = UIColor(hex: "#7B5CFF") // your custom color

        present(alert, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
         setupCollectionView()

        collectionView.backgroundColor = .clear
        recentNotesCollectionView.backgroundColor = .clear
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self

        recentNotesCollectionView.dataSource = self
        recentNotesCollectionView.delegate = self
    }
}




extension HomeViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        return collectionView == self.collectionView
        ? folders.count
        : recentNotes.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == self.collectionView {

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "FolderCollectionViewCell",
                for: indexPath
            ) as! FolderCollectionViewCell

            let folder = folders[indexPath.item]
            cell.configure(with: folders[indexPath.item])
            return cell

        } else {

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "RecentNotesCollectionViewCell",
                for: indexPath
            ) as! RecentNotesCollectionViewCell

            let note = recentNotes[indexPath.item]
            cell.dateLabel.text = note.date
            cell.categoryLabel.text = note.category
            cell.titleLabel.text = note.title
            cell.descriptionLabel.text = note.description

            return cell
        }
    }
}


extension HomeViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        if collectionView == self.collectionView {
            let selectedFolder = folders[indexPath.item]
            print("Tapped folder:", selectedFolder.title)
        } else {
            let selectedNote = recentNotes[indexPath.item]
            print("Tapped note:", selectedNote.title)
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        if collectionView == self.collectionView {

            let itemsPerRow: CGFloat = 4
//            let spacing: CGFloat = 0
//            let totalSpacing = spacing * (itemsPerRow - 1)
            let availableWidth = collectionView.bounds.width
            let itemWidth = availableWidth / itemsPerRow

            return CGSize(width: itemWidth, height: 149)

        } else {
            return CGSize(width: collectionView.bounds.width, height: 120)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == self.collectionView {
            return 0
        }else{
                return 12
                }
    }
}
