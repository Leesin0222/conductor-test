import Foundation

struct JWTPatterns: PatternDefinition {
    let patternType: PatternType = .jwt

    func detect(in text: String) -> [SensitiveDataMatch] {
        let pattern = #"eyJ[A-Za-z0-9_\-]+\.eyJ[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+"#
        let matches = matchesForRegex(pattern, in: text, options: [])
        return buildMatches(from: matches)
    }
}
