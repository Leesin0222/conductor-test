import Testing
@testable import PerthCore

@Suite("EmailPasswordPatterns")
struct EmailPasswordPatternsTests {
    let detector = EmailPasswordPatterns()

    // MARK: - True positives

    @Test("detects email:password format")
    func detectsEmailColonPassword() {
        let matches = detector.detect(in: "user@example.com:mypassword")
        #expect(!matches.isEmpty)
        #expect(matches.allSatisfy { $0.patternType == .emailPassword })
    }

    @Test("detects email|password format")
    func detectsEmailPipePassword() {
        let matches = detector.detect(in: "user@example.com|mypassword")
        #expect(!matches.isEmpty)
    }

    @Test("detects email;password format")
    func detectsEmailSemicolonPassword() {
        let matches = detector.detect(in: "user@example.com;mypassword")
        #expect(!matches.isEmpty)
    }

    @Test("detects email with subdomain and complex password")
    func detectsEmailWithSubdomainColonPassword() {
        let matches = detector.detect(in: "admin@mail.example.co.uk:P@ssw0rd!")
        #expect(!matches.isEmpty)
    }

    @Test("detects email with plus addressing")
    func detectsEmailWithPlusAddressingColonPassword() {
        let matches = detector.detect(in: "user+tag@example.com:password123")
        #expect(!matches.isEmpty)
    }

    @Test("detects email : password with spaces around separator")
    func detectsEmailPasswordWithSpacesAroundSeparator() {
        let matches = detector.detect(in: "user@example.com : mypassword")
        #expect(!matches.isEmpty)
    }

    @Test("detects email:password embedded in surrounding text")
    func detectsEmailPasswordEmbeddedInText() {
        let matches = detector.detect(in: "Credentials found: admin@corp.com:s3cret123 — please rotate")
        #expect(!matches.isEmpty)
    }

    // MARK: - True negatives

    @Test("does not detect email address alone")
    func doesNotDetectEmailAlone() {
        let matches = detector.detect(in: "user@example.com")
        #expect(matches.isEmpty)
    }

    @Test("does not detect email with password shorter than 3 chars")
    func doesNotDetectEmailWithTwoCharPassword() {
        let matches = detector.detect(in: "user@example.com:ab")
        #expect(matches.isEmpty)
    }

    @Test("does not detect non-email:password combination")
    func doesNotDetectInvalidEmailFormat() {
        let matches = detector.detect(in: "notanemail:password123")
        #expect(matches.isEmpty)
    }

    // MARK: - Redaction

    @Test("password part is redacted in snippet")
    func matchedSnippetIsRedacted() {
        let matches = detector.detect(in: "admin@example.com:supersecret")
        #expect(!matches.isEmpty)
        #expect(!matches[0].matchedSnippet.contains("supersecret"))
    }

    @Test("empty input returns no matches")
    func emptyInputReturnsNoMatches() {
        #expect(detector.detect(in: "").isEmpty)
    }
}
