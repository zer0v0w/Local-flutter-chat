# Local Dev Assistant

Local Dev Assistant is a lightweight Flutter application that connects to locally hosted LLMs through Ollama.

The project is designed around a hybrid development workflow where the developer remains fully in control while the model assists with repetitive implementation tasks such as generating widgets, writing boilerplate, cleaning code, and handling small logic structures.

Unlike fully autonomous coding agents, this project focuses on controlled assistance and fast iteration without removing the engineering process from the developer.

---

## Features

* Local AI integration using Ollama
* Streaming responses in real time
* Prompt memory through chat history injection
* Flutter-specific context injection system
* Markdown rendering
* Custom code block UI
* Copy code actions
* Rewrite action hooks
* Dark themed developer interface
* Offline-first workflow

---

## Tech Stack

* Flutter
* Dart
* Ollama
* Dio
* flutter_markdown

---

## How It Works

The application builds prompts using three layers:

1. Flutter context rules
2. Previous conversation history
3. Current user request

The Flutter context file acts as a temporary project brain containing:

* architecture rules
* Flutter patterns
* styling constraints
* reusable snippets
* output restrictions

Each request injects this context before sending the prompt to the local model.

The result is a more stable and project-aware coding assistant.

---

## Recommended Models

The project works best with coding-oriented local models.

Tested models:

* qwen2.5-coder
* deepseek-coder
* codellama
* gemma

---

## Getting Started

### 1. Install Ollama

Linux:

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

Verify installation:

```bash
ollama --version
```

---

### 2. Pull a Model

Example:

```bash
ollama pull qwen2.5-coder
```

Other options:

```bash
ollama pull deepseek-coder
ollama pull codellama
ollama pull gemma:2b
```

---

### 3. Start Ollama

```bash
ollama serve
```

Default endpoint:

```txt
http://127.0.0.1:11434
```

---

### 4. Install Flutter Dependencies

```yaml
dependencies:
  dio:
  flutter_markdown:
```

Install packages:

```bash
flutter pub get
```

---

## Project Structure

```txt
lib/
  models/
  screens/
  services/
  widgets/

assets/
  flutter_context.md
```

---

## Context Injection

The assistant loads a Flutter context file:

```dart
final context = await rootBundle.loadString(
  'assets/flutter_context.md',
);
```

This context is injected into every request before sending it to Ollama.

The context file defines:

* coding rules
* Flutter best practices
* project structure
* reusable patterns
* strict output behavior

This helps keep responses consistent and reduces unwanted generation behavior.

---

## Streaming Responses

Responses are streamed token-by-token from Ollama.

Example:

```dart
await for (final token in ollama.streamGenerate()) {
  streamingText += token;
}
```

This creates a more responsive coding workflow and allows the UI to update in real time.

---

## Memory System

The project currently uses prompt-based memory.

Conversation history is stored in memory and injected into future requests.

Example:

```dart
final List<Map<String, String>> history = [];
```

This allows the assistant to maintain short-term conversational continuity.

The current implementation is intentionally simple and lightweight.

---

## Design Philosophy

The goal of this project is not to replace the developer.

The assistant is intended to:

* reduce repetitive work
* speed up implementation
* assist with structure and boilerplate
* keep the developer in control

The project intentionally avoids fully autonomous code generation.

---

## Future Improvements

Planned improvements include:

* syntax highlighting
* diff viewer
* file-aware context injection
* IntelliJ integration
* MCP support
* semantic search
* vector memory
* project indexing
* apply-code actions

---

## License

MIT License
