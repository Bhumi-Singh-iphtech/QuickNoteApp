//
//  FolderCollectionViewCell.swift
//  NotesApp UI.
//
//  Created by iPHTech 22 on 02/01/26.
//
import UIKit

class FolderCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

   
    var onDeleteRequest: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.textAlignment = .center
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.clipsToBounds = true

        // 1. Enable interaction so it can be clicked
        iconImageView.isUserInteractionEnabled = true
        
        // 2. Add Tap Gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleIconTap))
        iconImageView.addGestureRecognizer(tap)

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func handleIconTap() {
        // 3. Trigger the delete request
        onDeleteRequest?()
    }

    func configure(with model: FolderModel) {
        titleLabel.text = model.title
        
        // Create a Bold configuration
        let boldConfig = UIImage.SymbolConfiguration(weight: .bold)
        
        if let customIconName = model.customSymbolName {
            // Apply the bold configuration to the SF Symbol
            iconImageView.image = UIImage(systemName: customIconName, withConfiguration: boldConfig)
        } else {
            
            iconImageView.image = UIImage(named: model.category.iconAssetName)
        }
        
       
        iconImageView.tintColor = .white
    }
}
