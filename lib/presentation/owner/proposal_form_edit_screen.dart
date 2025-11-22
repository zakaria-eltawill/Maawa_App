import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maawa_project/core/di/providers.dart';
import 'package:maawa_project/core/error/failures.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/data/dto/proposal_dto.dart';
import 'package:maawa_project/domain/entities/proposal.dart';
import 'package:maawa_project/l10n/app_localizations.dart';
import 'package:maawa_project/presentation/widgets/app_button.dart';
import 'package:maawa_project/presentation/widgets/app_text_field.dart';
import 'package:maawa_project/presentation/widgets/success_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProposalFormEditScreen extends ConsumerStatefulWidget {
  final String proposalId;

  const ProposalFormEditScreen({
    super.key,
    required this.proposalId,
  });

  @override
  ConsumerState<ProposalFormEditScreen> createState() =>
      _ProposalFormEditScreenState();
}

class _ProposalFormEditScreenState extends ConsumerState<ProposalFormEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationUrlController = TextEditingController();
  final _priceController = TextEditingController();
  
  String? _selectedCity;
  String? _selectedPropertyType;
  final List<String> _selectedAmenities = [];
  final List<File> _selectedPhotos = []; // New photos to upload
  final List<String> _existingPhotoUrls = []; // Existing photos from proposal
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;
  bool _isInitialized = false;
  
  // Location from GPS
  double? _gpsLatitude;
  double? _gpsLongitude;
  bool _isGettingLocation = false;

  // English city names (for backend API) - same as registration form
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

  // Arabic city names mapping
  final Map<String, String> _cityNamesAr = {
    'Benghazi': 'بنغازي',
    'Tripoli': 'طرابلس',
    'Misrata': 'مصراتة',
    'Zliten': 'زليتن',
    'Al-Bayda': 'البيضاء',
    'Sirte': 'سرت',
    'Derna': 'درنة',
    'Tobruk': 'طبرق',
  };

  String _getCityDisplayName(String city, Locale locale) {
    if (locale.languageCode == 'ar') {
      return _cityNamesAr[city] ?? city;
    }
    return city;
  }

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
    'balcony',
    'pool',
    'gym',
    'air_conditioning',
    'heating',
    'tv',
    'kitchen',
    'washing_machine',
    'elevator',
    'security',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationUrlController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _initializeForm(Proposal proposal) {
    if (_isInitialized) return;
    
    final proposalData = proposal.data;
    if (proposalData != null) {
      _titleController.text = proposalData.name ?? '';
      _descriptionController.text = proposalData.description ?? '';
      _selectedCity = proposalData.city; // Set selected city from proposal
      _locationUrlController.text = proposalData.address ?? '';
      _priceController.text = proposalData.pricePerNight?.toString() ?? '';
      _selectedPropertyType = proposalData.propertyType;
      _selectedAmenities.addAll(proposalData.amenities ?? []);
      _gpsLatitude = proposalData.latitude;
      _gpsLongitude = proposalData.longitude;
      
      // Load existing photos from proposal
      // Photos are stored in ProposalData.photos
      if (proposalData.photos != null && proposalData.photos!.isNotEmpty) {
        _existingPhotoUrls.addAll(proposalData.photos!);
      }
    }
    
    _isInitialized = true;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedPhotos.add(File(image.path));
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToPickImage)),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedPhotos.add(File(image.path));
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToTakePhoto)),
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

  void _toggleAmenity(String amenity) {
    setState(() {
      if (_selectedAmenities.contains(amenity)) {
        _selectedAmenities.remove(amenity);
      } else {
        _selectedAmenities.add(amenity);
      }
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
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.locationServicesDisabled),
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

      geo.Position position = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.high,
        ),
      );

      setState(() {
        _gpsLatitude = position.latitude;
        _gpsLongitude = position.longitude;
        _locationUrlController.text = 'https://maps.google.com/?q=${position.latitude},${position.longitude}';
        _isGettingLocation = false;
      });

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.locationRetrievedSuccessfully),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
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
      final uri = Uri.parse(url);
      
      if (uri.queryParameters.containsKey('q')) {
        final qValue = uri.queryParameters['q']!;
        final coords = qValue.split(',');
        if (coords.length >= 2) {
          final lat = double.tryParse(coords[0].trim());
          final lng = double.tryParse(coords[1].trim());
          if (lat != null && lng != null) {
            return (lat, lng);
          }
        }
      }
      
      final fullUrl = uri.toString();
      final pathMatch = RegExp(r'@(-?\d+\.?\d*),(-?\d+\.?\d*)').firstMatch(fullUrl);
      if (pathMatch != null) {
        final lat = double.tryParse(pathMatch.group(1)!);
        final lng = double.tryParse(pathMatch.group(2)!);
        if (lat != null && lng != null) {
          return (lat, lng);
        }
      }
      
      if (uri.queryParameters.containsKey('ll')) {
        final llValue = uri.queryParameters['ll']!;
        final coords = llValue.split(',');
        if (coords.length >= 2) {
          final lat = double.tryParse(coords[0].trim());
          final lng = double.tryParse(coords[1].trim());
          if (lat != null && lng != null) {
            return (lat, lng);
          }
        }
      }
      
      return (null, null);
    } catch (e) {
      return (null, null);
    }
  }

  Future<void> _updateProposal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    
    if (_selectedPropertyType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.propertyTypeRequired)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload new photos
      List<String> newPhotoUrls = [];
      
      if (_selectedPhotos.isNotEmpty) {
        try {
          final imageUploadApi = ref.read(imageUploadApiProvider);
          newPhotoUrls = await imageUploadApi.uploadImages(
            _selectedPhotos,
            folder: 'proposals',
          );
        } catch (uploadError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${l10n.failedToUploadPhotos}: $uploadError'),
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

      // Combine existing and new photos
      final allPhotoUrls = [..._existingPhotoUrls, ...newPhotoUrls];

      // Get coordinates
      double? latitude;
      double? longitude;
      String? locationUrl;

      if (_gpsLatitude != null && _gpsLongitude != null) {
        latitude = _gpsLatitude;
        longitude = _gpsLongitude;
        locationUrl = _locationUrlController.text.trim().isNotEmpty
            ? _locationUrlController.text.trim()
            : 'https://maps.google.com/?q=$latitude,$longitude';
      } else {
        final urlText = _locationUrlController.text.trim();
        if (urlText.isNotEmpty) {
          final coords = _extractCoordinatesFromUrl(urlText);
          latitude = coords.$1;
          longitude = coords.$2;
          locationUrl = urlText;
        }
      }

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

      final proposalData = ProposalDataDto(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        city: _selectedCity ?? '',
        type: _selectedPropertyType,
        price: double.tryParse(_priceController.text.trim()),
        location: ProposalLocationDto(
          latitude: latitude,
          longitude: longitude,
          mapUrl: locationUrl, // Backend expects map_url
          url: locationUrl, // Keep for backward compatibility
        ),
        amenities: _selectedAmenities.isNotEmpty ? _selectedAmenities : null,
        photos: allPhotoUrls.isNotEmpty ? allPhotoUrls : null,
      );

      // Get the original proposal to preserve type and propertyId
      final proposalAsync = ref.read(proposalDetailProvider(widget.proposalId));
      final originalProposal = proposalAsync.value;
      if (originalProposal == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Proposal not loaded. Please try again.'),
              backgroundColor: AppTheme.dangerRed,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final updatedProposal = Proposal(
        id: originalProposal.id,
        type: originalProposal.type,
        status: ProposalStatus.pending, // Change status to PENDING when edited
        propertyId: originalProposal.propertyId,
        ownerId: originalProposal.ownerId,
        data: ProposalData(
          name: proposalData.title ?? '',
          description: proposalData.description,
          city: proposalData.city,
          address: locationUrl,
          latitude: latitude,
          longitude: longitude,
          propertyType: proposalData.type,
          pricePerNight: proposalData.price ?? 0,
          amenities: proposalData.amenities,
          photos: allPhotoUrls.isNotEmpty ? allPhotoUrls : null, // Include photos in ProposalData
        ),
        createdAt: originalProposal.createdAt,
        updatedAt: DateTime.now(),
      );

      // Use updateProposal use case
      final updateUseCase = ref.read(updateProposalUseCaseProvider);
      await updateUseCase(widget.proposalId, updatedProposal);

      if (mounted) {
        // Invalidate providers to refresh data BEFORE showing success dialog
        // This ensures the list is refreshed when we navigate back
        ref.invalidate(ownerProposalsProvider);
        ref.invalidate(proposalDetailProvider(widget.proposalId));
        
        // Wait a moment for the invalidation to trigger
        await Future.delayed(const Duration(milliseconds: 200));
        
        if (mounted) {
          await SuccessDialog.show(
            context,
            title: l10n.success,
            message: l10n.proposalUpdatedSuccessfully,
          );
          if (mounted) {
            context.pop();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        String errorMessage = l10n.failedToUpdateProposal;
        
        // Handle specific error types with user-friendly messages
        if (e is ValidationFailure) {
          // 400 Bad Request or 422 Validation errors
          if (e.message.contains('PENDING') || e.message.contains('REJECTED')) {
            errorMessage = l10n.onlyPendingOrRejectedCanBeModified;
          } else {
            errorMessage = '${l10n.failedToUpdateProposal}\n${e.message}';
          }
        } else if (e is UnauthorizedFailure) {
          // 403 Forbidden
          if (e.message.contains('owner') || e.message.contains('permission')) {
            errorMessage = l10n.youDontHavePermissionToModify;
          } else {
            errorMessage = '${l10n.failedToUpdateProposal}\n${e.message}';
          }
        } else if (e is NotFoundFailure) {
          // 404 Not Found
          errorMessage = '${l10n.failedToUpdateProposal}\n${e.message}';
        } else if (e is ServerFailure) {
          errorMessage = '${l10n.failedToUpdateProposal}\n${e.message}';
        } else {
          errorMessage = '${l10n.failedToUpdateProposal}: ${e.toString()}';
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
      case 'balcony':
        return l10n.balcony;
      case 'pool':
        return l10n.pool;
      case 'gym':
        return l10n.gym;
      case 'air_conditioning':
        return l10n.airConditioning;
      case 'heating':
        return l10n.heating;
      case 'tv':
        return l10n.tv;
      case 'kitchen':
        return l10n.kitchen;
      case 'washing_machine':
        return l10n.laundry;
      case 'elevator':
        return l10n.elevator;
      case 'security':
        return l10n.security;
      default:
        return amenity.replaceAll('_', ' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final proposalAsync = ref.watch(proposalDetailProvider(widget.proposalId));
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.proposalEdit),
      ),
      body: proposalAsync.when(
        data: (proposal) {
          // Initialize form once when proposal data is loaded
          if (!_isInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _initializeForm(proposal);
            });
          }
          
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingLG),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    AppTextField(
                      label: l10n.title,
                      controller: _titleController,
                      autoValidate: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.titleRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    AppTextField(
                      label: l10n.description,
                      controller: _descriptionController,
                      maxLines: 4,
                      autoValidate: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.descriptionRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // City dropdown
                    Builder(
                      builder: (context) {
                        final locale = Localizations.localeOf(context);
                        return DropdownButtonFormField<String>(
                          value: _selectedCity,
                          decoration: InputDecoration(
                            labelText: l10n.city,
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            filled: true,
                            fillColor: AppTheme.gray50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppTheme.gray300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppTheme.gray300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppTheme.dangerRed),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppTheme.dangerRed, width: 2),
                            ),
                          ),
                          items: _cities.map((city) {
                            return DropdownMenuItem(
                              value: city,
                              child: Text(_getCityDisplayName(city, locale)),
                            );
                          }).toList(),
                          selectedItemBuilder: (context) {
                            return _cities.map((city) {
                              return Text(_getCityDisplayName(city, locale));
                            }).toList();
                          },
                          onChanged: (value) {
                            setState(() => _selectedCity = value);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.cityRequired;
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Property Type
                    DropdownButtonFormField<String>(
                      value: _selectedPropertyType,
                      decoration: InputDecoration(
                        labelText: l10n.propertyType,
                        filled: true,
                        fillColor: AppTheme.gray50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.gray300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.gray300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.dangerRed, width: 2),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.dangerRed, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
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
                        if (value == null) {
                          return l10n.propertyTypeRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Price
                    AppTextField(
                      label: l10n.pricePerNight,
                      controller: _priceController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      autoValidate: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.priceRequired;
                        }
                        if (double.tryParse(value) == null) {
                          return l10n.priceInvalid;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Location Section
                    Text(
                      l10n.location,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    
                    // Get Current Location Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isGettingLocation ? null : _getCurrentLocation,
                        icon: _isGettingLocation
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.location_on),
                        label: Text(
                          _isGettingLocation
                              ? l10n.gettingLocation
                              : (_gpsLatitude != null && _gpsLongitude != null)
                                  ? l10n.locationRetrieved
                                  : l10n.getCurrentLocation,
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: (_gpsLatitude != null && _gpsLongitude != null)
                                ? AppTheme.successGreen
                                : AppTheme.primaryBlue,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    if (_gpsLatitude != null && _gpsLongitude != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.successGreen,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppTheme.successGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${l10n.latitude}: ${_gpsLatitude!.toStringAsFixed(6)}\n${l10n.longitude}: ${_gpsLongitude!.toStringAsFixed(6)}',
                                style: TextStyle(
                                  color: AppTheme.successGreen,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    
                    // Location URL
                    AppTextField(
                      label: '${l10n.locationUrl} (${l10n.optional})',
                      controller: _locationUrlController,
                      keyboardType: TextInputType.url,
                      hint: 'https://maps.google.com/?q=32.115,20.067',
                      autoValidate: true,
                      validator: (value) {
                        if (value != null && value.isNotEmpty && _gpsLatitude == null && _gpsLongitude == null) {
                          final uri = Uri.tryParse(value);
                          if (uri == null || !uri.hasScheme) {
                            return l10n.locationUrlInvalid;
                          }
                          final coords = _extractCoordinatesFromUrl(value);
                          if (coords.$1 == null || coords.$2 == null) {
                            return null;
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Amenities
                    Text(
                      l10n.amenities,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableAmenities.map((amenity) {
                        final isSelected = _selectedAmenities.contains(amenity);
                        return FilterChip(
                          label: Text(_getAmenityLabel(amenity, l10n)),
                          selected: isSelected,
                          onSelected: (_) => _toggleAmenity(amenity),
                          selectedColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
                          checkmarkColor: AppTheme.primaryBlue,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    
                    // Photos
                    Text(
                      l10n.photos,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    
                    // Photo selection buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo_library),
                            label: Text(l10n.gallery),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _takePhoto,
                            icon: const Icon(Icons.camera_alt),
                            label: Text(l10n.camera),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Existing photos
                    if (_existingPhotoUrls.isNotEmpty) ...[
                      Text(
                        'Existing Photos',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _existingPhotoUrls.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: _existingPhotoUrls[index],
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: AppTheme.gray200,
                                    child: const Center(child: CircularProgressIndicator()),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: AppTheme.gray200,
                                    child: const Icon(Icons.image_not_supported),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeExistingPhoto(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // New photos grid
                    if (_selectedPhotos.isNotEmpty) ...[
                      Text(
                        'New Photos',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _selectedPhotos.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _selectedPhotos[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removePhoto(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    const SizedBox(height: 32),
                    
                    // Submit button
                    AppButton(
                      text: l10n.saveChanges,
                      onPressed: _isLoading ? null : _updateProposal,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppTheme.dangerRed),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load proposal',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.gray600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Go Back',
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
