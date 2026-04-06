import Foundation

struct PhoneNumberPatterns: PatternDefinition {
    let patternType: PatternType = .phoneNumber

    private let patterns = [
        // Korean mobile: 010-1234-5678, 010 1234 5678, 01012345678
        #"\b01[016789][\s\-]?\d{3,4}[\s\-]?\d{4}\b"#,
        // Korean landline: 02-1234-5678, 031-123-4567
        #"\b0[2-6][1-5]?[\s\-]?\d{3,4}[\s\-]?\d{4}\b"#,
        // Korean format with parentheses: (010) 1234-5678
        #"\(01[016789]\)\s?\d{3,4}[\s\-]?\d{4}"#,
        // Korean format with +82: +82-10-1234-5678, +8210-1234-5678
        #"\+82[\s\-]?10[\s\-]?\d{3,4}[\s\-]?\d{4}"#,
    ]

    func detect(in text: String) -> [SensitiveDataMatch] {
        var results: [SensitiveDataMatch] = []
        for pattern in patterns {
            results.append(contentsOf: buildMatches(from: matchesForRegex(pattern, in: text)))
        }
        return results
    }
}
