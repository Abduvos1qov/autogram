import 'package:equatable/equatable.dart';

/// Search filter entity

class SearchFilter extends Equatable {
  final double? minPrice;
  final double? maxPrice;
  final String? currency;
  final String? brand;
  final String? model;
  final int? minYear;
  final int? maxYear;
  final int? maxMileage;
  final String? fuelType;
  final String? transmission;
  final String? bodyType;
  final String? color;
  final String? city;
  final String? district;
  final bool? verifiedSellersOnly;
  final bool? noAccident;
  final bool? firstOwner;
  final SortOption sortBy;

  const SearchFilter({
    this.minPrice,
    this.maxPrice,
    this.currency,
    this.brand,
    this.model,
    this.minYear,
    this.maxYear,
    this.maxMileage,
    this.fuelType,
    this.transmission,
    this.bodyType,
    this.color,
    this.city,
    this.district,
    this.verifiedSellersOnly,
    this.noAccident,
    this.firstOwner,
    this.sortBy = SortOption.newest,
  });

  bool get hasActiveFilters {
    return minPrice != null ||
        maxPrice != null ||
        brand != null ||
        model != null ||
        minYear != null ||
        maxYear != null ||
        maxMileage != null ||
        fuelType != null ||
        transmission != null ||
        bodyType != null ||
        color != null ||
        city != null ||
        district != null ||
        verifiedSellersOnly == true ||
        noAccident == true ||
        firstOwner == true;
  }

  int get activeFilterCount {
    int count = 0;
    if (minPrice != null || maxPrice != null) count++;
    if (brand != null) count++;
    if (model != null) count++;
    if (minYear != null || maxYear != null) count++;
    if (maxMileage != null) count++;
    if (fuelType != null) count++;
    if (transmission != null) count++;
    if (bodyType != null) count++;
    if (color != null) count++;
    if (city != null) count++;
    if (verifiedSellersOnly == true) count++;
    if (noAccident == true) count++;
    if (firstOwner == true) count++;
    return count;
  }

  SearchFilter copyWith({
    double? minPrice,
    double? maxPrice,
    String? currency,
    String? brand,
    String? model,
    int? minYear,
    int? maxYear,
    int? maxMileage,
    String? fuelType,
    String? transmission,
    String? bodyType,
    String? color,
    String? city,
    String? district,
    bool? verifiedSellersOnly,
    bool? noAccident,
    bool? firstOwner,
    SortOption? sortBy,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearBrand = false,
    bool clearModel = false,
    bool clearMinYear = false,
    bool clearMaxYear = false,
    bool clearMaxMileage = false,
    bool clearFuelType = false,
    bool clearTransmission = false,
    bool clearBodyType = false,
    bool clearColor = false,
    bool clearCity = false,
    bool clearDistrict = false,
  }) {
    return SearchFilter(
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      currency: currency ?? this.currency,
      brand: clearBrand ? null : (brand ?? this.brand),
      model: clearModel ? null : (model ?? this.model),
      minYear: clearMinYear ? null : (minYear ?? this.minYear),
      maxYear: clearMaxYear ? null : (maxYear ?? this.maxYear),
      maxMileage: clearMaxMileage ? null : (maxMileage ?? this.maxMileage),
      fuelType: clearFuelType ? null : (fuelType ?? this.fuelType),
      transmission:
          clearTransmission ? null : (transmission ?? this.transmission),
      bodyType: clearBodyType ? null : (bodyType ?? this.bodyType),
      color: clearColor ? null : (color ?? this.color),
      city: clearCity ? null : (city ?? this.city),
      district: clearDistrict ? null : (district ?? this.district),
      verifiedSellersOnly: verifiedSellersOnly ?? this.verifiedSellersOnly,
      noAccident: noAccident ?? this.noAccident,
      firstOwner: firstOwner ?? this.firstOwner,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  SearchFilter clear() {
    return const SearchFilter();
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};

    if (minPrice != null) params['min_price'] = minPrice;
    if (maxPrice != null) params['max_price'] = maxPrice;
    if (currency != null) params['currency'] = currency;
    if (brand != null) params['brand'] = brand;
    if (model != null) params['model'] = model;
    if (minYear != null) params['min_year'] = minYear;
    if (maxYear != null) params['max_year'] = maxYear;
    if (maxMileage != null) params['max_mileage'] = maxMileage;
    if (fuelType != null) params['fuel_type'] = fuelType;
    if (transmission != null) params['transmission'] = transmission;
    if (bodyType != null) params['body_type'] = bodyType;
    if (color != null) params['color'] = color;
    if (city != null) params['city'] = city;
    if (district != null) params['district'] = district;
    if (verifiedSellersOnly == true) params['verified_only'] = true;
    if (noAccident == true) params['no_accident'] = true;
    if (firstOwner == true) params['first_owner'] = true;
    params['sort_by'] = sortBy.value;

    return params;
  }

  @override
  List<Object?> get props => [
        minPrice,
        maxPrice,
        currency,
        brand,
        model,
        minYear,
        maxYear,
        maxMileage,
        fuelType,
        transmission,
        bodyType,
        color,
        city,
        district,
        verifiedSellersOnly,
        noAccident,
        firstOwner,
        sortBy,
      ];
}

enum SortOption {
  newest('created_at_desc', 'Eng yangi'),
  oldest('created_at_asc', 'Eng eski'),
  priceLow('price_asc', 'Arzon'),
  priceHigh('price_desc', 'Qimmat'),
  popular('views_desc', 'Mashhur'),
  mileageLow('mileage_asc', 'Kam yurgan');

  final String value;
  final String label;

  const SortOption(this.value, this.label);
}

class BrandModel extends Equatable {
  final String id;
  final String name;
  final String? logoUrl;
  final List<CarModel> models;

  const BrandModel({
    required this.id,
    required this.name,
    this.logoUrl,
    this.models = const [],
  });

  @override
  List<Object?> get props => [id, name, logoUrl, models];
}

class CarModel extends Equatable {
  final String id;
  final String name;
  final String brandId;

  const CarModel({
    required this.id,
    required this.name,
    required this.brandId,
  });

  @override
  List<Object?> get props => [id, name, brandId];
}
