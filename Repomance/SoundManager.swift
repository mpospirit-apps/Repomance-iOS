//
//  SoundManager.swift
//  Repomance
//
//  Created for managing sound effects
//

import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    
    func playRizzSound() {
        guard let url = Bundle.main.url(forResource: "rizz", withExtension: "caf") else {
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            // Failed to play sound
        }
    }
}
