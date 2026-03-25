# Prompt Manager

A native macOS app for storing, organizing, and running prompts you use with CLI AI tools like GitHub Copilot, Claude, Gemini, ChatGPT, Ollama, and OpenCode.

I built this because I kept retyping the same prompts over and over. I needed a simple tool to save the prompts I frequently execute, with support for variables so I can swap out filenames, paths, or other details each time.

## Features

- **Store & organize prompts** with categories, favorites, and search
- **7 built-in command templates**: GitHub Copilot, Gemini, ChatGPT, Claude, Ollama, OpenCode, and Custom
- **Run in Terminal** -- click Run and the command opens in a new Terminal window, ready for interaction
- **Copy to clipboard** -- copy the full command or just the prompt body
- **Dynamic variables** -- use `{{variable_name}}` placeholders that get filled in before execution

## Variables

Prompts support `{{variable_name}}` syntax. When you run or copy a prompt that contains variables, a sheet appears asking you to fill in each value.

For example, a prompt like:

```
claude "Review the file {{filename}} and suggest improvements for {{area}}"
```

will ask you to fill in `filename` and `area` before running.

You can insert variables using the "Insert Variable" button above the prompt editor, or just type `{{name}}` directly.

## Requirements

- macOS 14.0+
- Xcode 15+

## Build

```bash
git clone https://github.com/your-username/prompt-manager.git
cd prompt-manager
xcodebuild -project PromptManager.xcodeproj -scheme PromptManager -configuration Debug build
```

Or open `PromptManager.xcodeproj` in Xcode and hit Run.
