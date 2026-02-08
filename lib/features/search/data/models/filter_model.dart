import '../../domain/entities/filter.dart';

/// Brand model for data layer

class BrandModelData extends BrandModel {
  const BrandModelData({
    required super.id,
    required super.name,
    super.logoUrl,
    super.models,
  });

  factory BrandModelData.fromJson(Map<String, dynamic> json) {
    return BrandModelData(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logo_url'] as String?,
      models: (json['models'] as List<dynamic>?)
              ?.map((e) => CarModelData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_url': logoUrl,
    };
  }
}

class CarModelData extends CarModel {
  const CarModelData({
    required super.id,
    required super.name,
    required super.brandId,
  });

  factory CarModelData.fromJson(Map<String, dynamic> json) {
    return CarModelData(
      id: json['id'] as String,
      name: json['name'] as String,
      brandId: json['brand_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand_id': brandId,
    };
  }
}
