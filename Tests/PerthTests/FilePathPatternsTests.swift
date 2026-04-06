import Testing
@testable import PerthCore

@Suite("FilePathPatterns")
struct FilePathPatternsTests {
    let detector = FilePathPatterns()

    // MARK: - /etc system files

    @Test("detects /etc/passwd reference")
    func detectsEtcPasswd() {
        let matches = detector.detect(in: "/etc/passwd")
        #expect(!matches.isEmpty)
        #expect(matches.allSatisfy { $0.patternType == .filePath })
    }

    @Test("detects /etc/shadow reference")
    func detectsEtcShadow() {
        #expect(!detector.detect(in: "/etc/shadow").isEmpty)
    }

    @Test("detects /etc/sudoers reference")
    func detectsEtcSudoers() {
        #expect(!detector.detect(in: "/etc/sudoers").isEmpty)
    }

    @Test("detects /etc/hosts reference")
    func detectsEtcHosts() {
        #expect(!detector.detect(in: "/etc/hosts").isEmpty)
    }

    // MARK: - .env files

    @Test("detects .env file reference")
    func detectsDotEnvFile() {
        #expect(!detector.detect(in: ".env").isEmpty)
    }

    @Test("detects .env.production file reference")
    func detectsDotEnvWithSuffix() {
        #expect(!detector.detect(in: ".env.production").isEmpty)
    }

    @Test("detects absolute path to .env file")
    func detectsDotEnvWithAbsolutePath() {
        #expect(!detector.detect(in: "/home/user/.env").isEmpty)
    }

    // MARK: - SSH / AWS credential directories

    @Test("detects ~/.ssh/ path")
    func detectsDotSshDirectory() {
        #expect(!detector.detect(in: "~/.ssh/id_rsa").isEmpty)
    }

    @Test("detects ~/.aws/ path")
    func detectsDotAwsDirectory() {
        #expect(!detector.detect(in: "~/.aws/credentials").isEmpty)
    }

    @Test("detects ~/.gnupg/ path")
    func detectsDotGnupgDirectory() {
        #expect(!detector.detect(in: "~/.gnupg/secring.gpg").isEmpty)
    }

    // MARK: - SSH key file names

    @Test("detects id_rsa key filename")
    func detectsIdRsaKeyFile() {
        #expect(!detector.detect(in: "id_rsa").isEmpty)
    }

    @Test("detects id_ecdsa key filename")
    func detectsIdEcdsaKeyFile() {
        #expect(!detector.detect(in: "id_ecdsa").isEmpty)
    }

    @Test("detects id_ed25519 key filename")
    func detectsIdEd25519KeyFile() {
        #expect(!detector.detect(in: "id_ed25519").isEmpty)
    }

    @Test("detects id_rsa.pub public key filename")
    func detectsIdRsaPubKeyFile() {
        #expect(!detector.detect(in: "id_rsa.pub").isEmpty)
    }

    // MARK: - Certificate and keystore files

    @Test("detects credentials.json filename")
    func detectsCredentialsJsonFile() {
        #expect(!detector.detect(in: "credentials.json").isEmpty)
    }

    @Test("detects .pem file reference")
    func detectsPemFile() {
        #expect(!detector.detect(in: "server.pem").isEmpty)
    }

    @Test("detects .p12 file reference")
    func detectsP12File() {
        #expect(!detector.detect(in: "certificate.p12").isEmpty)
    }

    @Test("detects .keystore file reference")
    func detectsKeystoreFile() {
        #expect(!detector.detect(in: "app.keystore").isEmpty)
    }

    @Test("detects kubeconfig reference")
    func detectsKubeconfigFile() {
        #expect(!detector.detect(in: "kubeconfig").isEmpty)
    }

    @Test("detects .netrc file reference")
    func detectsNetrcFile() {
        #expect(!detector.detect(in: ".netrc").isEmpty)
    }

    @Test("detects .pgpass file reference")
    func detectsPgpassFile() {
        #expect(!detector.detect(in: ".pgpass").isEmpty)
    }

    // MARK: - True negatives

    @Test("does not detect a normal document path")
    func doesNotDetectNormalTextFilePath() {
        #expect(detector.detect(in: "/home/user/documents/report.pdf").isEmpty)
    }

    @Test("does not detect a normal source code path")
    func doesNotDetectNormalSourceCodePath() {
        #expect(detector.detect(in: "/Users/dev/project/src/main.swift").isEmpty)
    }

    @Test("empty input returns no matches")
    func emptyInputReturnsNoMatches() {
        #expect(detector.detect(in: "").isEmpty)
    }
}
