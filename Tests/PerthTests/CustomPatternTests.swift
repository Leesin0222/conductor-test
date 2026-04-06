import Testing
import Foundation
@testable import PerthCore

@Suite("CustomPattern")
@MainActor
struct CustomPatternTests {

    // MARK: - CustomPattern.isValid

    @Test("pattern with valid regex is marked valid")
    func customPatternIsValidForCorrectRegex() {
        let pattern = CustomPattern(name: "SSN", regex: #"\d{3}-\d{2}-\d{4}"#)
        #expect(pattern.isValid)
    }

    @Test("pattern with malformed regex is marked invalid")
    func customPatternIsInvalidForMalformedRegex() {
        let pattern = CustomPattern(name: "Bad", regex: "[invalid(")
        #expect(!pattern.isValid)
    }

    @Test("empty regex is invalid because NSRegularExpression rejects empty pattern on this platform")
    func customPatternIsInvalidForEmptyRegex() {
        let pattern = CustomPattern(name: "Empty", regex: "")
        #expect(!pattern.isValid)
    }

    @Test("custom pattern defaults to enabled")
    func customPatternDefaultsToEnabled() {
        let pattern = CustomPattern(name: "Test", regex: #"\d+"#)
        #expect(pattern.isEnabled)
    }

    // MARK: - CustomPatternManager.detect

    @Test("manager detects match for enabled pattern")
    func managerDetectsMatchForEnabledPattern() {
        let manager = CustomPatternManager()
        manager.patterns = [CustomPattern(name: "Digits", regex: #"\d{5}"#, isEnabled: true)]
        let matches = manager.detect(in: "zip code 90210 here")
        #expect(!matches.isEmpty)
        #expect(matches[0].patternType == .custom)
    }

    @Test("manager skips disabled pattern")
    func managerSkipsDisabledPattern() {
        let manager = CustomPatternManager()
        manager.patterns = [CustomPattern(name: "Digits", regex: #"\d{5}"#, isEnabled: false)]
        let matches = manager.detect(in: "zip code 90210 here")
        #expect(matches.isEmpty)
    }

    @Test("manager detects multiple matches in text")
    func managerDetectsMultipleMatchesInText() {
        let manager = CustomPatternManager()
        manager.patterns = [CustomPattern(name: "Hex", regex: #"0x[0-9a-fA-F]+"#, isEnabled: true)]
        let matches = manager.detect(in: "values: 0xDEAD and 0xBEEF")
        #expect(matches.count == 2)
    }

    @Test("manager sets customPatternName on matched result")
    func managerSetsCustomPatternNameOnMatch() {
        let manager = CustomPatternManager()
        manager.patterns = [CustomPattern(name: "Internal Token", regex: #"INT-[A-Z]{6}"#, isEnabled: true)]
        let matches = manager.detect(in: "token INT-ABCDEF issued")
        #expect(!matches.isEmpty)
        #expect(matches[0].customPatternName == "Internal Token")
    }

    @Test("manager matched snippet is redacted")
    func managerMatchedSnippetIsRedacted() {
        let manager = CustomPatternManager()
        manager.patterns = [CustomPattern(name: "Long Secret", regex: #"SECRET-[A-Z0-9]{16}"#, isEnabled: true)]
        let secret = "SECRET-ABCDEF1234567890"
        let matches = manager.detect(in: secret)
        #expect(!matches.isEmpty)
        #expect(matches[0].matchedSnippet != secret)
    }

    @Test("manager returns no matches when pattern list is empty")
    func managerReturnsNoMatchesForEmptyPatternList() {
        let manager = CustomPatternManager()
        manager.patterns = []
        #expect(manager.detect(in: "some text 12345").isEmpty)
    }

    @Test("manager returns no matches for empty input")
    func managerReturnsNoMatchesForEmptyInput() {
        let manager = CustomPatternManager()
        manager.patterns = [CustomPattern(name: "Any", regex: #"\w+"#, isEnabled: true)]
        #expect(manager.detect(in: "").isEmpty)
    }

    // MARK: - CustomPatternManager.add

    @Test("add with valid regex appends pattern to list")
    func addValidPatternAppendsToList() {
        let manager = CustomPatternManager()
        manager.patterns = []
        manager.add(name: "Phone", regex: #"\d{3}-\d{4}"#)
        #expect(manager.patterns.count == 1)
        #expect(manager.patterns[0].name == "Phone")
    }

    @Test("add with invalid regex is rejected and list stays empty")
    func addInvalidPatternIsRejected() {
        let manager = CustomPatternManager()
        manager.patterns = []
        manager.add(name: "Bad", regex: "[unclosed")
        #expect(manager.patterns.isEmpty)
    }

    // MARK: - CustomPatternManager.remove

    @Test("remove at index set removes the correct pattern")
    func removePatternAtIndexSet() {
        let manager = CustomPatternManager()
        manager.patterns = [
            CustomPattern(name: "A", regex: #"\d"#),
            CustomPattern(name: "B", regex: #"\w"#),
        ]
        manager.remove(at: IndexSet([0]))
        #expect(manager.patterns.count == 1)
        #expect(manager.patterns[0].name == "B")
    }
}
