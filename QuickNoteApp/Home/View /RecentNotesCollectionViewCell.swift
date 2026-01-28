import UIKit

class RecentNotesCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!

    private let waveformView = WaveformLineView()
    private let playButton = UIButton(type: .system)

    
    var onPlayTapped: (() -> Void)?
    var onDeleteTapped: (() -> Void)?
    var onArrowTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 14
        
        setupPlayButton()
        setupWaveform()
        setupLongPressGesture()
        setupArrowGesture()
    }
    private func setupArrowGesture() {

        arrowImageView.isUserInteractionEnabled = true
        
       
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleArrowTap))
        arrowImageView.addGestureRecognizer(tap)
    }
    
    @objc private func handleArrowTap() {
        onArrowTapped?()
    }
    private func setupWaveform() {
        waveformView.translatesAutoresizingMaskIntoConstraints = false
        waveformView.barColor = .white
        waveformView.backgroundColor = .clear
        contentView.addSubview(waveformView)
        
   
        var constraints = [
            waveformView.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 8),
            waveformView.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            waveformView.heightAnchor.constraint(equalToConstant: 100)
        ]
        
        
        if let arrow = arrowImageView {
            constraints.append(waveformView.trailingAnchor.constraint(equalTo: arrow.leadingAnchor, constant: -20))
        } else {
            constraints.append(waveformView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12))
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    // MARK: - Long Press Logic
    private func setupLongPressGesture() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.5
        self.addGestureRecognizer(longPress)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
       
        if gesture.state == .began {
            
            onDeleteTapped?()
        }
    }
    
    // MARK: - Setup Views
    private func setupPlayButton() {
        playButton.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        playButton.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: config), for: .normal)
        playButton.tintColor = UIColor(red: 238/255, green: 162/255, blue: 120/255, alpha: 1.0)
        
        contentView.addSubview(playButton)
        
        NSLayoutConstraint.activate([
            playButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            playButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -45),
            playButton.widthAnchor.constraint(equalToConstant: 32),
            playButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        playButton.addTarget(self, action: #selector(playButtonAction), for: .touchUpInside)
    }
    
    // setupDeleteButton()
    
    @objc private func playButtonAction() {
        onPlayTapped?()
    }
    
    //    private func setupWaveform() {
    //        waveformView.translatesAutoresizingMaskIntoConstraints = false
    //        waveformView.barColor = .white
    //        waveformView.backgroundColor = .clear
    //        contentView.addSubview(waveformView)
    //
    //        NSLayoutConstraint.activate([
    //            waveformView.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 8),
    //            waveformView.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -20),
    //            waveformView.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
    //            waveformView.heightAnchor.constraint(equalToConstant: 100)
    //        ])
    //    }
    
    func configure(with item: HomeNoteItem) {
        switch item {
        case .plain(let note):
            titleLabel.isHidden = false
            descriptionLabel.isHidden = false
            
            titleLabel.text = note.title
            descriptionLabel.text = note.content
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, yyyy"
            dateLabel.text = formatter.string(from: note.date ?? Date())
            
            // FIX: Handle nil or empty category safely
            // If note.category is nil, default to "General" or "Uncategorized"
            let categoryName = note.category ?? "General"
            categoryLabel.text = categoryName.isEmpty ? "GENERAL" : categoryName.uppercased()
            
            waveformView.isHidden = true
            playButton.isHidden = true
            print("Title: \(note.title ?? "") | Category stored in DB: '\(note.category ?? "NIL")'")        case .voice(let voiceNote):
            titleLabel.isHidden = true
            descriptionLabel.isHidden = false
            
            waveformView.isHidden = false
            playButton.isHidden = false
            
            // 🔥 FIX: Same for Voice Notes
            let categoryName = voiceNote.title ?? "Voice Note"
            categoryLabel.text = categoryName.isEmpty ? "VOICE NOTE" : categoryName.uppercased()
            
            descriptionLabel.text = voiceNote.noteDescription ?? "No description provided"
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, yyyy"
            dateLabel.text = formatter.string(from: voiceNote.createdAt ?? Date())
            
            // Waveform
            waveformView.reset()
            if let data = voiceNote.waveformData,
               let levels = try? JSONDecoder().decode([Float].self, from: data) {
                waveformView.setLevels(levels.map { CGFloat($0) })
            }
        }
    }
}
