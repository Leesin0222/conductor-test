import SwiftUI

struct CustomPatternsView: View {
    @ObservedObject var manager: CustomPatternManager
    @State private var newName = ""
    @State private var newRegex = ""
    @State private var showError = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("커스텀 패턴")
                    .font(.headline)
                    .fontWeight(.semibold)

                // Add new pattern
                VStack(alignment: .leading, spacing: 6) {
                    TextField("패턴 이름", text: $newName)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 12))

                    TextField("정규식 (예: secret_\\w+)", text: $newRegex)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 12, design: .monospaced))

                    if showError {
                        Text("유효하지 않은 정규식이에요")
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    Button(action: addPattern) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("패턴 추가")
                        }
                        .font(.subheadline)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .disabled(newName.isEmpty || newRegex.isEmpty)
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color(.controlBackgroundColor)))

                Divider()

                // Pattern list
                if manager.patterns.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "star")
                            .font(.system(size: 24))
                            .foregroundColor(.secondary)
                        Text("아직 커스텀 패턴이 없어요")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                } else {
                    ForEach(manager.patterns) { pattern in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(pattern.name)
                                    .font(.system(size: 12, weight: .semibold))
                                Text(pattern.regex)
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer()

                            Toggle("", isOn: binding(for: pattern))
                                .labelsHidden()
                                .controlSize(.small)

                            Button(action: { remove(pattern) }) {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.controlBackgroundColor)))
                    }
                }
            }
            .padding(12)
        }
    }

    private func addPattern() {
        let test = CustomPattern(name: newName, regex: newRegex)
        if test.isValid {
            manager.add(name: newName, regex: newRegex)
            newName = ""
            newRegex = ""
            showError = false
        } else {
            showError = true
        }
    }

    private func remove(_ pattern: CustomPattern) {
        if let idx = manager.patterns.firstIndex(where: { $0.id == pattern.id }) {
            manager.patterns.remove(at: idx)
        }
    }

    private func binding(for pattern: CustomPattern) -> Binding<Bool> {
        Binding(
            get: { pattern.isEnabled },
            set: { enabled in
                if let idx = manager.patterns.firstIndex(where: { $0.id == pattern.id }) {
                    manager.patterns[idx].isEnabled = enabled
                }
            }
        )
    }
}
