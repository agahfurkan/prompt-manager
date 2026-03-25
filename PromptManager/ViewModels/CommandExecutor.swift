import Foundation
import AppKit

/// Handles executing prompts via CLI commands
struct CommandExecutor {
    
    /// Copy text to the system clipboard
    static func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
    
    /// Escape a string for safe embedding inside an AppleScript double-quoted string.
    /// Handles: backslash, double-quote, newlines, tabs, and carriage returns.
    private static func escapeForAppleScript(_ text: String) -> String {
        var result = text
        result = result.replacingOccurrences(of: "\\", with: "\\\\")
        result = result.replacingOccurrences(of: "\"", with: "\\\"")
        result = result.replacingOccurrences(of: "\n", with: "\\n")
        result = result.replacingOccurrences(of: "\r", with: "\\r")
        result = result.replacingOccurrences(of: "\t", with: "\\t")
        return result
    }
    
    /// Open Terminal.app (or iTerm) and run the command via AppleScript.
    static func runInTerminal(_ command: String) {
        let terminalApp = UserDefaults.standard.string(forKey: "terminalApp") ?? "Terminal"
        let escaped = escapeForAppleScript(command)
        
        let script: String
        
        if terminalApp == "iTerm" {
            script = """
            tell application "iTerm"
                activate
                set newWindow to (create window with default profile)
                tell current session of newWindow
                    write text "\(escaped)"
                end tell
            end tell
            """
        } else {
            script = """
            tell application "Terminal"
                activate
                do script "\(escaped)"
            end tell
            """
        }
        
        var error: NSDictionary?
        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(&error)
        }
        if let error = error {
            print("AppleScript error: \(error)")
        }
    }
    
    /// Copy just the prompt body to clipboard (without command prefix)
    static func copyPromptOnly(_ text: String) {
        copyToClipboard(text)
    }
}
