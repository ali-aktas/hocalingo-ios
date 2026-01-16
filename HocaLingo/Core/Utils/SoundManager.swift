//
//  SoundManager.swift
//  HocaLingo
//
//  Sound Effects Manager - Handles UI sound effects
//  Location: Core/Utils/SoundManager.swift
//

import AVFoundation
import Combine

// MARK: - Sound Manager
/// Singleton manager for sound effects
/// Handles button clicks, card flips, and other UI sounds
class SoundManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = SoundManager()
    
    // MARK: - Published Properties
    @Published var isEnabled: Bool = true
    
    // MARK: - Private Properties
    private var clickPlayer: AVAudioPlayer?
    private var cardFlipPlayer: AVAudioPlayer?
    private var isInitialized: Bool = false
    
    // MARK: - Initialization
    private init() {
        setupAudioSession()
        preloadSounds()
    }
    
    // MARK: - Setup Methods
    
    /// Configure audio session for sound effects
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            print("✅ Audio session configured")
        } catch {
            print("❌ Audio session setup error: \(error.localizedDescription)")
        }
    }
    
    /// Preload all sound effects into memory
    private func preloadSounds() {
        // Load click sound
        if let clickURL = Bundle.main.url(forResource: "click_sound", withExtension: "mp3") {
            do {
                clickPlayer = try AVAudioPlayer(contentsOf: clickURL)
                clickPlayer?.prepareToPlay()
                clickPlayer?.volume = 0.5 // 50% volume for clicks
                print("✅ Click sound loaded")
            } catch {
                print("❌ Failed to load click sound: \(error.localizedDescription)")
            }
        } else {
            print("⚠️ click_sound.mp3 not found in bundle")
        }
        
        // Load card flip sound
        if let flipURL = Bundle.main.url(forResource: "card_flip", withExtension: "mp3") {
            do {
                cardFlipPlayer = try AVAudioPlayer(contentsOf: flipURL)
                cardFlipPlayer?.prepareToPlay()
                cardFlipPlayer?.volume = 0.7 // 70% volume for card flip
                print("✅ Card flip sound loaded")
            } catch {
                print("❌ Failed to load card flip sound: \(error.localizedDescription)")
            }
        } else {
            print("⚠️ card_flip.mp3 not found in bundle")
        }
        
        isInitialized = (clickPlayer != nil) && (cardFlipPlayer != nil)
        
        if isInitialized {
            print("✅ SoundManager initialized successfully")
        } else {
            print("⚠️ SoundManager initialized with missing sounds")
        }
    }
    
    // MARK: - Public Methods
    
    /// Play button click sound
    /// Use for: All button taps (HARD, MEDIUM, EASY buttons)
    func playClickSound() {
        guard isEnabled else { return }
        
        clickPlayer?.currentTime = 0 // Reset to start
        clickPlayer?.play()
        print("🔊 Click sound played")
    }
    
    /// Play card flip sound
    /// Use for: When user taps card to flip it
    func playCardFlip() {
        guard isEnabled else { return }
        
        cardFlipPlayer?.currentTime = 0 // Reset to start
        cardFlipPlayer?.play()
        print("🔊 Card flip sound played")
    }
    
    /// Toggle sound effects on/off
    func toggleEnabled() {
        isEnabled.toggle()
        print("Sound effects \(isEnabled ? "enabled" : "disabled")")
    }
    
    /// Set volume for all sounds
    /// - Parameter volume: Volume level (0.0 to 1.0)
    func setVolume(_ volume: Float) {
        let clampedVolume = min(max(volume, 0.0), 1.0)
        clickPlayer?.volume = clampedVolume * 0.5 // Click at 50% of set volume
        cardFlipPlayer?.volume = clampedVolume * 0.7 // Flip at 70% of set volume
        print("Sound volume set to \(clampedVolume)")
    }
    
    /// Stop all currently playing sounds
    func stopAll() {
        clickPlayer?.stop()
        cardFlipPlayer?.stop()
    }
    
    /// Cleanup resources (call when app terminates)
    func cleanup() {
        stopAll()
        clickPlayer = nil
        cardFlipPlayer = nil
        isInitialized = false
        print("✅ SoundManager cleanup completed")
    }
}
