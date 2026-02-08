import 'package:autogram/features/home/domain/entities/feed_item.dart';
import 'package:autogram/core/network/api_response.dart';

/// Test fixtures for Feed items
class FeedFixtures {
  FeedFixtures._();

  static final DateTime testPublishedAt = DateTime(2024, 1, 15, 10, 30, 0);

  /// Basic feed item with video
  static FeedItem get withVideo => FeedItem(
        id: 'feed-001',
        sellerId: 'seller-001',
        sellerName: 'Premium Motors',
        sellerLogoUrl: 'https://example.com/logo.jpg',
        isSellerVerified: true,
        title: 'Chevrolet Malibu 2020',
        description: 'Excellent condition, low mileage',
        price: 25000,
        currency: 'USD',
        isNegotiable: true,
        videoUrl: 'https://example.com/video.mp4',
        videoThumbnailUrl: 'https://example.com/thumb.jpg',
        videoDuration: 45,
        images: [
          'https://example.com/img1.jpg',
          'https://example.com/img2.jpg',
        ],
        city: 'Toshkent',
        district: 'Yunusobod',
        autoDetails: autoDetails,
        viewsCount: 150,
        likesCount: 25,
        savesCount: 10,
        isLiked: false,
        isSaved: false,
        publishedAt: testPublishedAt,
      );

  /// Feed item without video (images only)
  static FeedItem get withoutVideo => FeedItem(
        id: 'feed-002',
        sellerId: 'seller-002',
        sellerName: 'Auto Gallery',
        isSellerVerified: false,
        title: 'Toyota Camry 2019',
        description: 'One owner, full service history',
        price: 22000,
        currency: 'USD',
        isNegotiable: false,
        images: [
          'https://example.com/camry1.jpg',
          'https://example.com/camry2.jpg',
          'https://example.com/camry3.jpg',
        ],
        city: 'Samarqand',
        autoDetails: const AutoDetails(
          brand: 'Toyota',
          model: 'Camry',
          year: 2019,
          mileage: 45000,
          fuelType: 'petrol',
          transmission: 'automatic',
          driveType: 'front',
          bodyType: 'sedan',
          color: 'White',
          engineVolume: 2.5,
          condition: 'excellent',
          hasAccident: false,
          ownersCount: 1,
        ),
        viewsCount: 89,
        likesCount: 12,
        savesCount: 5,
        isLiked: true,
        isSaved: false,
        publishedAt: testPublishedAt,
      );

  /// Feed item that is liked and saved
  static FeedItem get likedAndSaved => FeedItem(
        id: 'feed-003',
        sellerId: 'seller-003',
        sellerName: 'Best Cars',
        isSellerVerified: true,
        title: 'BMW X5 2021',
        price: 55000,
        currency: 'USD',
        isNegotiable: true,
        images: ['https://example.com/bmw.jpg'],
        viewsCount: 500,
        likesCount: 100,
        savesCount: 50,
        isLiked: true,
        isSaved: true,
        publishedAt: testPublishedAt,
      );

  /// Auto details fixture
  static const AutoDetails autoDetails = AutoDetails(
    brand: 'Chevrolet',
    model: 'Malibu',
    year: 2020,
    mileage: 35000,
    fuelType: 'petrol',
    transmission: 'automatic',
    driveType: 'front',
    bodyType: 'sedan',
    color: 'Black',
    engineVolume: 1.5,
    condition: 'excellent',
    hasAccident: false,
    ownersCount: 1,
  );

  /// List of feed items for pagination testing
  static List<FeedItem> get feedList => [
        withVideo,
        withoutVideo,
        likedAndSaved,
      ];

  /// Paginated response with more items
  static PaginatedResponse<FeedItem> get paginatedResponseWithMore =>
      PaginatedResponse<FeedItem>(
        data: feedList,
        page: 1,
        pageSize: 20,
        total: 100,
        hasMore: true,
      );

  /// Paginated response without more items
  static PaginatedResponse<FeedItem> get paginatedResponseNoMore =>
      PaginatedResponse<FeedItem>(
        data: feedList,
        page: 5,
        pageSize: 20,
        total: 100,
        hasMore: false,
      );

  /// Empty paginated response
  static PaginatedResponse<FeedItem> get emptyResponse =>
      const PaginatedResponse<FeedItem>(
        data: [],
        page: 1,
        pageSize: 20,
        total: 0,
        hasMore: false,
      );
}
