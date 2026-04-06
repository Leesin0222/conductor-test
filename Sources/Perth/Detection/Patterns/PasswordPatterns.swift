import Foundation

struct PasswordPatterns: PatternDefinition {
    let patternType: PatternType = .password

    private let patterns = [
        #"(?:password|passwd|pwd|pw|pass)\s*[:=\s]\s*['"]?[^\s'"]{3,}['"]?"#,
        #"(?:비밀번호|비번|패스워드)\s*[:=\s]\s*['"]?[^\s'"]{3,}['"]?"#,
        #"(?:secret|token)\s*[:=]\s*['"]?[^\s'"]{8,}['"]?"#,
    ]

    private let excludeValues = [
        "<placeholder>", "xxx", "***", "your_password",
        "changeme", "example", "${", "{{", "null", "none", "undefined",
    ]

    func detect(in text: String) -> [SensitiveDataMatch] {
        var results: [SensitiveDataMatch] = []
        for pattern in patterns {
            let matches = matchesForRegex(pattern, in: text)
            let filtered = matches.filter { match in
                // Extract the value part (after the delimiter) for exclude checking
                let value: String
                if let range = match.range(of: #"[:=\s]\s*['"]?"#, options: .regularExpression) {
                    value = String(match[range.upperBound...]).trimmingCharacters(in: CharacterSet(charactersIn: "'\""))
                } else {
                    value = match
                }
                let lower = value.lowercased()
                return !excludeValues.contains(where: { lower.contains($0) })
            }
            results.append(contentsOf: buildMatches(from: filtered))
        }
        return results
    }
}
