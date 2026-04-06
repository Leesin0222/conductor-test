import Testing
@testable import PerthCore

@Suite("PrivateKeyPatterns")
struct PrivateKeyPatternsTests {
    let detector = PrivateKeyPatterns()

    @Test("detects RSA private key header")
    func detectsRSAPrivateKeyHeader() {
        let matches = detector.detect(in: "-----BEGIN RSA PRIVATE KEY-----")
        #expect(!matches.isEmpty)
        #expect(matches.allSatisfy { $0.patternType == .privateKey })
    }

    @Test("detects EC private key header")
    func detectsECPrivateKeyHeader() {
        let matches = detector.detect(in: "-----BEGIN EC PRIVATE KEY-----")
        #expect(!matches.isEmpty)
    }

    @Test("detects DSA private key header")
    func detectsDSAPrivateKeyHeader() {
        let matches = detector.detect(in: "-----BEGIN DSA PRIVATE KEY-----")
        #expect(!matches.isEmpty)
    }

    @Test("detects OpenSSH private key header")
    func detectsOpenSSHPrivateKeyHeader() {
        let matches = detector.detect(in: "-----BEGIN OPENSSH PRIVATE KEY-----")
        #expect(!matches.isEmpty)
    }

    @Test("detects PGP private key block header")
    func detectsPGPPrivateKeyBlockHeader() {
        let matches = detector.detect(in: "-----BEGIN PGP PRIVATE KEY BLOCK-----")
        #expect(!matches.isEmpty)
    }

    @Test("detects generic PRIVATE KEY header without qualifier")
    func detectsGenericPrivateKeyHeader() {
        let matches = detector.detect(in: "-----BEGIN PRIVATE KEY-----")
        #expect(!matches.isEmpty)
    }

    @Test("detects private key header embedded in larger text")
    func detectsPrivateKeyEmbeddedInLargerText() {
        let text = """
        This is a config file.
        certificate = ...
        -----BEGIN RSA PRIVATE KEY-----
        MIIEowIBAAKCAQEA...
        -----END RSA PRIVATE KEY-----
        """
        let matches = detector.detect(in: text)
        #expect(!matches.isEmpty)
    }

    @Test("does not detect public key header")
    func doesNotDetectPublicKeyHeader() {
        let matches = detector.detect(in: "-----BEGIN PUBLIC KEY-----")
        #expect(matches.isEmpty)
    }

    @Test("does not detect certificate header")
    func doesNotDetectCertificateHeader() {
        let matches = detector.detect(in: "-----BEGIN CERTIFICATE-----")
        #expect(matches.isEmpty)
    }

    @Test("does not match END marker without a BEGIN marker")
    func doesNotDetectEndPrivateKeyMarker() {
        let matches = detector.detect(in: "-----END RSA PRIVATE KEY-----")
        #expect(matches.isEmpty)
    }

    @Test("empty input returns no matches")
    func emptyInputReturnsNoMatches() {
        #expect(detector.detect(in: "").isEmpty)
    }
}
