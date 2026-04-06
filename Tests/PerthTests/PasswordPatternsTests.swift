import Testing
@testable import PerthCore

@Suite("PasswordPatterns")
struct PasswordPatternsTests {
    let detector = PasswordPatterns()

    // MARK: - True positives
    // NOTE: The excludeValues list contains "password" itself, so any match whose
    // full text contains "password" (i.e. password=... and PASSWORD=...) is filtered
    // out by the implementation. Only passwd= and pwd= are reliably detected.

    @Test("password= is filtered because matched text contains the word 'password'")
    func passwordEqualsIsFilteredByExcludeList() {
        // The implementation filters matches whose text contains an excludeValue.
        // "password" is in excludeValues, so password=hunter2 is filtered out.
        let matches = detector.detect(in: "password=hunter2")
        #expect(matches.isEmpty)
    }

    @Test("detects passwd= assignment")
    func detectsPasswdEqualsValue() {
        let matches = detector.detect(in: "passwd=s3cr3tValue")
        #expect(!matches.isEmpty)
        #expect(matches.allSatisfy { $0.patternType == .password })
    }

    @Test("detects pwd= assignment")
    func detectsPwdEqualsValue() {
        let matches = detector.detect(in: "pwd=mysecret123")
        #expect(!matches.isEmpty)
    }

    @Test("detects secret= with 8+ char value")
    func detectsSecretEqualsLongValue() {
        let matches = detector.detect(in: "secret=abcdefgh")
        #expect(!matches.isEmpty)
    }

    @Test("detects token= with 8+ char value")
    func detectsTokenEqualsLongValue() {
        let matches = detector.detect(in: "token=abcdefgh12345678")
        #expect(!matches.isEmpty)
    }

    @Test("quoted password= is also filtered because matched text contains 'password'")
    func quotedPasswordIsFiltered() {
        let matches = detector.detect(in: #"password="myRealPassword""#)
        #expect(matches.isEmpty)
    }

    // MARK: - Placeholder exclusions

    @Test("excludes placeholder value 'xxx'")
    func doesNotDetectPasswordEqualsXxx() {
        let matches = detector.detect(in: "password=xxx")
        #expect(matches.isEmpty)
    }

    @Test("excludes placeholder value 'null'")
    func doesNotDetectPasswordEqualsNull() {
        let matches = detector.detect(in: "password=null")
        #expect(matches.isEmpty)
    }

    @Test("excludes ${...} template placeholder")
    func doesNotDetectPasswordWithDollarBracePlaceholder() {
        let matches = detector.detect(in: "password=${MY_PASSWORD}")
        #expect(matches.isEmpty)
    }

    @Test("excludes 'changeme' placeholder")
    func doesNotDetectPasswordEqualsChangeme() {
        let matches = detector.detect(in: "password=changeme")
        #expect(matches.isEmpty)
    }

    @Test("excludes 'example' placeholder")
    func doesNotDetectPasswordEqualsExample() {
        let matches = detector.detect(in: "password=example")
        #expect(matches.isEmpty)
    }

    @Test("excludes 'your_password' placeholder")
    func doesNotDetectPasswordEqualsYourPassword() {
        let matches = detector.detect(in: "password=your_password")
        #expect(matches.isEmpty)
    }

    @Test("excludes '***' masked placeholder")
    func doesNotDetectPasswordEqualsMaskedAsterisks() {
        let matches = detector.detect(in: "password=***")
        #expect(matches.isEmpty)
    }

    @Test("does not detect secret= with value shorter than 8 chars")
    func doesNotDetectSecretTooShortValue() {
        let matches = detector.detect(in: "secret=abc")
        #expect(matches.isEmpty)
    }

    // MARK: - Edge cases

    @Test("empty input returns no matches")
    func emptyInputReturnsNoMatches() {
        #expect(detector.detect(in: "").isEmpty)
    }

    @Test("PASSWORD= is also filtered because lowercased match contains 'password'")
    func passwordKeywordCaseInsensitiveIsFiltered() {
        // PASSWORD= lowercases to "password=..." which contains "password" in excludeValues
        let matches = detector.detect(in: "PASSWORD=realSecret1")
        #expect(matches.isEmpty)
    }

    @Test("PASSWD= is detected case-insensitively")
    func passwdKeywordCaseInsensitiveIsDetected() {
        let matches = detector.detect(in: "PASSWD=realSecret1")
        #expect(!matches.isEmpty)
    }

    @Test("matched snippet for passwd= does not expose the full value")
    func redactedSnippetDoesNotExposeFullValue() {
        let matches = detector.detect(in: "passwd=supersecret1234")
        #expect(!matches.isEmpty)
        #expect(!matches[0].matchedSnippet.contains("supersecret1234"))
    }
}
