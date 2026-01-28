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
    var onTapRequest: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.textAlignment = .center
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.clipsToBounds = true

        
        iconImageView.isUserInteractionEnabled = true
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
                longPress.minimumPressDuration = 0.5 // seconds
                iconImageView.addGestureRecognizer(longPress)
                
                // 2. Setup Single Tap (for Navigation)
                let tap = UITapGestureRecognizer(target: self, action: #selector(handleIconTap))
                iconImageView.addGestureRecognizer(tap)

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func handleIconTap() {
       
        onTapRequest?()
    }
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            // Only trigger when the press starts to avoid multiple alerts
            if gesture.state == .began {
                onDeleteRequest?()
            }
        }
    func configure(with model: FolderModel) {
        titleLabel.text = model.title
        let symbolName = IconMapper.getSymbolName(for: model.title)
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
