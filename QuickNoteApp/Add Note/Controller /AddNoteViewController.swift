//
//  AddNoteViewController.swift
//  QuickNoteApp
//
//  Created by iPHTech 22 on 07/01/26.
//

import UIKit

class AddNoteViewController: UIViewController {
    

    @IBOutlet weak var collectionView: UICollectionView!

    private let options: [AddNoteModel] = [
        AddNoteModel(title: "Plain note", iconName: "plain_notes"),
        AddNoteModel(title: "To-do list", iconName: "to do list"),
        AddNoteModel(title: "Voice note", iconName: "voice_note 1"),
        AddNoteModel(title: "Scan note.", iconName: "scan_note.")
    ]
    @IBAction func backArrowTapped(_ sender: UIButton) {
        // Switch to Home tab (index 0)
        tabBarController?.selectedIndex = 0
      
        // Pop this view controller
        navigationController?.popViewController(animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)

        if let tabBarController = self.tabBarController as? CustomTabBarController {
            tabBarController.setCustomTabBar(hidden: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let tabBarController = self.tabBarController as? CustomTabBarController {
            tabBarController.setCustomTabBar(hidden: false)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    navigationController?.view.backgroundColor = UIColor(hex: "#232329")
//        if let tabBarController = self.tabBarController as? CustomTabBarController {
//            tabBarController.setCustomTabBar(hidden: true)
//        }
//        navigationController?.setNavigationBarHidden(true, animated: false)
        setupCollectionView()
    }
    private func openPlainNote() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "PlainNoteViewController"
        ) as! PlainNoteViewController



        navigationController?.pushViewController(vc, animated: true)
    }

   



    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
    }
}
extension AddNoteViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return options.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "AddNoteOptionCell",
            for: indexPath
        ) as! AddNoteOptionCell

        let model = options[indexPath.item]
        cell.titleLabel.text = model.title
        cell.iconImageView.image = UIImage(named: model.iconName)

        return cell
    }
}
extension AddNoteViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(
            width: collectionView.frame.width,
            height: 110
            
        )
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}

extension AddNoteViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let selectedOption = options[indexPath.item]

        switch selectedOption.title {
        case "Plain note":
            openPlainNote()
        default:
            break
        }
    }
}
