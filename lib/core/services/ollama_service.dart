import 'dart:convert';
import 'package:dio/dio.dart';

class OllamaService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:11434',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// 🧠 MEMORY STORE
  final List<Map<String, String>> _history = [];

  /// =========================
  /// GENERATE (WITH MEMORY)
  /// =========================
  Future<String> generate({
    required String prompt,
    String? context,
    String model = "qwen2.5-coder",
  }) async {
    _addUser(prompt);

    final fullPrompt = _buildPrompt(
      context: context,
      task: prompt,
    );

    final response = await _dio.post(
      '/api/generate',
      data: {
        "model": model,
        "prompt": fullPrompt,
        "stream": false,
        "options": {"temperature": 0.1}
      },
    );

    final output = response.data["response"] ?? "";

    _addAssistant(output);

    return output;
  }

  /// =========================
  /// STREAM (WITH MEMORY)
  /// =========================
  Stream<String> streamGenerate({
    required String prompt,
    String? context,
    String model = "qwen2.5-coder",
  }) async* {
    _addUser(prompt);

    final fullPrompt = _buildPrompt(
      context: context,
      task: prompt,
    );

    final response = await _dio.post(
      '/api/generate',
      data: {
        "model": model,
        "prompt": fullPrompt,
        "stream": true,
      },
      options: Options(responseType: ResponseType.stream),
    );

    final stream = response.data.stream;

    String buffer = "";

    await for (final chunk in stream) {
      final decoded = utf8.decode(chunk);

      for (final line in decoded.split('\n')) {
        if (line.trim().isEmpty) continue;

        final json = jsonDecode(line);
        final token = json["response"] ?? "";

        if (token.isNotEmpty) {
          buffer += token;
          yield token;
        }
      }
    }

    _addAssistant(buffer);
  }

  /// =========================
  /// MEMORY HANDLING
  /// =========================
  void _addUser(String text) {
    _history.add({"role": "user", "content": text});
    _trimHistory();
  }

  void _addAssistant(String text) {
    _history.add({"role": "assistant", "content": text});
    _trimHistory();
  }

  void clearMemory() {
    _history.clear();
  }

  void _trimHistory() {
    if (_history.length > 10) {
      _history.removeRange(0, _history.length - 10);
    }
  }

  /// =========================
  /// PROMPT BUILDER
  /// =========================
  String _buildPrompt({
    required String task,
    String? context,
  }) {
    final historyText = _history
        .map((m) => "${m['role']}: ${m['content']}")
        .join("\n");

    return """
SYSTEM CONTEXT:
${context ?? "No context provided"}

CONVERSATION HISTORY:
$historyText

IMPORTANT RULES:
- Output ONLY Flutter (Dart) code
- No explanations
- No Python or other languages
- Follow clean architecture
- Keep widgets small and reusable
- Be production-ready

CURRENT TASK:
$task

OUTPUT:
Return only valid Dart code.
""";
  }
}