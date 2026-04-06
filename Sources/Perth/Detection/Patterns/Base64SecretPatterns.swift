import Foundation

struct Base64SecretPatterns: PatternDefinition {
    let patternType: PatternType = .base64Secret

    // Keywords that precede a Base64-encoded secret value
    private let keywordPattern = #"(?:password|passwd|pwd|pw|pass|secret|token|authorization|비밀번호|비번|패스워드)\s*[:=]\s*['"]?"#

    // Base64 string: 16+ chars of [A-Za-z0-9+/] with optional = padding
    private let base64Body = #"[A-Za-z0-9+/]{16,}={0,2}"#

    // Sensitive keywords that might appear inside decoded Base64
    private let sensitiveKeywords = [
        "password", "passwd", "secret", "token", "api_key", "apikey",
        "private_key", "access_key",
    ]

    func detect(in text: String) -> [SensitiveDataMatch] {
        var results: [SensitiveDataMatch] = []

        // 1. Keyword + Base64 value pattern (e.g., password=dXNlcjpwYXNz)
        let fullPattern = keywordPattern + base64Body
        let keywordMatches = matchesForRegex(fullPattern, in: text)
        results.append(contentsOf: buildMatches(from: keywordMatches))

        // 2. Standalone Base64 that decodes to something containing sensitive keywords
        let standalonePattern = #"\b[A-Za-z0-9+/]{20,}={0,2}\b"#
        let candidates = matchesForRegex(standalonePattern, in: text, options: [])
        for candidate in candidates {
            if let decoded = decodeBase64(candidate), containsSensitiveKeyword(decoded) {
                results.append(contentsOf: buildMatches(from: [candidate]))
            }
        }

        return results
    }

    private func decodeBase64(_ string: String) -> String? {
        guard let data = Data(base64Encoded: string) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func containsSensitiveKeyword(_ decoded: String) -> Bool {
        let lower = decoded.lowercased()
        return sensitiveKeywords.contains(where: { lower.contains($0) })
    }
}
