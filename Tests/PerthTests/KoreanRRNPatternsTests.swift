import Testing
@testable import PerthCore

@Suite("KoreanRRNPatterns")
struct KoreanRRNPatternsTests {
    let detector = KoreanRRNPatterns()

    // MARK: - Helpers

    private func computeCheckDigit(for digits: String) -> Int {
        let d = digits.compactMap { Int(String($0)) }
        guard d.count == 12 else { return -1 }
        let weights = [2, 3, 4, 5, 6, 7, 8, 9, 2, 3, 4, 5]
        var sum = 0
        for i in 0..<12 { sum += d[i] * weights[i] }
        return (11 - (sum % 11)) % 10
    }

    private func makeRRN(birth: String, genderDigit: Character) -> String {
        let body12 = birth + String(genderDigit) + "00000"
        let check = computeCheckDigit(for: body12)
        return birth + "-" + String(genderDigit) + "00000" + String(check)
    }

    // MARK: - True positives

    @Test("detects valid male RRN born in 1990s (gender digit 1)")
    func detectsValidMaleRRNBornIn1990s() {
        let rrn = makeRRN(birth: "900101", genderDigit: "1")
        let matches = detector.detect(in: rrn)
        #expect(!matches.isEmpty)
        #expect(matches.allSatisfy { $0.patternType == .koreanRRN })
    }

    @Test("detects valid female RRN born in 1980s (gender digit 2)")
    func detectsValidFemaleRRNBornIn1980s() {
        let rrn = makeRRN(birth: "850315", genderDigit: "2")
        let matches = detector.detect(in: rrn)
        #expect(!matches.isEmpty)
    }

    @Test("detects valid RRN with gender digit 3 (2000s male)")
    func detectsValidRRNBornIn2000s_genderDigit3() {
        let rrn = makeRRN(birth: "010203", genderDigit: "3")
        let matches = detector.detect(in: rrn)
        #expect(!matches.isEmpty)
    }

    @Test("detects valid RRN with gender digit 4 (2000s female)")
    func detectsValidRRNBornIn2000s_genderDigit4() {
        let rrn = makeRRN(birth: "020405", genderDigit: "4")
        let matches = detector.detect(in: rrn)
        #expect(!matches.isEmpty)
    }

    @Test("detects valid RRN without dash separator")
    func detectsValidRRNWithoutDashSeparator() {
        let body12 = "900101" + "1" + "00000"
        let check = computeCheckDigit(for: body12)
        let rrn = "9001011" + "00000" + String(check)
        let matches = detector.detect(in: rrn)
        #expect(!matches.isEmpty)
    }

    @Test("detects valid RRN embedded in Korean text")
    func detectsValidRRNEmbeddedInText() {
        let rrn = makeRRN(birth: "751010", genderDigit: "1")
        let text = "주민번호: \(rrn) 입니다."
        let matches = detector.detect(in: text)
        #expect(!matches.isEmpty)
    }

    // MARK: - True negatives

    @Test("does not detect RRN with invalid month (13)")
    func doesNotDetectInvalidMonth() {
        let matches = detector.detect(in: "901301-1000001")
        #expect(matches.isEmpty)
    }

    @Test("does not detect RRN with invalid day (00)")
    func doesNotDetectInvalidDay() {
        let matches = detector.detect(in: "900100-1000001")
        #expect(matches.isEmpty)
    }

    @Test("does not detect RRN with invalid gender digit 5")
    func doesNotDetectInvalidGenderDigit5() {
        let body12 = "900101" + "5" + "00000"
        let check = computeCheckDigit(for: body12)
        let rrn = "900101-5" + "00000" + String(check)
        let matches = detector.detect(in: rrn)
        #expect(matches.isEmpty)
    }

    @Test("does not detect RRN with wrong checksum digit")
    func doesNotDetectRRNWithWrongChecksum() {
        let body12 = "900101" + "1" + "00000"
        let correct = computeCheckDigit(for: body12)
        let wrong = (correct + 1) % 10
        let rrn = "900101-1" + "00000" + String(wrong)
        let matches = detector.detect(in: rrn)
        #expect(matches.isEmpty)
    }

    @Test("does not detect a 6-digit number alone as RRN")
    func doesNotDetectShortNumberSequence() {
        let matches = detector.detect(in: "123456")
        #expect(matches.isEmpty)
    }

    // MARK: - Redaction

    @Test("matched snippet is redacted")
    func matchedSnippetIsRedacted() {
        let rrn = makeRRN(birth: "900101", genderDigit: "1")
        let matches = detector.detect(in: rrn)
        #expect(!matches.isEmpty)
        #expect(matches[0].matchedSnippet != rrn)
    }

    @Test("empty input returns no matches")
    func emptyInputReturnsNoMatches() {
        #expect(detector.detect(in: "").isEmpty)
    }
}
