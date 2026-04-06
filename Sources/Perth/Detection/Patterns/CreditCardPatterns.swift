import Foundation

struct CreditCardPatterns: PatternDefinition {
    let patternType: PatternType = .creditCard

    func detect(in text: String) -> [SensitiveDataMatch] {
        let pattern = #"\b(?:\d[ \-]?){13,19}\b"#
        let candidates = matchesForRegex(pattern, in: text)

        let valid = candidates.filter { candidate in
            let digits = candidate.filter { $0.isNumber }
            guard digits.count >= 13, digits.count <= 19 else { return false }
            return luhnCheck(digits)
        }
        return buildMatches(from: valid)
    }

    private func luhnCheck(_ digits: String) -> Bool {
        var sum = 0
        let reversed = digits.reversed().map { Int(String($0))! }
        for (index, digit) in reversed.enumerated() {
            if index % 2 == 1 {
                let doubled = digit * 2
                sum += doubled > 9 ? doubled - 9 : doubled
            } else {
                sum += digit
            }
        }
        return sum % 10 == 0
    }
}
