import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/chat/chat_service.dart';
import '../../services/device/device_service.dart';
import '../../services/database/user_session_db.dart';
import '../../models/entities/chat_message.dart';

class ChatScreen extends StatefulWidget {
  final String orderId;
  final String customerFirebaseUID;
  final String customerName;
  final String? customerUserId;

  const ChatScreen({
    super.key,
    required this.orderId,
    required this.customerFirebaseUID,
    required this.customerName,
    this.customerUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isUploading = false;
  String? _currentUserUID;

  @override
  void initState() {
    super.initState();
    _getCurrentUserUID();
    _loadMessages();
  }

  Future<void> _getCurrentUserUID() async {
    final session = await UserSessionDB.getSession();
    final userId = session?['user_id']?.toString();

    if (userId != null && userId.isNotEmpty) {
      setState(() => _currentUserUID = userId);
    } else {
      final uid = await DeviceService.getFirebaseUID();
      setState(() => _currentUserUID = uid);
    }
  }

  void _loadMessages() {
    ChatService.getMessagesStream(widget.orderId).listen((messages) {
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    });
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

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    try {
      final receiverUID = widget.customerUserId ?? widget.customerFirebaseUID;

      await ChatService.sendMessage(
        senderUID: _currentUserUID!,
        receiverUID: receiverUID,
        text: message,
        orderId: widget.orderId,
      );
    } catch (e) {
      _showError('Failed to send message: $e');
    }
  }

  Future<void> _pickAndSendImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isUploading = true);

      final receiverUID = widget.customerUserId ?? widget.customerFirebaseUID;

      await ChatService.sendImageMessage(
        senderUID: _currentUserUID!,
        receiverUID: receiverUID,
        imageFile: File(image.path),
        orderId: widget.orderId,
      );

      setState(() => _isUploading = false);
    } catch (e) {
      setState(() => _isUploading = false);
      _showError('Failed to send image: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF5D8AA8)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF5D8AA8),
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.customerName,
                    style: const TextStyle(
                      color: Color(0xFF5D8AA8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Order #${widget.orderId}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe = message.senderUID == _currentUserUID;
                      return _buildMessageBubble(message, isMe);
                    },
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the conversation with your customer',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.messageType == 'image' && message.imageUrl != null)
              _buildImageBubble(message, isMe)
            else
              _buildTextBubble(message, isMe),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
              child: Text(
                DateFormat('HH:mm').format(message.timestamp),
                style: TextStyle(
                  fontSize: 10,
                  color: isMe ? Colors.grey[600] : Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextBubble(ChatMessage message, bool isMe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFF5D8AA8) : Colors.grey[200],
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMe ? 16 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 16),
        ),
      ),
      child: Text(
        message.text,
        style: TextStyle(
          color: isMe ? Colors.white : Colors.black87,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildImageBubble(ChatMessage message, bool isMe) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              message.imageUrl!,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stack) {
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                );
              },
            ),
          ),
          if (message.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isMe ? const Color(0xFF5D8AA8) : Colors.black87,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image picker button
          CircleAvatar(
            backgroundColor: Colors.grey[200],
            child: IconButton(
              icon: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.image, color: Color(0xFF5D8AA8)),
              onPressed: _isUploading ? null : _pickAndSendImage,
            ),
          ),
          const SizedBox(width: 8),

          // Text field
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),

          // Send button
          CircleAvatar(
            backgroundColor: const Color(0xFF5D8AA8),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
