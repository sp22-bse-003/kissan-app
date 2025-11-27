import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditInfoModal extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onSave;

  const EditInfoModal({
    super.key,
    required this.initialData,
    required this.onSave,
  });

  @override
  State<EditInfoModal> createState() => _EditInfoModalState();
}

class _EditInfoModalState extends State<EditInfoModal> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  final ImagePicker _picker = ImagePicker();
  String? _profilePicturePath;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialData['name']?.toString() ?? '',
    );
    final phone = widget.initialData['phone']?.toString() ?? '';
    _phoneController = TextEditingController(
      text: phone == 'Add phone number' ? '' : phone,
    );
    _profilePicturePath = widget.initialData['profilePicture']?.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() => _isUploadingImage = true);

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw 'User not logged in';
      }

      // Upload directly to Firebase Storage (web-compatible)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = pickedFile.path.split('.').last;
      final path = 'profiles/${userId}_$timestamp.$extension';
      
      final ref = FirebaseStorage.instance.ref().child(path);
      
      // For web, read bytes from XFile
      final bytes = await pickedFile.readAsBytes();
      final uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      if (mounted) {
        setState(() {
          _profilePicturePath = downloadUrl;
          _isUploadingImage = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Picture uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Upload error in modal: $e');
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

  void _saveInfo() {
    final updatedData = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'profilePicture': _profilePicturePath,
      'joinedOn': widget.initialData['joinedOn'] ?? '',
    };
    widget.onSave(updatedData);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final modalHeight = screenHeight * 0.85;

    return Container(
      height: modalHeight + keyboardHeight,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: keyboardHeight > 0 ? keyboardHeight : 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                const Text(
                  'Edit Info',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture Upload Section
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _pickAndUploadImage,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color(0xFF00C853),
                                      width: 3,
                                    ),
                                    color: Colors.grey[200],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child:
                                        _profilePicturePath != null
                                            ? Image.network(
                                              _profilePicturePath!,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (_, __, ___) => Icon(
                                                    Icons.person,
                                                    size: 50,
                                                    color: Colors.grey[400],
                                                  ),
                                            )
                                            : Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Colors.grey[400],
                                            ),
                                  ),
                                ),
                                if (_isUploadingImage)
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black54,
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF00C853),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tap to upload profile picture',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    _buildFormField(
                      label: 'Name',
                      controller: _nameController,
                      isRequired: true,
                    ),
                    _buildFormField(
                      label: 'Phone',
                      controller: _phoneController,
                      isRequired: true,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Save Info',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$label ${isRequired ? '*' : ''}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  print("Speaker clicked for $label");
                },
                child: const Icon(
                  Icons.volume_up,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF00C853),
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
