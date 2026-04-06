import Foundation

struct FilePathPatterns: PatternDefinition {
    let patternType: PatternType = .filePath

    private let patterns = [
        #"(?:/etc/(?:passwd|shadow|hosts|sudoers))"#,
        #"(?:~?/)?\.env(?:\.\w+)?"#,
        #"(?:~?/)?\.(aws|ssh|gnupg)/\S+"#,
        #"id_(?:rsa|dsa|ecdsa|ed25519)(?:\.pub)?"#,
        #"credentials\.json"#,
        #"\.pem\b"#,
        #"\.p12\b"#,
        #"\.keystore\b"#,
        #"kubeconfig"#,
        #"\.netrc"#,
        #"\.pgpass"#,
    ]

    func detect(in text: String) -> [SensitiveDataMatch] {
        var results: [SensitiveDataMatch] = []
        for pattern in patterns {
            results.append(contentsOf: buildMatches(from: matchesForRegex(pattern, in: text)))
        }
        return results
    }
}
