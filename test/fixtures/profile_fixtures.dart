import 'package:autogram/features/listing/domain/entities/listing.dart';
import 'package:autogram/features/profile/domain/entities/user_profile.dart';
import 'package:autogram/features/seller/domain/entities/seller_profile.dart';

/// Fixtures for Profile, Seller, and Listing entities used across tests.
///
/// Keep getters pure — every test gets its own fresh instance so test order
/// can't matter and no mutation leaks between groups.
class ProfileFixtures {
  ProfileFixtures._();

  static final DateTime _createdAt = DateTime(2024, 1, 1);
  static final DateTime _updatedAt = DateTime(2024, 6, 1);

  /// Plain buyer profile.
  static UserProfile get buyer => UserProfile(
        id: 'user-buyer',
        phone: '+998901234567',
        email: 'buyer@autogram.uz',
        fullName: 'Test Buyer',
        avatarUrl: null,
        role: 'buyer',
        isVerified: true,
        isActive: true,
        language: 'uz',
        sellerProfileId: null,
        createdAt: _createdAt,
        updatedAt: _updatedAt,
      );

  /// Seller profile (UserProfile side, not the SellerProfile row).
  static UserProfile get sellerUser => UserProfile(
        id: 'user-seller',
        phone: '+998909876543',
        email: 'seller@autogram.uz',
        fullName: 'Test Seller',
        avatarUrl: 'https://example.com/avatar.jpg',
        role: 'seller',
        isVerified: true,
        isActive: true,
        language: 'uz',
        sellerProfileId: 'seller-001',
        createdAt: _createdAt,
        updatedAt: _updatedAt,
      );

  /// User who has been flagged as a seller but the seller_profiles row
  /// hasn't been loaded yet — useful for testing fallback-to-buyer-view
  /// behavior when the storefront load fails.
  static UserProfile get sellerUserWithoutId => UserProfile(
        id: 'user-seller-no-id',
        phone: '+998909876544',
        email: 'sellernoid@autogram.uz',
        fullName: 'Seller No ID',
        avatarUrl: null,
        role: 'seller',
        isVerified: true,
        isActive: true,
        language: 'uz',
        sellerProfileId: null,
        createdAt: _createdAt,
        updatedAt: _updatedAt,
      );

  /// SellerProfile row (the storefront identity).
  static SellerProfile get sellerProfile => SellerProfile(
        id: 'seller-001',
        userId: 'user-seller',
        businessName: 'Test Avto',
        businessType: BusinessType.dealer,
        description: 'Sifatli mashinalar.',
        logoUrl: 'https://example.com/logo.png',
        coverUrl: 'https://example.com/cover.jpg',
        address: 'Sergeli 15',
        city: 'Toshkent',
        district: 'Sergeli',
        latitude: 41.2,
        longitude: 69.2,
        contactPhones: const ['+998909876543'],
        telegram: '@testavto',
        instagram: '@testavto',
        website: 'https://testavto.uz',
        workingHours: const {
          'monday': WorkingHours(open: '09:00', close: '18:00'),
        },
        isVerified: true,
        verifiedAt: _createdAt,
        subscriptionPlan: SubscriptionPlan.pro,
        subscriptionExpiresAt: DateTime(2025, 1, 1),
        stats: const SellerStats(
          totalListings: 10,
          activeListings: 5,
          totalSold: 50,
          totalViews: 1000,
          avgRating: 4.5,
          totalReviews: 20,
          followersCount: 100,
        ),
        seatsUsed: 1,
        additionalSeats: 0,
        createdAt: _createdAt,
        updatedAt: _updatedAt,
      );

  /// Mock seller for listing fixtures (different type than SellerProfile —
  /// see `Listing.seller` field).
  static Seller get listingSeller => Seller(
        id: 'seller-001',
        userId: 'user-seller',
        businessName: 'Test Avto',
        businessType: 'dealer',
        isVerified: true,
        subscriptionType: 'pro',
        totalListings: 10,
        activeListings: 5,
        totalSold: 50,
        totalViews: 1000,
        avgRating: 4.5,
        totalReviews: 20,
        isFollowing: false,
        createdAt: _createdAt,
      );

  /// Single active listing.
  static Listing activeListing(String id) => Listing(
        id: id,
        sellerId: 'seller-001',
        title: 'Listing $id',
        price: 10000,
        currency: 'USD',
        isNegotiable: false,
        status: ListingStatus.active,
        isFeatured: false,
        images: const ['https://example.com/img.jpg'],
        viewsCount: 100,
        likesCount: 10,
        savesCount: 5,
        sharesCount: 1,
        isLiked: false,
        isSaved: false,
        seller: listingSeller,
        createdAt: _createdAt,
        updatedAt: _updatedAt,
      );

  /// Single sold listing.
  static Listing soldListing(String id) => Listing(
        id: id,
        sellerId: 'seller-001',
        title: 'Sold $id',
        price: 8000,
        currency: 'USD',
        isNegotiable: false,
        status: ListingStatus.sold,
        isFeatured: false,
        images: const ['https://example.com/img.jpg'],
        viewsCount: 50,
        likesCount: 5,
        savesCount: 2,
        sharesCount: 0,
        isLiked: false,
        isSaved: false,
        seller: listingSeller,
        createdAt: _createdAt,
        updatedAt: _updatedAt,
      );

  /// Convenience: a list of N active listings.
  static List<Listing> activeListings(int count) =>
      List.generate(count, (i) => activeListing('active-$i'));

  /// Convenience: a list of N sold listings.
  static List<Listing> soldListings(int count) =>
      List.generate(count, (i) => soldListing('sold-$i'));
}
