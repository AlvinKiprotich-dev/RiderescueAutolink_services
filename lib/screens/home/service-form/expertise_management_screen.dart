import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riderescue_services/plugins/providers/network_provider.dart';
import 'package:riderescue_services/models/expertise.dart';

class ExpertiseManagementScreen extends ConsumerStatefulWidget {
  final List<String> initialExpertise;
  final String? selectedServiceType;
  final Function(List<String>)? onExpertiseChanged;

  const ExpertiseManagementScreen({
    super.key,
    required this.initialExpertise,
    this.selectedServiceType,
    this.onExpertiseChanged,
  });

  @override
  ConsumerState<ExpertiseManagementScreen> createState() =>
      _ExpertiseManagementScreenState();
}

class _ExpertiseManagementScreenState
    extends ConsumerState<ExpertiseManagementScreen> {
  late List<String> _selectedExpertise;
  List<Expertise> _availableExpertise = [];
  List<Expertise> _filteredExpertise = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String? _currentServiceType;

  @override
  void initState() {
    super.initState();
    _selectedExpertise = List.from(widget.initialExpertise);
    _currentServiceType = widget.selectedServiceType;
    _fetchExpertise();
  }

  @override
  void didUpdateWidget(ExpertiseManagementScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if service type changed
    if (widget.selectedServiceType != _currentServiceType) {
      _handleServiceTypeChange(widget.selectedServiceType);
    }
  }

  void _handleServiceTypeChange(String? newServiceType) {
    if (_currentServiceType != null && newServiceType != _currentServiceType) {
      _showServiceTypeChangeWarning(newServiceType);
    } else {
      _updateServiceType(newServiceType);
    }
  }

  void _showServiceTypeChangeWarning(String? newServiceType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Service Type Changed'),
        content: const Text(
          'Changing the service type will clear your selected expertise areas. Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateServiceType(newServiceType);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _updateServiceType(String? newServiceType) {
    setState(() {
      _currentServiceType = newServiceType;
      _selectedExpertise.clear();
      _filterExpertise();
    });

    // Notify parent about expertise change
    widget.onExpertiseChanged?.call(_selectedExpertise);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchExpertise() async {
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
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterExpertise() {
    setState(() {
      List<Expertise> filtered = List.from(_availableExpertise);

      // Filter by service type if selected
      if (_currentServiceType != null) {
        filtered = filtered
            .where(
              (expertise) =>
                  expertise.serviceTypes.contains(_currentServiceType),
            )
            .toList();
      }

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        filtered = filtered
            .where(
              (expertise) =>
                  expertise.name.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  expertise.description.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  expertise.category.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
            )
            .toList();
      }

      _filteredExpertise = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Areas of Expertise',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        toolbarHeight: 44,
        elevation: 4,
        backgroundColor: Theme.of(context).colorScheme.surface,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _filterExpertise();
              },
              decoration: InputDecoration(
                hintText: 'Search expertise areas...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                          _filterExpertise();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (_currentServiceType != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withOpacity(0.3),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Showing expertise for: ${_currentServiceType!.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(child: _buildExpertiseList()),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildExpertiseList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredExpertise.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No expertise areas found'
                  : _currentServiceType != null
                  ? 'No expertise areas available for ${_currentServiceType!.toUpperCase()}'
                  : 'No expertise areas available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search terms'
                  : 'Please check back later',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _filteredExpertise.length,
      itemBuilder: (context, index) {
        final expertise = _filteredExpertise[index];
        final isSelected = _selectedExpertise.contains(expertise.name);

        return ListTile(
          leading: Icon(
            Icons.work,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            size: 20,
          ),
          title: Text(
            expertise.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                expertise.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      expertise.category,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      expertise.serviceTypes.join(', '),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Checkbox(
            value: isSelected,
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  if (!_selectedExpertise.contains(expertise.name)) {
                    _selectedExpertise.add(expertise.name);
                  }
                } else {
                  _selectedExpertise.remove(expertise.name);
                }
              });
              widget.onExpertiseChanged?.call(_selectedExpertise);
            },
            activeColor: Theme.of(context).colorScheme.primary,
            checkColor: Colors.white,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _clearAllExpertise,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Clear All'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _saveAndReturn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearAllExpertise() {
    setState(() {
      _selectedExpertise.clear();
    });
    widget.onExpertiseChanged?.call(_selectedExpertise);
  }

  void _saveAndReturn() {
    Navigator.pop(context, _selectedExpertise);
  }
}
