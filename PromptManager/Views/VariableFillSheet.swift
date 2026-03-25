import SwiftUI

/// A sheet that appears when running/copying a prompt that contains `{{variables}}`.
/// Shows a text field for each variable so the user can fill in values before executing.
struct VariableFillSheet: View {
    let prompt: Prompt
    let variableNames: [String]
    let action: Action
    let onSubmit: (String) -> Void  // resolved full command
    let onCancel: () -> Void
    
    @State private var values: [String: String] = [:]
    @State private var lastUsedValues: [String: String] = [:]
    
    enum Action {
        case run
        case copyCommand
        case copyPromptOnly
        
        var title: String {
            switch self {
            case .run: return "Run in Terminal"
            case .copyCommand: return "Copy Command"
            case .copyPromptOnly: return "Copy Prompt"
            }
        }
        
        var icon: String {
            switch self {
            case .run: return "play.fill"
            case .copyCommand: return "doc.on.doc"
            case .copyPromptOnly: return "doc.on.clipboard"
            }
        }
    }
    
    init(prompt: Prompt, action: Action, onSubmit: @escaping (String) -> Void, onCancel: @escaping () -> Void) {
        self.prompt = prompt
        self.variableNames = prompt.variables
        self.action = action
        self.onSubmit = onSubmit
        self.onCancel = onCancel
    }
    
    private var allFilled: Bool {
        variableNames.allSatisfy { name in
            guard let val = values[name] else { return false }
            return !val.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }
    
    private var resolvedPreview: String {
        let resolvedBody = prompt.resolvedBody(with: values)
        switch action {
        case .copyPromptOnly:
            return resolvedBody
        default:
            let trimmed = resolvedBody.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                return prompt.command
            }
            return "\(prompt.command) \(resolvedBody)"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "variable")
                    .font(.title2)
                    .foregroundStyle(.orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Fill Variables")
                        .font(.title3.bold())
                    Text(prompt.title)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            
            Divider()
            
            // Variable fields
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(variableNames, id: \.self) { name in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left.forwardslash.chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                                Text(name)
                                    .font(.headline)
                            }
                            
                            TextField("Enter value for \(name)...", text: binding(for: name))
                                .textFieldStyle(.roundedBorder)
                                .font(.body.monospaced())
                        }
                    }
                }
            }
            .frame(maxHeight: 300)
            
            // Preview
            VStack(alignment: .leading, spacing: 6) {
                Text("Preview")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(resolvedPreview)
                    .font(.system(.caption, design: .monospaced))
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.black.opacity(0.85))
                    .foregroundStyle(.green)
                    .cornerRadius(6)
                    .lineLimit(5)
            }
            
            Divider()
            
            // Actions
            HStack {
                Button("Cancel") {
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button {
                    onSubmit(resolvedPreview)
                } label: {
                    Label(action.title, systemImage: action.icon)
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(!allFilled)
            }
        }
        .padding(20)
        .frame(width: 480, height: min(CGFloat(200 + variableNames.count * 70), 550))
        .onAppear {
            // Initialize empty values
            for name in variableNames {
                values[name] = ""
            }
        }
    }
    
    private func binding(for name: String) -> Binding<String> {
        Binding(
            get: { values[name] ?? "" },
            set: { values[name] = $0 }
        )
    }
}
