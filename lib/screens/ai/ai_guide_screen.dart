import 'dart:ui'; // Required for Glassmorphism
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../services/ai_service.dart';

class AIGuideScreen extends StatefulWidget {
  const AIGuideScreen({super.key});

  @override
  State<AIGuideScreen> createState() => _AIGuideScreenState();
}

class _AIGuideScreenState extends State<AIGuideScreen> {
  final TextEditingController _controller = TextEditingController();
  final AIService _aiService = AIService();
  final ScrollController _scrollController = ScrollController(); // To auto-scroll

  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // Colors
  final Color pupMaroon = const Color(0xFF800000);
  final Color pupGold = const Color(0xFFFFA500); 

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    final response = await _aiService.sendMessage(text);

    setState(() {
      _messages.add({'role': 'ai', 'text': response ?? "No response"});
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: const Text("PUP AI Guide", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: pupMaroon.withOpacity(0.85), 
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. BACKGROUND GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF5F5F5), Color(0xFFE0E0E0)], 
              ),
            ),
          ),
          
          // Decorative background circle
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: pupMaroon.withOpacity(0.1),
              ),
            ),
          ),

          // 2. CHAT CONTENT
          Column(
            children: [
              Expanded(
                child: _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.school, size: 80, color: pupMaroon.withOpacity(0.3)),
                            const SizedBox(height: 10),
                            Text(
                              "Ask me about PUP!",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 120, 16, 100), 
                        itemCount: _messages.length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _messages.length) {
                            return _buildTypingIndicator();
                          }
                          final msg = _messages[index];
                          return _buildMessageBubble(msg);
                        },
                      ),
              ),
            ],
          ),

          // 3. TRANSPARENT GLASS INPUT (UPDATED)
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), 
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    // --- THE TRANSPARENT EFFECT ---
                    // Pure white with very low opacity (Clear Glass)
                    color: Colors.white.withOpacity(0.1), 
                    // Subtle white border top
                    border: Border(top: BorderSide(color: Colors.white.withOpacity(0.3), width: 1.0)),
                    boxShadow: [
                      // Neutral grey shadow
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white, 
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: "Type your question...",
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // --- SEND BUTTON (Stays Maroon) ---
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [pupMaroon, const Color(0xFFA00000)], 
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: pupMaroon.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: Message Bubble ---
  Widget _buildMessageBubble(Map<String, String> msg) {
    final isUser = msg['role'] == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Avatar
          if (!isUser) 
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 18,
              child: Icon(Icons.school, color: pupMaroon, size: 20),
            ),
          if (!isUser) const SizedBox(width: 8),

          // The Bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // Gradient for User (Maroon->Gold), White for AI
                gradient: isUser 
                  ? LinearGradient(colors: [pupMaroon, pupGold.withOpacity(0.8)]) 
                  : const LinearGradient(colors: [Colors.white, Colors.white]),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(5),
                  bottomRight: isUser ? const Radius.circular(5) : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: MarkdownBody(
                data: msg['text']!,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    color: isUser ? Colors.white : Colors.black87,
                    fontSize: 15,
                    height: 1.4,
                  ),
                  strong: TextStyle(
                    color: isUser ? Colors.white : pupMaroon,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          if (isUser) const SizedBox(width: 8),
          // User Avatar
          if (isUser)
             CircleAvatar(
              backgroundColor: Colors.grey[300],
              radius: 18,
              child: const Icon(Icons.person, color: Colors.grey, size: 20),
            ),
        ],
      ),
    );
  }

  // --- WIDGET: Typing Animation ---
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 44), 
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
             SizedBox(
              width: 16, 
              height: 16, 
              child: CircularProgressIndicator(strokeWidth: 2, color: pupGold)
            ),
            const SizedBox(width: 10),
            Text(
              "PUP Guide is typing...",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}