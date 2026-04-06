import Testing
@testable import PerthCore

@Suite("Base64SecretPatterns")
struct Base64SecretPatternsTests {
    let detector = Base64SecretPatterns()

    // MARK: - Keyword + Base64 value

    @Test("detects password= with Base64 encoded value")
    func detectsPasswordWithBase64Value() {
        // "user:pass" in Base64
        let matches = detector.detect(in: "password=dXNlcjpwYXNz1234")
        #expect(!matches.isEmpty)
        #expect(matches.allSatisfy { $0.patternType == .base64Secret })
    }

    @Test("detects secret= with Base64 encoded value")
    func detectsSecretWithBase64Value() {
        let matches = detector.detect(in: "secret=c3VwZXJfc2VjcmV0X3ZhbHVl")
        #expect(!matches.isEmpty)
    }

    @Test("detects token= with Base64 encoded value")
    func detectsTokenWithBase64Value() {
        let matches = detector.detect(in: "token=YWJjZGVmZ2hpamtsbW5vcA==")
        #expect(!matches.isEmpty)
    }

    @Test("detects authorization= with Base64 encoded value")
    func detectsAuthorizationWithBase64Value() {
        let matches = detector.detect(in: "authorization=QmFzaWMgdXNlcjpwYXNz")
        #expect(!matches.isEmpty)
    }

    @Test("detects Korean keyword 비밀번호= with Base64 value")
    func detectsKoreanKeywordWithBase64() {
        let matches = detector.detect(in: "비밀번호=c3VwZXJfc2VjcmV0X3ZhbHVl")
        #expect(!matches.isEmpty)
    }

    // MARK: - Standalone Base64 decoding to sensitive content

    @Test("detects standalone Base64 that decodes to contain 'password'")
    func detectsStandaloneBase64WithPassword() {
        // "my_password=secret123" in Base64
        let encoded = "bXlfcGFzc3dvcmQ9c2VjcmV0MTIz"
        let matches = detector.detect(in: encoded)
        #expect(!matches.isEmpty)
    }

    @Test("detects standalone Base64 that decodes to contain 'api_key'")
    func detectsStandaloneBase64WithApiKey() {
        // "api_key=mysecretvalue" in Base64
        let encoded = "YXBpX2tleT1teXNlY3JldHZhbHVl"
        let matches = detector.detect(in: encoded)
        #expect(!matches.isEmpty)
    }

    // MARK: - Negative cases

    @Test("does not detect short Base64 value after keyword")
    func doesNotDetectShortBase64() {
        let matches = detector.detect(in: "password=abc")
        #expect(matches.isEmpty)
    }

    @Test("does not detect standalone Base64 without sensitive decoded content")
    func doesNotDetectInnocuousBase64() {
        // "hello world testing" in Base64
        let encoded = "aGVsbG8gd29ybGQgdGVzdGluZw=="
        let matches = detector.detect(in: encoded)
        #expect(matches.isEmpty)
    }

    @Test("empty input returns no matches")
    func emptyInputReturnsNoMatches() {
        #expect(detector.detect(in: "").isEmpty)
    }

    @Test("matched snippet is redacted")
    func matchedSnippetIsRedacted() {
        let matches = detector.detect(in: "secret=c3VwZXJfc2VjcmV0X3ZhbHVl")
        #expect(!matches.isEmpty)
        #expect(!matches[0].matchedSnippet.contains("c3VwZXJfc2VjcmV0X3ZhbHVl"))
    }
}
