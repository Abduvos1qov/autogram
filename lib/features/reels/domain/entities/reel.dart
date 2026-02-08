import 'package:equatable/equatable.dart';

import '../../../home/domain/entities/feed_item.dart';

/// Reel entity - represents a video listing in reels format

class Reel extends Equatable {
  final String id;
  final String sellerId;
  final String sellerName;
  final String? sellerLogoUrl;
  final bool isSellerVerified;
  final String title;
  final String? description;
  final double price;
  final String currency;
  final bool isNegotiable;
  final String videoUrl;
  final String? videoThumbnailUrl;
  final String? videoHlsUrl;
  final int videoDuration;
  final String? city;
  final AutoDetails? autoDetails;
  final int viewsCount;
  final int likesCount;
  final int savesCount;
  final int commentsCount;
  final int sharesCount;
  final bool isLiked;
  final bool isSaved;
  final bool isFollowing;
  final DateTime publishedAt;

  const Reel({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    this.sellerLogoUrl,
    required this.isSellerVerified,
    required this.title,
    this.description,
    required this.price,
    required this.currency,
    required this.isNegotiable,
    required this.videoUrl,
    this.videoThumbnailUrl,
    this.videoHlsUrl,
    required this.videoDuration,
    this.city,
    this.autoDetails,
    required this.viewsCount,
    required this.likesCount,
    required this.savesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.isLiked,
    required this.isSaved,
    required this.isFollowing,
    required this.publishedAt,
  });

  String get playbackUrl => videoHlsUrl ?? videoUrl;

  Reel copyWith({
    String? id,
    String? sellerId,
    String? sellerName,
    String? sellerLogoUrl,
    bool? isSellerVerified,
    String? title,
    String? description,
    double? price,
    String? currency,
    bool? isNegotiable,
    String? videoUrl,
    String? videoThumbnailUrl,
    String? videoHlsUrl,
    int? videoDuration,
    String? city,
    AutoDetails? autoDetails,
    int? viewsCount,
    int? likesCount,
    int? savesCount,
    int? commentsCount,
    int? sharesCount,
    bool? isLiked,
    bool? isSaved,
    bool? isFollowing,
    DateTime? publishedAt,
  }) {
    return Reel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerLogoUrl: sellerLogoUrl ?? this.sellerLogoUrl,
      isSellerVerified: isSellerVerified ?? this.isSellerVerified,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      isNegotiable: isNegotiable ?? this.isNegotiable,
      videoUrl: videoUrl ?? this.videoUrl,
      videoThumbnailUrl: videoThumbnailUrl ?? this.videoThumbnailUrl,
      videoHlsUrl: videoHlsUrl ?? this.videoHlsUrl,
      videoDuration: videoDuration ?? this.videoDuration,
      city: city ?? this.city,
      autoDetails: autoDetails ?? this.autoDetails,
      viewsCount: viewsCount ?? this.viewsCount,
      likesCount: likesCount ?? this.likesCount,
      savesCount: savesCount ?? this.savesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      isFollowing: isFollowing ?? this.isFollowing,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sellerId,
        sellerName,
        sellerLogoUrl,
        isSellerVerified,
        title,
        description,
        price,
        currency,
        isNegotiable,
        videoUrl,
        videoThumbnailUrl,
        videoHlsUrl,
        videoDuration,
        city,
        autoDetails,
        viewsCount,
        likesCount,
        savesCount,
        commentsCount,
        sharesCount,
        isLiked,
        isSaved,
        isFollowing,
        publishedAt,
      ];
}
