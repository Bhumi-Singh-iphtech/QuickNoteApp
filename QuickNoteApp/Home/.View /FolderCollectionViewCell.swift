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

    override func awakeFromNib() {
        super.awakeFromNib()

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.clipsToBounds = true

   
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    func configure(with model: FolderModel) {
        titleLabel.text = model.title
        iconImageView.image = UIImage(named: model.category.iconAssetName)
    }
}
