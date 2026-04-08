import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riderescue_services/plugins/providers/app_provider.dart';
import 'package:riderescue_services/plugins/providers/network_provider.dart';
import 'package:riderescue_services/widgets/file_upload_widget.dart';
import 'package:riderescue_services/constants/api_endpoints.dart';
import 'package:riderescue_services/constants/service.dart';
import 'package:riderescue_services/models/brands.dart';
import 'package:riderescue_services/models/expertise.dart';
import 'package:riderescue_services/models/service.dart';
import 'package:riderescue_services/widgets/selection_list_widget.dart';
import 'package:riderescue_services/constants/route_names.dart';
import 'package:go_router/go_router.dart';
import 'map_selection_screen.dart';

class ServiceOnboardingScreen extends ConsumerStatefulWidget {
  const ServiceOnboardingScreen({super.key});

  @override
  ConsumerState<ServiceOnboardingScreen> createState() =>
      _ServiceOnboardingScreenState();
}

class _ServiceOnboardingScreenState
    extends ConsumerState<ServiceOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _aboutController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _vehicleMakeController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleYearController = TextEditingController();

  String? _selectedServiceType;
  String? _selectedCountry;
  String? _selectedCity;
  String? _selectedGender;
  String? _selectedDateOfBirth;
  String? _photoUrl;
  String? _photoUploadId;
  List<String> _selectedBrands = [];
  List<String> _selectedExpertise = [];
  List<Brand> _availableBrands = [];
  List<Expertise> _availableExpertise = [];
  List<Brand> _filteredBrands = [];
  List<Expertise> _filteredExpertise = [];
  bool _isSubmitting = false;
  bool _isLoadingBrands = false;
  bool _isLoadingExpertise = false;
  int _currentStep = 0;

  final List<String> _serviceTypes = serviceTypesList;
  final List<String> _countries = countriesList;
  final List<String> _kenyanCities = kenyanCitiesList;
  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _setDefaultValues();

    // Add listeners to save form state and clear errors
    _nameController.addListener(_onFieldChanged);
    _aboutController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _addressController.addListener(_onFieldChanged);
    _companyNameController.addListener(_onFieldChanged);
    _vehicleMakeController.addListener(_onFieldChanged);
    _vehicleModelController.addListener(_onFieldChanged);
    _vehicleYearController.addListener(_onFieldChanged);

    // Load saved form state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedFormState();
    });

    // Load brands and expertise data
    _loadBrandsAndExpertise();
  }

  void _onFieldChanged() {
    _saveFormState();
    setState(() {});
  }

  void _setDefaultValues() {
    // Set default values
    _selectedServiceType ??= _getNextAvailableServiceType();
    if (_selectedCountry == null && _countries.isNotEmpty) {
      _selectedCountry = _countries.first;
    }
  }

  String _getServiceTypeLabel() {
    switch (_selectedServiceType) {
      case 'garage':
        return 'Garage Name';
      case 'towing':
        return 'Towing Service Name';
      default:
        return 'Full Name';
    }
  }

  String _getServiceTypeHint() {
    switch (_selectedServiceType) {
      case 'garage':
        return 'Enter your garage name';
      case 'towing':
        return 'Enter your towing service name';
      default:
        return 'Enter your full name';
    }
  }

  IconData _getServiceTypeIcon(String serviceType) {
    switch (serviceType) {
      case 'mechanic':
        return Icons.build;
      case 'garage':
        return Icons.garage;
      case 'towing':
        return Icons.local_shipping;
      default:
        return Icons.build;
    }
  }

  String _getServiceTypeDescription(String serviceType) {
    switch (serviceType) {
      case 'mechanic':
        return 'Mobile mechanic providing on-site vehicle repairs and maintenance services';
      case 'garage':
        return 'Fixed location garage offering comprehensive vehicle repair and maintenance services';
      case 'towing':
        return 'Vehicle towing and roadside assistance services for emergency situations';
      default:
        return '';
    }
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit Setup'),
          content: const Text(
            'Your changes have not been saved and may be lost. Are you sure you want to exit?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Continue Setup',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Exit the page
              },
              child: Text(
                'Exit',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  String? _getNextAvailableServiceType() {
    final existingServiceTypes = ref
        .read(serviceProfilesProvider)
        .map((service) => service.type)
        .toSet();

    // Find the first service type that hasn't been used yet
    for (final serviceType in _serviceTypes) {
      if (!existingServiceTypes.contains(serviceType)) {
        return serviceType;
      }
    }

    // If all service types are used, return null
    return null;
  }

  List<String> _getAvailableServiceTypes() {
    final existingServiceTypes = ref
        .read(serviceProfilesProvider)
        .map((service) => service.type)
        .toSet();

    // Return only service types that haven't been used yet
    return _serviceTypes
        .where((type) => !existingServiceTypes.contains(type))
        .toList();
  }

  void _loadSavedFormState() {
    final savedState = ref.read(serviceFormStateProvider);
    if (savedState != null) {
      setState(() {
        _nameController.text = savedState['name'] ?? '';
        _aboutController.text = savedState['about'] ?? '';
        _phoneController.text = savedState['phone'] ?? '';
        _emailController.text = savedState['email'] ?? '';
        _addressController.text = savedState['address'] ?? '';
        _selectedServiceType = savedState['serviceType'];
        _selectedCountry = savedState['country'];
        _selectedCity = savedState['city'];
        _photoUrl = savedState['photoUrl'];
        _photoUploadId = savedState['photoUploadId'];
        _selectedBrands = List<String>.from(savedState['brands'] ?? []);
        _selectedExpertise = List<String>.from(savedState['expertise'] ?? []);
        _selectedGender = savedState['gender'];
        _selectedDateOfBirth = savedState['dateOfBirth'];
        _companyNameController.text = savedState['companyName'] ?? '';
        _vehicleMakeController.text = savedState['vehicleMake'] ?? '';
        _vehicleModelController.text = savedState['vehicleModel'] ?? '';
        _vehicleYearController.text = savedState['vehicleYear'] ?? '';
      });
    }
  }

  void _saveFormState() {
    final formData = {
      'name': _nameController.text,
      'about': _aboutController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'address': _addressController.text,
      'serviceType': _selectedServiceType,
      'country': _selectedCountry,
      'city': _selectedCity,
      'photoUrl': _photoUrl,
      'photoUploadId': _photoUploadId,
      'brands': _selectedBrands,
      'expertise': _selectedExpertise,
      'gender': _selectedGender,
      'dateOfBirth': _selectedDateOfBirth,
      'companyName': _companyNameController.text,
      'vehicleMake': _vehicleMakeController.text,
      'vehicleModel': _vehicleModelController.text,
      'vehicleYear': _vehicleYearController.text,
    };

    ref.read(appNotifierProvider.notifier).saveServiceFormState(formData);
  }

  void _clearFormState() {
    // Clear saved form state in app provider
    ref.read(appNotifierProvider.notifier).clearServiceFormState();

    // Reset all form fields to initial state
    setState(() {
      _nameController.clear();
      _aboutController.clear();
      _phoneController.clear();
      _emailController.clear();
      _addressController.clear();
      _companyNameController.clear();
      _vehicleMakeController.clear();
      _vehicleModelController.clear();
      _vehicleYearController.clear();
      _selectedServiceType = _getNextAvailableServiceType();
      _selectedCountry = _countries.isNotEmpty ? _countries.first : null;
      _selectedCity = null;
      _selectedGender = null;
      _selectedDateOfBirth = null;
      _photoUrl = null;
      _photoUploadId = null;
      _selectedBrands.clear();
      _selectedExpertise.clear();
      _currentStep = 0;
    });
  }

  Future<void> _loadBrandsAndExpertise() async {
    await Future.wait([_loadBrands(), _loadExpertise()]);
  }

  Future<void> _loadBrands() async {
    setState(() {
      _isLoadingBrands = true;
    });

    try {
      final network = ref.read(networkProvider);
      final response = await network.get('/brands', query: {'limit': 100});

      if (response.success && response.data != null) {
        final brandsData = response.data!['brands'] as List<dynamic>? ?? [];
        setState(() {
          _availableBrands = brandsData
              .map((brand) => Brand.fromJson(brand as Map<String, dynamic>))
              .toList();
          _filteredBrands = List.from(_availableBrands);
          _isLoadingBrands = false;
        });
      } else {
        setState(() {
          _isLoadingBrands = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingBrands = false;
      });
    }
  }

  Future<void> _loadExpertise() async {
    setState(() {
      _isLoadingExpertise = true;
    });

    try {
      final network = ref.read(networkProvider);
      final response = await network.get('/expertise', query: {'limit': 100});

      if (response.success && response.data != null) {
        final expertiseData =
            response.data!['expertise'] as List<dynamic>? ?? [];
        setState(() {
          _availableExpertise = expertiseData
              .map(
                (expertise) =>
                    Expertise.fromJson(expertise as Map<String, dynamic>),
              )
              .toList();
          _filterExpertise();
          _isLoadingExpertise = false;
        });
      } else {
        setState(() {
          _isLoadingExpertise = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingExpertise = false;
      });
    }
  }

  void _filterExpertise() {
    List<Expertise> filtered = List.from(_availableExpertise);

    // Filter by service type if selected
    if (_selectedServiceType != null) {
      filtered = filtered
          .where(
            (expertise) =>
                expertise.serviceTypes.contains(_selectedServiceType),
          )
          .toList();
    }

    setState(() {
      _filteredExpertise = filtered;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _companyNameController.dispose();
    _vehicleMakeController.dispose();
    _vehicleModelController.dispose();
    _vehicleYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Column(
          children: [
            Row(
              children: [
                _currentStep == 0
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => _showExitConfirmation(),
                      )
                    : IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: _previousStep,
                      ),
                const Spacer(),
                // if (_currentStep == 0)
                TextButton(
                  onPressed: () => _showExitConfirmation(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
              child: _buildProgressIndicator(),
            ),
          ],
        ),
        elevation: 4,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(key: _formKey, child: _buildCurrentStep()),
          ),
          _buildProceedButton(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(5, (index) {
        final isCompleted = index < _currentStep;
        final isCurrent = index == _currentStep;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (index < 4)
                Container(
                  width: 8,
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalDetailsStep();
      case 1:
        return _buildContactLocationStep();
      case 2:
        return _buildPhotoStep();
      case 3:
        return _buildBrandsStep();
      case 4:
        return _buildExpertiseStep();
      default:
        return _buildPersonalDetailsStep();
    }
  }

  Widget _buildPersonalDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Provide your basic personal information to set up your account and tailor your service experience.',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),

          // Service Type Selection
          _buildServiceTypeField(),
          const SizedBox(height: 24),

          // Name Field
          _buildTextField(
            controller: _nameController,
            label: _getServiceTypeLabel(),
            hint: _getServiceTypeHint(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter ${_getServiceTypeLabel().toLowerCase()}';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Conditional fields based on service type
          if (_selectedServiceType == 'mechanic') ...[
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    value: _selectedGender,
                    label: 'Gender',
                    hint: 'Select gender',
                    items: _genders,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                        _saveFormState();
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select gender';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: _buildDateOfBirthField()),
              ],
            ),
            const SizedBox(height: 16),
          ] else if (_selectedServiceType == 'garage') ...[
            _buildTextField(
              controller: _companyNameController,
              label: 'Company Name',
              hint: 'Enter your garage company name',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter company name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
          ] else if (_selectedServiceType == 'towing') ...[
            _buildTextField(
              controller: _vehicleMakeController,
              label: 'Vehicle Make',
              hint: 'e.g., Toyota, Ford, Nissan',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter vehicle make';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _vehicleModelController,
                    label: 'Vehicle Model',
                    hint: 'e.g., Camry, F-150, Patrol',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter vehicle model';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _vehicleYearController,
                    label: 'Vehicle Year',
                    hint: 'e.g., 2020, 2019',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter vehicle year';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // About Field
          _buildTextField(
            controller: _aboutController,
            label: 'About',
            hint: 'Describe your service, experience, and expertise...',
            maxLines: 4,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter service description';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactLocationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact & Location',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Provide your contact information and service location.',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),

          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            hint: '+254712345678 (with country code)',
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _emailController,
            label: 'Email (Optional)',
            hint: 'john@autorepair.com (for business inquiries)',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Location',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              TextButton.icon(
                onPressed: _openMapSelection,
                icon: const Icon(Icons.map),
                label: const Text('Select from Map'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _addressController,
            label: 'Address',
            hint: '123 Main Street, Nairobi (your service location)',
            prefixIcon: const Icon(Icons.location_on),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  value: _selectedCity,
                  label: 'City',
                  hint: 'Select city',
                  items: _kenyanCities,
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value;
                      _saveFormState();
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a city';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  value: _selectedCountry,
                  label: 'Country',
                  hint: 'Select country',
                  items: _countries,
                  onChanged: (value) {
                    setState(() {
                      _selectedCountry = value;
                      _saveFormState();
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a country';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service Photo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload a photo that represents your service.',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            height: 200,
            child: FileUploadWidget(
              initialUrl: _photoUrl,
              initialUploadId: _photoUploadId,
              onFileUploaded: (url, uploadId) {
                setState(() {
                  _photoUrl = url;
                  _photoUploadId = uploadId;
                  _saveFormState();
                });
              },
              onFileDeleted: () {
                setState(() {
                  _photoUrl = null;
                  _photoUploadId = null;
                  _saveFormState();
                });
              },
              maxWidth: 800,
              maxHeight: 600,
              imageQuality: 80,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Brands of Expertise',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the brands you have expertise in.',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),

          if (_isLoadingBrands)
            const Center(child: CircularProgressIndicator())
          else
            SelectionListWidget(
              items: _filteredBrands
                  .map(
                    (brand) => SelectionItem(
                      id: brand.name,
                      title: brand.name,
                      emoji: '🚗',
                    ),
                  )
                  .toList(),
              selectedItems: _selectedBrands,
              onItemSelected: (brandName) {
                setState(() {
                  _selectedBrands.add(brandName);
                  _saveFormState();
                });
              },
              onItemDeselected: (brandName) {
                setState(() {
                  _selectedBrands.remove(brandName);
                  _saveFormState();
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildExpertiseStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Areas of Expertise',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your areas of expertise.',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),

          if (_isLoadingExpertise)
            const Center(child: CircularProgressIndicator())
          else
            SelectionListWidget(
              items: _filteredExpertise
                  .map(
                    (expertise) => SelectionItem(
                      id: expertise.name,
                      title: expertise.name,
                      emoji: '🔧',
                    ),
                  )
                  .toList(),
              selectedItems: _selectedExpertise,
              onItemSelected: (expertiseName) {
                setState(() {
                  _selectedExpertise.add(expertiseName);
                  _saveFormState();
                });
              },
              onItemDeselected: (expertiseName) {
                setState(() {
                  _selectedExpertise.remove(expertiseName);
                  _saveFormState();
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    Widget? prefixIcon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
          validator: validator,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceTypeField() {
    final availableServiceTypes = _getAvailableServiceTypes();
    final allServiceTypesUsed = availableServiceTypes.isEmpty;

    if (allServiceTypesUsed) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'All Service Types Added',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'You have already created profiles for all available service types.',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: availableServiceTypes.map((serviceType) {
            final isSelected = _selectedServiceType == serviceType;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedServiceType = serviceType;
                    _filterExpertise();
                    _saveFormState();
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getServiceTypeIcon(serviceType),
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        serviceType,
                        style: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        if (_selectedServiceType != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Text(
              _getServiceTypeDescription(_selectedServiceType!),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Please select a service type',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDateOfBirthField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDateOfBirth(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDateOfBirth ?? 'Date of Birth',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: _selectedDateOfBirth != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 6570),
      ), // 18 years ago
      firstDate: DateTime.now().subtract(
        const Duration(days: 36500),
      ), // 100 years ago
      lastDate: DateTime.now().subtract(
        const Duration(days: 6570),
      ), // 18 years ago
    );

    if (picked != null) {
      setState(() {
        _selectedDateOfBirth =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
        _saveFormState();
      });
    }
  }

  void _openMapSelection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapSelectionScreen()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _addressController.text = result['address'] ?? '';
        _selectedCity = result['city'];
        _selectedCountry = result['country'];
        _saveFormState();
      });
    }
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0:
        return _nameController.text.isNotEmpty &&
            _aboutController.text.isNotEmpty &&
            _selectedServiceType != null &&
            (_selectedServiceType != 'mechanic' || _selectedGender != null) &&
            (_selectedServiceType != 'garage' ||
                _companyNameController.text.isNotEmpty) &&
            (_selectedServiceType != 'towing' ||
                (_vehicleMakeController.text.isNotEmpty &&
                    _vehicleModelController.text.isNotEmpty &&
                    _vehicleYearController.text.isNotEmpty));
      case 1:
        return _phoneController.text.isNotEmpty &&
            _addressController.text.isNotEmpty &&
            _selectedCity != null &&
            _selectedCountry != null;
      case 2:
        return _photoUrl != null;
      case 3:
        return _selectedBrands.isNotEmpty;
      case 4:
        return _selectedExpertise.isNotEmpty;
      default:
        return false;
    }
  }

  String _getProceedButtonText() {
    switch (_currentStep) {
      case 0:
      case 1:
      case 2:
      case 3:
        return 'Proceed';
      case 4:
        return 'Submit Service Profile';
      default:
        return 'Proceed';
    }
  }

  Widget _buildProceedButton() {
    final canProceed = _canProceedToNextStep();
    final buttonText = _getProceedButtonText();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: canProceed ? _handleProceedAction : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  void _handleProceedAction() {
    if (_currentStep < 4) {
      _nextStep();
    } else {
      _submitForm();
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_photoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a service photo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedBrands.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one brand of expertise'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedExpertise.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one area of expertise'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final network = ref.read(networkProvider);
      final authToken = ref.read(authTokenProvider);

      if (authToken == null) {
        throw Exception('Authentication token not found');
      }

      final requestBody = {
        'type': _selectedServiceType,
        'name': _nameController.text.trim(),
        'about': _aboutController.text.trim(),
        'photo': _photoUrl,
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        'address': _addressController.text.trim(),
        'city': _selectedCity ?? '',
        'country': _selectedCountry ?? '',
        'geoLocation': {
          'type': 'Point',
          'coordinates': [36.8219, -1.2921], // Default coordinates for Nairobi
        },
        'brandOfExpertise': _selectedBrands,
        'areaOfExpertise': _selectedExpertise,
        'gender': _selectedGender,
        'dateOfBirth': _selectedDateOfBirth,
        'companyName': _companyNameController.text.trim(),
        'vehicleMake': _vehicleMakeController.text.trim(),
        'vehicleModel': _vehicleModelController.text.trim(),
        'vehicleYear': _vehicleYearController.text.trim(),
      };

      // Create new service
      final response = await network.submit(
        method: HttpMethod.post,
        path: ApiEndpoints.registerService,
        body: requestBody,
      );

      if (response.success) {
        // Refresh service profiles in app provider after successful submission
        await ref.read(appNotifierProvider.notifier).refreshServiceProfiles();

        final service = response.data!['service'];

        // set the active service
        await ref
            .read(appNotifierProvider.notifier)
            .setActiveService(Service.fromJson(service));

        _clearFormState();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Service profile submitted successfully! Now upload your documents.',
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Close current page and navigate to service progress screen
          Navigator.pop(context);
          context.push(Routes.serviceProgress);
        }
      } else {
        throw Exception(response.message ?? 'Failed to submit service profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
