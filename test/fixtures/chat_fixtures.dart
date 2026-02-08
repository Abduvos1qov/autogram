import 'package:autogram/features/chat/domain/entities/message.dart';
import 'package:autogram/features/chat/domain/entities/conversation.dart';

/// Test fixtures for Chat functionality
class ChatFixtures {
  ChatFixtures._();

  static final DateTime testCreatedAt = DateTime(2024, 1, 15, 10, 30, 0);

  /// Text message
  static Message get textMessage => Message(
        id: 'msg-001',
        conversationId: 'conv-001',
        senderId: 'user-123',
        content: 'Hello! Is this car still available?',
        type: MessageType.text,
        isRead: true,
        readAt: testCreatedAt.add(const Duration(minutes: 5)),
        createdAt: testCreatedAt,
      );

  /// Unread message
  static Message get unreadMessage => Message(
        id: 'msg-002',
        conversationId: 'conv-001',
        senderId: 'seller-456',
        content: 'Yes, it is! Would you like to schedule a viewing?',
        type: MessageType.text,
        isRead: false,
        createdAt: testCreatedAt.add(const Duration(minutes: 10)),
      );

  /// Image message
  static Message get imageMessage => Message(
        id: 'msg-003',
        conversationId: 'conv-001',
        senderId: 'seller-456',
        content: 'https://example.com/car-photo.jpg',
        type: MessageType.image,
        metadata: {'width': 1920, 'height': 1080},
        isRead: true,
        createdAt: testCreatedAt.add(const Duration(minutes: 15)),
      );

  /// Location message
  static Message get locationMessage => Message(
        id: 'msg-004',
        conversationId: 'conv-001',
        senderId: 'seller-456',
        content: 'Meeting location',
        type: MessageType.location,
        metadata: {
          'latitude': 41.311081,
          'longitude': 69.240562,
          'address': 'Tashkent, Yunusobod',
        },
        isRead: false,
        createdAt: testCreatedAt.add(const Duration(minutes: 20)),
      );

  /// List of messages in a conversation
  static List<Message> get conversationMessages => [
        textMessage,
        unreadMessage,
        imageMessage,
        locationMessage,
      ];

  /// Conversation fixture
  static Conversation get conversation => Conversation(
        id: 'conv-001',
        otherUserId: 'seller-456',
        otherUserName: 'Premium Motors',
        otherUserAvatarUrl: 'https://example.com/seller.jpg',
        isOtherUserVerified: true,
        listingId: 'listing-001',
        listingTitle: 'Chevrolet Malibu 2020',
        listingThumbnailUrl: 'https://example.com/car.jpg',
        lastMessageText: unreadMessage.content,
        lastMessageAt: testCreatedAt,
        unreadCount: 2,
        createdAt: testCreatedAt.subtract(const Duration(days: 1)),
      );

  /// Conversation with no unread messages
  static Conversation get readConversation => Conversation(
        id: 'conv-002',
        otherUserId: 'seller-789',
        otherUserName: 'Auto Gallery',
        isOtherUserVerified: false,
        listingId: 'listing-002',
        listingTitle: 'Toyota Camry 2019',
        lastMessageText: textMessage.content,
        lastMessageAt: testCreatedAt.subtract(const Duration(days: 1)),
        unreadCount: 0,
        createdAt: testCreatedAt.subtract(const Duration(days: 3)),
      );

  /// List of conversations
  static List<Conversation> get conversations => [
        conversation,
        readConversation,
      ];
}
