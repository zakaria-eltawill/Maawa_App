import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maawa_project/core/di/providers.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/domain/repositories/property_repository.dart';
import 'package:maawa_project/presentation/widgets/empty_state.dart';
import 'package:maawa_project/presentation/widgets/error_state.dart';
import 'package:maawa_project/presentation/widgets/property_card_compact.dart';
import 'package:maawa_project/presentation/widgets/filter_chip_widget.dart';
import 'package:maawa_project/presentation/widgets/shimmer_loading.dart';
import 'package:maawa_project/presentation/widgets/property_filter_sheet.dart';
import 'package:maawa_project/l10n/app_localizations.dart';

class PropertyListScreen extends ConsumerStatefulWidget {
  const PropertyListScreen({super.key});

  @override
  ConsumerState<PropertyListScreen> createState() =>
      _PropertyListScreenState();
}

class _PropertyListScreenState extends ConsumerState<PropertyListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  PropertyFilters _filters = const PropertyFilters();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  String _getPriceRangeText(int minPrice, int maxPrice) {
    final locale = Localizations.localeOf(context);
    final symbol = locale.languageCode == 'ar' ? 'د.ل' : 'LYD';
    return 'Price: $minPrice - $maxPrice+ $symbol';
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    setState(() {
      _isSearching = true;
    });
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
          // Always update searchQuery, even if empty (to clear search)
          _filters = PropertyFilters(
            city: _filters.city,
            propertyType: _filters.propertyType,
            minPrice: _filters.minPrice,
            maxPrice: _filters.maxPrice,
            searchQuery: query.trim().isEmpty ? null : query.trim(),
          );
        });
      }
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => PropertyFilterSheet(
          currentFilters: _filters,
          onApply: (newFilters) {
            setState(() {
              _filters = newFilters;
            });
          },
        ),
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _filters = const PropertyFilters();
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(propertiesProvider(_filters));
    final userAsync = ref.watch(currentUserProvider);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: AppTheme.gray50,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Invalidate the provider to refresh data
            ref.invalidate(propertiesProvider(_filters));
            // Wait for the refresh to complete
            await ref.read(propertiesProvider(_filters).future);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh
            slivers: [
            // Hero Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryBlue, AppTheme.lightBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            userAsync.when(
                              data: (user) {
                                final userName = user.name;
                                final greeting = locale.languageCode == 'ar'
                                    ? '${l10n.hello} $userName 👋'
                                    : 'Hi $userName 👋';
                                return Text(
                                  greeting,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                );
                              },
                              loading: () => Text(
                                '${l10n.hello} 👋',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                              error: (_, __) => Text(
                                '${l10n.hello} 👋',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.featuredProperties,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            context.push('/home/notifications');
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: l10n.searchForProperty,
                          hintStyle: const TextStyle(
                            color: AppTheme.gray400,
                            fontSize: 15,
                          ),
                          prefixIcon: _isSearching
                              ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme.primaryBlue,
                                      ),
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.search,
                                  color: AppTheme.gray400,
                                ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_searchController.text.isNotEmpty)
                                IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: AppTheme.gray400,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                  },
                                ),
                              Stack(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.tune,
                                      color: AppTheme.primaryBlue,
                                    ),
                                    onPressed: _showFilterSheet,
                                  ),
                                  if (_filters.hasActiveFilters)
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.dangerRed,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Filter chips
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      FilterChipWidget(
                        label: l10n.all,
                        selected: _filters.propertyType == null,
                        onTap: () {
                          setState(() {
                            _filters = _filters.copyWith(propertyType: null);
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChipWidget(
                        label: l10n.villa,
                        icon: Icons.villa_outlined,
                        selected: _filters.propertyType == 'villa',
                        onTap: () {
                          setState(() {
                            _filters = _filters.copyWith(propertyType: 'villa');
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChipWidget(
                        label: l10n.apartment,
                        icon: Icons.apartment_outlined,
                        selected: _filters.propertyType == 'apartment',
                        onTap: () {
                          setState(() {
                            _filters = _filters.copyWith(propertyType: 'apartment');
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChipWidget(
                        label: l10n.chalet,
                        icon: Icons.beach_access_outlined,
                        selected: _filters.propertyType == 'chalet',
                        onTap: () {
                          setState(() {
                            _filters = _filters.copyWith(propertyType: 'chalet');
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Active filters display
            if (_filters.hasActiveFilters)
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Search query chip
                      if (_filters.searchQuery != null)
                        _ActiveFilterChip(
                          label: '🔍 "${_filters.searchQuery}"',
                          onRemove: () {
                            setState(() {
                              _searchController.clear();
                              _filters = PropertyFilters(
                                city: _filters.city,
                                propertyType: _filters.propertyType,
                                minPrice: _filters.minPrice,
                                maxPrice: _filters.maxPrice,
                              );
                            });
                          },
                        ),
                      if (_filters.city != null)
                        _ActiveFilterChip(
                          label: '${l10n.city}: ${_filters.city}',
                          onRemove: () {
                            setState(() {
                              _filters = PropertyFilters(
                                searchQuery: _filters.searchQuery,
                                propertyType: _filters.propertyType,
                                minPrice: _filters.minPrice,
                                maxPrice: _filters.maxPrice,
                              );
                            });
                          },
                        ),
                      if (_filters.minPrice != null || _filters.maxPrice != null)
                        _ActiveFilterChip(
                          label: _getPriceRangeText(_filters.minPrice?.round() ?? 0, _filters.maxPrice?.round() ?? 10000),
                          onRemove: () {
                            setState(() {
                              _filters = PropertyFilters(
                                city: _filters.city,
                                propertyType: _filters.propertyType,
                                searchQuery: _filters.searchQuery,
                              );
                            });
                          },
                        ),
                      // Clear all button
                      InkWell(
                        onTap: _clearAllFilters,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.dangerRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.dangerRed,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.clear_all,
                                size: 16,
                                color: AppTheme.dangerRed,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.clearFilters,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.dangerRed,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Properties list
            propertiesAsync.when(
              data: (result) {
                debugPrint('🏠 PropertyListScreen: Rendering ${result.properties.length} properties');
                
                      if (result.properties.isEmpty) {
                        debugPrint('⚠️ PropertyListScreen: No properties to display');
                        return SliverFillRemaining(
                          child: Center(
                            child: EmptyState(
                              message: l10n.noPropertiesFound,
                              subtitle: _filters.hasActiveFilters
                                  ? 'Try adjusting your filters or search terms'
                                  : 'No properties available at the moment. Check back soon!',
                              icon: Icons.home_work_outlined,
                              iconColor: AppTheme.primaryBlue,
                            ),
                          ),
                        );
                      }
                
                debugPrint('✅ PropertyListScreen: Building list with ${result.properties.length} items');
                return SliverPadding(
                  padding: const EdgeInsets.only(bottom: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final property = result.properties[index];
                        return PropertyCardCompact(
                          property: property,
                          onTap: () {
                            context.push('/home/property/${property.id}');
                          },
                        );
                      },
                      childCount: result.properties.length,
                    ),
                  ),
                );
              },
                    loading: () {
                      debugPrint('⏳ PropertyListScreen: Still loading...');
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => const SkeletonPropertyCard(),
                          childCount: 3,
                        ),
                      );
                    },
              error: (error, stack) {
                debugPrint('❌ PropertyListScreen: Error displaying properties: $error');
                
                // Determine error type
                final errorString = error.toString().toLowerCase();
                Widget errorWidget;
                
                if (errorString.contains('socket') || 
                    errorString.contains('network') ||
                    errorString.contains('connection')) {
                  errorWidget = NetworkErrorState(
                    onRetry: () => ref.invalidate(propertiesProvider(_filters)),
                  );
                } else if (errorString.contains('404')) {
                  errorWidget = const NotFoundErrorState(
                    itemName: 'Properties',
                  );
                } else {
                  errorWidget = ServerErrorState(
                    onRetry: () => ref.invalidate(propertiesProvider(_filters)),
                    errorDetails: error.toString(),
                  );
                }
                
                return SliverFillRemaining(
                  child: errorWidget,
                );
              },
            ),
          ],
          ),
        ),
      ),
    );
  }
}

// Active filter chip widget
class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _ActiveFilterChip({
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 4, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryBlue,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 16,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}
