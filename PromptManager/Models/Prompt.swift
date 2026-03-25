import Foundation
import SwiftData

@Model
final class Prompt {
    var id: UUID
    var title: String
    var body: String
    var command: String
    var category: String
    var isFavorite: Bool
    var createdAt: Date
    var updatedAt: Date
    var usageCount: Int
    
    init(
        title: String = "",
        body: String = "",
        command: String = "copilot",
        category: String = "General",
        isFavorite: Bool = false
    ) {
        self.id = UUID()
        self.title = title
        self.body = body
        self.command = command
        self.category = category
        self.isFavorite = isFavorite
        self.createdAt = Date()
        self.updatedAt = Date()
        self.usageCount = 0
    }
    
    /// Returns the full terminal command string
    var fullCommand: String {
        "\(command) \"\(body)\""
    }
    
    /// Returns just the command with prompt for clipboard
    var clipboardText: String {
        "\(command) \"\(body)\""
    }
}
