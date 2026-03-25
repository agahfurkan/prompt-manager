import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedPrompt: Prompt?
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil
    @State private var selectedCommand: String? = nil
    @State private var showingNewPrompt = false
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(
                selectedCategory: $selectedCategory,
                selectedCommand: $selectedCommand
            )
            .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 250)
        } content: {
            PromptListView(
                selectedPrompt: $selectedPrompt,
                searchText: $searchText,
                selectedCategory: selectedCategory,
                selectedCommand: selectedCommand,
                showingNewPrompt: $showingNewPrompt
            )
            .navigationSplitViewColumnWidth(min: 250, ideal: 300, max: 400)
        } detail: {
            if let prompt = selectedPrompt {
                PromptEditorView(prompt: prompt)
            } else if showingNewPrompt {
                NewPromptView(
                    showingNewPrompt: $showingNewPrompt,
                    selectedPrompt: $selectedPrompt
                )
            } else {
                EmptyStateView(showingNewPrompt: $showingNewPrompt)
            }
        }
        .searchable(text: $searchText, prompt: "Search prompts...")
        .onReceive(NotificationCenter.default.publisher(for: .createNewPrompt)) { _ in
            selectedPrompt = nil
            showingNewPrompt = true
        }
    }
}

// MARK: - New Prompt View (inline in detail pane)
struct NewPromptView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var showingNewPrompt: Bool
    @Binding var selectedPrompt: Prompt?
    
    @State private var title = ""
    @State private var body_ = ""
    @State private var selectedCommandTemplate: CommandTemplate = CommandTemplate.builtIn[0]
    @State private var customCommand = ""
    @State private var selectedCategory = "General"
    @State private var newVariableName = ""
    @State private var showAddVariable = false
    
    private var resolvedCommand: String {
        if selectedCommandTemplate.name == "Custom" {
            return customCommand
        }
        return selectedCommandTemplate.command
    }
    
    private var detectedVariables: [String] {
        PromptVariableParser.extractVariables(from: body_)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundStyle(.blue)
                    Text("New Prompt")
                        .font(.title.bold())
                    Spacer()
                }
                .padding(.bottom, 4)
                
                // Title
                VStack(alignment: .leading, spacing: 6) {
                    Text("Title")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    TextField("Give your prompt a name...", text: $title)
                        .textFieldStyle(.roundedBorder)
                        .font(.title3)
                }
                
                // Command Selection
                VStack(alignment: .leading, spacing: 6) {
                    Text("Command")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 8) {
                        ForEach(CommandTemplate.builtIn) { template in
                            Button {
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
                                    selectedCommandTemplate.name == template.name
                                        ? Color.accentColor.opacity(0.15)
                                        : Color.gray.opacity(0.08)
                                )
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            selectedCommandTemplate.name == template.name
                                                ? Color.accentColor
                                                : Color.clear,
                                            lineWidth: 1.5
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    if selectedCommandTemplate.name == "Custom" {
                        TextField("Enter custom command (e.g., my-ai-tool)", text: $customCommand)
                            .textFieldStyle(.roundedBorder)
                            .padding(.top, 4)
                    }
                }
                
                // Category
                VStack(alignment: .leading, spacing: 6) {
                    Text("Category")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(PromptCategory.defaults, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 200)
                }
                
                // Prompt Body with variable support
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
                    }
                    
                    // Variable hint
                    Text("Use {{variable_name}} for dynamic values filled at run time")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    
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
                    
                    TextEditor(text: $body_)
                        .font(.body.monospaced())
                        .frame(minHeight: 180)
                        .padding(8)
                        .background(Color(nsColor: .textBackgroundColor))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    // Detected variables chips
                    if !detectedVariables.isEmpty {
                        VariableChipsView(variables: detectedVariables) { varName in
                            body_.append(" {{\(varName)}}")
                        }
                    }
                }
                
                // Preview
                if !body_.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Preview")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            if !detectedVariables.isEmpty {
                                Text("(\(detectedVariables.count) variable\(detectedVariables.count == 1 ? "" : "s"))")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                            }
                        }
                        HighlightedCommandPreview(text: "\(resolvedCommand) \"\(body_)\"")
                    }
                }
                
                // Actions
                HStack {
                    Button("Cancel") {
                        showingNewPrompt = false
                    }
                    .keyboardShortcut(.cancelAction)
                    
                    Spacer()
                    
                    Button("Save Prompt") {
                        savePrompt()
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(title.isEmpty || body_.isEmpty || resolvedCommand.isEmpty)
                    .buttonStyle(.borderedProminent)
                }
                .padding(.top, 8)
            }
            .padding(24)
        }
        .animation(.easeInOut(duration: 0.2), value: showAddVariable)
    }
    
    private func insertVariable() {
        let name = newVariableName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        body_.append(" {{\(name)}}")
        newVariableName = ""
        showAddVariable = false
    }
    
    private func savePrompt() {
        let prompt = Prompt(
            title: title,
            body: body_,
            command: resolvedCommand,
            category: selectedCategory
        )
        modelContext.insert(prompt)
        try? modelContext.save()
        selectedPrompt = prompt
        showingNewPrompt = false
    }
}
