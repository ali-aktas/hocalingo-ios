//
//  SoundManager.swift
//  HocaLingo
//
//  ✅ UPDATED: Fallback system beeps if audio files missing
//  Location: Core/Utils/SoundManager.swift
//

import AVFoundation
import AudioToolbox
import Combine

// MARK: - Sound Manager
/// Singleton manager for sound effects with fallback system beeps
class SoundManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = SoundManager()
    
    // MARK: - Published Properties
    @Published var isEnabled: Bool = true  // ✅ FIX: Default true
    
    // MARK: - Private Properties
    private var clickPlayer: AVAudioPlayer?
    private var cardFlipPlayer: AVAudioPlayer?
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
        var hasClickSound = false
        var hasFlipSound = false
        
        // Try to load click sound
        if let clickURL = Bundle.main.url(forResource: "click_sound", withExtension: "mp3") {
            do {
                clickPlayer = try AVAudioPlayer(contentsOf: clickURL)
                clickPlayer?.prepareToPlay()
                clickPlayer?.volume = 0.5
                hasClickSound = true
                print("✅ Click sound loaded")
            } catch {
                print("❌ Failed to load click sound: \(error.localizedDescription)")
            }
        } else {
            print("⚠️ click_sound.mp3 not found in bundle")
        }
        
        // Try to load card flip sound
        if let flipURL = Bundle.main.url(forResource: "card_flip", withExtension: "mp3") {
            do {
                cardFlipPlayer = try AVAudioPlayer(contentsOf: flipURL)
                cardFlipPlayer?.prepareToPlay()
                cardFlipPlayer?.volume = 0.7
                hasFlipSound = true
                print("✅ Card flip sound loaded")
            } catch {
                print("❌ Failed to load card flip sound: \(error.localizedDescription)")
            }
        } else {
            print("⚠️ card_flip.mp3 not found in bundle")
        }
        
        isInitialized = hasClickSound && hasFlipSound
        useSystemBeeps = !isInitialized
        
        if isInitialized {
            print("✅ SoundManager initialized successfully")
        } else {
            print("⚠️ SoundManager using system beeps as fallback")
        }
    }
    
    // MARK: - Public Methods
    
    /// Play button click sound (or system beep)
    func playClickSound() {
        guard isEnabled else { return }
        
        if useSystemBeeps {
            // ✅ FIX: Fallback to system beep
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
        
        if useSystemBeeps {
            // ✅ FIX: Fallback to system beep
            AudioServicesPlaySystemSound(1105)  // Peek sound
            print("🔊 Flip beep played (fallback)")
        } else {
            cardFlipPlayer?.currentTime = 0
            cardFlipPlayer?.play()
            print("🔊 Card flip sound played")
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
        print("Sound volume set to \(clampedVolume)")
    }
    
    /// Stop all currently playing sounds
    func stopAll() {
        clickPlayer?.stop()
        cardFlipPlayer?.stop()
    }
    
    /// Cleanup resources
    func cleanup() {
        stopAll()
        clickPlayer = nil
        cardFlipPlayer = nil
        isInitialized = false
        print("✅ SoundManager cleanup completed")
    }
}
