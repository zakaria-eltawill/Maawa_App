import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maawa_project/core/theme/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isOwner;
  final List<NavItem> items;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isOwner,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (isOwner) {
      return _buildOwnerNavBar(context);
    } else {
      return _buildTenantNavBar(context);
    }
  }

  Widget _buildOwnerNavBar(BuildContext context) {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 25,
            offset: const Offset(0, -5),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        border: Border(
          top: BorderSide(
            color: AppTheme.gray200,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = currentIndex == index;
              
              return Expanded(
                child: _buildOwnerNavItem(
                  context: context,
                  item: item,
                  isSelected: isSelected,
                  onTap: () {
                    // Add haptic feedback
                    HapticFeedback.lightImpact();
                    onTap(index);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildOwnerNavItem({
    required BuildContext context,
    required NavItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryBlue.withValues(alpha: 0.15),
                    AppTheme.primaryBlue.withValues(alpha: 0.08),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Background circle with animation - smaller
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  width: isSelected ? 38 : 32,
                  height: isSelected ? 38 : 32,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryBlue
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                ),
                // Icon - smaller
                Icon(
                  isSelected ? (item.selectedIcon ?? item.icon) : item.icon,
                  color: isSelected ? Colors.white : AppTheme.gray500,
                  size: isSelected ? 20 : 18,
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Label with better styling
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontSize: isSelected ? 10.5 : 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppTheme.primaryBlue
                    : AppTheme.gray500,
                letterSpacing: isSelected ? 0.1 : 0,
                fontFamily: Theme.of(context).textTheme.bodySmall?.fontFamily,
                height: 1.1,
              ),
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            // Active indicator dot - smaller
            if (isSelected)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(top: 2),
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget _buildTenantNavBar(BuildContext context) {
    // Find home index (should be index 0)
    final homeIndex = 0;
    final otherItems = items.asMap().entries.where((entry) => entry.key != homeIndex).toList();
    
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: SizedBox(
          height: 75,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // Regular nav items (excluding home) - positioned on sides
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Left side - My Bookings
                    Expanded(
                      child: _buildNavItem(
                        context: context,
                        item: otherItems[0].value,
                        isSelected: currentIndex == otherItems[0].key,
                        onTap: () => onTap(otherItems[0].key),
                        isCenter: false,
                      ),
                    ),
                    // Spacer for center button
                    const SizedBox(width: 60),
                    // Right side - Profile
                    Expanded(
                      child: _buildNavItem(
                        context: context,
                        item: otherItems[1].value,
                        isSelected: currentIndex == otherItems[1].key,
                        onTap: () => onTap(otherItems[1].key),
                        isCenter: false,
                      ),
                    ),
                  ],
                ),
              ),
              // Center home button
              Positioned(
                bottom: 15,
                child: _buildNavItem(
                  context: context,
                  item: items[homeIndex],
                  isSelected: currentIndex == homeIndex,
                  onTap: () => onTap(homeIndex),
                  isCenter: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required NavItem item,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isCenter,
  }) {
    if (isCenter) {
      // Floating center button
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? AppTheme.primaryBlue : Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            isSelected ? item.selectedIcon ?? item.icon : item.icon,
            color: isSelected ? Colors.white : AppTheme.gray600,
            size: 28,
          ),
        ),
      );
    }

    // Regular nav item
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        constraints: const BoxConstraints(
          minHeight: 50,
          maxHeight: 60,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? item.selectedIcon ?? item.icon : item.icon,
              color: isSelected ? AppTheme.primaryBlue : AppTheme.gray500,
              size: 22,
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: isSelected ? 20 : 0,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppTheme.primaryBlue : AppTheme.gray500,
                  fontFamily: Theme.of(context).textTheme.bodySmall?.fontFamily,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  const NavItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
}

