import SwiftUI
import SwiftData

struct PromptEditorView: View {
    @Bindable var prompt: Prompt
    @Environment(\.modelContext) private var modelContext
    @State private var showCopiedToast = false
    @State private var showRunToast = false
    @State private var selectedCommandTemplate: CommandTemplate?
    
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
                        CommandExecutor.copyToClipboard(prompt.fullCommand)
                        showCopiedToast = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showCopiedToast = false
                        }
                    } label: {
                        Label("Copy Command", systemImage: "doc.on.doc")
                    }
                    .help("Copy full command to clipboard (Cmd+Shift+C)")
                    .keyboardShortcut("c", modifiers: [.command, .shift])
                    
                    // Run button
                    Button {
                        CommandExecutor.runInTerminal(prompt.fullCommand)
                        prompt.usageCount += 1
                        prompt.updatedAt = Date()
                        showRunToast = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showRunToast = false
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
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Copied to clipboard!")
                            .font(.subheadline)
                    }
                    .padding(10)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                if showRunToast {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Opened in Terminal!")
                            .font(.subheadline)
                    }
                    .padding(10)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                    .transition(.move(edge: .top).combined(with: .opacity))
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
                    
                    // Custom command field or current command display
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
                
                // Prompt body
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Prompt")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button {
                            CommandExecutor.copyToClipboard(prompt.body)
                            showCopiedToast = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showCopiedToast = false
                            }
                        } label: {
                            Label("Copy Prompt Only", systemImage: "doc.on.clipboard")
                                .font(.caption)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
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
                }
                
                // Command Preview
                VStack(alignment: .leading, spacing: 6) {
                    Text("Command Preview")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Text(prompt.fullCommand)
                        .font(.system(.body, design: .monospaced))
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.black.opacity(0.85))
                        .foregroundStyle(.green)
                        .cornerRadius(8)
                        .textSelection(.enabled)
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
    }
}
