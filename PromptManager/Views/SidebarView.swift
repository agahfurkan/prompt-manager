import SwiftUI
import SwiftData

struct SidebarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var prompts: [Prompt]
    @Binding var selectedCategory: String?
    @Binding var selectedCommand: String?
    
    private var categories: [String] {
        let cats = Set(prompts.map(\.category))
        return Array(cats).sorted()
    }
    
    private var commands: [String] {
        let cmds = Set(prompts.map(\.command))
        return Array(cmds).sorted()
    }
    
    private var favoriteCount: Int {
        prompts.filter(\.isFavorite).count
    }
    
    var body: some View {
        List {
            // All Prompts
            Section {
                Button {
                    selectedCategory = nil
                    selectedCommand = nil
                } label: {
                    Label("All Prompts", systemImage: "tray.fill")
                }
                .buttonStyle(.plain)
                .padding(.vertical, 2)
                .fontWeight(selectedCategory == nil && selectedCommand == nil ? .semibold : .regular)
                
                if favoriteCount > 0 {
                    Button {
                        selectedCategory = "__favorites__"
                        selectedCommand = nil
                    } label: {
                        Label("Favorites", systemImage: "star.fill")
                            .foregroundStyle(.yellow)
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 2)
                    .fontWeight(selectedCategory == "__favorites__" ? .semibold : .regular)
                }
            }
            
            // Commands
            if !commands.isEmpty {
                Section("Commands") {
                    ForEach(commands, id: \.self) { cmd in
                        Button {
                            selectedCommand = cmd
                            selectedCategory = nil
                        } label: {
                            Label {
                                Text(cmd)
                                    .lineLimit(1)
                            } icon: {
                                Image(systemName: iconForCommand(cmd))
                            }
                            .badge(prompts.filter { $0.command == cmd }.count)
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 2)
                        .fontWeight(selectedCommand == cmd ? .semibold : .regular)
                    }
                }
            }
            
            // Categories
            if !categories.isEmpty {
                Section("Categories") {
                    ForEach(categories, id: \.self) { cat in
                        Button {
                            selectedCategory = cat
                            selectedCommand = nil
                        } label: {
                            Label(cat, systemImage: iconForCategory(cat))
                                .badge(prompts.filter { $0.category == cat }.count)
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 2)
                        .fontWeight(selectedCategory == cat ? .semibold : .regular)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Prompt Manager")
    }
    
    private func iconForCommand(_ cmd: String) -> String {
        let lower = cmd.lowercased()
        if lower.contains("copilot") { return "chevron.left.forwardslash.chevron.right" }
        if lower.contains("gemini") { return "sparkles" }
        if lower.contains("chatgpt") { return "bubble.left.fill" }
        if lower.contains("claude") { return "brain.head.profile" }
        if lower.contains("ollama") { return "desktopcomputer" }
        if lower.contains("opencode") { return "terminal.fill" }
        return "terminal"
    }
    
    private func iconForCategory(_ cat: String) -> String {
        switch cat {
        case "Coding": return "curlybraces"
        case "Writing": return "pencil.line"
        case "Debugging": return "ladybug.fill"
        case "Code Review": return "eye.fill"
        case "Refactoring": return "arrow.triangle.2.circlepath"
        case "Documentation": return "doc.text.fill"
        case "Testing": return "checkmark.circle.fill"
        case "DevOps": return "server.rack"
        case "Data": return "cylinder.fill"
        case "Design": return "paintpalette.fill"
        case "General": return "folder.fill"
        default: return "tag.fill"
        }
    }
}
