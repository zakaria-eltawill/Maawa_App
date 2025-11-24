import 'package:flutter/material.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/domain/repositories/property_repository.dart';
import 'package:maawa_project/l10n/app_localizations.dart';

class PropertyFilterSheet extends StatefulWidget {
  final PropertyFilters currentFilters;
  final ValueChanged<PropertyFilters> onApply;

  const PropertyFilterSheet({
    super.key,
    required this.currentFilters,
    required this.onApply,
  });

  @override
  State<PropertyFilterSheet> createState() => _PropertyFilterSheetState();
}

class _PropertyFilterSheetState extends State<PropertyFilterSheet> {
  late String? _selectedCity;
  late String? _selectedPropertyType;
  late double _minPrice;
  late double _maxPrice;
  late RangeValues _priceRange;

  final List<String> _cities = [
    'Benghazi',
    'Tripoli',
    'Misrata',
    'Zliten',
    'Al-Bayda',
    'Sirte',
    'Derna',
    'Tobruk',
  ];

  final List<String> _propertyTypes = [
    'villa',
    'apartment',
    'chalet',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.currentFilters.city;
    _selectedPropertyType = widget.currentFilters.propertyType;
    _minPrice = widget.currentFilters.minPrice ?? 0;
    _maxPrice = widget.currentFilters.maxPrice ?? 10000;
    _priceRange = RangeValues(_minPrice, _maxPrice);
  }

  void _applyFilters() {
    final filters = PropertyFilters(
      city: _selectedCity,
      propertyType: _selectedPropertyType,
      minPrice: _priceRange.start > 0 ? _priceRange.start : null,
      maxPrice: _priceRange.end < 10000 ? _priceRange.end : null,
      searchQuery: widget.currentFilters.searchQuery,
    );
    widget.onApply(filters);
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    setState(() {
      _selectedCity = null;
      _selectedPropertyType = null;
      _priceRange = const RangeValues(0, 10000);
    });
  }

  String _getPropertyTypeLabel(String type, AppLocalizations l10n) {
    switch (type) {
      case 'villa':
        return l10n.villa;
      case 'apartment':
        return l10n.apartment;
      case 'chalet':
        return l10n.chalet;
      default:
        return type;
    }
  }

  String _getPriceText(num price, {bool showPlus = false}) {
    final locale = Localizations.localeOf(context);
    final symbol = locale.languageCode == 'ar' ? 'د.ل' : 'LYD';
    final priceText = price.toStringAsFixed(0);
    return showPlus ? '$priceText+ $symbol' : '$priceText $symbol';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.filters,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: _clearFilters,
                  child: Text(l10n.clearFilters),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: AppTheme.gray200),

          // Filter content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // City filter
                  Text(
                    l10n.city,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _cities.map((city) {
                      final isSelected = _selectedCity == city;
                      return FilterChip(
                        label: Text(city),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCity = selected ? city : null;
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
                        checkmarkColor: AppTheme.primaryBlue,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppTheme.primaryBlue
                              : AppTheme.gray700,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppTheme.primaryBlue
                              : AppTheme.gray300,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Property Type filter
                  Text(
                    l10n.propertyType,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _propertyTypes.map((type) {
                      final isSelected = _selectedPropertyType == type;
                      return FilterChip(
                        label: Text(_getPropertyTypeLabel(type, l10n)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedPropertyType = selected ? type : null;
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
                        checkmarkColor: AppTheme.primaryBlue,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppTheme.primaryBlue
                              : AppTheme.gray700,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppTheme.primaryBlue
                              : AppTheme.gray300,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Price Range filter
                  Text(
                    l10n.priceRange,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.minPrice,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getPriceText(_priceRange.start.round()),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.maxPrice,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _priceRange.end >= 10000
                                  ? _getPriceText(10000, showPlus: true)
                                  : _getPriceText(_priceRange.end.round()),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 10000,
                    divisions: 100,
                    activeColor: AppTheme.primaryBlue,
                    inactiveColor: AppTheme.gray300,
                    labels: RangeLabels(
                      _getPriceText(_priceRange.start.round()),
                      _priceRange.end >= 10000
                          ? _getPriceText(10000, showPlus: true)
                          : _getPriceText(_priceRange.end.round()),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Apply button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.applyFilters,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

