import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maawa_project/core/di/providers.dart';
import 'package:maawa_project/domain/entities/user.dart';
import 'package:maawa_project/l10n/app_localizations.dart';
import 'package:maawa_project/presentation/discover/property_list_screen.dart';
import 'package:maawa_project/presentation/owner/owner_proposals_screen.dart';
import 'package:maawa_project/presentation/owner/owner_properties_screen.dart';
import 'package:maawa_project/presentation/owner/owner_bookings_screen.dart';
import 'package:maawa_project/presentation/tenant/tenant_bookings_screen.dart';
import 'package:maawa_project/presentation/profile/profile_screen.dart';
import 'package:maawa_project/presentation/widgets/custom_bottom_nav_bar.dart';

class RoleBasedShell extends ConsumerStatefulWidget {
  const RoleBasedShell({super.key});

  @override
  ConsumerState<RoleBasedShell> createState() => _RoleBasedShellState();
}

class _RoleBasedShellState extends ConsumerState<RoleBasedShell> {
  // Owner default: Properties (index 0), Tenant default: Home (index 0)
  int _currentIndex = 0;
  UserRole? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final secureStorage = ref.read(secureStorageProvider);
    final roleString = await secureStorage.getUserRole();
    if (roleString != null) {
      setState(() {
        _userRole = UserRole.fromString(roleString);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = _userRole == UserRole.owner;
    final l10n = AppLocalizations.of(context);

    if (_userRole == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (isOwner) {
      // Owner Navigation: My Properties (first/default), Proposals, Bookings, Profile
      return Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            OwnerPropertiesScreen(), // My Properties (index 0 - first/default)
            OwnerProposalsScreen(), // Proposals (index 1)
            OwnerBookingsScreen(), // Bookings (index 2)
            ProfileScreen(), // Profile (index 3)
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          isOwner: true,
          items: [
            NavItem(
              icon: Icons.home_work_outlined,
              selectedIcon: Icons.home_work,
              label: l10n.myProperties,
            ),
            NavItem(
              icon: Icons.edit_note_outlined,
              selectedIcon: Icons.edit_note,
              label: l10n.proposals,
            ),
            NavItem(
              icon: Icons.bookmark_outline,
              selectedIcon: Icons.bookmark,
              label: l10n.bookings,
            ),
            NavItem(
              icon: Icons.person_outline,
              selectedIcon: Icons.person,
              label: l10n.profile,
            ),
          ],
        ),
      );
    } else {
      // Tenant Navigation: My Bookings, Home (center), Profile
      return Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            PropertyListScreen(), // Home - Browse all properties (index 0)
            TenantBookingsScreen(), // My Bookings (index 1)
            ProfileScreen(), // Profile (index 2)
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          isOwner: false,
          items: [
            NavItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              label: l10n.home,
            ),
            NavItem(
              icon: Icons.bookmark_outline,
              selectedIcon: Icons.bookmark,
              label: l10n.myBookings,
            ),
            NavItem(
              icon: Icons.person_outline,
              selectedIcon: Icons.person,
              label: l10n.profile,
            ),
          ],
        ),
      );
    }
  }
}

