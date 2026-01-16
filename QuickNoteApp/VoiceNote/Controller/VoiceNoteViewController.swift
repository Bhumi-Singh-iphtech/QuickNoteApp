import UIKit
import AVFoundation

class VoiceNoteViewController: UIViewController, UITextFieldDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var waveformView: WaveformLineView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var noteTitleTextField: UITextField!

    @IBOutlet weak var categoryTextField: UITextField!
    // MARK: - Recording Properties
    private var audioRecorder: AVAudioRecorder?
    private var currentFileName: String = ""
    private var recordingTimer: Timer?
    private var waveformTimer: Timer?
    
    private var accumulatedTime: TimeInterval = 0
    private var sessionStartTime: Date?
    private var isRecordingSessionActive = false
    private var recordedLevels: [Float] = []
    
    private let customNavBar = CustomNavigationBar()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomNavBar()
        setupUI()
        setupDate()
        setupRecordButtonGestures()
        requestMicrophonePermission()
        noteTitleTextField.delegate = self
          categoryTextField.delegate = self // Your new category field
          
          // 2. Add Tap Gesture to dismiss keyboard when tapping the background
          let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
          // Important: This allows buttons (like record) to still work while keyboard is up
          tapGesture.cancelsTouchesInView = false
          view.addGestureRecognizer(tapGesture)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
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
        (tabBarController as? CustomTabBarController)?.setCustomTabBar(hidden: false)
        
        // Save automatically if the user leaves while recording
        if isRecordingSessionActive {
            finalizeAndSaveRecording()
        }
    }

    private func setupUI() {
        timerLabel.text = "00:00:00"
        timerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 28, weight: .bold)
        timerLabel.textAlignment = .center
        categoryTextField.backgroundColor = .clear
        categoryTextField.borderStyle = .none
        categoryTextField.textColor = .white // Text color when typing
        categoryTextField.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        noteTitleTextField.backgroundColor = .clear
  noteTitleTextField.textColor = .white

   
          let placeholderColor = UIColor.lightGray
        categoryTextField.attributedPlaceholder = NSAttributedString(
              string: "Enter Category ",
              attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
              )
        noteTitleTextField.attributedPlaceholder = NSAttributedString(
            string: "Voice note name",
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
     
    }

    private func setupCustomNavBar() {
        customNavBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customNavBar)
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 110)
        ])
        customNavBar.setTitle("My Notes")
        customNavBar.onBackTap = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }

    private func setupDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        dateLabel.text = formatter.string(from: Date())
    }

    // MARK: - RECORDING LOGIC
    private func setupRecordButtonGestures() {
        recordButton.addTarget(self, action: #selector(handleTouchDown), for: .touchDown)
        recordButton.addTarget(self, action: #selector(handleTouchUp), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(handleTouchUp), for: .touchUpOutside)
    }

    @objc private func handleTouchDown() {
        if !isRecordingSessionActive {
            recordedLevels.removeAll()
            startNewRecordingSession()
            isRecordingSessionActive = true
        } else {
            audioRecorder?.record()
            sessionStartTime = Date()
            startTimers()
        }
        UIView.animate(withDuration: 0.1) {
            self.recordButton.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        }
    }

    @objc private func handleTouchUp() {
        audioRecorder?.pause()
        if let start = sessionStartTime { accumulatedTime += Date().timeIntervalSince(start) }
        stopTimers()
        UIView.animate(withDuration: 0.1) {
            self.recordButton.transform = .identity
        }
    }

    private func startNewRecordingSession() {
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try? audioSession.setActive(true)
        
        currentFileName = UUID().uuidString + ".m4a"
        let url = getDocumentsDirectory().appendingPathComponent(currentFileName)
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            waveformView.reset()
            accumulatedTime = 0
            sessionStartTime = Date()
            startTimers()
        } catch { print("Recording failed") }
    }

    private func finalizeAndSaveRecording() {
        guard isRecordingSessionActive else { return }
        audioRecorder?.stop()
        stopTimers()
        
        // 1. Get the category text from your NEW label
        let categoryText = categoryTextField.text ?? "VOICE NOTE"
        
        // 2. Get the description from your TextField
        let descriptionText = noteTitleTextField.text?.isEmpty == false ? noteTitleTextField.text! : "No description"
        
        let compressedLevels = stride(from: 0, to: recordedLevels.count, by: 5).map { recordedLevels[$0] }
        
        // 3. Save both to Core Data (Make sure CoreDataManager accepts two strings)
        CoreDataManager.shared.saveVoiceNote(
            fileName: currentFileName,
            duration: timerLabel.text ?? "00:00:00",
            levels: compressedLevels,
            category: categoryText, 
            description: descriptionText
        )
        
        isRecordingSessionActive = false
    }
    private func startTimers() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.sessionStartTime else { return }
            self.updateTimerLabel(with: self.accumulatedTime + Date().timeIntervalSince(start))
        }
        waveformTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in self?.updateWaveform() }
    }

    private func stopTimers() {
        recordingTimer?.invalidate()
        waveformTimer?.invalidate()
    }

    private func updateWaveform() {
        guard let recorder = audioRecorder, recorder.isRecording else { return }
        recorder.updateMeters()
        let power = recorder.averagePower(forChannel: 0)
        let normalized = max(0.1, min(1.0, (power + 60) / 60))
        recordedLevels.append(normalized)
        DispatchQueue.main.async {
            self.waveformView.addLevel(CGFloat(normalized))
        }
    }

    private func updateTimerLabel(with total: TimeInterval) {
        let mins = (Int(total) % 3600) / 60
        let secs = Int(total) % 60
        self.timerLabel.text = String(format: "00:%02d:%02d", mins, secs)
    }

    private func getDocumentsDirectory() -> URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] }
    private func requestMicrophonePermission() { AVAudioSession.sharedInstance().requestRecordPermission { _ in } }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { textField.resignFirstResponder(); return true }
}
