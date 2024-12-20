import 'package:flutter/material.dart';
import 'api_service.dart';
import 'models/message_model.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Message> _messages = [];
  bool _isLoading = false;
  
  // Для "анимации" печати сообщения бота
  String _currentBotMessage = "";
  Timer? _typingTimer;
  String _fullBotResponse = "";

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    // Скролл к низу после добавления сообщения
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _sendMessage() async {
    final userText = _textController.text.trim();
    if (userText.isEmpty) return;

    setState(() {
      _messages.add(Message(sender: "user", text: userText));
      _textController.clear();
      _isLoading = true;
      _fullBotResponse = "";
      _currentBotMessage = "";
    });

    _scrollToBottom();

    try {
      final response = await _apiService.sendMessage(userText);
      setState(() {
        _isLoading = false;
        _fullBotResponse = response;
      });
      _showTypingAnimation(_fullBotResponse);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.add(Message(sender: "bot", text: "Ошибка соединения с сервером."));
      });
      _scrollToBottom();
    }
  }

  void _showTypingAnimation(String fullMessage) {
    int currentIndex = 0;
    const duration = Duration(milliseconds: 30); // Скорость печати

    _typingTimer?.cancel();
    _typingTimer = Timer.periodic(duration, (timer) {
      if (currentIndex < fullMessage.length) {
        setState(() {
          _currentBotMessage = fullMessage.substring(0, currentIndex + 1);
        });
        currentIndex++;
        _updateBotMessageInList(_currentBotMessage);
        _scrollToBottom();
      } else {
        timer.cancel();
      }
    });
  }

  void _updateBotMessageInList(String text) {
    // Если последним сообщением является печатающееся сообщение бота, обновляем его
    // Если нет, добавляем новое.
    if (_messages.isNotEmpty && _messages.last.sender == "bot" && _messages.last.text != _fullBotResponse) {
      _messages[_messages.length - 1] = Message(sender: "bot", text: text);
    } else {
      _messages.add(Message(sender: "bot", text: text));
    }
  }

  Widget _buildMessage(Message message) {
    final isUser = message.sender == "user";

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            CircleAvatar(
              backgroundColor: Colors.blue[400],
              child: Icon(Icons.android, color: Colors.white),
            ),
          Flexible(
            child: Container(
              margin:
                  EdgeInsets.only(left: isUser ? 50 : 10, right: isUser ? 10 : 50),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue[600] : Colors.grey[300],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 12 : 0),
                  topRight: Radius.circular(isUser ? 0 : 12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (isUser)
            CircleAvatar(
              backgroundColor: Colors.blue[400],
              child: Icon(Icons.person, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: "Введите сообщение...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            SizedBox(width: 8),
            InkWell(
              onTap: _sendMessage,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return _isLoading
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(child: CircularProgressIndicator()),
          )
        : SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kappy Chat"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[100]!, Colors.grey[300]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessage(_messages[index]);
                },
              ),
            ),
          ),
          _buildLoadingIndicator(),
          _buildInputArea(),
        ],
      ),
    );
  }
}
