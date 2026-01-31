//
//  PromptBuilder.swift
//  HocaLingo
//
//  Core/Utils/PromptBuilder.swift
//  AI prompt construction for story generation
//  Optimized for Gemini 2.5 Flash with cost-efficient token usage
//

import Foundation

/// Prompt builder for AI story generation
/// Creates structured prompts with explicit formatting rules
class PromptBuilder {
    
    /// Build AI prompt for story generation
    /// - Parameters:
    ///   - words: Selected vocabulary words to include
    ///   - topic: Optional user-specified topic
    ///   - type: Story type (motivation, fantasy, dialogue)
    ///   - length: Story length (affects word count target)
    /// - Returns: Formatted prompt for Gemini API
    func buildPrompt(
        words: [WordWithMeaning],
        topic: String?,
        type: StoryType,
        length: StoryLength
    ) -> String {
        
        // Word list for AI
        let wordList = words.map { $0.english }.joined(separator: ", ")
        
        // Type-specific instruction
        let typeInstruction = type.promptInstruction
        
        // Length instruction
        let lengthInstruction = "Yaklaşık \(length.targetWordCount) kelime kullan."
        
        // Optional topic
        let topicPart = topic.map { "Konu: \($0)\n\n" } ?? ""
        
        return """
        SEN BİR HİKAYE YAZARISIN. Türkçe olarak \(typeInstruction). \(lengthInstruction)
        
        ⚠️ ÇOK ÖNEMLİ FORMAT KURALI:
        İLK SATIR: Hikayeye uygun 3 kelimelik bir başlık yaz (sadece başlık, başka bir şey yazma)
        İKİNCİ SATIR: Boş bırak
        ÜÇÜNCÜ SATIRDAN İTİBAREN: Hikayeyi yaz
        
        ÖRNEK FORMAT:
        Kahramanın Yolculuğu
        
        Bir zamanlar uzak bir diyarda...
        
        \(topicPart)Aşağıdaki İngilizce kelimeleri kullan:
        \(wordList)
        
        ⚠️ KELİME KULLANIM KURALLARI:
        
        1. KELİMELER MUTLAKA İNGİLİZCE OLACAK
           ❌ YANLIŞ: "bu genç (young) adam"
           ❌ YANLIŞ: "bu **young** adam"
           ✅ DOĞRU: "bu young adam"
        
        2. HİÇBİR BİÇİMLENDİRME YAPMA
           - Markdown kullanma (**bold**, *italic*, _underline_)
           - Parantez içinde çeviri yazma (genç)
           - Sadece düz metin yaz
        
        3. İNGİLİZCE KELİMELER DOĞAL AKMALI
           ❌ "Bu happy bir gündü"
           ✅ "Bu sabah çok happy hissediyordu"
        
        4. HER KELİMEYİ EN AZ 1 KEZ KULLAN
           Tüm kelimeleri hikaye içinde kullanmalısın.
        
        5. BAŞLIKTAN SONRA BOŞ SATIR BIRAK
           Başlık ile hikaye arasında mutlaka boş bir satır olmalı.
        
        6. NOKTALAMA DİKKAT
           Cümleleri nokta, ünlem veya soru işaretiyle bitir.
           Tamamlanmamış cümle bırakma.
        
        ŞIMDI BAŞLA:
        """
    }
    
    /// Build prompt for specific story types with custom rules
    func buildCustomPrompt(
        words: [WordWithMeaning],
        topic: String?,
        type: StoryType,
        length: StoryLength
    ) -> String {
        
        switch type {
        case .fantasy:
            return buildFantasyPrompt(words: words, topic: topic, length: length)
        case .dialogue:
            return buildDialoguePrompt(words: words, topic: topic, length: length)
        case .motivation:
            return buildPrompt(words: words, topic: topic, type: type, length: length)
        }
    }
    
    // MARK: - Type-Specific Prompts
    
    /// Fantasy story prompt with kid-friendly rules
    private func buildFantasyPrompt(
        words: [WordWithMeaning],
        topic: String?,
        length: StoryLength
    ) -> String {
        
        let wordList = words.map { $0.english }.joined(separator: ", ")
        let topicPart = topic.map { "Konu: \($0)\n\n" } ?? ""
        
        return """
        SEN BİR ÇOCUK HİKAYESİ YAZARISIN. Türkçe olarak çocuklara uygun fantastik bir hikaye yaz.
        
        KARAKTER: Telifsiz, orijinal bir karakter kullan (örnek: süper kahraman, Keloğlan tarzı bir karakter)
        UZUNLUK: Yaklaşık \(length.targetWordCount) kelime
        
        ⚠️ FORMAT:
        İLK SATIR: 3 kelimelik başlık
        İKİNCİ SATIR: Boş
        ÜÇÜNCÜ SATIRDAN İTİBAREN: Hikaye
        
        \(topicPart)Şu İngilizce kelimeleri kullan:
        \(wordList)
        
        ⚠️ KURALLAR:
        - Kelimeler İngilizce olmalı (parantez yok, bold yok)
        - Her kelimeyi en az 1 kez kullan
        - Çocuklara uygun içerik (şiddet yok, korku yok)
        - İlham verici ve eğlenceli olmalı
        
        ŞIMDI BAŞLA:
        """
    }
    
    /// Dialogue prompt with conversation formatting
    private func buildDialoguePrompt(
        words: [WordWithMeaning],
        topic: String?,
        length: StoryLength
    ) -> String {
        
        let wordList = words.map { $0.english }.joined(separator: ", ")
        let topicPart = topic.map { "Konu: \($0)\n\n" } ?? ""
        
        return """
        SEN BİR DİYALOG YAZARISIN. Türkçe olarak 2 kişi arasında günlük hayattan bir konuşma yaz.
        
        UZUNLUK: Yaklaşık \(length.targetWordCount) kelime
        FORMAT: İki kişinin karşılıklı konuşması (Ali: ... / Ayşe: ...)
        
        ⚠️ FORMAT:
        İLK SATIR: 3 kelimelik başlık
        İKİNCİ SATIR: Boş
        ÜÇÜNCÜ SATIRDAN İTİBAREN: Diyalog
        
        \(topicPart)Şu İngilizce kelimeleri kullan:
        \(wordList)
        
        ⚠️ KURALLAR:
        - Kelimeler İngilizce olmalı (parantez yok, bold yok)
        - Her kelimeyi en az 1 kez kullan
        - Doğal konuşma dili kullan
        - Gerçekçi bir senaryo oluştur
        
        ÖRNEK:
        Kahve Molası
        
        Ali: Bugün çok busy bir gün geçirdim.
        Ayşe: Anladım, ben de aynı şekilde...
        
        ŞIMDI BAŞLA:
        """
    }
}
