import Testing
@testable import PerthCore

@Suite("PasswordPatterns")
struct PasswordPatternsTests {
    let detector = PasswordPatterns()

    // MARK: - True positives
    // NOTE: The excludeValues list contains "password" itself, so any match whose
    // full text contains "password" (i.e. password=... and PASSWORD=...) is filtered
    // out by the implementation. Only passwd= and pwd= are reliably detected.

    @Test("detects password= assignment")
    func detectsPasswordEqualsValue() {
        let matches = detector.detect(in: "password=hunter2")
        #expect(!matches.isEmpty)
        #expect(matches.allSatisfy { $0.patternType == .password })
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

    @Test("detects quoted password= assignment")
    func detectsQuotedPasswordEquals() {
        let matches = detector.detect(in: #"password="myRealPassword""#)
        #expect(!matches.isEmpty)
    }

    // MARK: - Placeholder exclusions

    @Test("excludes placeholder value 'xxx'")
    func doesNotDetectPasswordEqualsXxx() {
        let matches = detector.detect(in: "passwd=xxx")
        #expect(matches.isEmpty)
    }

    @Test("excludes ${...} template placeholder")
    func doesNotDetectPasswordWithDollarBracePlaceholder() {
        let matches = detector.detect(in: "password=${MY_PASSWORD}")
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

    // MARK: - Additional keywords (pw, pass, Korean)

    @Test("detects pw= assignment")
    func detectsPwEqualsValue() {
        let matches = detector.detect(in: "pw=mysecret123")
        #expect(!matches.isEmpty)
    }

    @Test("detects pass= assignment")
    func detectsPassEqualsValue() {
        let matches = detector.detect(in: "pass=mysecret123")
        #expect(!matches.isEmpty)
    }

    @Test("detects 비밀번호= assignment")
    func detectsKoreanPasswordEquals() {
        let matches = detector.detect(in: "비밀번호=mySecret123")
        #expect(!matches.isEmpty)
    }

    @Test("detects 비번= assignment")
    func detectsKoreanShortPasswordEquals() {
        let matches = detector.detect(in: "비번=mySecret123")
        #expect(!matches.isEmpty)
    }

    @Test("detects 패스워드= assignment")
    func detectsKoreanLoanwordPasswordEquals() {
        let matches = detector.detect(in: "패스워드=mySecret123")
        #expect(!matches.isEmpty)
    }

    @Test("detects 비밀번호: with colon separator")
    func detectsKoreanPasswordColon() {
        let matches = detector.detect(in: "비밀번호: mySecret123")
        #expect(!matches.isEmpty)
    }

    // MARK: - Space separator

    @Test("detects password with space separator")
    func detectsPasswordWithSpaceSeparator() {
        let matches = detector.detect(in: "password mySecret123")
        #expect(!matches.isEmpty)
    }

    @Test("detects 비밀번호 with space separator")
    func detectsKoreanPasswordWithSpaceSeparator() {
        let matches = detector.detect(in: "비밀번호 mySecret123")
        #expect(!matches.isEmpty)
    }

    // MARK: - Placeholder exclusions (value-only check)

    @Test("excludes placeholder value 'changeme' even with password= prefix")
    func excludesChangemeWithPasswordPrefix() {
        let matches = detector.detect(in: "password=changeme")
        #expect(matches.isEmpty)
    }

    @Test("excludes placeholder value 'null'")
    func excludesNullValue() {
        let matches = detector.detect(in: "passwd=null")
        #expect(matches.isEmpty)
    }

    // MARK: - Edge cases

    @Test("empty input returns no matches")
    func emptyInputReturnsNoMatches() {
        #expect(detector.detect(in: "").isEmpty)
    }

    @Test("detects PASSWORD= case-insensitively")
    func detectsPasswordUppercase() {
        let matches = detector.detect(in: "PASSWORD=realSecret1")
        #expect(!matches.isEmpty)
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
