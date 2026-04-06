import Testing
import Foundation
@testable import PerthCore

@Suite("SensitiveDataMatch")
struct SensitiveDataMatchTests {

    // MARK: - redact(_:)

    @Test("fully masks string of 6 chars (8 or fewer)")
    func redactReturnsAllStarsForShortText() {
        #expect(SensitiveDataMatch.redact("secret") == "******")
    }

    @Test("fully masks string of exactly 8 chars")
    func redactReturnsAllStarsForExactly8Chars() {
        #expect(SensitiveDataMatch.redact("12345678") == "********")
    }

    @Test("preserves first 4 chars for string longer than 8 chars")
    func redactPreservesFirstFourCharsForLongText() {
        let result = SensitiveDataMatch.redact("AKIAIOSFODNN7EXAMPLE")
        #expect(result.hasPrefix("AKIA"))
    }

    @Test("preserves last 4 chars for string longer than 8 chars")
    func redactPreservesLastFourCharsForLongText() {
        let result = SensitiveDataMatch.redact("AKIAIOSFODNN7EXAMPLE")
        #expect(result.hasSuffix("MPLE"))
    }

    @Test("middle section of redacted string contains only asterisks")
    func redactContainsMaskedMiddleSection() {
        let result = SensitiveDataMatch.redact("AKIAIOSFODNN7EXAMPLE")
        let middle = result.dropFirst(4).dropLast(4)
        #expect(middle.allSatisfy { $0 == "*" })
    }

    @Test("masked middle section is capped at 12 asterisks for very long strings")
    func redactCapsMaskedSectionAtTwelveStars() {
        let longText = String(repeating: "A", count: 50)
        let result = SensitiveDataMatch.redact(longText)
        let middle = String(result.dropFirst(4).dropLast(4))
        #expect(middle.count == 12)
    }

    @Test("9-char string produces exactly 1 star in middle")
    func redactNineCharStringHasOneStarInMiddle() {
        #expect(SensitiveDataMatch.redact("123456789") == "1234*6789")
    }

    // MARK: - SensitiveDataMatch properties

    @Test("match reports correct patternType")
    func matchHasCorrectPatternType() {
        let match = SensitiveDataMatch(patternType: .apiKey, matchedSnippet: "AKIA****MPLE", timestamp: Date())
        #expect(match.patternType == .apiKey)
    }

    @Test("match severity reflects its patternType")
    func matchSeverityReflectsPatternType() {
        let high = SensitiveDataMatch(patternType: .creditCard, matchedSnippet: "****", timestamp: Date())
        #expect(high.severity == .high)
        let medium = SensitiveDataMatch(patternType: .apiKey, matchedSnippet: "****", timestamp: Date())
        #expect(medium.severity == .medium)
    }

    @Test("displayName without customPatternName returns rawValue of patternType")
    func displayNameWithNoCustomNameReturnsRawValue() {
        let match = SensitiveDataMatch(patternType: .apiKey, matchedSnippet: "****", timestamp: Date())
        #expect(match.displayName == PatternType.apiKey.rawValue)
    }

    @Test("displayName with customPatternName includes both patternType and name")
    func displayNameWithCustomNameIncludesPatternTypeAndName() {
        var match = SensitiveDataMatch(patternType: .custom, matchedSnippet: "****", timestamp: Date())
        match.customPatternName = "My Rule"
        #expect(match.displayName == "\(PatternType.custom.rawValue): My Rule")
    }

    @Test("each match gets a unique UUID")
    func matchHasUniqueIDs() {
        let m1 = SensitiveDataMatch(patternType: .jwt, matchedSnippet: "****", timestamp: Date())
        let m2 = SensitiveDataMatch(patternType: .jwt, matchedSnippet: "****", timestamp: Date())
        #expect(m1.id != m2.id)
    }

    // MARK: - Severity ordering

    @Test("high severity is greater than medium")
    func highSeverityIsGreaterThanMedium() {
        #expect(Severity.high > Severity.medium)
    }

    @Test("medium severity is greater than low")
    func mediumSeverityIsGreaterThanLow() {
        #expect(Severity.medium > Severity.low)
    }

    @Test("privateKey pattern type has high severity")
    func privateKeyIsHighSeverity() {
        #expect(PatternType.privateKey.severity == .high)
    }

    @Test("koreanRRN pattern type has high severity")
    func koreanRRNIsHighSeverity() {
        #expect(PatternType.koreanRRN.severity == .high)
    }
}
