//
//  PromptBuilder.swift
//  HocaLingo
//
//  Core/Utils/PromptBuilder.swift
//  ✅ UPDATED: Stronger word rules, exact count, max 2 repetitions
//  Location: HocaLingo/Core/Utils/PromptBuilder.swift
//

import Foundation

/// Prompt builder for AI story generation
/// Creates structured prompts with explicit formatting rules
class PromptBuilder {
    
    /// Build AI prompt for story generation
    /// ✅ UPDATED: Exact word count + max 2 repetitions per word
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
        let wordCount = words.count  // ✅ Exact count (20 or 40)
        
        // Type-specific instruction
        let typeInstruction = type.promptInstruction
        
        // Length instruction
        let lengthInstruction = "Yaklaşık \(length.targetWordCount) kelime kullan."
        
        // ✅ Topic section (balanced - not too strong)
        let topicSection: String
        if let topic = topic, !topic.isEmpty {
            topicSection = """
            
            📝 HİKAYE KONUSU:
            Hikaye bu konu hakkında olsun: "\(topic)"
            Ancak ÖNCE aşağıdaki İngilizce kelimeleri kullanmaya odaklan.
            
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
        
        
        🎯 KELİME KULLANIM KURALLARI (ÇOK KRİTİK - BU KURALLARA UYMAZSAN BAŞARISIZ SAYILIRSIN):
        
        Aşağıdaki \(wordCount) İngilizce kelimeyi kullan:
        \(wordList)
        
        ⚠️ ZORUNLU KURALLAR:
        
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
        
        4. 🔥 HER KELİMEYİ MUTLAKA KULLAN - BU ZORUNLU! 🔥
           Tam \(wordCount) kelimeyi hikayeye yerleştirmelisin.
           Eksik kelime = BAŞARISIZ
        
        5. 🔥 HER KELİMEYİ EN AZ 1, EN FAZLA 2 KEZ KULLAN 🔥
           ❌ Aynı kelimeyi 3+ kez kullanma
           ✅ Her kelime: 1 veya 2 kez
           ✅ Varyasyon için farklı kelimeler kullan
        
        6. KELİMELER HİKAYENİN HER YERİNE DAĞILMALI
           İlk paragrafta 10, son paragrafta 10 kelime gibi dağıt.
           Hepsini tek paragrafta kullanma.
        
        7. BAŞLIKTAN SONRA BOŞ SATIR BIRAK
           Başlık ile hikaye arasında mutlaka boş bir satır olmalı.
        
        
        ✅ BAŞARI KRİTERLERİN:
        - \(wordCount) kelimeyi MUTLAKA kullan
        - Her kelime EN FAZLA 2 kez
        - Kelimeler doğal ve dağınık
        - Markdown YOK, parantez YOK
        - İlk satır başlık, sonra boş satır, sonra hikaye
        
        
        🚀 ŞİMDİ BAŞLA! Önce kelimeleri yerleştir, sonra konuya odaklan.
        """
    }
}
