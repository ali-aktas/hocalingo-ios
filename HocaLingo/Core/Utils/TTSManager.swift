//
//  TTSManager.swift
//  HocaLingo
//
//  Text-to-Speech Manager - Handles word pronunciation
//  Location: Core/Utils/TTSManager.swift
//

import AVFoundation
import Combine

// MARK: - TTS Manager
/// Singleton manager for Text-to-Speech functionality
/// Uses AVSpeechSynthesizer for native iOS speech synthesis
class TTSManager: NSObject, ObservableObject {
    
    // MARK: - Singleton
    static let shared = TTSManager()
    
    // MARK: - Published Properties
    @Published var isSpeaking: Bool = false
    @Published var isEnabled: Bool = true
    
    // MARK: - Private Properties
    private let synthesizer = AVSpeechSynthesizer()
    private var currentUtterance: AVSpeechUtterance?
    
    // MARK: - Initialization
    override private init() {
        super.init()
        synthesizer.delegate = self
        print("✅ TTSManager initialized")
    }
    
    // MARK: - Public Methods
    
    /// Speak text in specified language
    /// - Parameters:
    ///   - text: Text to speak
    ///   - languageCode: Language code (e.g., "en", "tr")
    func speak(text: String, languageCode: String = "en") {
        guard isEnabled else {
            print("🔇 TTS disabled")
            return
        }
        
        guard !text.isEmpty else {
            print("⚠️ Empty text provided to TTS")
            return
        }
        
        // Stop any ongoing speech
        stop()
        
        // Create utterance
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode)
        utterance.rate = 0.4 // Slower for learning (0.0-1.0, default 0.5)
        utterance.pitchMultiplier = 1.0 // Normal pitch
        utterance.volume = 0.8 // 80% volume
        
        currentUtterance = utterance
        synthesizer.speak(utterance)
        
        print("🔊 TTS speaking: '\(text)' in language: \(languageCode)")
    }
    
    /// Speak English word (convenience method)
    /// - Parameter word: English word to pronounce
    func speakEnglishWord(_ word: String) {
        speak(text: word, languageCode: "en-US")
    }
    
    /// Speak Turkish word (convenience method)
    /// - Parameter word: Turkish word to pronounce
    func speakTurkishWord(_ word: String) {
        speak(text: word, languageCode: "tr-TR")
    }
    
    /// Stop current speech
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            print("🛑 TTS stopped")
        }
    }
    
    /// Pause current speech
    func pause() {
        if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: .word)
            print("⏸️ TTS paused")
        }
    }
    
    /// Resume paused speech
    func resume() {
        if synthesizer.isPaused {
            synthesizer.continueSpeaking()
            print("▶️ TTS resumed")
        }
    }
    
    /// Toggle TTS enabled state
    func toggleEnabled() {
        isEnabled.toggle()
        if !isEnabled {
            stop()
        }
        print("TTS \(isEnabled ? "enabled" : "disabled")")
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension TTSManager: AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = true
        }
        print("🗣️ TTS started speaking")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = false
            self?.currentUtterance = nil
        }
        print("✅ TTS finished speaking")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        print("⏸️ TTS paused")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        print("▶️ TTS continued")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isSpeaking = false
            self?.currentUtterance = nil
        }
        print("❌ TTS cancelled")
    }
}
