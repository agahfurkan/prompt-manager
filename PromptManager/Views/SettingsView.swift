import SwiftUI

struct SettingsView: View {
    @AppStorage("defaultCommand") private var defaultCommand = "copilot"
    @AppStorage("defaultCategory") private var defaultCategory = "General"
    @AppStorage("terminalApp") private var terminalApp = "Terminal"
    
    var body: some View {
        TabView {
            GeneralSettingsView(
                defaultCommand: $defaultCommand,
                defaultCategory: $defaultCategory,
                terminalApp: $terminalApp
            )
            .tabItem {
                Label("General", systemImage: "gear")
            }
        }
        .frame(width: 450, height: 250)
    }
}

struct GeneralSettingsView: View {
    @Binding var defaultCommand: String
    @Binding var defaultCategory: String
    @Binding var terminalApp: String
    
    var body: some View {
        Form {
            Section("Defaults") {
                Picker("Default Command", selection: $defaultCommand) {
                    ForEach(CommandTemplate.builtIn.filter { $0.name != "Custom" }) { template in
                        Text(template.name).tag(template.command)
                    }
                }
                
                Picker("Default Category", selection: $defaultCategory) {
                    ForEach(PromptCategory.defaults, id: \.self) { cat in
                        Text(cat).tag(cat)
                    }
                }
            }
            
            Section("Terminal") {
                Picker("Terminal Application", selection: $terminalApp) {
                    Text("Terminal").tag("Terminal")
                    Text("iTerm").tag("iTerm")
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}
