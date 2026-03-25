import Foundation

/// Predefined command templates for popular CLI AI tools
struct CommandTemplate: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let command: String
    let icon: String
    let description: String
    
    static let builtIn: [CommandTemplate] = [
        CommandTemplate(
            name: "GitHub Copilot",
            command: "copilot",
            icon: "chevron.left.forwardslash.chevron.right",
            description: "GitHub Copilot CLI"
        ),
        CommandTemplate(
            name: "Gemini",
            command: "gemini",
            icon: "sparkles",
            description: "Google Gemini CLI"
        ),
        CommandTemplate(
            name: "ChatGPT",
            command: "chatgpt",
            icon: "bubble.left.fill",
            description: "OpenAI ChatGPT CLI"
        ),
        CommandTemplate(
            name: "Claude",
            command: "claude",
            icon: "brain.head.profile",
            description: "Anthropic Claude CLI"
        ),
        CommandTemplate(
            name: "Ollama",
            command: "ollama run llama3",
            icon: "desktopcomputer",
            description: "Ollama local models"
        ),
        CommandTemplate(
            name: "OpenCode",
            command: "opencode",
            icon: "terminal.fill",
            description: "OpenCode CLI"
        ),
        CommandTemplate(
            name: "Custom",
            command: "",
            icon: "gear",
            description: "Enter your own command"
        ),
    ]
}

/// Predefined categories for organizing prompts
struct PromptCategory {
    static let defaults: [String] = [
        "General",
        "Coding",
        "Writing",
        "Debugging",
        "Code Review",
        "Refactoring",
        "Documentation",
        "Testing",
        "DevOps",
        "Data",
        "Design",
        "Other"
    ]
}
