import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dart_openai/dart_openai.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

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

  // Firebase database references
  final DatabaseReference _chatsRef =
  FirebaseDatabase.instance.ref().child('chats');
  final DatabaseReference _chatHistoryRef =
  FirebaseDatabase.instance.ref().child('chat_history');

  // List to store previous chat sessions
  final List<ChatSession> _previousChats = [];
  String? _currentChatId;

  static const primaryGreen = Color(0xFF4CAF50);
  static const backgroundColor = Color(0xFFF5F5F5);

  bool _isSidebarCollapsed = false;

  @override
  void initState() {
    super.initState();
    // Initialize OpenAI with your API key
    OpenAI.apiKey = '';

    // Initialize Firebase and load previous chats
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();

    // Load previous chat history
    _chatHistoryRef.onChildAdded.listen((event) {
      final DataSnapshot snapshot = event.snapshot;

      final Map<Object?, Object?>? chatData =
      snapshot.value as Map<Object?, Object?>?;
      final String? chatId = snapshot.key;

      if (chatData != null && chatId != null) {
        setState(() {
          _previousChats.add(ChatSession.fromMap(chatId, chatData));
        });
      }
    });
  }

  void _startNewChat() {
    setState(() {
      _messages.clear();
      _currentChatId = null;
    });
  }

  Future<void> _saveChatSession() async {
    if (_messages.isEmpty) return;

    final chatRef = _chatHistoryRef.push();
    final String chatId = chatRef.key ?? '';

    String titleText = _messages.first.text;
    if (titleText.length > 30) {
      titleText = '${titleText.substring(0, 30)}...';
    }

    final chatData = {
      'timestamp': DateTime.now().toIso8601String(),
      'title': titleText,
      'messages': _messages
          .map((msg) => {
        'text': msg.text,
        'isUser': msg.isUser,
      })
          .toList()
    };

    await chatRef.set(chatData);

    setState(() {
      _currentChatId = chatId;
      _previousChats.add(ChatSession(
        id: chatId,
        timestamp: chatData['timestamp'] as String,
        title: chatData['title'] as String,
      ));
    });
  }

  void _loadChatSession(ChatSession session) async {
    try {
      final snapshot = await _chatHistoryRef.child(session.id).get();
      final Map<Object?, Object?>? chatData =
      snapshot.value as Map<Object?, Object?>?;

      if (chatData != null) {
        final messagesList = chatData['messages'];

        if (messagesList is List) {
          setState(() {
            _messages.clear();
            _currentChatId = session.id;

            for (var msgData in messagesList) {
              if (msgData is Map<Object?, Object?>) {
                final text = (msgData['text'] as String?) ?? '';
                final isUser = (msgData['isUser'] as bool?) ?? false;
                _messages.add(ChatMessage(text: text, isUser: isUser));
              }
            }
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load chat session')));
    }
  }

  Future<String> processAIResponse(String input) async {
    try {
      final chatCompletion = await OpenAI.instance.chat.create(
        model: "gpt-3.5-turbo",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(input)
            ],
            role: OpenAIChatMessageRole.user,
          )
        ],
        maxTokens: 150,
      );

      return chatCompletion.choices.first.message.content?.first.text ??
          "I couldn't generate a response.";
    } catch (e) {
      return "I'm experiencing some technical difficulties. Could you please try again?";
    }
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

    compute(_computeWrapper, text).then((response) {
      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
        ));
      });
      _scrollToBottom();

      if (_currentChatId == null) {
        _saveChatSession();
      }
    });
    _focusNode.requestFocus();
  }

  static Future<String> _computeWrapper(String input) async {
    final state = _ChatbotPageState();
    return state.processAIResponse(input);
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
            icon: const Icon(Icons.add),
            onPressed: _startNewChat,
          ),
          IconButton(
            icon: Icon(_isSidebarCollapsed ? Icons.menu : Icons.close),
            onPressed: () {
              setState(() {
                _isSidebarCollapsed = !_isSidebarCollapsed;
              });
            },
          ),
        ],
      ),
      body: Row(
        children: [
          AnimatedContainer(
            width: _isSidebarCollapsed ? 0 : 250,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            color: Colors.white,
            child: _isSidebarCollapsed
                ? null
                : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Previous Chats',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _previousChats.length,
                    itemBuilder: (context, index) {
                      final chat = _previousChats[index];
                      return ListTile(
                        title: Text(chat.title),
                        subtitle: Text(chat.timestamp.split(' ')[0]),
                        onTap: () => _loadChatSession(chat),
                        tileColor: _currentChatId == chat.id
                            ? primaryGreen.withOpacity(0.1)
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _messages[index];
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_voice,
                            color: primaryGreen),
                        onPressed: () {},
                      ),
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
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: _handleSubmitted,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: primaryGreen),
                        onPressed: () => _handleSubmitted(_textController.text),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatSession {
  final String id;
  final String timestamp;
  final String title;

  ChatSession({
    required this.id,
    required this.timestamp,
    required this.title,
  });

  factory ChatSession.fromMap(String id, Map<Object?, Object?> data) {
    return ChatSession(
      id: id,
      timestamp:
      (data['timestamp'] as String?) ?? DateTime.now().toIso8601String(),
      title: (data['title'] as String?) ?? 'Untitled Chat',
    );
  }
}

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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.chat),
            ),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isUser ? Colors.green[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                text,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (isUser)
            const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.person),
            ),
        ],
      ),
    );
  }
}
