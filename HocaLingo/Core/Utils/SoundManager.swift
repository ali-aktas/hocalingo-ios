//
//  SoundManager.swift
//  HocaLingo
//
//  ✅ UPDATED: Added swipe sounds (swipe_right, swipe_left)
//  Location: HocaLingo/Core/Utils/SoundManager.swift
//

import AVFoundation
import AudioToolbox
import Combine

// MARK: - Sound Manager
/// Singleton manager for sound effects with 4 sound files
/// Sounds: card_flip, click_sound, swipe_right, swipe_left
class SoundManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = SoundManager()
    
    // MARK: - Published Properties
    @Published var isEnabled: Bool = true
    
    // MARK: - Private Properties
    private var clickPlayer: AVAudioPlayer?
    private var cardFlipPlayer: AVAudioPlayer?
    private var swipeRightPlayer: AVAudioPlayer?
    private var swipeLeftPlayer: AVAudioPlayer?
    private var isInitialized: Bool = false
    private var useSystemBeeps: Bool = false
    
    // MARK: - Initialization
    private init() {
        setupAudioSession()
        preloadSounds()
    }
    
    // MARK: - Setup Methods
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            print("✅ Audio session configured")
        } catch {
            print("❌ Audio session setup error: \(error.localizedDescription)")
        }
    }
    
    private func preloadSounds() {
        var loadedCount = 0
        
        // 1. Load click sound
        if let clickURL = Bundle.main.url(forResource: "click_sound", withExtension: "wav") {
            do {
                clickPlayer = try AVAudioPlayer(contentsOf: clickURL)
                clickPlayer?.prepareToPlay()
                clickPlayer?.volume = 0.4
                loadedCount += 1
                print("✅ Click sound loaded")
            } catch {
                print("❌ Failed to load click sound: \(error.localizedDescription)")
            }
        } else {
            print("⚠️ click_sound.mp3 not found in bundle")
        }
        
        // 2. Load card flip sound
        if let flipURL = Bundle.main.url(forResource: "card_flip", withExtension: "wav") {
            do {
                cardFlipPlayer = try AVAudioPlayer(contentsOf: flipURL)
                cardFlipPlayer?.prepareToPlay()
                cardFlipPlayer?.volume = 0.7
                loadedCount += 1
                print("✅ Card flip sound loaded")
            } catch {
                print("❌ Failed to load card flip sound: \(error.localizedDescription)")
            }
        } else {
            print("⚠️ card_flip.mp3 not found in bundle")
        }
        
        // 3. Load swipe right sound
        if let swipeRightURL = Bundle.main.url(forResource: "playSwipeRight", withExtension: "wav") {
            do {
                swipeRightPlayer = try AVAudioPlayer(contentsOf: swipeRightURL)
                swipeRightPlayer?.prepareToPlay()
                swipeRightPlayer?.volume = 0.4
                loadedCount += 1
                print("✅ Swipe right sound loaded")
            } catch {
                print("❌ Failed to load swipe right sound: \(error.localizedDescription)")
            }
        } else {
            print("⚠️ swipe_right.mp3 not found in bundle")
        }
        
        // 4. Load swipe left sound
        if let swipeLeftURL = Bundle.main.url(forResource: "playSwipeLeft", withExtension: "wav") {
            do {
                swipeLeftPlayer = try AVAudioPlayer(contentsOf: swipeLeftURL)
                swipeLeftPlayer?.prepareToPlay()
                swipeLeftPlayer?.volume = 0.4
                loadedCount += 1
                print("✅ Swipe left sound loaded")
            } catch {
                print("❌ Failed to load swipe left sound: \(error.localizedDescription)")
            }
        } else {
            print("⚠️ swipe_left.mp3 not found in bundle")
        }
        
        isInitialized = loadedCount == 4
        useSystemBeeps = !isInitialized
        
        if isInitialized {
            print("✅ SoundManager initialized successfully (4/4 sounds)")
        } else {
            print("⚠️ SoundManager using system beeps as fallback (\(loadedCount)/4 sounds)")
        }
    }
    
    // MARK: - Public Methods
    
    /// Play button click sound (or system beep)
    func playClickSound() {
        guard isEnabled else { return }
        
        if useSystemBeeps || clickPlayer == nil {
            AudioServicesPlaySystemSound(1104)  // Tap sound
            print("🔊 Click beep played (fallback)")
        } else {
            clickPlayer?.currentTime = 0
            clickPlayer?.play()
            print("🔊 Click sound played")
        }
    }
    
    /// Play card flip sound (or system beep)
    func playCardFlip() {
        guard isEnabled else { return }
        
        if useSystemBeeps || cardFlipPlayer == nil {
            AudioServicesPlaySystemSound(1105)  // Peek sound
            print("🔊 Flip beep played (fallback)")
        } else {
            cardFlipPlayer?.currentTime = 0
            cardFlipPlayer?.play()
            print("🔊 Card flip sound played")
        }
    }
    
    /// Play swipe right sound (word selected)
    func playSwipeRight() {
        guard isEnabled else { return }
        
        if useSystemBeeps || swipeRightPlayer == nil {
            AudioServicesPlaySystemSound(1102)  // Success sound
            print("🔊 Swipe right beep played (fallback)")
        } else {
            swipeRightPlayer?.currentTime = 0
            swipeRightPlayer?.play()
            print("🔊 Swipe right sound played (word selected)")
        }
    }
    
    /// Play swipe left sound (word skipped)
    func playSwipeLeft() {
        guard isEnabled else { return }
        
        if useSystemBeeps || swipeLeftPlayer == nil {
            AudioServicesPlaySystemSound(1053)  // Dismiss sound
            print("🔊 Swipe left beep played (fallback)")
        } else {
            swipeLeftPlayer?.currentTime = 0
            swipeLeftPlayer?.play()
            print("🔊 Swipe left sound played (word skipped)")
        }
    }
    
    /// Toggle sound effects on/off
    func toggleEnabled() {
        isEnabled.toggle()
        print("Sound effects \(isEnabled ? "enabled" : "disabled")")
    }
    
    /// Set volume for all sounds
    func setVolume(_ volume: Float) {
        let clampedVolume = min(max(volume, 0.0), 1.0)
        clickPlayer?.volume = clampedVolume * 0.5
        cardFlipPlayer?.volume = clampedVolume * 0.7
        swipeRightPlayer?.volume = clampedVolume * 0.6
        swipeLeftPlayer?.volume = clampedVolume * 0.6
        print("Sound volume set to \(clampedVolume)")
    }
    
    /// Stop all currently playing sounds
    func stopAll() {
        clickPlayer?.stop()
        cardFlipPlayer?.stop()
        swipeRightPlayer?.stop()
        swipeLeftPlayer?.stop()
    }
    
    /// Cleanup resources
    func cleanup() {
        stopAll()
        clickPlayer = nil
        cardFlipPlayer = nil
        swipeRightPlayer = nil
        swipeLeftPlayer = nil
        isInitialized = false
        print("✅ SoundManager cleanup completed")
    }
}
