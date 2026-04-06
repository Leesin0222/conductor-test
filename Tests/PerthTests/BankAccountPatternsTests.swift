import Testing
@testable import PerthCore

@Suite("BankAccountPatterns")
struct BankAccountPatternsTests {
    let detector = BankAccountPatterns()

    // MARK: - Keyword-based detection

    @Test("detects '계좌번호' followed by account number")
    func detectsKoreanKeywordWithNumber() {
        let matches = detector.detect(in: "계좌번호: 110-123-456789")
        #expect(!matches.isEmpty)
        #expect(matches.allSatisfy { $0.patternType == .bankAccount })
    }

    @Test("detects '계좌' followed by account number")
    func detectsShortKoreanKeyword() {
        let matches = detector.detect(in: "계좌=1234-56-789012")
        #expect(!matches.isEmpty)
    }

    @Test("detects 'account number' followed by digits")
    func detectsEnglishAccountKeyword() {
        let matches = detector.detect(in: "account number: 1234-567-890123")
        #expect(!matches.isEmpty)
    }

    // MARK: - Bank-specific patterns

    @Test("detects KB국민 account format")
    func detectsKBAccount() {
        let matches = detector.detect(in: "국민 123-45-6789012-01")
        #expect(!matches.isEmpty)
    }

    @Test("detects 신한 account format")
    func detectsShinhanAccount() {
        let matches = detector.detect(in: "신한 110-123-456789")
        #expect(!matches.isEmpty)
    }

    @Test("detects 카카오뱅크 account format")
    func detectsKakaoAccount() {
        let matches = detector.detect(in: "카카오 3333-12-1234567")
        #expect(!matches.isEmpty)
    }

    @Test("detects NH농협 account format")
    func detectsNHAccount() {
        let matches = detector.detect(in: "NH 123-1234-5678-12")
        #expect(!matches.isEmpty)
    }

    // MARK: - Negative cases

    @Test("does not detect random short numbers without keyword")
    func doesNotDetectRandomShortNumbers() {
        let matches = detector.detect(in: "12345")
        #expect(matches.isEmpty)
    }

    @Test("empty input returns no matches")
    func emptyInputReturnsNoMatches() {
        #expect(detector.detect(in: "").isEmpty)
    }

    @Test("matched snippet is redacted")
    func matchedSnippetIsRedacted() {
        let matches = detector.detect(in: "계좌번호: 110-123-456789")
        #expect(!matches.isEmpty)
        #expect(!matches[0].matchedSnippet.contains("456789"))
    }
}
