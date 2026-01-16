//
//  AudioManager.swift
//  QuickNoteApp
//
//  Created by iPHTech 22 on 15/01/26.
//

import Foundation
import AVFoundation

class AudioManager: NSObject, AVAudioPlayerDelegate {
    static let shared = AudioManager()
    
    var player: AVAudioPlayer?
    var timer: Timer?
    var currentNote: VoiceNoteEntity?
    
    // Callbacks to update the UI
    var onProgressUpdate: ((Double) -> Void)?
    var onPlaybackStatusChange: ((Bool) -> Void)?

    func play(_ note: VoiceNoteEntity) {
        currentNote = note
        guard let fileName = note.audioFileName else { return }
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.play()
            startTimer()
            onPlaybackStatusChange?(true)
        } catch {
            print("Playback failed")
        }
    }

    func togglePlayPause() {
        guard let player = player else { return }
        
        if player.isPlaying {
            player.pause()
           
            timer?.invalidate()
            onPlaybackStatusChange?(false)
        } else {
            player.play()
           
            startTimer()
            onPlaybackStatusChange?(true)
        }
    }


    func seek(seconds: TimeInterval) {
        guard let player = player else { return }
        player.currentTime += seconds
    }
    func stop() {
        player?.stop()
        player = nil
        timer?.invalidate()
        timer = nil
        onPlaybackStatusChange?(false)
        onProgressUpdate?(0)
    }
    func startTimer() {
        timer?.invalidate() // Always clean up old timers first
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.player else { return }
            
            // Calculate progress (e.g., 0.5 for 50%)
            let progress = player.currentTime / player.duration
            
            // Ensure UI updates happen on the main thread
            DispatchQueue.main.async {
                print("Updating progress: \(progress)") // Debug: Check your console
                self.onProgressUpdate?(progress)
            }
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        timer?.invalidate()
        onPlaybackStatusChange?(false)
        onProgressUpdate?(0)
    }
}
