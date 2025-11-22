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
import 'package:maawa_project/data/dto/proposal_dto.dart';
import 'package:maawa_project/domain/entities/proposal.dart';
import 'package:maawa_project/l10n/app_localizations.dart';
import 'package:maawa_project/presentation/widgets/app_button.dart';
import 'package:maawa_project/presentation/widgets/app_text_field.dart';
import 'package:maawa_project/presentation/widgets/success_dialog.dart';

class ProposalFormAddScreen extends ConsumerStatefulWidget {
  const ProposalFormAddScreen({super.key});

  @override
  ConsumerState<ProposalFormAddScreen> createState() =>
      _ProposalFormAddScreenState();
}

class _ProposalFormAddScreenState extends ConsumerState<ProposalFormAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationUrlController = TextEditingController();
  final _priceController = TextEditingController();
  
  String? _selectedCity;
  String? _selectedPropertyType;
  final List<String> _selectedAmenities = [];
  final List<File> _selectedPhotos = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;
  
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
  // Backend expects: apartment, villa, chalet (not challete)
  final List<String> _propertyTypes = [
    'villa',
    'chalet', // Backend expects 'chalet', not 'challete'
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
      // Check if location services are enabled
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

      // Check location permissions
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
              duration: const Duration(seconds: 5),
            ),
          );
        }
        setState(() {
          _isGettingLocation = false;
        });
        return;
      }

      // Get current position
      geo.Position position = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.high,
        ),
      );

      setState(() {
        _gpsLatitude = position.latitude;
        _gpsLongitude = position.longitude;
        // Update the URL field with a Google Maps URL
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
      if (kDebugMode) {
        debugPrint('❌ Error getting location: $e');
      }
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

  /// Extracts latitude and longitude from Google Maps URL
  /// Supports formats like:
  /// - https://maps.google.com/?q=32.115,20.067
  /// - https://maps.app.goo.gl/...
  /// - https://www.google.com/maps/@32.0758635,20.104523,15z
  /// - https://www.google.com/maps/place/.../@32.0758635,20.104523,15z
  (double?, double?) _extractCoordinatesFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      
      // Method 1: Extract from query parameter ?q=lat,lng
      if (uri.queryParameters.containsKey('q')) {
        final qValue = uri.queryParameters['q']!;
        // Check if it's coordinates (lat,lng format)
        final coords = qValue.split(',');
        if (coords.length >= 2) {
          final lat = double.tryParse(coords[0].trim());
          final lng = double.tryParse(coords[1].trim());
          if (lat != null && lng != null) {
            if (kDebugMode) {
              debugPrint('📍 Extracted coordinates from ?q=: $lat, $lng');
            }
            return (lat, lng);
          }
        }
      }
      
      // Method 2: Extract from path pattern @lat,lng (e.g., /@32.0758635,20.104523)
      final fullUrl = uri.toString();
      final pathMatch = RegExp(r'@(-?\d+\.?\d*),(-?\d+\.?\d*)').firstMatch(fullUrl);
      if (pathMatch != null) {
        final lat = double.tryParse(pathMatch.group(1)!);
        final lng = double.tryParse(pathMatch.group(2)!);
        if (lat != null && lng != null) {
          if (kDebugMode) {
            debugPrint('📍 Extracted coordinates from @pattern: $lat, $lng');
          }
          return (lat, lng);
        }
      }
      
      // Method 3: Try to extract from ll parameter (lat,lng)
      if (uri.queryParameters.containsKey('ll')) {
        final llValue = uri.queryParameters['ll']!;
        final coords = llValue.split(',');
        if (coords.length >= 2) {
          final lat = double.tryParse(coords[0].trim());
          final lng = double.tryParse(coords[1].trim());
          if (lat != null && lng != null) {
            if (kDebugMode) {
              debugPrint('📍 Extracted coordinates from ll=: $lat, $lng');
            }
            return (lat, lng);
          }
        }
      }
      
      // Method 4: For short URLs (maps.app.goo.gl), we might need to resolve them
      // For now, return null and show error
      if (kDebugMode) {
        debugPrint('⚠️ Could not extract coordinates from URL: $url');
      }
      return (null, null);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error extracting coordinates: $e');
      }
      return (null, null);
    }
  }

  Future<void> _submitProposal() async {
    // Trigger validation on all fields - this will show red borders and error messages
    // The validate() method will automatically show error messages and red borders
    if (!_formKey.currentState!.validate()) {
      // Validation failed - errors are now visible on the form
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
      // Upload photos to backend and get URLs
      // Backend expects photos as array of URL strings: ["https://...", "https://..."]
      List<String> photoUrls = [];
      
      if (_selectedPhotos.isNotEmpty) {
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.uploading} ${_selectedPhotos.length} ${l10n.photos}...'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        
        try {
          final imageUploadApi = ref.read(imageUploadApiProvider);
          final uploadedUrls = await imageUploadApi.uploadImages(
            _selectedPhotos,
            folder: 'proposals', // Optional: organize uploads by folder
          );
          
          // Backend expects array of URL strings, not objects
          photoUrls = uploadedUrls;
          
          if (kDebugMode) {
            debugPrint('✅ Successfully uploaded ${photoUrls.length} photos');
            for (var url in photoUrls) {
              debugPrint('   - Photo URL: $url');
            }
          }
        } catch (uploadError) {
          if (mounted) {
            final l10n = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${l10n.failedToUploadPhotos}: $uploadError'),
                backgroundColor: AppTheme.dangerRed,
                duration: const Duration(seconds: 5),
              ),
            );
          }
          setState(() {
            _isLoading = false;
          });
          return; // Stop submission if photo upload fails
        }
      }

      // Get coordinates from GPS or URL
      double? latitude;
      double? longitude;
      String? locationUrl;

      // Priority: GPS location > URL extraction
      if (_gpsLatitude != null && _gpsLongitude != null) {
        latitude = _gpsLatitude;
        longitude = _gpsLongitude;
        locationUrl = _locationUrlController.text.trim().isNotEmpty
            ? _locationUrlController.text.trim()
            : 'https://maps.google.com/?q=$latitude,$longitude';
      } else {
        // Try to extract from URL
        final urlText = _locationUrlController.text.trim();
        if (urlText.isNotEmpty) {
          final coords = _extractCoordinatesFromUrl(urlText);
          latitude = coords.$1;
          longitude = coords.$2;
          locationUrl = urlText;
        }
      }

      // Validate that we have coordinates
      if (latitude == null || longitude == null) {
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.locationRequired),
              backgroundColor: AppTheme.dangerRed,
              duration: const Duration(seconds: 5),
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
          url: locationUrl,
          latitude: latitude,
          longitude: longitude,
        ),
        amenities: _selectedAmenities.isNotEmpty ? _selectedAmenities : null,
        photos: photoUrls.isNotEmpty ? photoUrls : null, // Array of URL strings
      );

      // Create proposal entity for type/propertyId (photos are in DTO, not entity)
      final proposal = Proposal(
        id: '',
        type: ProposalType.add,
        status: ProposalStatus.pending,
        ownerId: '', // Will be set by backend
        data: ProposalData(
          name: proposalData.title ?? '',
          description: proposalData.description,
          city: proposalData.city,
          address: locationUrl, // Store URL in address field
          latitude: latitude, // Store extracted latitude
          longitude: longitude, // Store extracted longitude
          propertyType: proposalData.type,
          pricePerNight: proposalData.price ?? 0,
          amenities: proposalData.amenities,
        ),
        createdAt: DateTime.now(),
      );

      // Create the request DTO with photos included
      final request = CreateProposalRequestDto(
        type: proposal.type.name.toUpperCase(),
        propertyId: proposal.propertyId,
        payload: proposalData, // Pass the DTO with photos directly
      );

      if (kDebugMode) {
        debugPrint('📤 Submitting proposal with payload: ${request.toJson()}');
        if (proposalData.photos != null && proposalData.photos!.isNotEmpty) {
          debugPrint('📸 Including ${proposalData.photos!.length} photos in payload');
          for (int i = 0; i < proposalData.photos!.length; i++) {
            debugPrint('   - Photo $i: ${proposalData.photos![i]}');
          }
        } else {
          debugPrint('⚠️ No photos in payload');
        }
      }

      // Call the API directly to preserve photos in the payload
      // (Bypassing repository to avoid losing photos in domain entity conversion)
      final proposalApi = ref.read(proposalApiProvider);
      
      ProposalDto createdProposalDto;
      try {
        createdProposalDto = await proposalApi.createProposal(request);
      } catch (e) {
        // Wrap the error using ErrorHandler to get proper Failure types
        throw ErrorHandler.handleError(e);
      }

      if (kDebugMode) {
        debugPrint('✅ Proposal created successfully with ID: ${createdProposalDto.id}');
      }

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        await SuccessDialog.show(
          context,
          title: l10n.success,
          message: l10n.proposalSubmittedSuccessfully,
        );
        if (mounted) {
          context.pop();
          // Refresh proposals list
          ref.invalidate(ownerProposalsProvider);
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        String errorMessage = l10n.failedToSubmitProposal;
        
        if (kDebugMode) {
          debugPrint('❌ Proposal submission error: $e');
          debugPrint('❌ Error type: ${e.runtimeType}');
        }
        
        // Check if it's an UnauthorizedFailure
        if (e is UnauthorizedFailure) {
          errorMessage = '${l10n.failedToSubmitProposal}\n${e.message}';
        } else if (e is ValidationFailure) {
          errorMessage = '${l10n.failedToSubmitProposal}\n${e.message}';
        } else if (e is ServerFailure) {
          errorMessage = '${l10n.failedToSubmitProposal}\n${e.message}';
        } else {
          // For other errors, show a more user-friendly message
          final errorString = e.toString();
          if (errorString.contains('type') && errorString.contains('Null') && errorString.contains('String')) {
            // This is the parsing error - proposal was created but response parsing failed
            errorMessage = '${l10n.proposalSubmittedSuccessfully}\n(Note: Response parsing issue - proposal may have been created)';
          } else {
            errorMessage = '${l10n.failedToSubmitProposal}: ${errorString.split('(').first.trim()}';
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
            backgroundColor: AppTheme.dangerRed,
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
        return l10n.challete; // Display label uses 'challete', but backend expects 'chalet'
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
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createProposal),
      ),
      body: SafeArea(
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
                    errorStyle: const TextStyle(
                      color: AppTheme.dangerRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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
                
                // Location URL (Optional - for manual entry or display)
                AppTextField(
                  label: '${l10n.locationUrl} (${l10n.optional})',
                  controller: _locationUrlController,
                  keyboardType: TextInputType.url,
                  hint: 'https://maps.google.com/?q=32.115,20.067',
                  autoValidate: true,
                  validator: (value) {
                    // Only validate if user entered something and GPS location is not set
                    if (value != null && value.isNotEmpty && _gpsLatitude == null && _gpsLongitude == null) {
                      final uri = Uri.tryParse(value);
                      if (uri == null || !uri.hasScheme) {
                        return l10n.locationUrlInvalid;
                      }
                      // Try to extract coordinates to validate URL format
                      final coords = _extractCoordinatesFromUrl(value);
                      if (coords.$1 == null || coords.$2 == null) {
                        // Allow shortened URLs - they might be valid but we can't extract coords
                        // Just check if it's a valid URL format
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
                
                // Selected photos grid
                if (_selectedPhotos.isNotEmpty)
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
                
                const SizedBox(height: 32),
                
                // Submit button
                AppButton(
                  text: l10n.submitProposal,
                  onPressed: _isLoading ? null : _submitProposal,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
