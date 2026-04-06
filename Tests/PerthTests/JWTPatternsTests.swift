import Testing
@testable import PerthCore

@Suite("JWTPatterns")
struct JWTPatternsTests {
    let detector = JWTPatterns()

    let validJWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"

    // MARK: - True positives

    @Test("detects a well-formed JWT token")
    func detectsWellFormedJWT() {
        let matches = detector.detect(in: validJWT)
        #expect(!matches.isEmpty)
        #expect(matches.allSatisfy { $0.patternType == .jwt })
    }

    @Test("detects JWT in Authorization Bearer header")
    func detectsJWTEmbeddedInAuthorizationHeader() {
        let text = "Authorization: Bearer \(validJWT)"
        let matches = detector.detect(in: text)
        #expect(!matches.isEmpty)
    }

    @Test("detects JWT embedded in surrounding text")
    func detectsJWTEmbeddedInLargerText() {
        let text = "token=\(validJWT) stored in config"
        let matches = detector.detect(in: text)
        #expect(!matches.isEmpty)
    }

    @Test("detects JWT with URL-safe base64 chars (- and _) in signature")
    func detectsJWTWithUnderscoreAndDashInSignature() {
        let jwt = "eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJ1c2VyIn0.abc-def_ghi"
        let matches = detector.detect(in: jwt)
        #expect(!matches.isEmpty)
    }

    // MARK: - True negatives

    @Test("does not detect header.payload without a signature segment")
    func doesNotDetectTwoPartBase64WithoutThirdSegment() {
        let text = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1c2VyIn0"
        let matches = detector.detect(in: text)
        #expect(matches.isEmpty)
    }

    @Test("does not detect a random base64 string as JWT")
    func doesNotDetectRandomBase64String() {
        let matches = detector.detect(in: "aGVsbG8gd29ybGQ=")
        #expect(matches.isEmpty)
    }

    @Test("does not detect JWT where payload segment does not start with eyJ")
    func doesNotDetectPayloadSegmentNotStartingWithEyJ() {
        let matches = detector.detect(in: "eyJhbGciOiJIUzI1NiJ9.notAJWTpayload.signature")
        #expect(matches.isEmpty)
    }

    @Test("empty input returns no matches")
    func doesNotDetectEmptyString() {
        #expect(detector.detect(in: "").isEmpty)
    }

    // MARK: - Redaction

    @Test("JWT snippet is redacted, not returned verbatim")
    func matchedSnippetIsRedacted() {
        let matches = detector.detect(in: validJWT)
        #expect(!matches.isEmpty)
        #expect(matches[0].matchedSnippet != validJWT)
    }
}
