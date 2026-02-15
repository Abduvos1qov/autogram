import '../../features/auth/domain/entities/user.dart';
import '../../features/chat/domain/entities/conversation.dart';
import '../../features/chat/domain/entities/message.dart';
import '../../features/home/domain/entities/feed_item.dart' as home;
import '../../features/listing/domain/entities/listing.dart';
import '../../features/reels/domain/entities/reel.dart';

/// Mock data for testing the app without backend
class MockData {
  // Mock users
  static final List<User> mockUsers = [
    User(
      id: 'user1',
      phone: '+998901234567',
      fullName: 'Sardor Aliyev',
      email: 'sardor@example.com',
      avatarUrl: 'https://ui-avatars.com/api/?name=Sardor+Aliyev&size=200',
      role: UserRole.buyer,
      isVerified: false,
      isActive: true,
      language: 'uz',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    ),
    User(
      id: 'user2',
      phone: '+998909876543',
      fullName: 'Aziza Karimova',
      email: 'aziza@example.com',
      avatarUrl: 'https://ui-avatars.com/api/?name=Aziza+Karimova&size=200',
      role: UserRole.seller,
      isVerified: true,
      isActive: true,
      language: 'uz',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now(),
    ),
    User(
      id: 'user3',
      phone: '+998971234567',
      fullName: 'Jasur Toshmatov',
      email: 'jasur@example.com',
      avatarUrl: 'https://ui-avatars.com/api/?name=Jasur+Toshmatov&size=200',
      role: UserRole.seller,
      isVerified: true,
      isActive: true,
      language: 'uz',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now(),
    ),
  ];

  // Mock sellers
  static final List<Seller> mockSellers = [
    Seller(
      id: 'seller1',
      userId: 'user2',
      businessName: 'AutoStar Salon',
      businessType: 'dealer',
      description: 'Eng yaxshi avtomobillar',
      logoUrl: 'https://ui-avatars.com/api/?name=AutoStar&size=200&background=0088cc&color=fff',
      coverUrl: 'https://picsum.photos/800/400?random=1',
      address: 'Sergeli ko\'chasi 15',
      city: 'Toshkent',
      district: 'Sergeli',
      latitude: 41.2162,
      longitude: 69.2563,
      contactPhones: ['+998901234567', '+998971234567'],
      telegram: '@autostar_uz',
      instagram: '@autostar_uz',
      website: 'https://autostar.uz',
      workingHours: {
        'monday': '9:00-19:00',
        'tuesday': '9:00-19:00',
        'wednesday': '9:00-19:00',
        'thursday': '9:00-19:00',
        'friday': '9:00-19:00',
        'saturday': '9:00-18:00',
        'sunday': 'closed',
      },
      isVerified: true,
      verifiedAt: DateTime.now().subtract(const Duration(days: 30)),
      subscriptionType: 'premium',
      subscriptionExpiresAt: DateTime.now().add(const Duration(days: 365)),
      totalListings: 45,
      activeListings: 38,
      totalSold: 234,
      totalViews: 12450,
      avgRating: 4.8,
      totalReviews: 156,
      isFollowing: false,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
    Seller(
      id: 'seller2',
      userId: 'user3',
      businessName: 'AvtoPlus Motors',
      businessType: 'dealer',
      description: 'Sifatli avtomobillar',
      logoUrl: 'https://ui-avatars.com/api/?name=AvtoPlus&size=200&background=ff6600&color=fff',
      coverUrl: 'https://picsum.photos/800/400?random=2',
      address: 'Chilonzor 12-mavze',
      city: 'Toshkent',
      district: 'Chilonzor',
      latitude: 41.2850,
      longitude: 69.2036,
      contactPhones: ['+998909876543'],
      telegram: '@avtoplus',
      instagram: '@avtoplus_motors',
      workingHours: {
        'monday': '9:00-20:00',
        'tuesday': '9:00-20:00',
        'wednesday': '9:00-20:00',
        'thursday': '9:00-20:00',
        'friday': '9:00-20:00',
        'saturday': '9:00-20:00',
        'sunday': '10:00-18:00',
      },
      isVerified: true,
      verifiedAt: DateTime.now().subtract(const Duration(days: 60)),
      subscriptionType: 'premium',
      subscriptionExpiresAt: DateTime.now().add(const Duration(days: 180)),
      totalListings: 32,
      activeListings: 28,
      totalSold: 189,
      totalViews: 9870,
      avgRating: 4.6,
      totalReviews: 98,
      isFollowing: true,
      createdAt: DateTime.now().subtract(const Duration(days: 300)),
    ),
    Seller(
      id: 'seller3',
      userId: 'user1',
      businessName: 'Premium Auto',
      businessType: 'dealer',
      description: 'Premium sinfli avtomobillar',
      logoUrl: 'https://ui-avatars.com/api/?name=Premium+Auto&size=200&background=333333&color=fff',
      coverUrl: 'https://picsum.photos/800/400?random=3',
      address: 'Yunusobod 8-mavze',
      city: 'Toshkent',
      district: 'Yunusobod',
      latitude: 41.3491,
      longitude: 69.2891,
      contactPhones: ['+998881234567'],
      telegram: '@premium_auto',
      workingHours: {},
      isVerified: true,
      verifiedAt: DateTime.now().subtract(const Duration(days: 90)),
      subscriptionType: 'basic',
      subscriptionExpiresAt: DateTime.now().add(const Duration(days: 30)),
      totalListings: 18,
      activeListings: 15,
      totalSold: 67,
      totalViews: 4560,
      avgRating: 4.9,
      totalReviews: 45,
      isFollowing: false,
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
    ),
  ];

  // Mock listings
  static final List<Listing> mockListings = [
    Listing(
      id: 'listing1',
      sellerId: 'seller1',
      categoryId: 'cars',
      title: 'Chevrolet Gentra 2022',
      description: 'A\'lo holatda, to\'liq to\'plangan versiya. Garajda turgan.',
      price: 15000,
      currency: 'USD',
      isNegotiable: true,
      status: ListingStatus.active,
      isFeatured: true,
      featuredUntil: DateTime.now().add(const Duration(days: 7)),
      videoUrl: 'https://customer-m033z5x00ks6nunl.cloudflarestream.com/b236bde30eb07b9d01318940e5fc3eda/manifest/video.m3u8',
      videoThumbnailUrl: 'https://picsum.photos/400/600?random=1',
      videoDuration: 45,
      images: [
        'https://picsum.photos/400/600?random=1',
        'https://picsum.photos/400/600?random=2',
        'https://picsum.photos/400/600?random=3',
      ],
      city: 'Toshkent',
      district: 'Sergeli',
      viewsCount: 2340,
      likesCount: 234,
      savesCount: 89,
      sharesCount: 45,
      isLiked: false,
      isSaved: false,
      autoDetails: const AutoDetails(
        brand: 'Chevrolet',
        model: 'Gentra',
        year: 2022,
        mileage: 45000,
        fuelType: 'Benzin',
        transmission: 'Avtomat',
        driveType: 'Old',
        bodyType: 'Sedan',
        color: 'Oq',
        engineVolume: 1.5,
        condition: 'Yangi',
        hasAccident: false,
        ownersCount: 1,
        features: ['ABS', 'Klimat-kontrol', 'Orqa kamera', 'Park radar'],
      ),
      seller: mockSellers[0],
      publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Listing(
      id: 'listing2',
      sellerId: 'seller1',
      categoryId: 'cars',
      title: 'Chevrolet Malibu 2 2023',
      description: 'Premier to\'plangan, 1 ta xo\'jayindan. Toza holatda.',
      price: 32000,
      currency: 'USD',
      isNegotiable: true,
      status: ListingStatus.active,
      isFeatured: false,
      videoUrl: 'https://customer-m033z5x00ks6nunl.cloudflarestream.com/b236bde30eb07b9d01318940e5fc3eda/manifest/video.m3u8',
      videoThumbnailUrl: 'https://picsum.photos/400/600?random=4',
      videoDuration: 60,
      images: [
        'https://picsum.photos/400/600?random=4',
        'https://picsum.photos/400/600?random=5',
      ],
      city: 'Toshkent',
      district: 'Sergeli',
      viewsCount: 1890,
      likesCount: 187,
      savesCount: 56,
      sharesCount: 23,
      isLiked: true,
      isSaved: false,
      autoDetails: const AutoDetails(
        brand: 'Chevrolet',
        model: 'Malibu 2',
        year: 2023,
        mileage: 15000,
        fuelType: 'Benzin',
        transmission: 'Avtomat',
        driveType: 'Old',
        bodyType: 'Sedan',
        color: 'Qora',
        engineVolume: 1.5,
        condition: 'Yangi',
        hasAccident: false,
        ownersCount: 1,
        features: ['ABS', 'Klimat-kontrol', 'Teri salon', 'Panorama tom'],
      ),
      seller: mockSellers[0],
      publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Listing(
      id: 'listing3',
      sellerId: 'seller2',
      categoryId: 'cars',
      title: 'Chevrolet Tracker 2024',
      description: 'Yangi mashina, garantiya bilan. Barcha qog\'oz ishlari tugallangan.',
      price: 28500,
      currency: 'USD',
      isNegotiable: false,
      status: ListingStatus.active,
      isFeatured: true,
      featuredUntil: DateTime.now().add(const Duration(days: 3)),
      videoUrl: 'https://customer-m033z5x00ks6nunl.cloudflarestream.com/b236bde30eb07b9d01318940e5fc3eda/manifest/video.m3u8',
      videoThumbnailUrl: 'https://picsum.photos/400/600?random=6',
      videoDuration: 50,
      images: [
        'https://picsum.photos/400/600?random=6',
        'https://picsum.photos/400/600?random=7',
        'https://picsum.photos/400/600?random=8',
      ],
      city: 'Toshkent',
      district: 'Chilonzor',
      viewsCount: 3120,
      likesCount: 298,
      savesCount: 112,
      sharesCount: 67,
      isLiked: false,
      isSaved: true,
      autoDetails: const AutoDetails(
        brand: 'Chevrolet',
        model: 'Tracker',
        year: 2024,
        mileage: 0,
        fuelType: 'Benzin',
        transmission: 'Avtomat',
        driveType: 'To\'liq',
        bodyType: 'Krossover',
        color: 'Ko\'k',
        engineVolume: 1.5,
        condition: 'Yangi',
        hasAccident: false,
        ownersCount: 1,
        features: ['ABS', 'Klimat-kontrol', 'Orqa kamera', 'Kruiz-kontrol'],
      ),
      seller: mockSellers[1],
      publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
      createdAt: DateTime.now().subtract(const Duration(hours: 9)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    Listing(
      id: 'listing4',
      sellerId: 'seller2',
      categoryId: 'cars',
      title: 'Chevrolet Cobalt 2021',
      description: 'Ideal holatda, barcha texnik ko\'riklar o\'tkazilgan.',
      price: 12000,
      currency: 'USD',
      isNegotiable: true,
      status: ListingStatus.active,
      isFeatured: false,
      videoUrl: 'https://customer-m033z5x00ks6nunl.cloudflarestream.com/b236bde30eb07b9d01318940e5fc3eda/manifest/video.m3u8',
      videoThumbnailUrl: 'https://picsum.photos/400/600?random=9',
      videoDuration: 40,
      images: [
        'https://picsum.photos/400/600?random=9',
        'https://picsum.photos/400/600?random=10',
      ],
      city: 'Toshkent',
      district: 'Chilonzor',
      viewsCount: 1560,
      likesCount: 145,
      savesCount: 34,
      sharesCount: 18,
      isLiked: false,
      isSaved: false,
      autoDetails: const AutoDetails(
        brand: 'Chevrolet',
        model: 'Cobalt',
        year: 2021,
        mileage: 65000,
        fuelType: 'Benzin/Gaz',
        transmission: 'Mexanika',
        driveType: 'Old',
        bodyType: 'Sedan',
        color: 'Kulrang',
        engineVolume: 1.5,
        condition: 'Ishlatilgan',
        hasAccident: false,
        ownersCount: 1,
        features: ['ABS', 'Konditsioner'],
      ),
      seller: mockSellers[1],
      publishedAt: DateTime.now().subtract(const Duration(hours: 12)),
      createdAt: DateTime.now().subtract(const Duration(hours: 13)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    Listing(
      id: 'listing5',
      sellerId: 'seller3',
      categoryId: 'cars',
      title: 'Kia K5 2022',
      description: 'Koreya yig\'imi, premier to\'plangan. Barcha zarur qulayliklar bilan.',
      price: 35000,
      currency: 'USD',
      isNegotiable: true,
      status: ListingStatus.active,
      isFeatured: true,
      featuredUntil: DateTime.now().add(const Duration(days: 5)),
      videoUrl: 'https://customer-m033z5x00ks6nunl.cloudflarestream.com/b236bde30eb07b9d01318940e5fc3eda/manifest/video.m3u8',
      videoThumbnailUrl: 'https://picsum.photos/400/600?random=11',
      videoDuration: 55,
      images: [
        'https://picsum.photos/400/600?random=11',
        'https://picsum.photos/400/600?random=12',
        'https://picsum.photos/400/600?random=13',
        'https://picsum.photos/400/600?random=14',
      ],
      city: 'Toshkent',
      district: 'Yunusobod',
      viewsCount: 4230,
      likesCount: 412,
      savesCount: 156,
      sharesCount: 89,
      isLiked: true,
      isSaved: true,
      autoDetails: const AutoDetails(
        brand: 'Kia',
        model: 'K5',
        year: 2022,
        mileage: 28000,
        fuelType: 'Benzin',
        transmission: 'Avtomat',
        driveType: 'Old',
        bodyType: 'Sedan',
        color: 'Oq',
        engineVolume: 2.0,
        condition: 'Yangi',
        hasAccident: false,
        ownersCount: 1,
        features: ['ABS', 'Klimat-kontrol', 'Teri salon', 'Panorama tom', 'Orqa kamera', 'Kruiz-kontrol'],
      ),
      seller: mockSellers[2],
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Listing(
      id: 'listing6',
      sellerId: 'seller3',
      categoryId: 'cars',
      title: 'Kia Sportage 2023',
      description: 'Premium krossover, to\'liq to\'plangan. Garajda turgan.',
      price: 42000,
      currency: 'USD',
      isNegotiable: false,
      status: ListingStatus.active,
      isFeatured: false,
      videoUrl: 'https://customer-m033z5x00ks6nunl.cloudflarestream.com/b236bde30eb07b9d01318940e5fc3eda/manifest/video.m3u8',
      videoThumbnailUrl: 'https://picsum.photos/400/600?random=15',
      videoDuration: 65,
      images: [
        'https://picsum.photos/400/600?random=15',
        'https://picsum.photos/400/600?random=16',
      ],
      city: 'Toshkent',
      district: 'Yunusobod',
      viewsCount: 2890,
      likesCount: 267,
      savesCount: 98,
      sharesCount: 45,
      isLiked: false,
      isSaved: false,
      autoDetails: const AutoDetails(
        brand: 'Kia',
        model: 'Sportage',
        year: 2023,
        mileage: 12000,
        fuelType: 'Benzin',
        transmission: 'Avtomat',
        driveType: 'To\'liq',
        bodyType: 'Krossover',
        color: 'Qora',
        engineVolume: 2.0,
        condition: 'Yangi',
        hasAccident: false,
        ownersCount: 1,
        features: ['ABS', 'Klimat-kontrol', 'Teri salon', 'Panorama tom', 'Orqa kamera', 'Park radar', 'Kruiz-kontrol'],
      ),
      seller: mockSellers[2],
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Listing(
      id: 'listing7',
      sellerId: 'seller1',
      categoryId: 'cars',
      title: 'Chevrolet Lacetti 2020',
      description: 'O\'rta holatda, gaz o\'rnatilgan. Narxi kelishiladi.',
      price: 9500,
      currency: 'USD',
      isNegotiable: true,
      status: ListingStatus.active,
      isFeatured: false,
      videoUrl: 'https://customer-m033z5x00ks6nunl.cloudflarestream.com/b236bde30eb07b9d01318940e5fc3eda/manifest/video.m3u8',
      videoThumbnailUrl: 'https://picsum.photos/400/600?random=17',
      videoDuration: 35,
      images: [
        'https://picsum.photos/400/600?random=17',
        'https://picsum.photos/400/600?random=18',
      ],
      city: 'Toshkent',
      district: 'Sergeli',
      viewsCount: 1120,
      likesCount: 89,
      savesCount: 23,
      sharesCount: 12,
      isLiked: false,
      isSaved: false,
      autoDetails: const AutoDetails(
        brand: 'Chevrolet',
        model: 'Lacetti',
        year: 2020,
        mileage: 95000,
        fuelType: 'Benzin/Gaz',
        transmission: 'Mexanika',
        driveType: 'Old',
        bodyType: 'Xetchbek',
        color: 'Kumush',
        engineVolume: 1.6,
        condition: 'Ishlatilgan',
        hasAccident: false,
        ownersCount: 2,
        features: ['ABS', 'Konditsioner'],
      ),
      seller: mockSellers[0],
      publishedAt: DateTime.now().subtract(const Duration(days: 3)),
      createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  // Mock reels (same as listings but formatted for reels)
  static List<Reel> get mockReels {
    return mockListings
        .where((listing) => listing.videoUrl != null)
        .map((listing) {
          // Convert AutoDetails from listing to home.AutoDetails (Reel uses the same as home)
          home.AutoDetails? reelAutoDetails;
          if (listing.autoDetails != null) {
            reelAutoDetails = home.AutoDetails(
              brand: listing.autoDetails!.brand,
              model: listing.autoDetails!.model,
              year: listing.autoDetails!.year,
              mileage: listing.autoDetails!.mileage,
              fuelType: listing.autoDetails!.fuelType,
              transmission: listing.autoDetails!.transmission,
              driveType: listing.autoDetails!.driveType,
              bodyType: listing.autoDetails!.bodyType,
              color: listing.autoDetails!.color,
              engineVolume: listing.autoDetails!.engineVolume,
              condition: listing.autoDetails!.condition,
              hasAccident: listing.autoDetails!.hasAccident,
              ownersCount: listing.autoDetails!.ownersCount,
            );
          }

          return Reel(
            id: listing.id,
            sellerId: listing.sellerId,
            sellerName: listing.seller.businessName,
            sellerLogoUrl: listing.seller.logoUrl,
            isSellerVerified: listing.seller.isVerified,
            title: listing.title,
            description: listing.description,
            price: listing.price,
            currency: listing.currency,
            isNegotiable: listing.isNegotiable,
            videoUrl: listing.videoUrl!,
            videoThumbnailUrl: listing.videoThumbnailUrl,
            videoHlsUrl: listing.videoUrl,
            videoDuration: listing.videoDuration ?? 45,
            city: listing.city,
            autoDetails: reelAutoDetails,
            viewsCount: listing.viewsCount,
            likesCount: listing.likesCount,
            savesCount: listing.savesCount,
            commentsCount: (listing.likesCount * 0.3).round(),
            sharesCount: listing.sharesCount,
            isLiked: listing.isLiked,
            isSaved: listing.isSaved,
            isFollowing: listing.seller.isFollowing,
            publishedAt: listing.publishedAt ?? DateTime.now(),
          );
        })
        .toList();
  }

  // Mock feed items
  static List<home.FeedItem> get mockFeedItems {
    return mockListings.map((listing) {
      // Convert AutoDetails from listing to home.AutoDetails
      home.AutoDetails? homeAutoDetails;
      if (listing.autoDetails != null) {
        homeAutoDetails = home.AutoDetails(
          brand: listing.autoDetails!.brand,
          model: listing.autoDetails!.model,
          year: listing.autoDetails!.year,
          mileage: listing.autoDetails!.mileage,
          fuelType: listing.autoDetails!.fuelType,
          transmission: listing.autoDetails!.transmission,
          driveType: listing.autoDetails!.driveType,
          bodyType: listing.autoDetails!.bodyType,
          color: listing.autoDetails!.color,
          engineVolume: listing.autoDetails!.engineVolume,
          condition: listing.autoDetails!.condition,
          hasAccident: listing.autoDetails!.hasAccident,
          ownersCount: listing.autoDetails!.ownersCount,
        );
      }

      return home.FeedItem(
        id: listing.id,
        sellerId: listing.sellerId,
        sellerName: listing.seller.businessName,
        sellerLogoUrl: listing.seller.logoUrl,
        isSellerVerified: listing.seller.isVerified,
        title: listing.title,
        description: listing.description,
        price: listing.price,
        currency: listing.currency,
        isNegotiable: listing.isNegotiable,
        videoUrl: listing.videoUrl,
        videoThumbnailUrl: listing.videoThumbnailUrl,
        videoDuration: listing.videoDuration,
        images: listing.images,
        city: listing.city,
        district: listing.district,
        autoDetails: homeAutoDetails,
        viewsCount: listing.viewsCount,
        likesCount: listing.likesCount,
        savesCount: listing.savesCount,
        isLiked: listing.isLiked,
        isSaved: listing.isSaved,
        publishedAt: listing.publishedAt ?? DateTime.now(),
      );
    }).toList();
  }

  // Mock conversations
  static final List<Conversation> mockConversations = [
    Conversation(
      id: 'conv1',
      listingId: 'listing1',
      listingTitle: 'Chevrolet Gentra 2022',
      listingThumbnailUrl: 'https://picsum.photos/400/600?random=1',
      listingPrice: 15000,
      otherUserId: 'seller1',
      otherUserName: 'AutoStar Salon',
      otherUserAvatarUrl: 'https://ui-avatars.com/api/?name=AutoStar&size=200&background=0088cc&color=fff',
      isOtherUserVerified: true,
      lastMessageText: 'Salom, bu mashina hali bormi?',
      lastMessageAt: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 1,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Conversation(
      id: 'conv2',
      listingId: 'listing3',
      listingTitle: 'Chevrolet Tracker 2024',
      listingThumbnailUrl: 'https://picsum.photos/400/600?random=6',
      listingPrice: 28500,
      otherUserId: 'seller2',
      otherUserName: 'AvtoPlus Motors',
      otherUserAvatarUrl: 'https://ui-avatars.com/api/?name=AvtoPlus&size=200&background=ff6600&color=fff',
      isOtherUserVerified: true,
      lastMessageText: 'Marhamat, keling ko\'ring',
      lastMessageAt: DateTime.now().subtract(const Duration(hours: 5)),
      unreadCount: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Conversation(
      id: 'conv3',
      listingId: 'listing5',
      listingTitle: 'Kia K5 2022',
      listingThumbnailUrl: 'https://picsum.photos/400/600?random=11',
      listingPrice: 35000,
      otherUserId: 'seller3',
      otherUserName: 'Premium Auto',
      otherUserAvatarUrl: 'https://ui-avatars.com/api/?name=Premium+Auto&size=200&background=333333&color=fff',
      isOtherUserVerified: true,
      lastMessageText: 'Narx qancha?',
      lastMessageAt: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  // Mock messages
  static final Map<String, List<Message>> mockMessages = {
    'conv1': [
      Message(
        id: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        content: 'Salom, bu mashina hali bormi?',
        type: MessageType.text,
        metadata: const {},
        isRead: true,
        readAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Message(
        id: 'msg2',
        conversationId: 'conv1',
        senderId: 'seller1',
        content: 'Ha, bor. Ko\'rishni xohlaysizmi?',
        type: MessageType.text,
        metadata: const {},
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      ),
      Message(
        id: 'msg3',
        conversationId: 'conv1',
        senderId: 'user1',
        content: 'Manzil qayerda?',
        type: MessageType.text,
        metadata: const {},
        isRead: true,
        readAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 40)),
      ),
      Message(
        id: 'msg4',
        conversationId: 'conv1',
        senderId: 'seller1',
        content: 'Sergeli tumani, 15-ko\'cha',
        type: MessageType.text,
        metadata: const {},
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      ),
    ],
    'conv2': [
      Message(
        id: 'msg5',
        conversationId: 'conv2',
        senderId: 'user1',
        content: 'Narx qancha?',
        type: MessageType.text,
        metadata: const {},
        isRead: true,
        readAt: DateTime.now().subtract(const Duration(hours: 5)),
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      Message(
        id: 'msg6',
        conversationId: 'conv2',
        senderId: 'seller2',
        content: '28 500 dollar',
        type: MessageType.text,
        metadata: const {},
        isRead: true,
        readAt: DateTime.now().subtract(const Duration(hours: 5)),
        createdAt: DateTime.now().subtract(const Duration(hours: 5, minutes: 30)),
      ),
      Message(
        id: 'msg7',
        conversationId: 'conv2',
        senderId: 'user1',
        content: 'Ko\'rib chiqsam bo\'ladimi?',
        type: MessageType.text,
        metadata: const {},
        isRead: true,
        readAt: DateTime.now().subtract(const Duration(hours: 5)),
        createdAt: DateTime.now().subtract(const Duration(hours: 5, minutes: 15)),
      ),
      Message(
        id: 'msg8',
        conversationId: 'conv2',
        senderId: 'seller2',
        content: 'Marhamat, keling ko\'ring',
        type: MessageType.text,
        metadata: const {},
        isRead: true,
        readAt: DateTime.now().subtract(const Duration(hours: 4, minutes: 30)),
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ],
    'conv3': [
      Message(
        id: 'msg9',
        conversationId: 'conv3',
        senderId: 'user1',
        content: 'Narx qancha?',
        type: MessageType.text,
        metadata: const {},
        isRead: true,
        readAt: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Message(
        id: 'msg10',
        conversationId: 'conv3',
        senderId: 'seller3',
        content: '35 000 dollar, narx qattiq',
        type: MessageType.text,
        metadata: const {},
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 23)),
      ),
      Message(
        id: 'msg11',
        conversationId: 'conv3',
        senderId: 'seller3',
        content: 'Qiziqsangiz aloqaga chiqing',
        type: MessageType.text,
        metadata: const {},
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 23)),
      ),
    ],
  };

  // Get listing by ID
  static Listing? getListingById(String id) {
    try {
      return mockListings.firstWhere((listing) => listing.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get seller by ID
  static Seller? getSellerById(String id) {
    try {
      return mockSellers.firstWhere((seller) => seller.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get user by phone
  static User? getUserByPhone(String phone) {
    try {
      return mockUsers.firstWhere((user) => user.phone == phone);
    } catch (e) {
      return null;
    }
  }

  // Get user by email
  static User? getUserByEmail(String email) {
    try {
      return mockUsers.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  // Search listings
  static List<Listing> searchListings({
    String? query,
    String? brand,
    String? model,
    int? minYear,
    int? maxYear,
    double? minPrice,
    double? maxPrice,
    String? city,
  }) {
    var results = mockListings.where((listing) => listing.status == ListingStatus.active);

    if (query != null && query.isNotEmpty) {
      results = results.where((listing) =>
          listing.title.toLowerCase().contains(query.toLowerCase()) ||
          (listing.description?.toLowerCase().contains(query.toLowerCase()) ?? false));
    }

    if (brand != null) {
      results = results.where((listing) =>
          listing.autoDetails?.brand?.toLowerCase() == brand.toLowerCase());
    }

    if (model != null) {
      results = results.where((listing) =>
          listing.autoDetails?.model?.toLowerCase() == model.toLowerCase());
    }

    if (minYear != null) {
      results = results.where((listing) =>
          listing.autoDetails?.year != null && listing.autoDetails!.year! >= minYear);
    }

    if (maxYear != null) {
      results = results.where((listing) =>
          listing.autoDetails?.year != null && listing.autoDetails!.year! <= maxYear);
    }

    if (minPrice != null) {
      results = results.where((listing) => listing.price >= minPrice);
    }

    if (maxPrice != null) {
      results = results.where((listing) => listing.price <= maxPrice);
    }

    if (city != null) {
      results = results.where((listing) =>
          listing.city?.toLowerCase() == city.toLowerCase());
    }

    return results.toList();
  }
}
