//
//  PromptBuilder.swift
//  HocaLingo
//
//  Core/Utils/PromptBuilder.swift
//  ✅ REDESIGNED: Much higher English word density
//  - Deck words used more aggressively
//  - Bonus non-deck English words required
//  - Every 3-4 Turkish words must have 1 English word
//  Location: HocaLingo/Core/Utils/PromptBuilder.swift
//

import Foundation

/// Prompt builder for AI story generation
/// Creates structured prompts with explicit formatting rules
/// ✅ REDESIGNED: Maximizes English word density in stories
class PromptBuilder {
    
    /// Build AI prompt for story generation
    /// ✅ REDESIGNED: Higher word density + bonus English words
    /// - Parameters:
    ///   - words: Selected vocabulary words to include (deck words)
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
        let wordCount = words.count
        
        // Type-specific instruction
        let typeInstruction = type.promptInstruction
        
        // Length instruction
        let lengthInstruction = "Yaklaşık \(length.targetWordCount) kelime kullan."
        
        // ✅ Calculate bonus English word count
        // Target: ~1 English word per 3-4 total words
        // Deck words cover some, bonus covers the rest
        let totalTargetEnglish = length.targetWordCount / 4  // ~25% English
        let bonusWordCount = max(5, totalTargetEnglish - wordCount)
        
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
        
        ═══════════════════════════════════════
        BÖLÜM A - ZORUNLU DESTE KELİMELERİ
        ═══════════════════════════════════════
        
        Aşağıdaki \(wordCount) İngilizce kelimeyi HİKAYEDE KULLAN:
        \(wordList)
        
        - Bu kelimelerin HEPSİNİ kullan. Hiçbirini atlama.
        - Her kelimeyi EN AZ 1, EN FAZLA 2 kez kullan.
        - Bu kelimeler hikayede İngilizce olarak geçecek, Türkçeye çevirme.
        
        ═══════════════════════════════════════
        BÖLÜM B - BONUS İNGİLİZCE KELİMELER (ÇOK ÖNEMLİ!)
        ═══════════════════════════════════════
        
        Yukarıdaki deste kelimelerine EK OLARAK, hikayede konuyla uyumlu yaklaşık \(bonusWordCount) tane DAHA basit/yaygın İngilizce kelime kullan.
        
        Bu bonus kelimelerin amacı hikayeyi İNGİLİZCE-TÜRKÇE KARIŞIK bir metin yapmak.
        Bonus kelimeleri mor renkle işaretlemeyeceğiz, sadece hikayenin doğallığını artırıyorlar.
        
        ═══════════════════════════════════════
        BÖLÜM C - YOĞUNLUK KURALI (EN KRİTİK!)
        ═══════════════════════════════════════
        
        ⚠️ HER 3-4 TÜRKÇE KELİMEDEN SONRA 1 İNGİLİZCE KELİME KULLANILMALI! YANİ HER CÜMLEDE 1 İNGİLİZCE KELİME KULLANIMI İDEAL.
        
        ❌ KÖTÜ ÖRNEK (çok fazla düz Türkçe):
        "Ertesi gün sabah erkenden kalktı ve mutfağa gitti. Kahvaltısını hazırladı, çayını koydu ve pencereden dışarı baktı. Hava çok güzeldi."
        
        ✅ İYİ ÖRNEK (İngilizce doğal şekilde serpiştirilmiş):
        "Ertesi day sabah erkenden kalktı ve quietly mutfağa gitti. Kahvaltısını careful bir şekilde hazırladı, warm çayını koydu ve big pencereden outside baktı. Hava really beautiful görünüyordu."
        
        ✅ BAŞKA İYİ ÖRNEK:
        "The young adam, her morning aynı path üzerinden walk ederdi. Bu road onun için special bir place gibiydi."
        
        Bu dağılımı hikayenin BAŞINDAN SONUNA KADAR koru. Ortada veya sonda sadece Türkçe veya sadece İngilizce paragraflar OLMASIN.
        
        ═══════════════════════════════════════
        BÖLÜM D - FORMAT KURALLARI
        ═══════════════════════════════════════
        
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
        
        4. HER İNGİLİZCE KELİMEYİ EN FAZLA 2 KEZ KULLAN
           ❌ "happy olan adam happy bir şekilde happy yürüdü"
           ✅ "happy olan adam joyful bir şekilde yürüdü"
        
        5. SADECE KÜÇÜK HARF KULLAN (İngilizce kelimeler için)
           ❌ "Bu HAPPY bir gündü"
           ✅ "Bu happy bir gündü"
           İstisna: Cümle başındaki kelimeler büyük harfle başlayabilir.
        
        6. İNGİLİZCE KELİMELERİ TÜRKÇE EK İLE BİRLEŞTİRME
           ❌ "happilik", "beautifuldu"
           ✅ "çok happy hissetti", "gerçekten beautiful bir manzaraydı"
        
        
        SON KONTROL: Yazdığın hikayeyi gözden geçir.
        1. Art arda 2 cümle tamamen Türkçe ise, aralara birer İngilizce kelime ekle.
        2. Art arda 2 cümle tamamen İngilizce ise, bir cümleyi Türkçe olarak değiştir. Hikaye hiçbir zaman tamamen İngilizce'ye veya tamamen Türkçe'ye kaymamalı.
        3. Hikayenin başındaki Türkçe-İngilizce dengesi tüm hikaye boyunca korunmalı.
        4. Hikaye Pratikte %60 türkçe kelime %40 ingilizce kelime içermeli. 
        """
    }
}
