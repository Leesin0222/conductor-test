import Foundation

enum PatternType: String, CaseIterable, Identifiable {
    case apiKey = "API 키"
    case password = "비밀번호"
    case privateKey = "개인 키"
    case creditCard = "신용카드"
    case koreanRRN = "주민등록번호"
    case emailPassword = "이메일+비밀번호"
    case jwt = "JWT 토큰"
    case connectionString = "접속 문자열"
    case filePath = "파일 경로"
    case phoneNumber = "전화번호"
    case bankAccount = "계좌번호"
    case base64Secret = "Base64 시크릿"
    case custom = "사용자 정의"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .apiKey: return "key.fill"
        case .password: return "lock.fill"
        case .privateKey: return "key.horizontal.fill"
        case .creditCard: return "creditcard.fill"
        case .koreanRRN: return "person.text.rectangle.fill"
        case .emailPassword: return "envelope.badge.shield.half.filled.fill"
        case .jwt: return "ticket.fill"
        case .connectionString: return "server.rack"
        case .filePath: return "doc.fill"
        case .phoneNumber: return "phone.fill"
        case .bankAccount: return "banknote.fill"
        case .base64Secret: return "lock.doc.fill"
        case .custom: return "star.fill"
        }
    }

    var severity: Severity {
        switch self {
        case .koreanRRN, .privateKey, .creditCard: return .high
        case .apiKey, .password, .connectionString: return .medium
        case .emailPassword, .jwt, .filePath: return .medium
        case .phoneNumber, .bankAccount: return .high
        case .base64Secret: return .medium
        case .custom: return .medium
        }
    }
}

enum Severity: String, Comparable {
    case low, medium, high

    static func < (lhs: Severity, rhs: Severity) -> Bool {
        let order: [Severity] = [.low, .medium, .high]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }

    var color: String {
        switch self {
        case .low: return "yellow"
        case .medium: return "orange"
        case .high: return "red"
        }
    }
}

struct SensitiveDataMatch: Identifiable {
    let id = UUID()
    let patternType: PatternType
    let matchedSnippet: String
    let timestamp: Date
    var customPatternName: String?

    var severity: Severity { patternType.severity }

    var displayName: String {
        if let name = customPatternName {
            return "\(patternType.rawValue): \(name)"
        }
        return patternType.rawValue
    }

    static func redact(_ text: String) -> String {
        guard text.count > 8 else {
            return String(repeating: "*", count: text.count)
        }
        let prefix = text.prefix(4)
        let suffix = text.suffix(4)
        let masked = String(repeating: "*", count: min(text.count - 8, 12))
        return "\(prefix)\(masked)\(suffix)"
    }
}
