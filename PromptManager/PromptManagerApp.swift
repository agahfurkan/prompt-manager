import SwiftUI
import SwiftData

@main
struct PromptManagerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Prompt.self)
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        .defaultSize(width: 1000, height: 650)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Prompt") {
                    NotificationCenter.default.post(
                        name: .createNewPrompt,
                        object: nil
                    )
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
        
        Settings {
            SettingsView()
        }
    }
}

extension Notification.Name {
    static let createNewPrompt = Notification.Name("createNewPrompt")
}
