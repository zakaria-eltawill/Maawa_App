import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maawa_project/core/di/providers.dart';
import 'package:maawa_project/core/error/error_handler.dart';
import 'package:maawa_project/core/error/failures.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/l10n/app_localizations.dart';
import 'package:maawa_project/presentation/widgets/app_button.dart';
import 'package:maawa_project/presentation/widgets/app_text_field.dart';
import 'package:maawa_project/presentation/widgets/success_dialog.dart';

class PropertyEditScreen extends ConsumerStatefulWidget {
  final String propertyId;

  const PropertyEditScreen({
    super.key,
    required this.propertyId,
  });

  @override
  ConsumerState<PropertyEditScreen> createState() => _PropertyEditScreenState();
}

class _PropertyEditScreenState extends ConsumerState<PropertyEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _locationUrlController = TextEditingController();
  final _priceController = TextEditingController();
  
  String? _selectedPropertyType;
  final List<String> _selectedAmenities = [];
  final List<File> _selectedPhotos = [];
  final List<String> _existingPhotoUrls = []; // Photos already on the property
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;
  bool _isLoadingProperty = true;
  
  // Location from GPS
  double? _gpsLatitude;
  double? _gpsLongitude;
  bool _isGettingLocation = false;

  // Available property types
  final List<String> _propertyTypes = [
    'villa',
    'chalet',
    'apartment',
  ];

  // Available amenities
  final List<String> _availableAmenities = [
    'wifi',
    'parking',
    'pool',
    'gym',
    'balcony',
    'kitchen',
    'tv',
    'air_conditioning',
    'heating',
    'laundry',
    'elevator',
    'security',
  ];

  @override
  void initState() {
    super.initState();
    _loadProperty();
  }

  Future<void> _loadProperty() async {
    try {
      final propertyAsync = ref.read(propertyDetailProvider(widget.propertyId));
      propertyAsync.whenData((property) {
        setState(() {
          _titleController.text = property.name;
          _descriptionController.text = property.description ?? '';
          _cityController.text = property.city;
          _locationUrlController.text = property.locationUrl ?? '';
          _priceController.text = property.pricePerNight.toStringAsFixed(0);
          _selectedPropertyType = property.propertyType;
          _selectedAmenities.clear();
          _selectedAmenities.addAll(property.amenities);
          _existingPhotoUrls.clear();
          _existingPhotoUrls.addAll(property.imageUrls);
          _gpsLatitude = property.latitude;
          _gpsLongitude = property.longitude;
          _isLoadingProperty = false;
        });
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProperty = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load property: $e'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _locationUrlController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedPhotos.add(File(image.path));
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(source == ImageSource.camera 
                ? l10n.failedToTakePhoto 
                : l10n.failedToPickImage),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  void _removeExistingPhoto(int index) {
    setState(() {
      _existingPhotoUrls.removeAt(index);
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location service is disabled. Please enable it in settings.'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
        setState(() {
          _isGettingLocation = false;
        });
        return;
      }

      geo.LocationPermission permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) {
          if (mounted) {
            final l10n = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.locationPermissionDenied),
                backgroundColor: AppTheme.dangerRed,
              ),
            );
          }
          setState(() {
            _isGettingLocation = false;
          });
          return;
        }
      }

      if (permission == geo.LocationPermission.deniedForever) {
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.locationPermissionPermanentlyDenied),
              backgroundColor: AppTheme.dangerRed,
            ),
          );
        }
        setState(() {
          _isGettingLocation = false;
        });
        return;
      }

      final position = await geo.Geolocator.getCurrentPosition();
      setState(() {
        _gpsLatitude = position.latitude;
        _gpsLongitude = position.longitude;
        _locationUrlController.text = 'https://maps.google.com/?q=${position.latitude},${position.longitude}';
        _isGettingLocation = false;
      });
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.failedToGetLocation}: $e'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  (double?, double?) _extractCoordinatesFromUrl(String url) {
    try {
      // Try to extract from various Google Maps URL formats
      final patterns = [
        RegExp(r'[?&]q=([0-9.-]+),([0-9.-]+)'),
        RegExp(r'@([0-9.-]+),([0-9.-]+)'),
        RegExp(r'([0-9.-]+),([0-9.-]+)'),
      ];

      for (final pattern in patterns) {
        final match = pattern.firstMatch(url);
        if (match != null) {
          final lat = double.tryParse(match.group(1)!);
          final lng = double.tryParse(match.group(2)!);
          if (lat != null && lng != null) {
            return (lat, lng);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error extracting coordinates: $e');
      }
    }
    return (null, null);
  }

  Future<void> _submitProposal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final l10n = AppLocalizations.of(context);
      final imageUploadApi = ref.read(imageUploadApiProvider);

      // Upload new photos if any
      List<String> photoUrls = List.from(_existingPhotoUrls);
      if (_selectedPhotos.isNotEmpty) {
        try {
          final uploadedUrls = await imageUploadApi.uploadImages(_selectedPhotos);
          photoUrls.addAll(uploadedUrls);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.failedToUploadPhotos),
                backgroundColor: AppTheme.dangerRed,
              ),
            );
          }
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Determine location
      double? latitude = _gpsLatitude;
      double? longitude = _gpsLongitude;
      String? locationUrl = _locationUrlController.text.trim();

      // If GPS location is not available, try to extract from URL
      if (latitude == null || longitude == null) {
        if (locationUrl.isNotEmpty) {
          final coords = _extractCoordinatesFromUrl(locationUrl);
          latitude = coords.$1;
          longitude = coords.$2;
        }
      } else {
        // If GPS is available, update URL
        if (locationUrl.isEmpty || !locationUrl.contains('maps.google.com')) {
          locationUrl = 'https://maps.google.com/?q=$latitude,$longitude';
        }
      }

      // Validate that we have coordinates
      if (latitude == null || longitude == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.locationRequired),
              backgroundColor: AppTheme.dangerRed,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // At this point, latitude and longitude are guaranteed to be non-null
      final finalLatitude = latitude;
      final finalLongitude = longitude;

      // Build payload for PUT /owner/properties/:id endpoint
      final payload = <String, dynamic>{};
      if (_titleController.text.trim().isNotEmpty) {
        payload['title'] = _titleController.text.trim();
      }
      if (_descriptionController.text.trim().isNotEmpty) {
        payload['description'] = _descriptionController.text.trim();
      }
      if (_cityController.text.trim().isNotEmpty) {
        payload['city'] = _cityController.text.trim();
      }
      if (_selectedPropertyType != null) {
        payload['type'] = _selectedPropertyType;
      }
      if (_priceController.text.trim().isNotEmpty) {
        final price = double.tryParse(_priceController.text.trim());
        if (price != null) {
          payload['price'] = price;
        }
      }
      payload['location'] = {
        'latitude': finalLatitude,
        'longitude': finalLongitude,
        if (locationUrl.isNotEmpty) 'map_url': locationUrl,
      };
      if (_selectedAmenities.isNotEmpty) {
        payload['amenities'] = _selectedAmenities;
      }
      if (photoUrls.isNotEmpty) {
        payload['photos'] = photoUrls;
      }

      if (kDebugMode) {
        debugPrint('📤 Submitting property edit via PUT /owner/properties/${widget.propertyId}');
        debugPrint('📦 Payload: $payload');
      }

      final propertyApi = ref.read(propertyApiProvider);
      
      Map<String, dynamic> response;
      try {
        response = await propertyApi.createEditProposalForProperty(
          propertyId: widget.propertyId,
          title: payload['title'] as String?,
          description: payload['description'] as String?,
          city: payload['city'] as String?,
          type: payload['type'] as String?,
          price: payload['price'] as double?,
          location: payload['location'] as Map<String, dynamic>?,
          amenities: payload['amenities'] as List<String>?,
          photos: payload['photos'] as List<String>?,
        );
      } catch (e) {
        throw ErrorHandler.handleError(e);
      }

      if (kDebugMode) {
        debugPrint('✅ Property edit proposal created successfully');
        debugPrint('📦 Response: $response');
      }

      if (mounted) {
        // Show success dialog
        await showDialog(
          context: context,
          builder: (context) => SuccessDialog(
            title: l10n.proposalSubmittedSuccessfully,
            message: 'Your edit proposal has been submitted and is pending admin approval. The property will be updated once approved.',
            onDismiss: () {
              context.pop(); // Go back to property detail
              // Invalidate providers to refresh data
              ref.invalidate(ownerPropertiesProvider);
              ref.invalidate(propertyDetailProvider(widget.propertyId));
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        String errorMessage = l10n.failedToSubmitProposal;
        
        if (e is UnauthorizedFailure) {
          errorMessage = '${l10n.failedToSubmitProposal}\nUnauthorized. Please login again.';
        } else if (e is ValidationFailure) {
          errorMessage = '${l10n.failedToSubmitProposal}\n${e.message}';
        } else if (e is ServerFailure) {
          errorMessage = '${l10n.failedToSubmitProposal}\n${e.message}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.dangerRed,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getPropertyTypeLabel(String type, AppLocalizations l10n) {
    switch (type) {
      case 'villa':
        return l10n.villa;
      case 'chalet':
        return l10n.challete;
      case 'apartment':
        return l10n.apartment;
      default:
        return type;
    }
  }

  String _getAmenityLabel(String amenity, AppLocalizations l10n) {
    switch (amenity) {
      case 'wifi':
        return l10n.wifi;
      case 'parking':
        return l10n.parking;
      case 'pool':
        return l10n.pool;
      case 'gym':
        return l10n.gym;
      case 'balcony':
        return l10n.balcony;
      case 'kitchen':
        return l10n.kitchen;
      case 'tv':
        return l10n.tv;
      case 'air_conditioning':
        return l10n.airConditioning;
      case 'heating':
        return l10n.heating;
      case 'laundry':
        return l10n.laundry;
      case 'elevator':
        return l10n.elevator;
      case 'security':
        return l10n.security;
      default:
        return amenity;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_isLoadingProperty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.editProperty),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProperty),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              AppTextField(
                controller: _titleController,
                label: l10n.title,
                hint: l10n.title,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.titleRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              AppTextField(
                controller: _descriptionController,
                label: l10n.description,
                hint: l10n.description,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.titleRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // City
              AppTextField(
                controller: _cityController,
                label: l10n.city,
                hint: l10n.city,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.titleRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Property Type
              DropdownButtonFormField<String>(
                value: _selectedPropertyType,
                decoration: InputDecoration(
                  labelText: l10n.propertyType,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.dangerRed),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.dangerRed, width: 2),
                  ),
                ),
                items: _propertyTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getPropertyTypeLabel(type, l10n)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPropertyType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.propertyType;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Price
              AppTextField(
                controller: _priceController,
                label: l10n.pricePerNight,
                hint: l10n.pricePerNight,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.priceRequired;
                  }
                  final price = double.tryParse(value.trim());
                  if (price == null || price <= 0) {
                    return l10n.priceInvalid;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location Section
              Text(
                l10n.location,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              
              // GPS Button
              ElevatedButton.icon(
                onPressed: _isGettingLocation ? null : _getCurrentLocation,
                icon: _isGettingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: Text(_gpsLatitude != null && _gpsLongitude != null
                    ? '${l10n.locationRetrieved} (${_gpsLatitude!.toStringAsFixed(6)}, ${_gpsLongitude!.toStringAsFixed(6)})'
                    : 'Get My Current Location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gpsLatitude != null && _gpsLongitude != null
                      ? Colors.green
                      : AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              // Location URL (Optional)
              AppTextField(
                controller: _locationUrlController,
                label: '${l10n.locationUrl} (${l10n.optional})',
                hint: l10n.locationUrl,
              ),
              const SizedBox(height: 16),

              // Amenities
              Text(
                l10n.amenities,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableAmenities.map((amenity) {
                  final isSelected = _selectedAmenities.contains(amenity);
                  return FilterChip(
                    label: Text(_getAmenityLabel(amenity, l10n)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedAmenities.add(amenity);
                        } else {
                          _selectedAmenities.remove(amenity);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Photos Section
              Text(
                l10n.photos,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // Existing Photos
              if (_existingPhotoUrls.isNotEmpty) ...[
                Text(
                  'Existing Photos:',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.gray600,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _existingPhotoUrls.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _existingPhotoUrls[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: () => _removeExistingPhoto(index),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                  padding: const EdgeInsets.all(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Photo Selection Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: Text(l10n.gallery),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: Text(l10n.camera),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Selected Photos Preview
              if (_selectedPhotos.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedPhotos.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedPhotos[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: () => _removePhoto(index),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                  padding: const EdgeInsets.all(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 24),

              // Submit Button
              AppButton(
                text: l10n.submitProposal,
                onPressed: _isLoading ? null : _submitProposal,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

