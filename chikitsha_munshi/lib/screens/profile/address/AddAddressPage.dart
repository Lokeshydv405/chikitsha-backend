import 'package:chikitsha_munshi/core/services/userRelatedServices.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddAddressPage extends StatefulWidget {
  final String userId;
  final Function(Map<String, dynamic>)? onAddressAdded;

  const AddAddressPage({
    super.key,
    required this.userId,
    this.onAddressAdded,
  });

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();

  // Controllers (removed name and phone controllers)
  final TextEditingController _line1Controller = TextEditingController();
  final TextEditingController _line2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();

  bool _isDefault = false;
  bool _isLoading = false;
  String _selectedAddressType = 'Home';

  final List<String> _addressTypes = ['Home', 'Office', 'Other'];

  int? _editIndex;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map) {
      final existing = args["address"] as Map<String, dynamic>?;
      _editIndex = args["index"];

      if (existing != null) {
        // Prefill controllers (removed name and phone)
        _line1Controller.text = existing['line1'] ?? '';
        _line2Controller.text = existing['line2'] ?? '';
        _cityController.text = existing['city'] ?? '';
        _stateController.text = existing['state'] ?? '';
        _postalCodeController.text = existing['postalCode'] ?? '';
        _landmarkController.text = existing['landmark'] ?? '';
        _selectedAddressType = existing['type'] ?? 'Home';
        _isDefault = existing['isDefault'] ?? false;
      }
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final newAddress = {
        // Removed name and phone from the address object
        'line1': _line1Controller.text.trim(),
        'line2': _line2Controller.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'postalCode': _postalCodeController.text.trim(),
        'landmark': _landmarkController.text.trim(),
        'type': _selectedAddressType,
        'isDefault': _isDefault,
      };

      final userDetails = await _userService.getUserDetails();
      if (userDetails == null) throw Exception('Failed to load user details');

      List<dynamic> addresses = userDetails['addresses'] ?? [];

      // Handle default address
      if (addresses.isEmpty || _isDefault) {
        addresses = addresses
            .map((addr) => {...addr, 'isDefault': false})
            .toList();
        newAddress['isDefault'] = true;
      }

      // Editing existing address
      if (_editIndex != null && _editIndex! < addresses.length) {
        addresses[_editIndex!] = newAddress;
      } else {
        // Adding new
        addresses.add(newAddress);
      }

      final result =
          await _userService.updateUserProfile(addresses: addresses);

      if (result != null) {
        if (widget.onAddressAdded != null) widget.onAddressAdded!(newAddress);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_editIndex != null
                  ? 'Address updated successfully!'
                  : 'Address added successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.of(context).pop(newAddress);
        }
      } else {
        throw Exception('Failed to save address');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving address: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          _editIndex != null ? 'Edit Address' : 'Add New Address',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Color(0xFF1A1A1A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address Type Selection
                  _buildAddressTypeSelector(),
                  const SizedBox(height: 24),
                  
                  // Address Fields
                  _buildAddressFields(),
                  
                  const SizedBox(height: 24),
                  
                  // Default Address Toggle
                  _buildDefaultToggle(),
                  
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
          
          // Fixed Bottom Button
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildAddressTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Address Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _addressTypes.map((type) {
            final isSelected = _selectedAddressType == type;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedAddressType = type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2196F3) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF2196F3) : const Color(0xFFE0E0E0),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          type == 'Home' ? Icons.home : 
                          type == 'Office' ? Icons.business : Icons.location_on,
                          color: isSelected ? Colors.white : const Color(0xFF666666),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          type,
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF666666),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAddressFields() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Address Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),
          
          _buildTextField(
            controller: _line1Controller,
            label: "Street Address",
            hint: "House no, Building name, Street",
            icon: Icons.location_on_outlined,
            validator: (v) => v == null || v.isEmpty ? "Street address is required" : null,
          ),
          
          _buildTextField(
            controller: _line2Controller,
            label: "Area / Locality",
            hint: "Area, Locality",
            icon: Icons.map_outlined,
          ),
          
          _buildTextField(
            controller: _landmarkController,
            label: "Landmark",
            hint: "Near famous place (optional)",
            icon: Icons.place_outlined,
          ),
          
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _cityController,
                  label: "City",
                  hint: "City",
                  icon: Icons.location_city_outlined,
                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _stateController,
                  label: "State",
                  hint: "State",
                  icon: Icons.map_outlined,
                  validator: (v) => v == null || v.isEmpty ? "Required" : null,
                ),
              ),
            ],
          ),
          
          _buildTextField(
            controller: _postalCodeController,
            label: "PIN Code",
            hint: "123456",
            icon: Icons.markunread_mailbox_outlined,
            keyboardType: TextInputType.number,
            validator: (v) => v == null || v.isEmpty ? "Required" : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CheckboxListTile(
        value: _isDefault,
        onChanged: (val) => setState(() => _isDefault = val ?? false),
        title: const Text(
          "Set as default delivery address",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A1A),
          ),
        ),
        subtitle: const Text(
          "This address will be selected by default for deliveries",
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF666666),
          ),
        ),
        activeColor: const Color(0xFF2196F3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              disabledBackgroundColor: const Color(0xFF2196F3).withOpacity(0.6),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    _editIndex != null ? "Update Address" : "Save Address",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1A1A1A),
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF666666),
            size: 20,
          ),
          labelStyle: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: const TextStyle(
            color: Color(0xFF999999),
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          filled: true,
          fillColor: const Color(0xFFFAFAFA),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _line1Controller.dispose();
    _line2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }
}