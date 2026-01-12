//
//  RecentNotesCollectionViewCell.swift
//  NotesApp UI.
//
//  Created by iPHTech 22 on 05/01/26.
//

import UIKit

class RecentNotesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
      @IBOutlet weak var titleLabel: UILabel!
      @IBOutlet weak var descriptionLabel: UILabel!
      @IBOutlet weak var arrowImageView: UIImageView!

      override func awakeFromNib() {
          super.awakeFromNib()

      
          contentView.layer.cornerRadius = 14
      }
    
}
