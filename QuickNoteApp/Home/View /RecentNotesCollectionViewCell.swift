import UIKit

class RecentNotesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    // 1. Create subviews programmatically
    private let waveformView = WaveformLineView()
    private let playButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system) // Added Delete Button
    
    // Callbacks for HomeViewController to handle actions
    var onPlayTapped: (() -> Void)?
    var onDeleteTapped: (() -> Void)? // Added Delete Callback

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 14
        setupPlayButton()
        setupDeleteButton() // Added Setup
        setupWaveform()
    }
    
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

    // New: Setup Delete Button
    private func setupDeleteButton() {
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        deleteButton.setImage(UIImage(systemName: "trash", withConfiguration: config), for: .normal)
        deleteButton.tintColor = UIColor(red: 238/255, green: 162/255, blue: 120/255, alpha: 1.0)
        
        contentView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
         
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            deleteButton.widthAnchor.constraint(equalToConstant: 30),
            deleteButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        deleteButton.addTarget(self, action: #selector(deleteButtonAction), for: .touchUpInside)
    }
    
    @objc private func playButtonAction() {
        onPlayTapped?()
    }

    @objc private func deleteButtonAction() {
        onDeleteTapped?()
    }
    
    private func setupWaveform() {
        waveformView.translatesAutoresizingMaskIntoConstraints = false
        waveformView.barColor = .white
        waveformView.backgroundColor = .clear
        contentView.addSubview(waveformView)
        
        NSLayoutConstraint.activate([
            waveformView.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 8),
           
            waveformView.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -20),
            waveformView.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            waveformView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func configure(with item: HomeNoteItem) {
        switch item {
        case .plain(let note):
            titleLabel.isHidden = false
            descriptionLabel.isHidden = false
            waveformView.isHidden = true
            playButton.isHidden = true
            deleteButton.isHidden = true // Hide for plain notes
            
            dateLabel.text = note.date
            categoryLabel.text = note.category
            titleLabel.text = note.title
            descriptionLabel.text = note.description
            
        case .voice(let voiceNote):
                titleLabel.isHidden = true // Hide the top title label
                descriptionLabel.isHidden = false // Show the description label
                
                waveformView.isHidden = false
                playButton.isHidden = false
                deleteButton.isHidden = false
                
                // DISPLAY LOGIC:
                // Category Label gets the text from the Recording Screen's Category Label
                categoryLabel.text = voiceNote.title?.uppercased() ?? "VOICE NOTE"
                
                // Description Label gets the text you typed in the TextField
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
