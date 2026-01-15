import SwiftUI

struct ContentView: View {
    @State private var testResult = "Test ediliyor..."
    
    var body: some View {
        VStack(spacing: 20) {
            Text("HocaLingo JSON Test")
                .font(.title)
            
            Text(testResult)
                .padding()
            
            Button("JSON Yükle") {
                testJSON()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    func testJSON() {
        if let package = JSONLoader.loadPackage(fileName: "en_tr_a1_001") {
            testResult = "✅ Yüklendi!\n\(package.words.count) kelime\nİlk kelime: \(package.words[0].english)"
        } else {
            testResult = "❌ Yüklenemedi"
        }
    }
}
