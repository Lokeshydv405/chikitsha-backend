import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/booking_services.dart';
import '../../core/services/userRelatedServices.dart';
import '../profile/address/AddAddressPage.dart';

class BookingPage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic>? bookingData;

  const BookingPage({
    super.key,
    required this.userId,
    this.bookingData,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final BookingService _bookingService = BookingService();
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();
  
  Map<String, dynamic>? bookingData;
  
  // Form data
  DateTime? selectedDate;
  String? selectedTimeSlot;
  int? selectedAddressIndex;
  File? prescriptionFile;
  List<String> availableTimeSlots = [];
  
  // User addresses (will be fetched from backend)
  List<Map<String, dynamic>> userAddresses = [];
  
  bool isLoading = false;
  bool isCreatingBooking = false;
  bool isLoadingAddresses = true;

  // Computed property for form validation
  bool get canConfirm => selectedDate != null && 
                        selectedTimeSlot != null && 
                        selectedAddressIndex != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get booking data from route arguments if not passed directly
    if (widget.bookingData != null) {
      bookingData = widget.bookingData;
    } else {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is Map<String, dynamic>) {
        bookingData = arguments;
      }
    }
    
    // Debug: Print booking data structure
    print('BookingPage: Received booking data: $bookingData');
    if (bookingData != null) {
      print('BookingPage: Keys in booking data: ${bookingData!.keys.toList()}');
      print('BookingPage: cartItems type: ${bookingData!['cartItems']?.runtimeType}');
      print('BookingPage: cartItems value: ${bookingData!['cartItems']}');
    }
    
    // Handle case where we're coming from LabInfoPage (no cart items)
    if (bookingData != null && !bookingData!.containsKey('cartItems')) {
      print('BookingPage: Converting lab booking data to cart format');
      // This is a lab booking, create minimal cart structure
      bookingData = {
        'cartItems': [],
        'totalAmount': 0,
        'originalAmount': 0,
        'discount': 0,
        'labId': bookingData!['labId'],
        'labName': bookingData!['labName'],
        'isLabBooking': true, // Flag to indicate this is a lab appointment booking
      };
    }
    
    // Fetch user addresses when component loads
    _fetchUserAddresses();
  }
  
  // Fetch real user addresses from backend
  Future<void> _fetchUserAddresses() async {
    try {
      setState(() {
        isLoadingAddresses = true;
      });
      
      // Use the userId passed to the widget
      String userId = widget.userId;
      
      // List<Map<String, dynamic>> addresses = await _userService.fetchUserAddresses(userId);
      List<Map<String, dynamic>> addresses = await _userService.fetchUserAddresses();
      // print(userAddresses);
      
      // print('Fetched addresses: $addresses'); // Debug print
      
      setState(() {
        userAddresses = addresses;
        isLoadingAddresses = false;
        
        // Set default address if none is selected and addresses exist
        if (selectedAddressIndex == null && userAddresses.isNotEmpty) {
          final defaultIndex = userAddresses.indexWhere(
            (addr) => addr['isDefault'] == true,
          );
          selectedAddressIndex = defaultIndex >= 0 ? defaultIndex : 0;
          // print('Auto-selected address index: $selectedAddressIndex'); // Debug print
        }
      });
    } catch (e) {
      // print('Error fetching user addresses: $e');
      setState(() {
        isLoadingAddresses = false;
      });
      
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load addresses. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Navigate to add address page
  Future<void> _navigateToAddAddress() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddAddressPage(
            userId: widget.userId,
            onAddressAdded: (newAddress) {
              // Refresh addresses after adding new one
              _fetchUserAddresses();
            },
          ),
        ),
      );

      // If an address was added, refresh the list
      if (result != null) {
        await _fetchUserAddresses();
        
        // Auto-select the newly added address if it's marked as default
        if (result is Map<String, dynamic> && result['isDefault'] == true) {
          setState(() {
            // Find the index of the new default address
            final defaultIndex = userAddresses.indexWhere((addr) => addr['isDefault'] == true);
            selectedAddressIndex = defaultIndex >= 0 ? defaultIndex : userAddresses.length - 1;
          });
        }
      }
    } catch (e) {
      print('Error navigating to add address: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening add address page'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper method to select an address
  void _selectAddress(int addressIndex) {
    // print('Selecting address at index: $addressIndex');
    setState(() {
      selectedAddressIndex = addressIndex;
    });
    // print('Selected address index is now: $selectedAddressIndex');
  }

  // Helper method to get address display name
  String _getAddressDisplayName(Map<String, dynamic> address) {
    // Try to use name field first, then fall back to creating a name from address parts
    if (address['name'] != null && address['name'].toString().isNotEmpty) {
      return address['name'];
    }
    
    // Create a display name from address components
    List<String> nameParts = [];
    
    if (address['line1'] != null && address['line1'].toString().isNotEmpty) {
      nameParts.add(address['line1']);
    }
    if (address['city'] != null && address['city'].toString().isNotEmpty) {
      nameParts.add(address['city']);
    }
    
    if (nameParts.isNotEmpty) {
      return nameParts.join(', ');
    }
    
    // Final fallback
    return address['type'] ?? 'Address';
  }

  // Helper method to format address for display
  String _formatAddress(Map<String, dynamic> address) {
    List<String> parts = [];
    
    if (address['line1'] != null && address['line1'].toString().isNotEmpty) {
      parts.add(address['line1']);
    }
    if (address['line2'] != null && address['line2'].toString().isNotEmpty) {
      parts.add(address['line2']);
    }
    if (address['landmark'] != null && address['landmark'].toString().isNotEmpty) {
      parts.add('Near ${address['landmark']}');
    }
    if (address['city'] != null && address['city'].toString().isNotEmpty) {
      parts.add(address['city']);
    }
    if (address['state'] != null && address['state'].toString().isNotEmpty) {
      parts.add(address['state']);
    }
    if (address['postalCode'] != null && address['postalCode'].toString().isNotEmpty) {
      parts.add(address['postalCode']);
    }
    
    return parts.join(', ');
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectedTimeSlot = null; // Reset time slot when date changes
      });
      await _loadTimeSlots();
    }
  }

  Future<void> _loadTimeSlots() async {
    if (selectedDate == null) return;
    
    setState(() => isLoading = true);
    try {
      final slots = await _bookingService.getAvailableTimeSlots(selectedDate!);
      setState(() {
        availableTimeSlots = slots;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading time slots: $e')),
      );
    }
  }

  Future<void> _pickPrescription() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    
    if (image != null) {
      setState(() {
        prescriptionFile = File(image.path);
      });
    }
  }

  Future<void> _removePrescription() async {
    setState(() {
      prescriptionFile = null;
    });
  }

  Future<void> _confirmBooking() async {
    // Check if form is valid before proceeding
    if (!canConfirm) {
      if (selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date')),
        );
      } else if (selectedAddressIndex == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a time slot')),
        );
      } else if (selectedAddressIndex == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an address')),
        );
      }
      return;
    }

    if (!_validateForm()) return;

    setState(() => isCreatingBooking = true);

    try {
      // Upload prescription if provided (you'll need to implement file upload)
      String? prescriptionUrl;
      if (prescriptionFile != null) {
        // TODO: Implement file upload to your server
        prescriptionUrl = 'uploaded_prescription_url';
      }

      final booking = await _bookingService.createBooking(
        // userId: widget.userId,
        bookingDate: selectedDate!,
        timeSlot: selectedTimeSlot!,
        addressIndex: selectedAddressIndex!,
        prescriptionUrl: prescriptionUrl,
      );

      if (booking != null) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text('Booking Confirmed!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your test booking has been confirmed successfully.'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Booking ID: ${booking.id}'),
                      Text('Date: ${DateFormat('dd MMM yyyy').format(booking.bookingDate)}'),
                      Text('Time: ${booking.timeSlot}'),
                      Text('Amount: ₹${booking.priceBreakdown.total.toInt()}'),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  // Navigator.of(context).pop(); // Go back to previous screen
                  Navigator.pushNamed(context, '/main');
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating booking: $e')),
      );
    } finally {
      setState(() => isCreatingBooking = false);
    }
  }

  bool _validateForm() {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return false;
    }

    if (selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return false;
    }

    if (selectedAddressIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an address')),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (bookingData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking')),
        body: const Center(
          child: Text('No booking data available'),
        ),
      );
    }

    // Safely extract data with null checks and defaults
    final cartItems = bookingData!['cartItems'] as List<dynamic>? ?? [];
    final totalAmount = bookingData!['totalAmount'] as int? ?? 0;
    final originalAmount = bookingData!['originalAmount'] as int? ?? 0;
    final discount = bookingData!['discount'] as int? ?? 0;

    // Additional validation for required data
    if (cartItems.isEmpty) {
      // Check if this is a lab booking (appointment booking without specific packages)
      final isLabBooking = bookingData!['isLabBooking'] == true;
      
      if (isLabBooking) {
        // For lab bookings, show lab appointment booking interface
        final labName = bookingData!['labName'] ?? 'Lab';
        return Scaffold(
          backgroundColor: const Color(0xFFF9F9F9),
          appBar: AppBar(
            title: Text('Book Appointment - $labName'),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lab Appointment Card
                      _buildLabAppointmentCard(labName),
                      
                      const SizedBox(height: 16),
                      
                      // Date Selection Card
                      _buildDateSelectionCard(),
                      
                      const SizedBox(height: 16),
                      
                      // Time Slot Selection Card
                      _buildTimeSlotCard(),
                      
                      const SizedBox(height: 16),
                      
                      // Address Selection Card
                      _buildAddressSelectionCard(),
                      
                      const SizedBox(height: 16),
                      
                      // Prescription Upload Card
                      _buildPrescriptionCard(),
                    ],
                  ),
                ),
              ),
              
              // Confirm Booking Button
              _buildLabBookingBottomSection(),
            ],
          ),
        );
      } else {
        // Original empty cart UI
        return Scaffold(
          appBar: AppBar(
            title: const Text('Booking'),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No items in cart',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                Text(
                  'Please add some test packages to proceed',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('Complete Your Booking'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Booking Summary Card
                  _buildBookingSummaryCard(cartItems, originalAmount, discount, totalAmount),
                  
                  const SizedBox(height: 16),
                  
                  // Date Selection Card
                  _buildDateSelectionCard(),
                  
                  const SizedBox(height: 16),
                  
                  // Time Slot Selection Card
                  _buildTimeSlotCard(),
                  
                  const SizedBox(height: 16),
                  
                  // Address Selection Card
                  _buildAddressSelectionCard(),
                  
                  const SizedBox(height: 16),
                  
                  // Prescription Upload Card
                  _buildPrescriptionCard(),
                ],
              ),
            ),
          ),
          
          // Confirm Booking Button
          _buildBottomSection(totalAmount),
        ],
      ),
    );
  }

  Widget _buildLabAppointmentCard(String labName) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.local_hospital, color: Colors.teal),
                SizedBox(width: 8),
                Text(
                  'Lab Appointment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: Text(
                    labName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'General consultation appointment',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Schedule your appointment and our team will contact you to discuss available services',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 13,
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

  Widget _buildLabBookingBottomSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lab Appointment:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Free',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: isCreatingBooking ? null : _confirmBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: canConfirm ? Colors.teal : Colors.grey.shade400,
              disabledBackgroundColor: Colors.grey.shade400,
              disabledForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Center(
              child: isCreatingBooking
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Booking Appointment...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      'Book Appointment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSummaryCard(List<dynamic> cartItems, int originalAmount, int discount, int totalAmount) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.teal),
                SizedBox(width: 8),
                Text(
                  'Booking Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // List of packages and selected members
            ...cartItems.map((item) => _buildBookingItem(item)).toList(),
            
            const Divider(height: 32),
            
            // Price breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Original Amount:'),
                Text('₹$originalAmount'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Discount:'),
                Text('-₹$discount', style: const TextStyle(color: Colors.green)),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '₹$totalAmount',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingItem(Map<String, dynamic> item) {
    // Safely extract data with null checks and defaults
    final packageName = item['packageName'] as String? ?? 'Unknown Package';
    final price = item['price'] as int? ?? 0;
    final selectedMembers = item['selectedMembers'] as List<dynamic>? ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  packageName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text('₹$price', style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            selectedMembers.isNotEmpty 
                ? 'Members: ${selectedMembers.map((m) => m is Map ? (m['name'] ?? 'Unknown') : m.toString()).join(', ')}'
                : 'No members selected',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelectionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.teal),
                SizedBox(width: 8),
                Text(
                  'Select Date',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDate != null
                          ? DateFormat('EEEE, dd MMM yyyy').format(selectedDate!)
                          : 'Choose date for sample collection',
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedDate != null ? Colors.black : Colors.grey[600],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.access_time, color: Colors.teal),
                SizedBox(width: 8),
                Text(
                  'Select Time Slot',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (selectedDate == null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Please select a date first',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              )
            else if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (availableTimeSlots.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'No time slots available for selected date',
                  style: TextStyle(color: Colors.orange),
                  textAlign: TextAlign.center,
                ),
              )
            // else
            //   Wrap(
            //     spacing: 8,
            //     runSpacing: 8,
            //     children: availableTimeSlots.map((slot) {
            //       final isSelected = selectedTimeSlot == slot;
            //       return InkWell(
            //         onTap: () => setState(() => selectedTimeSlot = slot),
            //         child: Container(
            //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            //           decoration: BoxDecoration(
            //             color: isSelected ? Colors.teal : Colors.white,
            //             border: Border.all(
            //               color: isSelected ? Colors.teal : Colors.grey.shade300,
            //             ),
            //             borderRadius: BorderRadius.circular(8),
            //           ),
            //           child: Text(
            //             slot,
            //             style: TextStyle(
            //               color: isSelected ? Colors.white : Colors.black,
            //               fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            //             ),
            //           ),
            //         ),
            //       );
            //     }).toList(),
            //   ),
   else
  Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        menuMaxHeight: 200,
        isExpanded: true,
        value: selectedTimeSlot,
        hint: const Text(
          "Select a time slot",
          style: TextStyle(color: Colors.grey),
        ),
        items: availableTimeSlots.map((slot) {
          return DropdownMenuItem<String>(
            value: slot,
            child: Text(
              slot,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          );
        }).toList(),
        onChanged: (val) {
          setState(() {
            selectedTimeSlot = val;
          });
        },
        icon: const Icon(Icons.arrow_drop_down, color: Colors.teal),
        dropdownColor: Colors.white,
      ),
    ),
  )


          ],
        ),
      ),
    );
  }

  Widget _buildAddressSelectionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.teal),
                    SizedBox(width: 8),
                    Text(
                      'Select Address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: _navigateToAddAddress,
                  icon: const Icon(Icons.add),
                  label: const Text('Add New'),
                ),
                
              ],
            ),
            const SizedBox(height: 12),
            
            // Debug: Show currently selected address index
            // if (selectedAddressIndex != null)
            //   Container(
            //     padding: const EdgeInsets.all(8),
            //     margin: const EdgeInsets.only(bottom: 8),
            //     decoration: BoxDecoration(
            //       color: Colors.blue.shade50,
            //       borderRadius: BorderRadius.circular(4),
            //     ),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           'Selected Address Index: $selectedAddressIndex',
            //           style: TextStyle(
            //             fontSize: 12,
            //             color: Colors.blue.shade700,
            //             fontWeight: FontWeight.w500,
            //           ),
            //         ),
            //         Text(
            //           'Total Addresses: ${userAddresses.length}',
            //           style: TextStyle(
            //             fontSize: 12,
            //             color: Colors.blue.shade700,
            //           ),
            //         ),
            //         if (selectedAddressIndex != null && userAddresses.isNotEmpty) ...[
            //           const SizedBox(height: 4),
            //           Text(
            //             'Selected Address Fields: ${userAddresses[selectedAddressIndex!].keys.join(", ")}',
            //             style: TextStyle(
            //               fontSize: 10,
            //               color: Colors.blue.shade600,
            //             ),
            //           ),
            //         ],
            //       ],
            //     ),
            //   ),
            
            // Show loading state
            if (isLoadingAddresses)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Loading addresses...'),
                  ],
                ),
              )
            // Show empty state
            else if (userAddresses.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(Icons.location_off, color: Colors.orange.shade600, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'No addresses found',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Please add an address to continue',
                      style: TextStyle(
                        color: Colors.orange.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _navigateToAddAddress,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Address Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            // Show addresses
            else
              ...userAddresses.asMap().entries.map((entry) {
                final index = entry.key;
                final address = entry.value;
                // print('Address $index structure: ${address.keys.toList()}');
                // print('Address $index data: $address');
                final isSelected = selectedAddressIndex == index;
                
                // print('Address $index: Selected=$isSelected, SelectedIndex=$selectedAddressIndex'); // Debug
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      _selectAddress(index);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.teal.shade50 : Colors.grey.shade50,
                        border: Border.all(
                          color: isSelected ? Colors.teal : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                            color: isSelected ? Colors.teal : Colors.grey,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _getAddressDisplayName(address),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: isSelected ? Colors.teal.shade700 : Colors.black,
                                        ),
                                      ),
                                    ),
                                    if (address['isDefault'] == true) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.teal.shade100,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          'Default',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.teal.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                    if (isSelected) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.teal,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'SELECTED',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                if (address['phone'] != null && address['phone'].toString().isNotEmpty) ...[
                                  Text(
                                    address['phone'],
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                ],
                                Text(
                                  _formatAddress(address),
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 14,
                                    height: 1.3,
                                  ),
                                ),
                                if (address['type'] != null) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      address['type'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.description, color: Colors.teal),
                SizedBox(width: 8),
                Text(
                  'Upload Prescription (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Upload your prescription if recommended by doctor',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            
            if (prescriptionFile == null)
              InkWell(
                onTap: _pickPrescription,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.cloud_upload, size: 32, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Tap to upload prescription'),
                    ],
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Prescription uploaded: ${prescriptionFile!.path.split('/').last}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    IconButton(
                      onPressed: _removePrescription,
                      icon: const Icon(Icons.close, color: Colors.red),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(int totalAmount) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '₹$totalAmount',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: isCreatingBooking ? null : _confirmBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: canConfirm ? Colors.teal : Colors.grey.shade400,
              disabledBackgroundColor: Colors.grey.shade400,
              disabledForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Center(
              child: isCreatingBooking
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Creating Booking...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      'Confirm Booking',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
