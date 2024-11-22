import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  static const primaryGreen = Color(0xFF4CAF50);
  static const backgroundColor = Color(0xFFF5F5F5);

  // Function to simulate AI response processing in a separate isolate
  Future<String> processAIResponse(String input) async {
    // Simulate a heavy computation (replace with your AI logic)
    await Future.delayed(const Duration(seconds: 1));
    return "Thank you for sharing. How are you feeling right now?";
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    _textController.clear();
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
      ));
    });

    // Use compute to process AI logic in a separate isolate
    compute(processAIResponse, text).then((response) {
      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
        ));
      });
      _scrollToBottom();
    });
    _focusNode.requestFocus();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        title: const Text('MindCare Chatbot'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showGuideDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index];
              },
            ),
          ),

          // Suggestions Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildSuggestionChip('Mood Check-in'),
                  const SizedBox(width: 10),
                  _buildSuggestionChip('Stress Relief'),
                  const SizedBox(width: 10),
                  _buildSuggestionChip('Breathing Exercise'),
                ],
              ),
            ),
          ),

          // Message Input
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Voice Input Button
                IconButton(
                  icon: const Icon(Icons.keyboard_voice, color: primaryGreen),
                  onPressed: () {
                    // Implement voice input
                  },
                ),

                // Text Input
                Expanded(
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: _handleSubmitted,
                  ),
                ),

                // Send Button
                IconButton(
                  icon: const Icon(Icons.send, color: primaryGreen),
                  onPressed: () => _handleSubmitted(_textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return ChoiceChip(
      label: Text(label),
      selected: false,
      onSelected: (bool selected) {
        _textController.text = 'I want to do a $label';
        _handleSubmitted(_textController.text);
      },
      backgroundColor: Colors.white,
      selectedColor: primaryGreen.withOpacity(0.2),
      side: BorderSide(color: primaryGreen.withOpacity(0.5)),
      labelStyle: TextStyle(color: primaryGreen.withOpacity(0.8)),
    );
  }

  void _showGuideDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About MindCare'),
          content: const Text(
            'MindCare is an AI-powered mental health support chatbot. '
                'Our goal is to provide compassionate, non-judgmental support '
                'and guide you towards better mental well-being.',
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

// Custom Chat Message Widget
class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF4CAF50).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.green[800] : Colors.black87,
          ),
        ),
      ),
    );
  }
}
