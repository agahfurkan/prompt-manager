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
    
    /// Open Terminal.app and run the command
    static func runInTerminal(_ command: String) {
        let terminalApp = UserDefaults.standard.string(forKey: "terminalApp") ?? "Terminal"
        
        // Escape the command for AppleScript
        let escaped = command
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        
        let script: String
        
        if terminalApp == "iTerm" {
            script = """
            tell application "iTerm"
                activate
                if (count of windows) = 0 then
                    create window with default profile
                end if
                tell current session of current window
                    write text "\(escaped)"
                end tell
            end tell
            """
        } else {
            script = """
            tell application "Terminal"
                activate
                if (count of windows) = 0 then
                    do script "\(escaped)"
                else
                    do script "\(escaped)" in front window
                end if
            end tell
            """
        }
        
        if let appleScript = NSAppleScript(source: script) {
            var error: NSDictionary?
            appleScript.executeAndReturnError(&error)
            if let error = error {
                print("AppleScript error: \(error)")
            }
        }
    }
    
    /// Copy just the prompt body to clipboard (without command prefix)
    static func copyPromptOnly(_ text: String) {
        copyToClipboard(text)
    }
}
