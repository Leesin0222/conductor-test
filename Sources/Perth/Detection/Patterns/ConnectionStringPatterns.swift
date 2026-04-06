import Foundation

struct ConnectionStringPatterns: PatternDefinition {
    let patternType: PatternType = .connectionString

    private let patterns = [
        #"jdbc:[a-z]+://[^:]+:[^@]+@[^\s]+"#,
        #"mongodb(?:\+srv)?://[^:]+:[^@]+@[^\s]+"#,
        #"postgres(?:ql)?://[^:]+:[^@]+@[^\s]+"#,
        #"mysql://[^:]+:[^@]+@[^\s]+"#,
        #"redis://:[^@]+@[^\s]+"#,
        #"(?:Server|Data Source)\s*=\s*[^;]+;\s*(?:Password|Pwd)\s*=\s*[^;]+"#,
    ]

    func detect(in text: String) -> [SensitiveDataMatch] {
        var results: [SensitiveDataMatch] = []
        for pattern in patterns {
            results.append(contentsOf: buildMatches(from: matchesForRegex(pattern, in: text)))
        }
        return results
    }
}
