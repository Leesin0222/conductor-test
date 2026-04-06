import Testing
@testable import PerthCore

@Suite("CreditCardPatterns")
struct CreditCardPatternsTests {
    let detector = CreditCardPatterns()

    // MARK: - Valid Luhn numbers

    @Test("detects valid Visa card number")
    func detectsVisaCardNumber() {
        let matches = detector.detect(in: "4111111111111111")
        #expect(!matches.isEmpty)
        #expect(matches.allSatisfy { $0.patternType == .creditCard })
    }

    @Test("detects valid Mastercard number")
    func detectsMastercardNumber() {
        let matches = detector.detect(in: "5500005555555559")
        #expect(!matches.isEmpty)
    }

    @Test("detects valid Amex card number (15 digits)")
    func detectsAmexCardNumber() {
        let matches = detector.detect(in: "371449635398431")
        #expect(!matches.isEmpty)
    }

    @Test("detects card number with space separators")
    func detectsCardNumberWithSpaceSeparators() {
        let matches = detector.detect(in: "4111 1111 1111 1111")
        #expect(!matches.isEmpty)
    }

    @Test("detects card number with dash separators")
    func detectsCardNumberWithDashSeparators() {
        let matches = detector.detect(in: "4111-1111-1111-1111")
        #expect(!matches.isEmpty)
    }

    @Test("detects card number embedded in prose")
    func detectsCardNumberEmbeddedInText() {
        let matches = detector.detect(in: "Please charge card 4111111111111111 for the order.")
        #expect(!matches.isEmpty)
    }

    // MARK: - Invalid Luhn

    @Test("rejects number that fails Luhn check")
    func doesNotDetectNumberThatFailsLuhnCheck() {
        let matches = detector.detect(in: "4111111111111112")
        #expect(matches.isEmpty)
    }

    @Test("rejects all-same-digit sequence (fails Luhn)")
    func doesNotDetectAllSameDigitsSequence() {
        let matches = detector.detect(in: "1111111111111111")
        #expect(matches.isEmpty)
    }

    // MARK: - Length boundary checks

    @Test("does not detect number with only 12 digits (below minimum)")
    func doesNotDetectTwelveDigitNumber() {
        let matches = detector.detect(in: "411111111111")
        #expect(matches.isEmpty)
    }

    @Test("does not detect number with 20 digits (exceeds maximum)")
    func doesNotDetectTwentyDigitNumber() {
        let matches = detector.detect(in: "41111111111111111119")
        #expect(matches.isEmpty)
    }

    // MARK: - Redaction

    @Test("matched snippet is redacted, not the raw card number")
    func redactedSnippetDoesNotExposeFullCardNumber() {
        let text = "4111111111111111"
        let matches = detector.detect(in: text)
        #expect(!matches.isEmpty)
        #expect(matches[0].matchedSnippet != text)
    }

    @Test("empty input returns no matches")
    func emptyInputReturnsNoMatches() {
        #expect(detector.detect(in: "").isEmpty)
    }
}
