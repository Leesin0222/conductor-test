import Foundation

struct EmailPasswordPatterns: PatternDefinition {
    let patternType: PatternType = .emailPassword

    func detect(in text: String) -> [SensitiveDataMatch] {
        let pattern = #"[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}\s*[:;|]\s*\S{3,}"#
        let matches = matchesForRegex(pattern, in: text, options: [])
        return buildMatches(from: matches)
    }
}
