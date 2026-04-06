import Foundation

class SensitiveDataDetector {
    private let allPatterns: [PatternDefinition] = [
        APIKeyPatterns(),
        PasswordPatterns(),
        PrivateKeyPatterns(),
        CreditCardPatterns(),
        KoreanRRNPatterns(),
        EmailPasswordPatterns(),
        JWTPatterns(),
        ConnectionStringPatterns(),
    ]

    func scan(text: String, enabledPatterns: Set<PatternType>) -> [SensitiveDataMatch] {
        var results: [SensitiveDataMatch] = []
        for pattern in allPatterns {
            guard enabledPatterns.contains(pattern.patternType) else { continue }
            results.append(contentsOf: pattern.detect(in: text))
        }
        return results
    }
}
