import Testing
@testable import PerthCore

@Suite("APIKeyPatterns")
struct APIKeyPatternsTests {
    let detector = APIKeyPatterns()

    // Build token strings via concatenation to avoid GitHub push protection false positives
    private static let slackBotToken = "xoxb" + "-000000000000-000000000000-fakefakefakefake"
    private static let slackUserToken = "xoxp" + "-000000000000-000000000000-fakefakefakefake"
    private static let openAIClassic = "sk-fakefakefakefakefa" + "T3BlbkFJ" + "fakefakefakefakefake"
    private static let openAIProj = "sk-proj" + "-fakefakefakefakefakefakefakeFAKEFAKEFAKE"
    private static let openAILong = "sk-fakefakefakefake" + "fakefakefakeFAKEFAKEFAKEFAKEFA"

    // MARK: - AWS Access Key

    @Test("detects AWS access key")
    func detectsAWSAccessKey() {
        let matches = detector.detect(in: "AKIAIOSFODNN7EXAMPLE")
        #expect(!matches.isEmpty)
        #expect(matches.allSatisfy { $0.patternType == .apiKey })
    }

    @Test("does not detect AKIA with fewer than 16 trailing chars")
    func doesNotDetectShortAWSLikePrefix() {
        let matches = detector.detect(in: "AKIA123")
        #expect(matches.isEmpty)
    }

    // MARK: - GitHub Tokens

    @Test("detects GitHub personal access token (ghp_)")
    func detectsGitHubPersonalAccessToken() {
        let matches = detector.detect(in: "ghp_abcdefghijklmnopqrstuvwxyz1234567890")
        #expect(!matches.isEmpty)
    }

    @Test("detects GitHub OAuth token (gho_)")
    func detectsGitHubOAuthToken() {
        let matches = detector.detect(in: "gho_abcdefghijklmnopqrstuvwxyz1234567890")
        #expect(!matches.isEmpty)
    }

    @Test("detects GitHub user token (ghu_)")
    func detectsGitHubUserToken() {
        let matches = detector.detect(in: "ghu_abcdefghijklmnopqrstuvwxyz1234567890")
        #expect(!matches.isEmpty)
    }

    @Test("detects GitHub server token (ghs_)")
    func detectsGitHubServerToken() {
        let matches = detector.detect(in: "ghs_abcdefghijklmnopqrstuvwxyz1234567890")
        #expect(!matches.isEmpty)
    }

    @Test("detects GitHub refresh token (ghr_)")
    func detectsGitHubRefreshToken() {
        let matches = detector.detect(in: "ghr_abcdefghijklmnopqrstuvwxyz1234567890")
        #expect(!matches.isEmpty)
    }

    @Test("does not detect GitHub token with insufficient length (< 36 chars after prefix)")
    func doesNotDetectGitHubTokenWithWrongLength() {
        let matches = detector.detect(in: "ghp_abcdefghij")
        #expect(matches.isEmpty)
    }

    // MARK: - Slack Token

    @Test("detects Slack bot token (xoxb-)")
    func detectsSlackBotToken() {
        let matches = detector.detect(in: Self.slackBotToken)
        #expect(!matches.isEmpty)
    }

    @Test("detects Slack user token (xoxp-)")
    func detectsSlackUserToken() {
        let matches = detector.detect(in: Self.slackUserToken)
        #expect(!matches.isEmpty)
    }

    @Test("does not detect Slack token with body shorter than 10 chars")
    func doesNotDetectSlackTokenWithShortBody() {
        let matches = detector.detect(in: "xoxb-abc")
        #expect(matches.isEmpty)
    }

    // MARK: - Google API Key

    @Test("detects Google API key (AIza...)")
    func detectsGoogleAPIKey() {
        let matches = detector.detect(in: "AIzaSyD-abcdefghijklmnopqrstuvwxyz12345")
        #expect(!matches.isEmpty)
    }

    @Test("does not detect AIza with fewer than 35 trailing chars")
    func doesNotDetectShortGoogleKeyLike() {
        let matches = detector.detect(in: "AIzaShort")
        #expect(matches.isEmpty)
    }

    // MARK: - OpenAI Key

    @Test("detects OpenAI key in classic format (sk-...T3BlbkFJ...)")
    func detectsOpenAIKeyClassicFormat() {
        let matches = detector.detect(in: Self.openAIClassic)
        #expect(!matches.isEmpty)
    }

    @Test("detects OpenAI key in newer proj format (sk-proj-...)")
    func detectsOpenAIKeyNewerFormat() {
        let matches = detector.detect(in: Self.openAIProj)
        #expect(!matches.isEmpty)
    }

    @Test("detects OpenAI key without proj prefix with 40+ chars")
    func detectsOpenAIKeyWithoutProjPrefix() {
        let matches = detector.detect(in: Self.openAILong)
        #expect(!matches.isEmpty)
    }

    // MARK: - Generic api_key

    @Test("detects generic api_key= assignment with 16+ char value")
    func detectsGenericApiKeyAssignment() {
        let matches = detector.detect(in: "api_key=supersecretvalue1234567890")
        #expect(!matches.isEmpty)
    }

    @Test("detects apikey: assignment with 16+ char value")
    func detectsApiKeyWithColonSeparator() {
        let matches = detector.detect(in: "apikey: supersecretvalue1234567890")
        #expect(!matches.isEmpty)
    }

    @Test("does not detect api_key with value shorter than 16 chars")
    func doesNotDetectApiKeyTooShort() {
        let matches = detector.detect(in: "api_key=tooshort")
        #expect(matches.isEmpty)
    }

    // MARK: - Redaction

    @Test("matched snippet is redacted, not the raw key")
    func matchedSnippetIsRedacted() {
        let text = "AKIAIOSFODNN7EXAMPLE"
        let matches = detector.detect(in: text)
        #expect(!matches.isEmpty)
        #expect(matches[0].matchedSnippet != text)
    }

    @Test("empty input returns no matches")
    func emptyInputReturnsNoMatches() {
        #expect(detector.detect(in: "").isEmpty)
    }
}
