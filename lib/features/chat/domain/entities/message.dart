import 'package:equatable/equatable.dart';

/// Message entity

class Message extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final MessageType type;
  final Map<String, dynamic> metadata;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.type,
    this.metadata = const {},
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  bool isMine(String currentUserId) => senderId == currentUserId;

  @override
  List<Object?> get props => [
        id,
        conversationId,
        senderId,
        content,
        type,
        metadata,
        isRead,
        readAt,
        createdAt,
      ];
}

enum MessageType {
  text,
  image,
  location,
  contact;

  static MessageType fromString(String value) {
    switch (value) {
      case 'image':
        return MessageType.image;
      case 'location':
        return MessageType.location;
      case 'contact':
        return MessageType.contact;
      default:
        return MessageType.text;
    }
  }
}
