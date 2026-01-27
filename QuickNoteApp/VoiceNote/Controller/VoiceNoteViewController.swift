import UIKit
import AVFoundation

class VoiceNoteViewController: UIViewController, UITextFieldDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var waveformView: WaveformLineView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var noteTitleTextField: UITextField!


    // MARK: - Recording Properties
    private var audioRecorder: AVAudioRecorder?
    private var currentFileName: String = ""
    private var recordingTimer: Timer?
    private var waveformTimer: Timer?
    private var selectedCategory: String? = nil
    private var accumulatedTime: TimeInterval = 0
    private var sessionStartTime: Date?
    private var isRecordingSessionActive = false
    private var recordedLevels: [Float] = []
    private func loadVoiceNoteData() {
           guard let note = currentVoiceNote else { return }
           
           // 1. Set Title
           noteTitleTextField.text = note.title // assuming you used 'title' for name, or 'noteDescription'
           // If your entity uses 'audioFileName' as the unique ID, keep track of it:
           currentFileName = note.audioFileName ?? ""
           
           // 2. Set Category (for the Share Menu logic)
           selectedCategory = note.title // Or note.category depending on your Entity
           
           // 3. Set Date
           if let date = note.createdAt {
               let formatter = DateFormatter()
               formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
               dateLabel.text = formatter.string(from: date)
           }
           
           // 4. Set Duration
           timerLabel.text = note.durationText ?? "00:00:00"
           
           // 5. Draw Waveform
           if let data = note.waveformData,
              let levels = try? JSONDecoder().decode([Float].self, from: data) {
               
               waveformView.reset()
               // Assuming your WaveformView has a method to set all levels at once
               // If not, you might need to loop: levels.forEach { waveformView.addLevel(CGFloat($0)) }
               // But usually for static display:
               for level in levels {
                   waveformView.addLevel(CGFloat(level))
               }
           }
           
           // 6. Disable Record Button (Since we are viewing/editing, not recording new audio)
           // You might want to change this button to a "Play" button in the future
           recordButton.isEnabled = false
           recordButton.alpha = 0.5
       }
    private let customNavBar = CustomNavigationBar()
    var currentVoiceNote: VoiceNoteEntity?
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomNavBar()
        setupUI()
        setupDate()
        setupRecordButtonGestures()
        requestMicrophonePermission()
        noteTitleTextField.delegate = self
     
          
          // Tap Gesture to dismiss keyboard when tapping the background
          let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
          // This allows buttons (like record) to still work while keyboard is up
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
    // MARK: - Navigation Helper
    private func navigateBack() {
        // 1. Send signal to switch tab to Home
        NotificationCenter.default.post(name: .navigateToHome, object: nil)
        
        // 2. Force close the screen
        if let navigationController = self.navigationController {
            // If pushed, pop immediately
            navigationController.popToRootViewController(animated: false)
        } else {
            // If presented modally, dismiss
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        let bottomSheet = ShareMenuView(frame: self.view.bounds)
  
        // 1. Folders Setup (Same as before)
        let defaultFolders = ["Personal", "Work", "School", "Travel"]
        let savedFolderObjects = CoreDataManager.shared.fetchAllFolders()
        let savedFolderNames = savedFolderObjects.compactMap { $0.title }
        let uniqueSavedFolders = savedFolderNames.filter { !defaultFolders.contains($0) }
        bottomSheet.existingFolders = defaultFolders + uniqueSavedFolders
        
        // Tell Menu if Existing
        bottomSheet.isExistingNote = (self.currentVoiceNote != nil)
        
        // Callbacks
        bottomSheet.onCreateNewFolder = { newName in
            CoreDataManager.shared.createFolder(name: newName)
        }
        
        bottomSheet.onMoveToFolder = { [weak self] folderName in
            self?.selectedCategory = folderName
            
            // If existing, update immediately
            if let existing = self?.currentVoiceNote {
                existing.title = folderName // Assuming 'title' is used for Category in your Voice Entity
                CoreDataManager.shared.saveContext()
            }
        }
        
        //  DELETE LOGIC
        bottomSheet.onDeleteRequest = { [weak self] in
            guard let self = self, let note = self.currentVoiceNote else { return }
            
            let alert = UIAlertController(
                title: AlertMessages.Title.deleteNote,
                message: AlertMessages.Message.deleteNoteConfirmation,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                CoreDataManager.shared.deleteVoiceNote(note: note)
                self.navigateBack()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.present(alert, animated: true)
        }
        
        // Save Logic
        bottomSheet.onSaveRequest = { [weak self] in
            self?.showSaveConfirmationAlert()
        }
        
        bottomSheet.show(in: view)
    }
    private func showSaveConfirmationAlert() {
        print("Presenting Alert...") // Debug print
        
        let alert = UIAlertController(
            title: AlertMessages.Title.saveNote,
            message: AlertMessages.Message.saveNoteConfirmation,
            preferredStyle: .alert
        )
        
        // Save Action
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            self.saveNoteAndExit()
        }
        
        // Cancel Action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    private func saveNoteAndExit() {
        // 1. Process the recording and save to Core Data
        finalizeAndSaveRecording()
        
       

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
        
        noteTitleTextField.backgroundColor = .clear
  noteTitleTextField.textColor = .white

   
          let placeholderColor = UIColor.lightGray
    
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
        
        // 1. Get Description
        let descriptionText = noteTitleTextField.text?.isEmpty == false ? noteTitleTextField.text! : "No description"
        
        // 2. Prepare Waveform Data
        let compressedLevels = stride(from: 0, to: recordedLevels.count, by: 5).map { recordedLevels[$0] }
        
        // DETERMINE CATEGORY
        // Use the selected one, or default to "Personal"
        let categoryToSave = self.selectedCategory ?? "Personal"
        
        // 4. Save to Core Data
        CoreDataManager.shared.saveVoiceNote(
            fileName: currentFileName,
            duration: timerLabel.text ?? "00:00:00",
            levels: compressedLevels,
            category: categoryToSave, //  Uses the variable now
            description: descriptionText
        )
        
        print("Saved Voice Note to Category: \(categoryToSave)")
        
        // 5. Notify Home Screen
        NotificationCenter.default.post(name: NSNotification.Name("RefreshHomeNotes"), object: nil)
        
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
