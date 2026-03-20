import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/entities/chat_message.dart';

class ChatService {
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Send text message
  static Future<void> sendMessage({
    required String senderUID,
    required String receiverUID,
    required String text,
    required String orderId,
  }) async {
    try {
      final messageRef = _database
          .child('chats')
          .child(orderId)
          .child('messages')
          .push();

      final message = ChatMessage(
        id: messageRef.key!,
        senderUID: senderUID,
        receiverUID: receiverUID,
        text: text,
        timestamp: DateTime.now(),
        orderId: orderId,
        messageType: 'text',
      );

      await messageRef.set(message.toJson());
      print('[CHAT] Text message sent: $text');
    } catch (e) {
      print('[CHAT ERROR] sendMessage: $e');
      rethrow;
    }
  }

  // Send image message
  static Future<void> sendImageMessage({
    required String senderUID,
    required String receiverUID,
    required File imageFile,
    required String orderId,
    String? caption,
  }) async {
    try {
      // Upload image to Firebase Storage
      final fileName =
          'chat_images/$orderId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(fileName);
      final uploadTask = await storageRef.putFile(imageFile);
      final imageUrl = await uploadTask.ref.getDownloadURL();

      // Send message with image URL
      final messageRef = _database
          .child('chats')
          .child(orderId)
          .child('messages')
          .push();

      final message = ChatMessage(
        id: messageRef.key!,
        senderUID: senderUID,
        receiverUID: receiverUID,
        text: caption ?? '',
        timestamp: DateTime.now(),
        orderId: orderId,
        imageUrl: imageUrl,
        messageType: 'image',
      );

      await messageRef.set(message.toJson());
      print('[CHAT] Image message sent');
    } catch (e) {
      print('[CHAT ERROR] sendImageMessage: $e');
      rethrow;
    }
  }

  // Listen to messages stream
  static Stream<List<ChatMessage>> getMessagesStream(String orderId) {
    return _database
        .child('chats')
        .child(orderId)
        .child('messages')
        .onValue
        .map((event) {
          if (event.snapshot.value == null) return [];

          final messagesMap = event.snapshot.value as Map<dynamic, dynamic>;
          final messages = <ChatMessage>[];

          messagesMap.forEach((key, value) {
            if (value is Map) {
              messages.add(
                ChatMessage.fromJson(
                  key.toString(),
                  Map<String, dynamic>.from(value),
                ),
              );
            }
          });

          messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          return messages;
        });
  }

  // Get messages once
  static Future<List<ChatMessage>> getMessages(String orderId) async {
    try {
      final snapshot = await _database
          .child('chats')
          .child(orderId)
          .child('messages')
          .get();

      if (snapshot.value == null) return [];

      final messagesMap = snapshot.value as Map<dynamic, dynamic>;
      final messages = <ChatMessage>[];

      messagesMap.forEach((key, value) {
        if (value is Map) {
          messages.add(
            ChatMessage.fromJson(
              key.toString(),
              Map<String, dynamic>.from(value),
            ),
          );
        }
      });

      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return messages;
    } catch (e) {
      print('[CHAT ERROR] getMessages: $e');
      return [];
    }
  }

  // Delete chat
  static Future<void> deleteOrderChat(String orderId) async {
    try {
      await _database.child('chats').child(orderId).remove();
      print('[CHAT] Chat deleted for order: $orderId');
    } catch (e) {
      print('[CHAT ERROR] deleteOrderChat: $e');
      rethrow;
    }
  }
}
