import Foundation

struct BankAccountPatterns: PatternDefinition {
    let patternType: PatternType = .bankAccount

    // Korean bank account patterns by major banks
    // Format: keyword + account number pattern
    private let keywordPatterns = [
        // "계좌" or "계좌번호" followed by account-like number
        #"(?:계좌번호|계좌)\s*[:=]?\s*\d{2,4}[\s\-]?\d{2,6}[\s\-]?\d{2,8}"#,
        // "account" followed by number
        #"(?:account|acct)[\s_\-]*(?:no|num|number)?\s*[:=]?\s*\d{2,4}[\s\-]?\d{2,6}[\s\-]?\d{2,8}"#,
    ]

    // Known Korean bank account formats (with bank name prefix for accuracy)
    private let bankPatterns = [
        // KB국민: 3-2-7-2 or 6-2-6 format
        #"(?:국민|KB|kookmin)\s*[:=]?\s*\d{3}[\s\-]\d{2}[\s\-]\d{4,7}[\s\-]\d{2,3}"#,
        // 신한: 3-3-6 format
        #"(?:신한|shinhan)\s*[:=]?\s*\d{3}[\s\-]\d{3}[\s\-]\d{6}"#,
        // 우리: 4-3-6 format
        #"(?:우리|woori)\s*[:=]?\s*\d{4}[\s\-]\d{3}[\s\-]\d{6}"#,
        // 하나: 3-6-5 format
        #"(?:하나|hana|KEB)\s*[:=]?\s*\d{3}[\s\-]\d{6}[\s\-]\d{5}"#,
        // 카카오뱅크: 4-2-7 format
        #"(?:카카오|kakao)\s*[:=]?\s*\d{4}[\s\-]\d{2}[\s\-]\d{7}"#,
        // 토스뱅크: 4-4-4 format
        #"(?:토스|toss)\s*[:=]?\s*\d{4}[\s\-]\d{4}[\s\-]\d{4}"#,
        // NH농협: 3-4-4-2 or 3-2-6-2 format
        #"(?:농협|NH)\s*[:=]?\s*\d{3}[\s\-]\d{2,4}[\s\-]\d{4,6}[\s\-]\d{2}"#,
        // IBK기업: 3-6-2-3 format
        #"(?:기업|IBK)\s*[:=]?\s*\d{3}[\s\-]\d{6}[\s\-]\d{2}[\s\-]\d{3}"#,
    ]

    func detect(in text: String) -> [SensitiveDataMatch] {
        var results: [SensitiveDataMatch] = []
        for pattern in keywordPatterns + bankPatterns {
            results.append(contentsOf: buildMatches(from: matchesForRegex(pattern, in: text)))
        }
        return results
    }
}
