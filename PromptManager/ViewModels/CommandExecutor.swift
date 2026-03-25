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
    
    /// Open Terminal.app (or iTerm) and run the command.
    ///
    /// Strategy: save the command to the clipboard, then use AppleScript to
    /// paste and execute it in the terminal. This avoids all AppleScript
    /// string-escaping issues with newlines, quotes, backslashes, etc.
    static func runInTerminal(_ command: String) {
        let terminalApp = UserDefaults.standard.string(forKey: "terminalApp") ?? "Terminal"
        
        // Save current clipboard so we can restore it
        let pasteboard = NSPasteboard.general
        let previousContents = pasteboard.string(forType: .string)
        
        // Put the command on the clipboard
        pasteboard.clearContents()
        pasteboard.setString(command, forType: .string)
        
        let script: String
        
        if terminalApp == "iTerm" {
            script = """
            tell application "iTerm"
                activate
                if (count of windows) = 0 then
                    create window with default profile
                end if
                tell current session of current window
                    set theCommand to the clipboard
                    write text theCommand
                end tell
            end tell
            """
        } else {
            script = """
            tell application "Terminal"
                activate
                set theCommand to the clipboard
                if (count of windows) = 0 then
                    do script theCommand
                else
                    do script theCommand in front window
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
        
        // Restore previous clipboard after a short delay
        // (give Terminal time to read the clipboard)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let prev = previousContents {
                pasteboard.clearContents()
                pasteboard.setString(prev, forType: .string)
            }
        }
    }
    
    /// Copy just the prompt body to clipboard (without command prefix)
    static func copyPromptOnly(_ text: String) {
        copyToClipboard(text)
    }
}
