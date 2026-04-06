import Foundation

protocol PatternDefinition {
    var patternType: PatternType { get }
    func detect(in text: String) -> [SensitiveDataMatch]
}

extension PatternDefinition {
    func matchesForRegex(_ pattern: String, in text: String, options: NSRegularExpression.Options = [.caseInsensitive]) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return []
        }
        let range = NSRange(text.startIndex..., in: text)
        return regex.matches(in: text, range: range).compactMap { result in
            guard let matchRange = Range(result.range, in: text) else { return nil }
            return String(text[matchRange])
        }
    }

    func buildMatches(from strings: [String]) -> [SensitiveDataMatch] {
        strings.map { matched in
            SensitiveDataMatch(
                patternType: patternType,
                matchedSnippet: SensitiveDataMatch.redact(matched),
                timestamp: Date()
            )
        }
    }
}
