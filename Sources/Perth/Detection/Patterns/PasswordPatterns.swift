import Foundation

struct PasswordPatterns: PatternDefinition {
    let patternType: PatternType = .password

    private let patterns = [
        #"(?:password|passwd|pwd)\s*[:=]\s*['"]?[^\s'"]{3,}['"]?"#,
        #"(?:secret|token)\s*[:=]\s*['"]?[^\s'"]{8,}['"]?"#,
    ]

    private let excludeValues = [
        "<placeholder>", "xxx", "***", "your_password", "password",
        "changeme", "example", "${", "{{", "null", "none", "undefined",
    ]

    func detect(in text: String) -> [SensitiveDataMatch] {
        var results: [SensitiveDataMatch] = []
        for pattern in patterns {
            let matches = matchesForRegex(pattern, in: text)
            let filtered = matches.filter { match in
                let lower = match.lowercased()
                return !excludeValues.contains(where: { lower.contains($0) })
            }
            results.append(contentsOf: buildMatches(from: filtered))
        }
        return results
    }
}
