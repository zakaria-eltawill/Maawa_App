import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maawa_project/core/di/providers.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/presentation/widgets/app_button.dart';
import 'package:maawa_project/presentation/widgets/app_text_field.dart';
import 'package:maawa_project/l10n/app_localizations.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedRegion;
  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _regions = [
    'Benghazi',
    'Tripoli',
    'Misrata',
    'Zliten',
    'Al-Bayda'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await ref.read(getCurrentUserUseCaseProvider)();
      if (mounted) {
        setState(() {
          _nameController.text = user.name ?? '';
          _phoneController.text = user.phoneNumber ?? '';
          _selectedRegion = user.region;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: ${e.toString()}'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updateProfileUseCase = ref.read(updateProfileUseCaseProvider);

      await updateProfileUseCase(
        name: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        region: _selectedRegion,
      );

      // Invalidate current user to refresh profile
      ref.invalidate(currentUserProvider);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: AppTheme.dangerRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.editProfile),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfile),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLG),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name Field
              AppTextField(
                label: l10n.fullName,
                controller: _nameController,
                keyboardType: TextInputType.name,
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.nameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacingMD),

              // Phone Number Field
              AppTextField(
                label: l10n.phone,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.phoneRequired;
                  }
                  // Libyan format: 09XXXXXXXX (10 digits starting with 09)
                  final phoneRegex = RegExp(r'^09\d{8}$');
                  if (!phoneRegex.hasMatch(value)) {
                    return 'Phone must be 10 digits starting with 09 (e.g., 0912345678)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacingMD),

              // Region Dropdown
              DropdownButtonFormField<String>(
                value: _selectedRegion,
                decoration: InputDecoration(
                  labelText: l10n.region,
                  prefixIcon: const Icon(Icons.location_city_outlined),
                ),
                items: _regions
                    .map((region) => DropdownMenuItem(
                          value: region,
                          child: Text(region),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRegion = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.regionRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacingXL),

              // Save Button
              AppButton(
                text: l10n.saveChanges,
                onPressed: _isSaving ? null : _saveProfile,
                isLoading: _isSaving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

