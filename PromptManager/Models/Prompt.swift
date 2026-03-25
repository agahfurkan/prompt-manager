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
    
    // MARK: - Variables
    
    /// All unique `{{variable}}` names found in the prompt body, in order.
    var variables: [String] {
        PromptVariableParser.extractVariables(from: body)
    }
    
    /// Whether this prompt contains any `{{variable}}` placeholders.
    var hasVariables: Bool {
        PromptVariableParser.hasVariables(in: body)
    }
    
    /// Resolve the prompt body by replacing `{{variable}}` with provided values.
    func resolvedBody(with values: [String: String]) -> String {
        PromptVariableParser.resolve(body, with: values)
    }
    
    // MARK: - Command generation
    
    /// Returns the full terminal command string (raw, with placeholders intact).
    /// Simply concatenates command + body. If body is empty, returns just the command.
    var fullCommand: String {
        let trimmedBody = body.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedBody.isEmpty {
            return command
        }
        return "\(command) \(body)"
    }
    
    /// Returns the full command with variables replaced.
    func resolvedCommand(with values: [String: String]) -> String {
        let resolved = resolvedBody(with: values)
        let trimmedResolved = resolved.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedResolved.isEmpty {
            return command
        }
        return "\(command) \(resolved)"
    }
    
    /// Returns just the command with prompt for clipboard
    var clipboardText: String {
        fullCommand
    }
}
