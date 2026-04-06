import Foundation

struct CustomPattern: Identifiable, Codable {
    var id = UUID()
    var name: String
    var regex: String
    var isEnabled: Bool = true

    var isValid: Bool {
        (try? NSRegularExpression(pattern: regex)) != nil
    }
}

class CustomPatternManager: ObservableObject {
    @Published var patterns: [CustomPattern] = [] {
        didSet { save() }
    }

    private let key = "customPatterns"

    init() {
        load()
    }

    func add(name: String, regex: String) {
        let pattern = CustomPattern(name: name, regex: regex)
        guard pattern.isValid else { return }
        patterns.append(pattern)
    }

    func remove(at offsets: IndexSet) {
        patterns.remove(atOffsets: offsets)
    }

    func detect(in text: String) -> [SensitiveDataMatch] {
        var results: [SensitiveDataMatch] = []
        for pattern in patterns where pattern.isEnabled {
            guard let regex = try? NSRegularExpression(pattern: pattern.regex) else { continue }
            let range = NSRange(text.startIndex..., in: text)
            let matches = regex.matches(in: text, range: range)
            for match in matches {
                guard let r = Range(match.range, in: text) else { continue }
                let matched = String(text[r])
                results.append(SensitiveDataMatch(
                    patternType: .custom,
                    matchedSnippet: SensitiveDataMatch.redact(matched),
                    timestamp: Date(),
                    customPatternName: pattern.name
                ))
            }
        }
        return results
    }

    private func save() {
        if let data = try? JSONEncoder().encode(patterns) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let loaded = try? JSONDecoder().decode([CustomPattern].self, from: data) else { return }
        patterns = loaded
    }
}
