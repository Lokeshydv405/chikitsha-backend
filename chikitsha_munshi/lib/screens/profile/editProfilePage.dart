import 'dart:io';
import 'package:chikitsha_munshi/core/services/userRelatedServices.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  Map<String, dynamic>? userData;
  bool isLoading = true;
  String selectedGender = 'Male';

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _loadUserData();
    DateTime dob = DateTime(2005, 4, 10);
    dobController.text = DateFormat('dd-MM-yyyy').format(dob);
    ageController.text = _calculateAge(dob).toString() + ' years';
  }
  Future<void> _loadUserData() async {
    final service = UserService();
    final data = await service.getUserDetails(); // Replace with dynamic ID

    if (data != null) {
      setState(() {
        userData = data;
        nameController.text = data['name'] ?? '';
        emailController.text = data['email'] ?? '';
        mobileController.text = data['phone'] ?? '';
        selectedGender = data['gender'] ?? 'Male';
        heightController.text = data['height']?.toString() ?? '';
        weightController.text = data['weight']?.toString() ?? '';

        if (data['dob'] != null) {
          final parsedDob = DateTime.tryParse(data['dob']);
          if (parsedDob != null) {
            dobController.text = DateFormat('dd-MM-yyyy').format(parsedDob);
            ageController.text = '${_calculateAge(parsedDob)} years';
          }
        }

        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_path');
    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(pickedFile.path);
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', savedImage.path);

      setState(() {
        _profileImage = savedImage;
      });
    }
  }

  int _calculateAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005, 4, 10),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        dobController.text = DateFormat('dd-MM-yyyy').format(picked);
        ageController.text = _calculateAge(picked).toString() + ' years';
      });
    }
  }
  Future<void> _updateProfile() async {
    final service = UserService();
    final updatedData = await service.updateUserProfile(
      // userId: '6888630281468917dd8b7f8b', // Replace with dynamic ID
      name: nameController.text,
      email: emailController.text,
      age: int.tryParse(ageController.text.split(' ')[0]),
      height: double.tryParse(heightController.text),
      weight: double.tryParse(weightController.text),
      addresses: [], // Add addresses if needed
    );
    if (updatedData != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
      // Optionally, reload user data
      _loadUserData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isLoading) return Center(child: CircularProgressIndicator());

    // if (userData == null) return Center(child: Text('User not found'));
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Edit Profile', style: theme.textTheme.titleLarge),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Picture Section
            Container(
              margin: EdgeInsets.only(bottom: 24),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.secondary.withOpacity(0.4),
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : AssetImage('assets/images/profile_default.png') as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickProfileImage,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _buildInputField(label: 'Name', controller: nameController),
            SizedBox(height: 16),
            _buildInputField(label: 'Email', controller: emailController),
            SizedBox(height: 16),
            _buildInputField(label: 'Mobile Number', controller: mobileController,readOnly: true,),
            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickDate(context),
                    child: AbsorbPointer(
                      child: _buildInputField(label: 'Date Of Birth*', controller: dobController),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildInputField(label: 'Age*', controller: ageController,readOnly: true),
                ),
              ],
            ),

            SizedBox(height: 16),
            _buildGenderSelector(theme),
            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStaticUnitInputField(
                    label: 'Height (cm)',
                    controller: heightController,
                    unit: 'cm',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStaticUnitInputField(
                    label: 'Weight (kg)',
                    controller: weightController,
                    unit: 'kg',
                  ),
                ),
              ],
            ),

            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  _updateProfile();
                },
                child: Text('Update Profile', style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: theme.textTheme.bodySmall),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: theme.textTheme.bodyLarge,
          readOnly: readOnly,
          decoration: InputDecoration(),
        ),
      ],
    );
  }

  Widget _buildStaticUnitInputField({
    required String label,
    required TextEditingController controller,
    required String unit,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: theme.textTheme.bodySmall),
        ),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(),
              ),
            ),
            SizedBox(width: 8),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text('Gender*', style: theme.textTheme.bodySmall),
        ),
        Row(
          children: [
            _buildGenderButton('Male', Icons.male),
            SizedBox(width: 12),
            _buildGenderButton('Female', Icons.female),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderButton(String gender, IconData icon) {
    final theme = Theme.of(context);
    final isSelected = selectedGender == gender;
    final selectedColor = theme.colorScheme.primary;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedGender = gender),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? selectedColor : theme.dividerColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : theme.iconTheme.color, size: 20),
              SizedBox(width: 8),
              Text(
                gender,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
