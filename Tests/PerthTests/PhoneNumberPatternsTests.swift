import Testing
@testable import PerthCore

@Suite("PhoneNumberPatterns")
struct PhoneNumberPatternsTests {
    let detector = PhoneNumberPatterns()

    // MARK: - Korean mobile numbers

    @Test("detects 010-1234-5678 format")
    func detectsMobileWithDashes() {
        let matches = detector.detect(in: "전화번호 010-1234-5678 입니다")
        #expect(!matches.isEmpty)
        #expect(matches.allSatisfy { $0.patternType == .phoneNumber })
    }

    @Test("detects 01012345678 format without separators")
    func detectsMobileWithoutSeparators() {
        let matches = detector.detect(in: "01012345678")
        #expect(!matches.isEmpty)
    }

    @Test("detects 010 1234 5678 format with spaces")
    func detectsMobileWithSpaces() {
        let matches = detector.detect(in: "010 1234 5678")
        #expect(!matches.isEmpty)
    }

    @Test("detects 016, 017, 018, 019 old mobile prefixes")
    func detectsOldMobilePrefixes() {
        let matches016 = detector.detect(in: "016-123-4567")
        let matches019 = detector.detect(in: "019-234-5678")
        #expect(!matches016.isEmpty)
        #expect(!matches019.isEmpty)
    }

    // MARK: - Korean landline numbers

    @Test("detects Seoul landline 02-1234-5678")
    func detectsSeoulLandline() {
        let matches = detector.detect(in: "02-1234-5678")
        #expect(!matches.isEmpty)
    }

    @Test("detects regional landline 031-123-4567")
    func detectsRegionalLandline() {
        let matches = detector.detect(in: "031-123-4567")
        #expect(!matches.isEmpty)
    }

    // MARK: - International format

    @Test("detects +82-10-1234-5678 international format")
    func detectsInternationalFormat() {
        let matches = detector.detect(in: "+82-10-1234-5678")
        #expect(!matches.isEmpty)
    }

    @Test("detects +8210-1234-5678 without dash after country code")
    func detectsInternationalFormatCompact() {
        let matches = detector.detect(in: "+8210-1234-5678")
        #expect(!matches.isEmpty)
    }

    // MARK: - Negative cases

    @Test("does not detect short number sequences")
    func doesNotDetectShortNumbers() {
        let matches = detector.detect(in: "1234-5678")
        #expect(matches.isEmpty)
    }

    @Test("empty input returns no matches")
    func emptyInputReturnsNoMatches() {
        #expect(detector.detect(in: "").isEmpty)
    }

    @Test("matched snippet is redacted")
    func matchedSnippetIsRedacted() {
        let matches = detector.detect(in: "010-1234-5678")
        #expect(!matches.isEmpty)
        #expect(!matches[0].matchedSnippet.contains("1234-5678"))
    }
}
