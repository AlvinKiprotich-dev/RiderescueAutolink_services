import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:riderescue_services/constants/api_endpoints.dart';
import 'package:riderescue_services/plugins/providers/app_provider.dart';
import 'package:riderescue_services/plugins/providers/network_provider.dart';
import 'package:riderescue_services/models/user.dart';
import 'package:riderescue_services/widgets/file_upload_widget.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;
  String? _avatarUrl;
  String? _avatarUploadId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = ref.read(userProvider);
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
      _addressController.text = user.address ?? '';
      _avatarUrl = user.avatar;
    }
  }

  void _onAvatarUploaded(String url, String uploadId) {
    setState(() {
      _avatarUrl = url;
      _avatarUploadId = uploadId;
    });
  }

  void _onAvatarDeleted() {
    setState(() {
      _avatarUrl = null;
      _avatarUploadId = null;
    });
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    final network = ref.read(networkProvider);
    final app = ref.read(appNotifierProvider.notifier);

    final body = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
    };

    // Add avatar if it was uploaded
    if (_avatarUploadId != null && _avatarUrl != null) {
      body['avatar'] = _avatarUrl!;
      body['avatarUploadId'] = _avatarUploadId!;
    }

    final response = await network.submit(
      method: HttpMethod.put,
      path: ApiEndpoints.userProfile,
      body: body,
    );

    setState(() => _isLoading = false);

    if (response.success && response.data != null) {
      final userMap = response.data?['user'] as Map<String, dynamic>?;
      if (userMap != null) {
        await app.updateUserDetails(User.fromJson(userMap));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid response from server')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Update failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDisabled = _isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colors.onSurface,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SpinKitThreeBounce(color: Colors.grey, size: 20),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Picture Section
            Center(
              child: Stack(
                children: [
                  // Avatar with border and FileUploadWidget
                  AbsorbPointer(
                    absorbing: isDisabled,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.amber, width: 3),
                      ),
                      child: ClipOval(
                                              child: FileUploadWidget(
                        initialUrl: _avatarUrl,
                        initialUploadId: _avatarUploadId,
                        onFileUploaded: _onAvatarUploaded,
                        onFileDeleted: _onAvatarDeleted,
                        showPreview: true,
                        maxWidth: 400,
                        maxHeight: 400,
                        imageQuality: 80,
                        customIcon: Icons.person,
                      ),
                      ),
                    ),
                  ),
                  // Edit Icon overlay (disabled if loading)
                  if (!isDisabled)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.amber[700],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // User Name
            Text(
              _nameController.text.isNotEmpty
                  ? _nameController.text
                  : 'User Name',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 32),
            // Information Cards
            _buildInfoCard(
              icon: Icons.person,
              title: 'Name',
              value: _nameController.text.isNotEmpty
                  ? _nameController.text
                  : 'Enter your name',
              onTap: isDisabled
                  ? null
                  : () => _showEditDialog('Name', _nameController),
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.email,
              title: 'Email',
              value: ref.read(userProvider)?.email ?? 'No email',
              onTap: null, // Email editing not implemented
            ),
            // const SizedBox(height: 12),
            // _buildInfoCard(
            //   icon: Icons.lock,
            //   title: 'Password',
            //   value: '••••••••••',
            //   onTap: isDisabled ? null : () => context.push('/change-password'),
            // ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.location_on,
              title: 'Location',
              value: _addressController.text.isNotEmpty
                  ? _addressController.text
                  : 'Enter your location',
              onTap: isDisabled
                  ? null
                  : () => _showEditDialog('Location', _addressController),
            ),
            const SizedBox(height: 32),
            // Update button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isDisabled ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isDisabled
                    ? const SpinKitThreeBounce(color: Colors.white, size: 20)
                    : const Text(
                        'UPDATE PROFILE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: ListTile(
        leading: Icon(icon, color: colors.onSurface, size: 24),
        title: Text(
          value,
          style: TextStyle(color: colors.onSurface, fontSize: 16),
        ),
        trailing: onTap != null
            ? Icon(
                Icons.edit_outlined,
                color: colors.onSurface.withOpacity(0.6),
                size: 20,
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  void _showEditDialog(String field, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $field'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: field,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {}); // Refresh UI
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
