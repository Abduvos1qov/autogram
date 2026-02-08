import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/filter.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';

/// Filter screen for search

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late SearchFilter _filter;
  RangeValues _priceRange = const RangeValues(0, 100000);

  @override
  void initState() {
    super.initState();
    _filter = context.read<SearchBloc>().state.filter;
    if (_filter.minPrice != null || _filter.maxPrice != null) {
      _priceRange = RangeValues(
        _filter.minPrice ?? 0,
        _filter.maxPrice ?? 100000,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtrlar'),
        actions: [
          TextButton(
            onPressed: _clearFilters,
            child: const Text('Tozalash'),
          ),
        ],
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // Price range
              _buildSectionTitle('Narx (USD)'),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 100000,
                divisions: 100,
                labels: RangeLabels(
                  '\$${_priceRange.start.toInt()}',
                  '\$${_priceRange.end.toInt()}',
                ),
                onChanged: (values) {
                  setState(() {
                    _priceRange = values;
                    _filter = _filter.copyWith(
                      minPrice: values.start,
                      maxPrice: values.end,
                    );
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\$${_priceRange.start.toInt()}'),
                  Text('\$${_priceRange.end.toInt()}'),
                ],
              ),
              AppSpacing.gapVerticalLg,

              // Brand
              _buildSectionTitle('Marka'),
              _buildDropdown(
                value: _filter.brand,
                hint: 'Markani tanlang',
                items: state.brands.map((b) => b.name).toList(),
                onChanged: (value) {
                  setState(() {
                    _filter = _filter.copyWith(brand: value, clearModel: true);
                  });
                  if (value != null) {
                    final brand = state.brands.firstWhere((b) => b.name == value);
                    context.read<SearchBloc>().add(SearchBrandSelected(brand.id));
                  }
                },
              ),
              AppSpacing.gapVerticalMd,

              // Model
              _buildSectionTitle('Model'),
              _buildDropdown(
                value: _filter.model,
                hint: 'Modelni tanlang',
                items: state.models.map((m) => m.name).toList(),
                onChanged: (value) {
                  setState(() {
                    _filter = _filter.copyWith(model: value);
                  });
                },
              ),
              AppSpacing.gapVerticalMd,

              // Year
              _buildSectionTitle('Yil'),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      value: _filter.minYear?.toString(),
                      hint: 'Dan',
                      items: List.generate(
                        30,
                        (i) => (DateTime.now().year - i).toString(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filter = _filter.copyWith(
                            minYear: value != null ? int.parse(value) : null,
                          );
                        });
                      },
                    ),
                  ),
                  AppSpacing.gapHorizontalMd,
                  Expanded(
                    child: _buildDropdown(
                      value: _filter.maxYear?.toString(),
                      hint: 'Gacha',
                      items: List.generate(
                        30,
                        (i) => (DateTime.now().year - i).toString(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filter = _filter.copyWith(
                            maxYear: value != null ? int.parse(value) : null,
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
              AppSpacing.gapVerticalMd,

              // Mileage
              _buildSectionTitle('Yurgan masofasi'),
              _buildDropdown(
                value: _filter.maxMileage?.toString(),
                hint: 'Maksimum yurgan',
                items: AppConstants.mileageRanges,
                onChanged: (value) {
                  setState(() {
                    _filter = _filter.copyWith(
                      maxMileage: value != null ? int.tryParse(value.split('-').last.replaceAll('+', '')) : null,
                    );
                  });
                },
              ),
              AppSpacing.gapVerticalMd,

              // Fuel type
              _buildSectionTitle('Yoqilg\'i turi'),
              _buildDropdown(
                value: _filter.fuelType,
                hint: 'Yoqilg\'i turini tanlang',
                items: AppConstants.fuelTypes,
                onChanged: (value) {
                  setState(() {
                    _filter = _filter.copyWith(fuelType: value);
                  });
                },
              ),
              AppSpacing.gapVerticalMd,

              // Transmission
              _buildSectionTitle('Uzatmalar qutisi'),
              _buildDropdown(
                value: _filter.transmission,
                hint: 'Uzatmalar qutisini tanlang',
                items: AppConstants.transmissionTypes,
                onChanged: (value) {
                  setState(() {
                    _filter = _filter.copyWith(transmission: value);
                  });
                },
              ),
              AppSpacing.gapVerticalMd,

              // Body type
              _buildSectionTitle('Kuzov turi'),
              _buildDropdown(
                value: _filter.bodyType,
                hint: 'Kuzov turini tanlang',
                items: AppConstants.bodyTypes,
                onChanged: (value) {
                  setState(() {
                    _filter = _filter.copyWith(bodyType: value);
                  });
                },
              ),
              AppSpacing.gapVerticalMd,

              // City
              _buildSectionTitle('Shahar'),
              _buildDropdown(
                value: _filter.city,
                hint: 'Shaharni tanlang',
                items: AppConstants.cities,
                onChanged: (value) {
                  setState(() {
                    _filter = _filter.copyWith(city: value);
                  });
                },
              ),
              AppSpacing.gapVerticalLg,

              // Checkboxes
              _buildSectionTitle('Qo\'shimcha'),
              CheckboxListTile(
                title: const Text('Faqat tasdiqlangan sotuvchilar'),
                value: _filter.verifiedSellersOnly ?? false,
                onChanged: (value) {
                  setState(() {
                    _filter = _filter.copyWith(verifiedSellersOnly: value);
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Avariyasiz'),
                value: _filter.noAccident ?? false,
                onChanged: (value) {
                  setState(() {
                    _filter = _filter.copyWith(noAccident: value);
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Birinchi egasidan'),
                value: _filter.firstOwner ?? false,
                onChanged: (value) {
                  setState(() {
                    _filter = _filter.copyWith(firstOwner: value);
                  });
                },
              ),

              AppSpacing.gapVerticalXl,
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: ElevatedButton(
            onPressed: _applyFilters,
            child: const Text('Natijalarni ko\'rish'),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: AppTypography.titleSmall,
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint),
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text(hint),
        ),
        ...items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }),
      ],
      onChanged: onChanged,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _filter = const SearchFilter();
      _priceRange = const RangeValues(0, 100000);
    });
  }

  void _applyFilters() {
    context.read<SearchBloc>().add(SearchFilterChanged(_filter));
    context.pop();
  }
}
