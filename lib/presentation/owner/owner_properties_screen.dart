import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maawa_project/core/di/providers.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/l10n/app_localizations.dart';
import 'package:maawa_project/presentation/widgets/empty_state.dart';
import 'package:maawa_project/presentation/widgets/error_state.dart';
import 'package:maawa_project/presentation/widgets/property_card_compact.dart';
import 'package:maawa_project/presentation/widgets/shimmer_loading.dart';

class OwnerPropertiesScreen extends ConsumerWidget {
  const OwnerPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(ownerPropertiesProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myProperties),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(ownerPropertiesProvider);
        },
        child: propertiesAsync.when(
          data: (result) {
            if (result.properties.isEmpty) {
              return Center(
                child: EmptyState(
                  message: l10n.noPropertiesFound,
                  subtitle: 'Create a proposal to add your first property',
                  icon: Icons.home_work_outlined,
                  iconColor: AppTheme.primaryBlue,
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: result.properties.length,
              itemBuilder: (context, index) {
                final property = result.properties[index];
                return PropertyCardCompact(
                  property: property,
                  onTap: () {
                    context.push('/home/property/${property.id}');
                  },
                );
              },
            );
          },
          loading: () => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 3,
            itemBuilder: (context, index) => const SkeletonPropertyCard(),
          ),
          error: (error, stack) {
            final errorString = error.toString().toLowerCase();
            if (errorString.contains('socket') ||
                errorString.contains('network') ||
                errorString.contains('connection')) {
              return NetworkErrorState(
                onRetry: () => ref.invalidate(ownerPropertiesProvider),
              );
            } else {
              return ServerErrorState(
                onRetry: () => ref.invalidate(ownerPropertiesProvider),
                errorDetails: error.toString(),
              );
            }
          },
        ),
      ),
    );
  }
}

