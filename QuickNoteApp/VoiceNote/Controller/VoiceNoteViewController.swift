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
   
    private var accumulatedTime: TimeInterval = 0
    private var sessionStartTime: Date?
    private var isRecordingSessionActive = false
    private var recordedLevels: [Float] = []
    private var selectedCategory: String = "Personal"
    private func loadVoiceNoteData() {
  
            guard let note = currentVoiceNote else { return }
            
            // 1. Set Title (Remember: we saved the name into 'noteDescription')
            noteTitleTextField.text = note.noteDescription ?? "No Name"
            
            // 2. Set Category
            self.selectedCategory = note.title ?? "Personal"
            
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
                
                waveformView.reset() // Clear any existing lines
                
                // Convert [Float] to [CGFloat] and send to waveformView
                let cgLevels = levels.map { CGFloat($0) }
                waveformView.setLevels(cgLevels) // Use setLevels for static data
            }
            
            // 6. UI Adjustments for Editing Mode
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
           
           // 🔥 Correctly call the load function
           if currentVoiceNote != nil {
               loadVoiceNoteData()
           }
           
           let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
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
        // 3. Move to Folder Logic
        bottomSheet.onMoveToFolder = { [weak self] folderName in
            guard let self = self else { return }
            
            // Local variable update karein taaki Save logic ko pata chale
            self.selectedCategory = folderName
            
            // Agar note pehle se save hai, toh DB mein turant update karein
            if let existing = self.currentVoiceNote {
                existing.title = folderName // VoiceNote mein 'title' attribute category ke liye use ho raha hai
                CoreDataManager.shared.saveContext()
            }
            
            // 🔥 Visual Feedback (Moved Alert)
            let alert = UIAlertController(
                title: AlertMessages.Title.moved,
                message: AlertMessages.Message.movedToFolder(folderName), // Ab 'folderName' scope mein hai
                preferredStyle: .alert
            )
            self.present(alert, animated: true)
            
            // 1 second baad auto-dismiss
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                alert.dismiss(animated: true)
            }
        }
        
        // 4. Delete Logic with Centralized Messages
        bottomSheet.onDeleteRequest = { [weak self] in
            guard let self = self, let note = self.currentVoiceNote else { return }
            
            let alert = UIAlertController(
                title: AlertMessages.Title.deleteNote,
                message: AlertMessages.Message.deleteNoteConfirmation,
                preferredStyle: .alert
            )
            
            let deleteAction = UIAlertAction(title: AlertMessages.Action.delete, style: .destructive) { _ in
                CoreDataManager.shared.deleteVoiceNote(note: note)
                self.navigateBack() // Delete ke baad home par jayein
            }
            
            let cancelAction = UIAlertAction(title: AlertMessages.Action.cancel, style: .cancel)
            
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
        }
        
        // 5. Save Logic
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
           let descriptionText = noteTitleTextField.text?.isEmpty == false ? noteTitleTextField.text! : "No description"
           let categoryToSave = self.selectedCategory // 🔥 Use the variable

           if isRecordingSessionActive {
               audioRecorder?.stop()
               stopTimers()
               
               let compressedLevels = stride(from: 0, to: recordedLevels.count, by: 5).map { recordedLevels[$0] }
               
               // Capture the new note so further saves update this one
               let newNote = CoreDataManager.shared.saveVoiceNote(
                   fileName: currentFileName,
                   duration: timerLabel.text ?? "00:00:00",
                   levels: compressedLevels,
                   category: categoryToSave,
                   description: descriptionText
               )
               self.currentVoiceNote = newNote
               isRecordingSessionActive = false
           } else if let existing = currentVoiceNote {
               // Updating metadata if already saved
               existing.noteDescription = descriptionText
               existing.title = categoryToSave
               CoreDataManager.shared.saveContext()
           }
           
           NotificationCenter.default.post(name: .refreshHomeNotes, object: nil)
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
