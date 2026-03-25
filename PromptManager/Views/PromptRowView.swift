import SwiftUI

struct PromptRowView: View {
    let prompt: Prompt
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(prompt.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                if prompt.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                }
            }
            
            Text(prompt.body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            
            HStack(spacing: 8) {
                // Command badge
                HStack(spacing: 3) {
                    Image(systemName: "terminal")
                        .font(.system(size: 9))
                    Text(prompt.command)
                        .font(.caption2)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.blue.opacity(0.12))
                .foregroundStyle(.blue)
                .cornerRadius(4)
                
                // Category badge
                HStack(spacing: 3) {
                    Image(systemName: "tag")
                        .font(.system(size: 9))
                    Text(prompt.category)
                        .font(.caption2)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.purple.opacity(0.12))
                .foregroundStyle(.purple)
                .cornerRadius(4)
                
                Spacer()
                
                if prompt.usageCount > 0 {
                    Text("\(prompt.usageCount)x")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
