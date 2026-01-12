//
//  AddNoteOptionCell.swift
//  QuickNoteApp
//
//  Created by iPHTech 22 on 07/01/26.
//
import UIKit

class AddNoteOptionCell: UICollectionViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
      
        layer.cornerRadius = 12
        layer.masksToBounds = true

        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

     
       
    }
}
