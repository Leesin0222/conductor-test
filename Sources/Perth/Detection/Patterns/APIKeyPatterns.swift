import Foundation

struct APIKeyPatterns: PatternDefinition {
    let patternType: PatternType = .apiKey

    private let patterns = [
        #"AKIA[0-9A-Z]{16}"#,                          // AWS Access Key
        #"ghp_[A-Za-z0-9]{36}"#,                        // GitHub Personal Token
        #"gho_[A-Za-z0-9]{36}"#,                        // GitHub OAuth Token
        #"ghu_[A-Za-z0-9]{36}"#,                        // GitHub User Token
        #"ghs_[A-Za-z0-9]{36}"#,                        // GitHub Server Token
        #"ghr_[A-Za-z0-9]{36}"#,                        // GitHub Refresh Token
        #"xox[bpsa]-[A-Za-z0-9\-]{10,}"#,               // Slack Token
        #"AIza[0-9A-Za-z\-_]{35}"#,                     // Google API Key
        #"sk-[A-Za-z0-9]{20}T3BlbkFJ[A-Za-z0-9]{20}"#, // OpenAI Key
        #"sk-(?:proj-)?[A-Za-z0-9_\-]{40,}"#,           // OpenAI newer format
        #"(?:api[_\-]?key|apikey)\s*[:=]\s*['"]?[A-Za-z0-9_\-]{16,}['"]?"#,
        #"(?:aws[_\-]?secret[_\-]?(?:access[_\-]?)?key|secret[_\-]?access[_\-]?key)\s*[:=]\s*['"]?[A-Za-z0-9/+=]{40}['"]?"#,
    ]

    func detect(in text: String) -> [SensitiveDataMatch] {
        var results: [SensitiveDataMatch] = []
        for pattern in patterns {
            results.append(contentsOf: buildMatches(from: matchesForRegex(pattern, in: text)))
        }
        return results
    }
}
