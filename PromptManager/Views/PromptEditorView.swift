import SwiftUI
import SwiftData

struct PromptEditorView: View {
    @Bindable var prompt: Prompt
    @Environment(\.modelContext) private var modelContext
    @State private var showCopiedToast = false
    @State private var showRunToast = false
    @State private var selectedCommandTemplate: CommandTemplate?
    @State private var showVariableSheet = false
    @State private var variableSheetAction: VariableFillSheet.Action = .run
    @State private var newVariableName = ""
    @State private var showAddVariable = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with actions
                HStack(spacing: 12) {
                    // Favorite toggle
                    Button {
                        prompt.isFavorite.toggle()
                        prompt.updatedAt = Date()
                    } label: {
                        Image(systemName: prompt.isFavorite ? "star.fill" : "star")
                            .foregroundStyle(prompt.isFavorite ? .yellow : .gray)
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                    .help(prompt.isFavorite ? "Remove from favorites" : "Add to favorites")
                    
                    Spacer()
                    
                    // Usage count
                    if prompt.usageCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.caption)
                            Text("Used \(prompt.usageCount) time\(prompt.usageCount == 1 ? "" : "s")")
                                .font(.caption)
                        }
                        .foregroundStyle(.tertiary)
                    }
                    
                    // Copy button
                    Button {
                        if prompt.hasVariables {
                            variableSheetAction = .copyCommand
                            showVariableSheet = true
                        } else {
                            CommandExecutor.copyToClipboard(prompt.fullCommand)
                            showToast(copied: true)
                        }
                    } label: {
                        Label("Copy Command", systemImage: "doc.on.doc")
                    }
                    .help("Copy full command to clipboard (Cmd+Shift+C)")
                    .keyboardShortcut("c", modifiers: [.command, .shift])
                    
                    // Run button
                    Button {
                        if prompt.hasVariables {
                            variableSheetAction = .run
                            showVariableSheet = true
                        } else {
                            CommandExecutor.runInTerminal(prompt.fullCommand)
                            prompt.usageCount += 1
                            prompt.updatedAt = Date()
                            showToast(copied: false)
                        }
                    } label: {
                        Label("Run", systemImage: "play.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .help("Run in Terminal (Cmd+R)")
                    .keyboardShortcut("r", modifiers: .command)
                }
                
                // Toast notifications
                if showCopiedToast {
                    toastView(text: "Copied to clipboard!", icon: "checkmark.circle.fill")
                }
                
                if showRunToast {
                    toastView(text: "Opened in Terminal!", icon: "checkmark.circle.fill")
                }
                
                // Title
                VStack(alignment: .leading, spacing: 6) {
                    Text("Title")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    TextField("Prompt title", text: $prompt.title)
                        .textFieldStyle(.roundedBorder)
                        .font(.title3)
                        .onChange(of: prompt.title) {
                            prompt.updatedAt = Date()
                        }
                }
                
                // Command
                VStack(alignment: .leading, spacing: 6) {
                    Text("Command")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 8) {
                        ForEach(CommandTemplate.builtIn) { template in
                            Button {
                                if template.name != "Custom" {
                                    prompt.command = template.command
                                    prompt.updatedAt = Date()
                                }
                                selectedCommandTemplate = template
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: template.icon)
                                        .font(.title3)
                                    Text(template.name)
                                        .font(.caption)
                                        .lineLimit(1)
                                }
                                .frame(width: 70, height: 52)
                                .background(
                                    prompt.command == template.command || (selectedCommandTemplate?.name == "Custom" && template.name == "Custom")
                                        ? Color.accentColor.opacity(0.15)
                                        : Color.gray.opacity(0.08)
                                )
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            prompt.command == template.command || (selectedCommandTemplate?.name == "Custom" && template.name == "Custom")
                                                ? Color.accentColor
                                                : Color.clear,
                                            lineWidth: 1.5
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    // Custom command field
                    HStack {
                        Image(systemName: "terminal")
                            .foregroundStyle(.secondary)
                        TextField("Command", text: $prompt.command)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                            .onChange(of: prompt.command) {
                                prompt.updatedAt = Date()
                            }
                    }
                    .padding(.top, 4)
                }
                
                // Category
                VStack(alignment: .leading, spacing: 6) {
                    Text("Category")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Picker("Category", selection: $prompt.category) {
                        ForEach(PromptCategory.defaults, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 200)
                    .onChange(of: prompt.category) {
                        prompt.updatedAt = Date()
                    }
                }
                
                // Prompt body with variable insertion
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Prompt")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        // Insert variable button
                        Button {
                            showAddVariable.toggle()
                        } label: {
                            Label("Insert Variable", systemImage: "curlybraces")
                                .font(.caption)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.orange)
                        
                        Button {
                            CommandExecutor.copyToClipboard(prompt.body)
                            showToast(copied: true)
                        } label: {
                            Label("Copy Prompt Only", systemImage: "doc.on.clipboard")
                                .font(.caption)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                    }
                    
                    // Add variable inline
                    if showAddVariable {
                        HStack(spacing: 8) {
                            Image(systemName: "curlybraces")
                                .foregroundStyle(.orange)
                            TextField("Variable name (e.g. filename)", text: $newVariableName)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(.body, design: .monospaced))
                                .onSubmit {
                                    insertVariable()
                                }
                            Button("Insert") {
                                insertVariable()
                            }
                            .disabled(newVariableName.trimmingCharacters(in: .whitespaces).isEmpty)
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                            
                            Button {
                                showAddVariable = false
                                newVariableName = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(8)
                        .background(Color.orange.opacity(0.08))
                        .cornerRadius(8)
                    }
                    
                    TextEditor(text: $prompt.body)
                        .font(.body.monospaced())
                        .frame(minHeight: 200)
                        .padding(8)
                        .background(Color(nsColor: .textBackgroundColor))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .onChange(of: prompt.body) {
                            prompt.updatedAt = Date()
                        }
                    
                    // Detected variables chips
                    if !prompt.variables.isEmpty {
                        VariableChipsView(variables: prompt.variables) { varName in
                            // Quick-insert tapped variable again
                            prompt.body.append(" {{\(varName)}}")
                            prompt.updatedAt = Date()
                        }
                    }
                }
                
                // Command Preview
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Command Preview")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        if prompt.hasVariables {
                            Text("(contains variables)")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }
                    
                    HighlightedCommandPreview(text: prompt.fullCommand)
                }
                
                // Metadata
                HStack {
                    Text("Created: \(prompt.createdAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Spacer()
                    Text("Updated: \(prompt.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.top, 8)
            }
            .padding(24)
        }
        .animation(.easeInOut(duration: 0.2), value: showCopiedToast)
        .animation(.easeInOut(duration: 0.2), value: showRunToast)
        .animation(.easeInOut(duration: 0.2), value: showAddVariable)
        .sheet(isPresented: $showVariableSheet) {
            VariableFillSheet(
                prompt: prompt,
                action: variableSheetAction,
                onSubmit: { resolvedText in
                    showVariableSheet = false
                    switch variableSheetAction {
                    case .run:
                        CommandExecutor.runInTerminal(resolvedText)
                        prompt.usageCount += 1
                        prompt.updatedAt = Date()
                        showToast(copied: false)
                    case .copyCommand:
                        CommandExecutor.copyToClipboard(resolvedText)
                        showToast(copied: true)
                    case .copyPromptOnly:
                        CommandExecutor.copyToClipboard(resolvedText)
                        showToast(copied: true)
                    }
                },
                onCancel: {
                    showVariableSheet = false
                }
            )
        }
    }
    
    // MARK: - Helpers
    
    private func insertVariable() {
        let name = newVariableName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        prompt.body.append(" {{\(name)}}")
        prompt.updatedAt = Date()
        newVariableName = ""
        showAddVariable = false
    }
    
    private func showToast(copied: Bool) {
        if copied {
            showCopiedToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showCopiedToast = false }
        } else {
            showRunToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showRunToast = false }
        }
    }
    
    private func toastView(text: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.green)
            Text(text)
                .font(.subheadline)
        }
        .padding(10)
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

// MARK: - Variable Chips (shows detected variables as tappable badges)

struct VariableChipsView: View {
    let variables: [String]
    let onTap: (String) -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: "variable")
                .font(.caption)
                .foregroundStyle(.orange)
                .padding(.trailing, 6)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(variables, id: \.self) { name in
                        Button {
                            onTap(name)
                        } label: {
                            HStack(spacing: 3) {
                                Text("{{\(name)}}")
                                    .font(.caption.monospaced())
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.12))
                            .foregroundStyle(.orange)
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .help("Click to insert {{\(name)}} again")
                    }
                }
            }
        }
        .padding(.top, 4)
    }
}

// MARK: - Highlighted Command Preview (variables shown in orange)

struct HighlightedCommandPreview: View {
    let text: String
    
    var body: some View {
        let parts = splitByVariables(text)
        
        HStack(spacing: 0) {
            FlowText(parts: parts)
        }
        .font(.system(.body, design: .monospaced))
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.85))
        .cornerRadius(8)
        .textSelection(.enabled)
    }
    
    private func splitByVariables(_ text: String) -> [(String, Bool)] {
        let pattern = #"\{\{[^}]+\}\}"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return [(text, false)]
        }
        
        var parts: [(String, Bool)] = []
        var lastEnd = text.startIndex
        let nsRange = NSRange(text.startIndex..., in: text)
        
        for match in regex.matches(in: text, range: nsRange) {
            if let range = Range(match.range, in: text) {
                // Text before the match
                if lastEnd < range.lowerBound {
                    parts.append((String(text[lastEnd..<range.lowerBound]), false))
                }
                // The variable match
                parts.append((String(text[range]), true))
                lastEnd = range.upperBound
            }
        }
        
        // Remaining text
        if lastEnd < text.endIndex {
            parts.append((String(text[lastEnd...]), false))
        }
        
        return parts
    }
}

/// Simple view that renders text parts with different colors inline
struct FlowText: View {
    let parts: [(String, Bool)]
    
    var body: some View {
        parts.reduce(Text("")) { result, part in
            result + Text(part.0)
                .foregroundColor(part.1 ? .orange : .green)
        }
    }
}
