import SwiftUI
import SwiftData

struct PromptListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Prompt.updatedAt, order: .reverse) private var allPrompts: [Prompt]
    @Binding var selectedPrompt: Prompt?
    @Binding var searchText: String
    var selectedCategory: String?
    var selectedCommand: String?
    @Binding var showingNewPrompt: Bool
    
    @State private var variableSheetPrompt: Prompt?
    @State private var variableSheetAction: VariableFillSheet.Action = .run
    @State private var showVariableSheet = false
    
    private var filteredPrompts: [Prompt] {
        var result = allPrompts
        
        // Filter by favorites
        if selectedCategory == "__favorites__" {
            result = result.filter(\.isFavorite)
        }
        // Filter by category
        else if let cat = selectedCategory {
            result = result.filter { $0.category == cat }
        }
        
        // Filter by command
        if let cmd = selectedCommand {
            result = result.filter { $0.command == cmd }
        }
        
        // Search
        if !searchText.isEmpty {
            let search = searchText.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(search) ||
                $0.body.lowercased().contains(search) ||
                $0.command.lowercased().contains(search) ||
                $0.category.lowercased().contains(search)
            }
        }
        
        return result
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with count and add button
            HStack {
                Text(headerTitle)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(filteredPrompts.count)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                
                Button {
                    selectedPrompt = nil
                    showingNewPrompt = true
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.plain)
                .help("New Prompt (Cmd+N)")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            
            Divider()
            
            if filteredPrompts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.largeTitle)
                        .foregroundStyle(.tertiary)
                    Text("No prompts found")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    if !searchText.isEmpty {
                        Text("Try a different search term")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(filteredPrompts, selection: $selectedPrompt) { prompt in
                    PromptRowView(prompt: prompt)
                        .tag(prompt)
                        .contextMenu {
                            Button("Copy Command") {
                                if prompt.hasVariables {
                                    variableSheetPrompt = prompt
                                    variableSheetAction = .copyCommand
                                    showVariableSheet = true
                                } else {
                                    CommandExecutor.copyToClipboard(prompt.fullCommand)
                                }
                            }
                            Button("Copy Prompt Only") {
                                if prompt.hasVariables {
                                    variableSheetPrompt = prompt
                                    variableSheetAction = .copyPromptOnly
                                    showVariableSheet = true
                                } else {
                                    CommandExecutor.copyToClipboard(prompt.body)
                                }
                            }
                            Divider()
                            Button("Run in Terminal") {
                                if prompt.hasVariables {
                                    variableSheetPrompt = prompt
                                    variableSheetAction = .run
                                    showVariableSheet = true
                                } else {
                                    CommandExecutor.runInTerminal(prompt.fullCommand)
                                    prompt.usageCount += 1
                                    prompt.updatedAt = Date()
                                }
                            }
                            Divider()
                            Button(prompt.isFavorite ? "Unfavorite" : "Favorite") {
                                prompt.isFavorite.toggle()
                            }
                            Divider()
                            Button("Delete", role: .destructive) {
                                if selectedPrompt == prompt {
                                    selectedPrompt = nil
                                }
                                modelContext.delete(prompt)
                                try? modelContext.save()
                            }
                        }
                }
                .listStyle(.inset)
                .onChange(of: selectedPrompt) {
                    if selectedPrompt != nil {
                        showingNewPrompt = false
                    }
                }
            }
        }
        .sheet(isPresented: $showVariableSheet) {
            if let prompt = variableSheetPrompt {
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
                        case .copyCommand:
                            CommandExecutor.copyToClipboard(resolvedText)
                        case .copyPromptOnly:
                            CommandExecutor.copyToClipboard(resolvedText)
                        }
                        variableSheetPrompt = nil
                    },
                    onCancel: {
                        showVariableSheet = false
                        variableSheetPrompt = nil
                    }
                )
            }
        }
    }
    
    private var headerTitle: String {
        if selectedCategory == "__favorites__" { return "Favorites" }
        if let cat = selectedCategory { return cat }
        if let cmd = selectedCommand { return cmd }
        return "All Prompts"
    }
}
