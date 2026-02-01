//
//  PromptBuilder.swift
//  HocaLingo
//
//  Core/Utils/PromptBuilder.swift
//  AI prompt construction for story generation
//  ✅ FIXED: Strong topic focus, original fantasy characters, content safety
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
        
        // ✅ STRONG topic integration
        let topicSection: String
        if let topic = topic, !topic.isEmpty {
            topicSection = """
            
            🎯 HİKAYE KONUSU (ZORUNLU):
            Hikaye MUTLAKA bu konu hakkında olmalı: "\(topic)"
            Konuyu hikayenin merkezine koy. Tüm hikaye bu konuya odaklanmalı.
            
            """
        } else {
            topicSection = "\n\n"
        }
        
        return """
        SEN BİR HİKAYE YAZARISIN. Türkçe olarak \(typeInstruction). \(lengthInstruction)
        \(topicSection)⚠️ ÇOK ÖNEMLİ FORMAT KURALI:
        İLK SATIR: Hikayeye uygun 3 kelimelik bir başlık yaz (sadece başlık, başka bir şey yazma)
        İKİNCİ SATIR: Boş bırak
        ÜÇÜNCÜ SATIRDAN İTİBAREN: Hikayeyi yaz
        
        ÖRNEK FORMAT:
        Kahramanın Yolculuğu
        
        Bir zamanlar uzak bir diyarda...
        
        Aşağıdaki İngilizce kelimeleri kullan:
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
        \(ContentValidator.aiSafetyRules)
        
        ŞIMDI BAŞLA:
        """
    }
}
