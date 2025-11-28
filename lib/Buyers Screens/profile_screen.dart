import 'package:flutter/material.dart';
import 'edit_info_modal.dart';
import 'custom_drawer.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'user_data.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kissan/core/services/image_upload_service.dart';
import 'package:kissan/core/di/service_locator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kissan/core/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kissan/screens/forgot_password.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _selectedImagePath;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isHoveringProfileImage = false;
  bool _isUploadingImage = false;
  bool _isLoading = true;
  late final ImageUploadService _imageUploadService;
  late final AuthService _authService;

  Map<String, dynamic> userData = {
    'name': 'User',
    'phone': '',
    'profilePicture': null,
    'joinedOn': '',
  };

  @override
  void initState() {
    super.initState();
    _authService = AuthService.instance;
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ServiceLocator.init(context);
    _imageUploadService = ServiceLocator.get<ImageUploadService>();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final userId = currentUser?.uid;

      debugPrint('🔍 Loading user data for userId: $userId');
      debugPrint('🔍 Current user displayName: ${currentUser?.displayName}');
      debugPrint('🔍 Current user phoneNumber: ${currentUser?.phoneNumber}');

      if (userId == null || currentUser == null) {
        debugPrint('❌ No user logged in');
        if (mounted) {
          setState(() {
            _isLoading = false;
            userData = {
              'name': 'Guest',
              'phone': 'Not logged in',
              'profilePicture': null,
              'joinedOn': 'N/A',
            };
          });
        }
        return;
      }

      // Get Firestore data
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      debugPrint('🔍 Firestore doc exists: ${doc.exists}');
      debugPrint('🔍 Firestore data: ${doc.data()}');

      if (mounted) {
        String name = 'User';
        String phone = '';
        String? profilePic;
        String joinedOn = 'Recently';

        if (doc.exists) {
          final data = doc.data()!;
          name = data['name'] ?? currentUser.displayName ?? 'User';
          phone = data['phone'] ?? currentUser.phoneNumber ?? '';
          profilePic = data['profilePicture'];

          final createdAt = data['createdAt'] as Timestamp?;
          if (createdAt != null) {
            joinedOn = _formatDate(createdAt.toDate());
          }

          // If phone is empty but we have it in the document, it means user signed up
          // but phone wasn't saved. Show a placeholder.
          if (phone.isEmpty) {
            phone = 'Add phone number';
            debugPrint('⚠️ Phone number is empty in Firestore');
          }
        } else {
          // Use Firebase Auth data and create Firestore doc
          name = currentUser.displayName ?? 'User';
          phone = currentUser.phoneNumber ?? '';
          profilePic = currentUser.photoURL;

          debugPrint('📝 Creating Firestore document...');
          // Create the document
          await FirebaseFirestore.instance.collection('users').doc(userId).set({
            'uid': userId,
            'name': name,
            'phone': phone,
            'profilePicture': profilePic,
            'role': 'buyer',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          debugPrint('✅ Firestore document created');
        }

        setState(() {
          userData = {
            'name': name,
            'phone': phone,
            'profilePicture': profilePic,
            'joinedOn': joinedOn,
          };
          _selectedImagePath = profilePic;
          if (_selectedImagePath != null) {
            sharedProfileImagePath = _selectedImagePath;
          }
          _isLoading = false;
        });

        debugPrint('✅ User data loaded: $userData');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading user data: $e');
      debugPrint('❌ Stack trace: $stackTrace');

      if (mounted) {
        // Show actual Firebase Auth data as fallback
        final currentUser = FirebaseAuth.instance.currentUser;
        setState(() {
          userData = {
            'name': currentUser?.displayName ?? 'User',
            'phone': currentUser?.phoneNumber ?? 'No phone',
            'profilePicture': currentUser?.photoURL,
            'joinedOn': 'Recently',
          };
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Future<void> _uploadProfileImage(File imageFile) async {
    if (!mounted) return;
    setState(() => _isUploadingImage = true);

    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        throw 'User not logged in. Please sign in again.';
      }

      final downloadUrl = await _imageUploadService.uploadProfileImage(
        imageFile,
        userId,
      );

      // Save to Firestore - create document if it doesn't exist
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'profilePicture': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        setState(() {
          _selectedImagePath = downloadUrl;
          sharedProfileImagePath = downloadUrl;
          userData['profilePicture'] = downloadUrl;
          _isUploadingImage = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      if (mounted) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditInfoModal() {
    // Capture the ScaffoldMessenger before the async operation
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => EditInfoModal(
            initialData: userData,
            onSave: (updatedData) async {
              try {
                final userId = _authService.currentUserId;
                if (userId == null) {
                  throw 'User not logged in';
                }

                // Update Firestore with merge to avoid overwriting
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .set({
                      'name': updatedData['name'],
                      'phone': updatedData['phone'],
                      if (updatedData['profilePicture'] != null)
                        'profilePicture': updatedData['profilePicture'],
                      'updatedAt': FieldValue.serverTimestamp(),
                    }, SetOptions(merge: true));

                // Also update Firebase Auth display name
                await FirebaseAuth.instance.currentUser?.updateDisplayName(
                  updatedData['name'],
                );

                await _loadUserData();
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                debugPrint('Save error: $e');
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Failed to update: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Change Profile Photo",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPhotoOption(
                      icon: Icons.photo_camera,
                      label: 'Take a photo',
                      onTap: () async {
                        Navigator.pop(context);
                        final pickedFile = await ImagePicker().pickImage(
                          source: ImageSource.camera,
                        );
                        if (pickedFile != null) {
                          await _uploadProfileImage(File(pickedFile.path));
                        }
                      },
                    ),
                    _buildPhotoOption(
                      icon: Icons.photo_library,
                      label: 'Choose from gallery',
                      onTap: () async {
                        Navigator.pop(context);
                        final pickedFile = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                        );
                        if (pickedFile != null) {
                          await _uploadProfileImage(File(pickedFile.path));
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF4CAF50).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Color(0xFF4CAF50), size: 30),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: CustomDrawer(imagePath: sharedProfileImagePath),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gradient Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00C853), Color(0xFF00E676)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      MouseRegion(
                        onEnter:
                            (_) =>
                                setState(() => _isHoveringProfileImage = true),
                        onExit:
                            (_) =>
                                setState(() => _isHoveringProfileImage = false),
                        child: GestureDetector(
                          onTap: _showPhotoOptions,
                          onTapDown:
                              (_) => setState(
                                () => _isHoveringProfileImage = true,
                              ),
                          onTapUp:
                              (_) => setState(
                                () => _isHoveringProfileImage = false,
                              ),
                          onTapCancel:
                              () => setState(
                                () => _isHoveringProfileImage = false,
                              ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF4CAF50),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child:
                                      _isUploadingImage
                                          ? Container(
                                            width: 130,
                                            height: 130,
                                            color: Colors.grey[200],
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Color(0xFF4CAF50)),
                                              ),
                                            ),
                                          )
                                          : _selectedImagePath != null
                                          ? (_selectedImagePath!.startsWith(
                                                'http',
                                              )
                                              ? Image.network(
                                                _selectedImagePath!,
                                                width: 130,
                                                height: 130,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (
                                                  context,
                                                  child,
                                                  loadingProgress,
                                                ) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  }
                                                  return Container(
                                                    width: 130,
                                                    height: 130,
                                                    color: Colors.grey[200],
                                                    child: Center(
                                                      child: CircularProgressIndicator(
                                                        value:
                                                            loadingProgress
                                                                        .expectedTotalBytes !=
                                                                    null
                                                                ? loadingProgress
                                                                        .cumulativeBytesLoaded /
                                                                    loadingProgress
                                                                        .expectedTotalBytes!
                                                                : null,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return Container(
                                                    color: Colors.grey[200],
                                                    child: Icon(
                                                      Icons.person,
                                                      size: 70,
                                                      color: Colors.grey[400],
                                                    ),
                                                  );
                                                },
                                              )
                                              : Image.file(
                                                File(_selectedImagePath!),
                                                width: 130,
                                                height: 130,
                                                fit: BoxFit.cover,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return Container(
                                                    color: Colors.grey[200],
                                                    child: Icon(
                                                      Icons.person,
                                                      size: 70,
                                                      color: Colors.grey[400],
                                                    ),
                                                  );
                                                },
                                              ))
                                          : Image.asset(
                                            'assets/images/Kissan.png',
                                            width: 130,
                                            height: 130,
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Container(
                                                color: Colors.grey[200],
                                                child: Icon(
                                                  Icons.person,
                                                  size: 70,
                                                  color: Colors.grey[400],
                                                ),
                                              );
                                            },
                                          ),
                                ),
                              ),
                              if (_isHoveringProfileImage)
                                Container(
                                  width: 130,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Change Photo',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        userData['name'] ?? 'User',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Profile Information Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child:
                  _isLoading
                      ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF00C853),
                          ),
                        ),
                      )
                      : Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildInfoRow(
                                  'Phone:',
                                  userData['phone'] ?? '',
                                ),
                                _buildInfoRow(
                                  'Joined on:',
                                  userData['joinedOn'] ?? '',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          SizedBox(
                            width: 200,
                            child: ElevatedButton.icon(
                              onPressed: _showEditInfoModal,
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit Info'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00C853),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 2,
                                textStyle: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          SizedBox(
                            width: 200,
                            child: OutlinedButton.icon(
                              onPressed: _navigateToChangePassword,
                              icon: const Icon(Icons.lock_outline),
                              label: const Text('Change Password'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF00C853),
                                side: const BorderSide(
                                  color: Color(0xFF00C853),
                                  width: 2,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                textStyle: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.15), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
