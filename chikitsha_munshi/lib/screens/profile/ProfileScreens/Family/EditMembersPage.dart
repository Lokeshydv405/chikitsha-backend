import 'package:chikitsha_munshi/core/services/userRelatedServices.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditMemberPage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> member;

  const EditMemberPage({super.key, required this.userId, required this.member});

  @override
  State<EditMemberPage> createState() => _EditMemberPageState();
}

class _EditMemberPageState extends State<EditMemberPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  bool isFormValid = false;

  final service = UserService();
  String selectedGender = 'Male';
  String selectedRelation = 'Father';

  final Map<String, String> relationAvatars = {
    'Father': 'assets/images/certifiedlabs.png',
    'Mother': 'assets/images/certifiedlabs.png',
    'Wife': 'assets/images/certifiedlabs.png',
    'Husband': 'assets/images/certifiedlabs.png',
    'Son': 'assets/images/certifiedlabs.png',
    'Daughter': 'assets/images/certifiedlabs.png',
    'Brother': 'assets/images/certifiedlabs.png',
    'Sister': 'assets/images/certifiedlabs.png',
  };

  @override
  void initState() {
    super.initState();
    final member = widget.member;

    nameController.text = member['name'] ?? '';
    heightController.text = member['height']?.toString() ?? '';
    weightController.text = member['weight']?.toString() ?? '';
    selectedGender = member['gender'] ?? 'Male';
    selectedRelation = member['relation'] ?? 'Father';

    DateTime dob;
    try {
  dob = DateTime.parse(member['dob']);
  dobController.text = DateFormat('yyyy-MM-dd').format(dob);
  ageController.text = _calculateAge(dob).toString() + ' years';
} catch (_) {
  dob = DateTime.now();
}

    ageController.text = _calculateAge(dob).toString() + ' years';

    // Add listeners to validate form when text changes
    // nameController.addListener(_validateForm);
    // dobController.addListener(_validateForm);
  }

  // void _validateForm() {
  //   final isValid = nameController.text.trim().isNotEmpty &&
  //       dobController.text.trim().isNotEmpty &&
  //       selectedGender.isNotEmpty &&
  //       selectedRelation.isNotEmpty;

  //   if (isFormValid != isValid) {
  //     setState(() {
  //       isFormValid = isValid;
  //     });
  //   }
  // }

  int _calculateAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
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
        dobController.text = DateFormat('yyyy-MM-dd').format(picked);
        ageController.text = _calculateAge(picked).toString() + ' years';
      });
    }
  }

  void _submitMember() async {
    final name = nameController.text.trim();
    final age = ageController.text.trim().replaceAll(' years', '');
    final height = heightController.text.trim();
    final weight = weightController.text.trim();

    if (name.isEmpty ||
        age.isEmpty ||
        selectedGender.isEmpty ||
        selectedRelation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final success = await service.updateMember(
      // userId: widget.userId,
      memberId: widget.member['_id'],
      updatedData: {
        'name': name,
        'age': int.tryParse(age) ?? 0,
        'gender': selectedGender,
        'relation': selectedRelation,
        'height': int.tryParse(height) ?? 0,
        'weight': int.tryParse(weight) ?? 0,
        'dob': DateFormat('yyyy-MM-dd').parse(dobController.text.trim()).toIso8601String(),
      },
      
    );

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Member updated successfully!')));
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed')));
    }
  }

  void _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Delete Member'),
            content: Text('Are you sure you want to delete this member?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final success = await service.deleteMember(
        // userId: widget.userId,
        memberId: widget.member['_id'],
      );
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Member deleted')));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Update Member', style: theme.textTheme.titleLarge),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatars
            SizedBox(height: 25),

            Container(
              margin: EdgeInsets.only(bottom: 24),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.secondary.withOpacity(0.4),
                // backgroundImage: AssetImage(relationAvatars[selectedRelation] ?? 'assets/images/profile_default.png'),
              ),
            ),

            _buildInputField(label: 'Name*', controller: nameController),
            SizedBox(height: 25),

            // _buildInputField(label: 'Email', controller: emailController),
            // SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickDate(context),
                    child: AbsorbPointer(
                      child: _buildInputField(
                        label: 'Date Of Birth*',
                        controller: dobController,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildInputField(
                    label: 'Age*',
                    controller: ageController,
                    readOnly: true,
                  ),
                ),
              ],
            ),

            SizedBox(height: 25),
            _buildGenderSelector(theme),
            SizedBox(height: 25),

            // Relation Dropdown
            DropdownButtonFormField<String>(
              value: selectedRelation,
              items:
                  relationAvatars.keys
                      .map(
                        (relation) => DropdownMenuItem(
                          value: relation,
                          child: Text(relation),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedRelation = value);
                }
              },
              decoration: InputDecoration(labelText: 'Relation'),
            ),

            SizedBox(height: 25),

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

            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'NOTE : Please fill all the required fields marked with *',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitMember,
                child: Text(
                  'Save Changes',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            TextButton(
              onPressed: _confirmDelete,
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete Member'),
            ),
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
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(),
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
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedGender = gender),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected ? theme.colorScheme.primary : theme.dividerColor,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : theme.iconTheme.color,
              ),
              SizedBox(width: 8),
              Text(
                gender,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      isSelected
                          ? Colors.white
                          : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
