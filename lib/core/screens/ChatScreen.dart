import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../models/chatModel.dart';
import '../services/ollama_service.dart';

Future<String> loadContext() async {
  return await rootBundle.loadString('flutter_context.md');
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();

  final ollama = OllamaService();

  final scrollController = ScrollController();

  final messages = <ChatMessage>[];

  bool loading = false;

  String streamingText = "";

  Future<void> send() async {
    final text = controller.text.trim();

    if (text.isEmpty) return;

    final context = await loadContext();

    setState(() {
      messages.add(
        ChatMessage(
          text: text,
          isUser: true,
        ),
      );

      loading = true;

      streamingText = "";
    });

    controller.clear();

    setState(() {
      messages.add(
        ChatMessage(
          text: "",
          isUser: false,
        ),
      );
    });

    final botIndex = messages.length - 1;

    await for (final token in ollama.streamGenerate(
      prompt: text,
      context: context,
    )) {
      streamingText += token;

      setState(() {
        messages[botIndex] = ChatMessage(
          text: streamingText,
          isUser: false,
        );
      });

      _autoScroll();
    }

    setState(() {
      loading = false;
    });
  }

  void _autoScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),


      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: messages.length,
              itemBuilder: (_, index) {
                final message = messages[index];

                final isUser = message.isUser;

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,

                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),

                    constraints: const BoxConstraints(
                      maxWidth: 750,
                    ),

                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF111827),

                      borderRadius: BorderRadius.circular(22),

                    ),
                    child: MarkdownBody(
                      selectable: true,

                      data: message.text.isEmpty &&
                          loading &&
                          index == messages.length - 1
                          ? "thinking..."
                          : message.text,

                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.5,
                        ),

                        code: const TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.greenAccent,
                        ),

                        h1: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),

                        h2: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),

                      builders: {
                        'code': CodeBlockBuilder(),
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(

              border: Border(
                top: BorderSide(
                  color: Colors.white.withAlpha(15),
                ),
              ),
            ),

            child: SafeArea(
              top: false,

              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,

                      minLines: 1,
                      maxLines: 8,

                      style: const TextStyle(
                        color: Colors.white,
                      ),

                      decoration: InputDecoration(
                        hintText: "Ask something...",

                        hintStyle: TextStyle(
                          color: Colors.white.withAlpha(120),
                        ),

                        filled: true,

                        fillColor: Colors.white.withAlpha(8),

                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: IconButton(
                      onPressed: loading ? null : send,

                      icon: loading
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(
                        Icons.arrow_upward_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(
      element,
      TextStyle? preferredStyle,
      ) {
    final code = element.textContent;

    return Container(

      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),


        border: Border.all(
          color: Colors.white.withAlpha(15),
        ),
      ),

      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),

            decoration: BoxDecoration(
              color: Colors.white.withAlpha(8),

              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),

            child: Row(
              children: [
                const Text(
                  "dart",

                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const Spacer(),

                _CodeActionButton(
                  icon: Icons.copy_rounded,
                  label: "Copy",

                  onTap: () async {



                    await Clipboard.setData(
                      ClipboardData(text: code),
                    );


                  },

                ),

                const SizedBox(width: 8),

                _CodeActionButton(
                  icon: Icons.refresh_rounded,
                  label: "Rewrite",

                  onTap: () {
                    debugPrint("rewrite clicked");
                  },
                ),
              ],
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            padding: const EdgeInsets.all(16),

            child: SelectableText(
              code,

              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                height: 1.6,
                color: Color(0xFFD1FAE5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeActionButton extends StatelessWidget {
  final IconData icon;

  final String label;

  final VoidCallback onTap;

  const _CodeActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),

      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),

        decoration: BoxDecoration(
          color: Colors.white.withAlpha(10),

          borderRadius: BorderRadius.circular(10),
        ),

        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: Colors.white70,
            ),

            const SizedBox(width: 6),

            Text(
              label,

              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class HoverText extends StatefulWidget {
  final String text;

  const HoverText({super.key, required this.text});

  @override
  State<HoverText> createState() => _HoverTextState();
}

class _HoverTextState extends State<HoverText> {
  final Set<int> hovered = {};

  void _setHover(int index, bool value) {
    setState(() {
      if (value) {
        hovered.add(index);
      } else {
        hovered.remove(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 24),
        children: List.generate(widget.text.length, (index) {
          final letter = widget.text[index];
          final isHovered = hovered.contains(index);

          return WidgetSpan(
            child: MouseRegion(
              onEnter: (_) => _setHover(index, true),
              onExit: (_) => _setHover(index, false),
              child: GestureDetector(
                onTap: () {
                  // TODO: tap action per letter
                },
                child: Text(
                  letter,
                  style: TextStyle(
                    color: isHovered ? Colors.black : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );

  }
}