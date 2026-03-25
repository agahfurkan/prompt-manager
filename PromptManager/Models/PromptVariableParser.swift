import Foundation

/// Utility for parsing and resolving `{{variable}}` placeholders in prompt text.
struct PromptVariableParser {
    
    /// Regex pattern matching `{{variableName}}` or `{{ variableName }}`
    private static let pattern = #"\{\{\s*([a-zA-Z_][a-zA-Z0-9_ ]*?)\s*\}\}"#
    
    /// Extract all unique variable names from a prompt body, in order of first appearance.
    static func extractVariables(from text: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, range: range)
        
        var seen = Set<String>()
        var result: [String] = []
        
        for match in matches {
            if let captureRange = Range(match.range(at: 1), in: text) {
                let name = String(text[captureRange]).trimmingCharacters(in: .whitespaces)
                if !seen.contains(name) {
                    seen.insert(name)
                    result.append(name)
                }
            }
        }
        
        return result
    }
    
    /// Returns true if the text contains any `{{variable}}` placeholders.
    static func hasVariables(in text: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let range = NSRange(text.startIndex..., in: text)
        return regex.firstMatch(in: text, range: range) != nil
    }
    
    /// Replace all `{{variable}}` placeholders with the provided values.
    /// Missing keys are left as-is.
    static func resolve(_ text: String, with values: [String: String]) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return text }
        let range = NSRange(text.startIndex..., in: text)
        var result = text
        
        // Process matches in reverse order so replacement ranges stay valid
        let matches = regex.matches(in: text, range: range).reversed()
        
        for match in matches {
            if let fullRange = Range(match.range(at: 0), in: result),
               let captureRange = Range(match.range(at: 1), in: result) {
                let name = String(result[captureRange]).trimmingCharacters(in: .whitespaces)
                if let value = values[name], !value.isEmpty {
                    result.replaceSubrange(fullRange, with: value)
                }
            }
        }
        
        return result
    }
    
    /// Insert a variable placeholder at a given position in a string.
    static func insertVariable(named name: String, into text: String, at offset: Int) -> String {
        let placeholder = "{{\(name)}}"
        let index = text.index(text.startIndex, offsetBy: min(offset, text.count))
        var result = text
        result.insert(contentsOf: placeholder, at: index)
        return result
    }
}
