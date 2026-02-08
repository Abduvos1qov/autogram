import 'package:autogram/features/search/domain/entities/filter.dart';
import 'package:autogram/features/search/domain/entities/search_result.dart';
import 'package:autogram/core/network/api_response.dart';

/// Test fixtures for Search functionality
class SearchFixtures {
  SearchFixtures._();

  /// Empty filter
  static const SearchFilter emptyFilter = SearchFilter();

  /// Filter with price range
  static const SearchFilter priceFilter = SearchFilter(
    minPrice: 10000,
    maxPrice: 30000,
    currency: 'USD',
  );

  /// Filter with brand and model
  static const SearchFilter brandModelFilter = SearchFilter(
    brand: 'chevrolet',
    model: 'malibu',
  );

  /// Filter with year range
  static const SearchFilter yearFilter = SearchFilter(
    minYear: 2018,
    maxYear: 2023,
  );

  /// Filter with multiple options
  static const SearchFilter complexFilter = SearchFilter(
    minPrice: 15000,
    maxPrice: 40000,
    brand: 'toyota',
    minYear: 2019,
    fuelType: 'petrol',
    transmission: 'automatic',
    verifiedSellersOnly: true,
    noAccident: true,
    sortBy: SortOption.priceLow,
  );

  /// Filter with verified sellers only
  static const SearchFilter verifiedFilter = SearchFilter(
    verifiedSellersOnly: true,
  );

  /// Brand models list
  static List<BrandModel> get brands => [
        const BrandModel(
          id: 'chevrolet',
          name: 'Chevrolet',
          logoUrl: 'https://example.com/chevrolet.png',
          models: [
            CarModel(id: 'malibu', name: 'Malibu', brandId: 'chevrolet'),
            CarModel(id: 'tracker', name: 'Tracker', brandId: 'chevrolet'),
            CarModel(id: 'cobalt', name: 'Cobalt', brandId: 'chevrolet'),
          ],
        ),
        const BrandModel(
          id: 'toyota',
          name: 'Toyota',
          logoUrl: 'https://example.com/toyota.png',
          models: [
            CarModel(id: 'camry', name: 'Camry', brandId: 'toyota'),
            CarModel(id: 'corolla', name: 'Corolla', brandId: 'toyota'),
            CarModel(id: 'rav4', name: 'RAV4', brandId: 'toyota'),
          ],
        ),
        const BrandModel(
          id: 'bmw',
          name: 'BMW',
          logoUrl: 'https://example.com/bmw.png',
        ),
      ];

  /// Car models for a brand
  static List<CarModel> get chevroletModels => [
        const CarModel(id: 'malibu', name: 'Malibu', brandId: 'chevrolet'),
        const CarModel(id: 'tracker', name: 'Tracker', brandId: 'chevrolet'),
        const CarModel(id: 'cobalt', name: 'Cobalt', brandId: 'chevrolet'),
        const CarModel(id: 'spark', name: 'Spark', brandId: 'chevrolet'),
        const CarModel(id: 'captiva', name: 'Captiva', brandId: 'chevrolet'),
      ];

  /// Recent searches
  static List<String> get recentSearches => [
        'Malibu 2020',
        'Toyota Camry',
        'BMW X5',
        'Chevrolet Tracker',
      ];

  /// Popular searches
  static List<String> get popularSearches => [
        'Chevrolet Malibu',
        'Toyota Camry',
        'Gentra',
        'Cobalt',
        'Nexia',
      ];

  /// Search suggestions
  static List<String> get suggestions => [
        'Chevrolet Malibu 2020',
        'Chevrolet Malibu 2021',
        'Chevrolet Malibu LT',
        'Chevrolet Malibu Premier',
      ];
}
