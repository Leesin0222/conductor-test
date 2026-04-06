import Foundation

struct PrivateKeyPatterns: PatternDefinition {
    let patternType: PatternType = .privateKey

    func detect(in text: String) -> [SensitiveDataMatch] {
        let pattern = #"-----BEGIN\s+(?:RSA\s+|EC\s+|DSA\s+|OPENSSH\s+|PGP\s+)?PRIVATE\s+KEY(?:\s+BLOCK)?-----"#
        let matches = matchesForRegex(pattern, in: text)
        return buildMatches(from: matches)
    }
}
