import UIKit

class MiniPlayerView: UIView {
    
    var onDismiss: (() -> Void)?
    
    // MARK: - UI Components
    let progressSlider: UISlider = {
        let slider = UISlider()
        
        // 1. Create a small solid white circle for the "dot"
        let thumbSize: CGFloat = 12
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: thumbSize, height: thumbSize))
        let thumbImage = renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            ctx.cgContext.addEllipse(in: CGRect(x: 0, y: 0, width: thumbSize, height: thumbSize))
            ctx.cgContext.fillPath()
        }
        
        slider.setThumbImage(thumbImage, for: .normal)
        slider.minimumTrackTintColor = .white
        slider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.2)
        return slider
    }()
    
    let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "0:00"
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    let totalTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "0:00"
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .right
        return label
    }()
    
    let playPauseButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        btn.tintColor = .white
        return btn
    }()
    
    let forwardButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "goforward.10"), for: .normal)
        btn.tintColor = .white
        return btn
    }()
    
    let backwardButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "gobackward.10"), for: .normal)
        btn.tintColor = .white
        return btn
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) { fatalError("init") }

    private func setupView() {
        // Match the dark background from your screenshot
        backgroundColor = UIColor(hex: "#2F2F34" , alpha: 0.8)
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        [progressSlider, currentTimeLabel, totalTimeLabel, playPauseButton, forwardButton, backwardButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            // Slider position (top)
            progressSlider.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            progressSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
            progressSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
            progressSlider.heightAnchor.constraint(equalToConstant: 20),
            
            // Current Time Label (under slider left)
            currentTimeLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: -2),
            currentTimeLabel.leadingAnchor.constraint(equalTo: progressSlider.leadingAnchor),
            
            // Total Time Label (under slider right)
            totalTimeLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: -2),
            totalTimeLabel.trailingAnchor.constraint(equalTo: progressSlider.trailingAnchor),
            
            // Buttons position (below labels)
            playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playPauseButton.topAnchor.constraint(equalTo: currentTimeLabel.bottomAnchor, constant: 10),
            
            backwardButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -50),
            backwardButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            
            forwardButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 50),
            forwardButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor)
        ])
        
        playPauseButton.addTarget(self, action: #selector(toggle), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(fwd), for: .touchUpInside)
        backwardButton.addTarget(self, action: #selector(bwd), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleViewTap))
        self.addGestureRecognizer(tap)
    }

    // MARK: - Logic
    @objc private func handleViewTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self)
        if !playPauseButton.frame.contains(location) && !forwardButton.frame.contains(location) &&
           !backwardButton.frame.contains(location) && !progressSlider.frame.contains(location) {
            onDismiss?()
        }
    }

    @objc func toggle() { AudioManager.shared.togglePlayPause() }
    @objc func fwd() { AudioManager.shared.seek(seconds: 10) }
    @objc func bwd() { AudioManager.shared.seek(seconds: -10) }
}
