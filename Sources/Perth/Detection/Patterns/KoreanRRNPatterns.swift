import Foundation

struct KoreanRRNPatterns: PatternDefinition {
    let patternType: PatternType = .koreanRRN

    func detect(in text: String) -> [SensitiveDataMatch] {
        let pattern = #"\b(\d{6})\s*[-]?\s*(\d{7})\b"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }

        let range = NSRange(text.startIndex..., in: text)
        let nsMatches = regex.matches(in: text, range: range)

        var results: [SensitiveDataMatch] = []
        for match in nsMatches {
            guard match.numberOfRanges >= 3,
                  let birthRange = Range(match.range(at: 1), in: text),
                  let suffixRange = Range(match.range(at: 2), in: text) else { continue }

            let birth = String(text[birthRange])
            let suffix = String(text[suffixRange])

            guard isValidBirthDate(birth),
                  let genderDigit = suffix.first,
                  "1234".contains(genderDigit),
                  validateChecksum(birth + suffix) else { continue }

            let full = birth + "-" + suffix
            results.append(SensitiveDataMatch(
                patternType: patternType,
                matchedSnippet: SensitiveDataMatch.redact(full),
                timestamp: Date()
            ))
        }
        return results
    }

    private func isValidBirthDate(_ birth: String) -> Bool {
        let digits = Array(birth)
        guard digits.count == 6 else { return false }
        guard let month = Int(String(digits[2...3])),
              let day = Int(String(digits[4...5])) else { return false }
        return (1...12).contains(month) && (1...31).contains(day)
    }

    private func validateChecksum(_ rrn: String) -> Bool {
        let digits = rrn.compactMap { Int(String($0)) }
        guard digits.count == 13 else { return false }
        let weights = [2, 3, 4, 5, 6, 7, 8, 9, 2, 3, 4, 5]
        var sum = 0
        for i in 0..<12 {
            sum += digits[i] * weights[i]
        }
        let check = (11 - (sum % 11)) % 10
        return check == digits[12]
    }
}
