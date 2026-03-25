import SwiftUI

struct EmptyStateView: View {
    @Binding var showingNewPrompt: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "text.bubble.fill")
                .font(.system(size: 64))
                .foregroundStyle(.tertiary)
            
            Text("Prompt Manager")
                .font(.largeTitle.bold())
                .foregroundStyle(.primary)
            
            Text("Write, organize, and execute prompts\nwith your favorite AI CLI tools.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 8) {
                FeatureRow(icon: "square.and.pencil", text: "Write and save reusable prompts")
                FeatureRow(icon: "terminal.fill", text: "Run with copilot, gemini, claude & more")
                FeatureRow(icon: "doc.on.doc", text: "Copy commands to clipboard instantly")
                FeatureRow(icon: "tag.fill", text: "Organize by command and category")
                FeatureRow(icon: "magnifyingglass", text: "Search and filter your prompt library")
            }
            .padding(.vertical, 8)
            
            Button {
                showingNewPrompt = true
            } label: {
                Label("Create Your First Prompt", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Text("Cmd+N to create a new prompt")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(.blue)
            Text(text)
                .foregroundStyle(.secondary)
        }
    }
}
