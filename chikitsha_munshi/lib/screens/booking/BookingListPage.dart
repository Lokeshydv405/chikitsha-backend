import 'package:chikitsha_munshi/screens/booking/BookingDetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:chikitsha_munshi/core/services/booking_services.dart';
import 'package:chikitsha_munshi/models/booking_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class BookingListPage extends StatefulWidget {
  // final String? userId;  // ✅ store userId as a field

  // const BookingListPage({Key? key, this.userId}) : super(key: key);
  const BookingListPage({Key? key}) : super(key: key);

  @override
  State<BookingListPage> createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage> {
  final BookingService _bookingService = BookingService();
  List<Booking> _bookings = [];
  List<Booking> _filteredBookings = [];
  bool _isLoading = true;
  String _currentFilter = 'All';
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
    // _loadCurrentUserId();
  }

  // Future<void> _loadCurrentUserId() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final userId = prefs.getString('userId'); // Only fetch from SharedPreferences
  //   print(userId);
  //   if (userId != null && userId.isNotEmpty) {
  //     setState(() {
  //       _currentUserId = userId;
  //     });
  //     print("User Id in BookingListPage is $_currentUserId (from SharedPreferences)");
  //     _fetchBookings();
  //   } else {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please login to view bookings')),
  //     );
  //   }
  // }

  // Future<void> _loadCurrentUserId() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final userId = "688217fd660df33b9a85f42c";
  //   if (userId != null) {
  //     setState(() {
  //       _currentUserId = userId;
  //     });
  //     _fetchBookings();
  //   } else {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please login to view bookings')),
  //     );
  //   }
  // }

  Future<void> _fetchBookings() async {
    // if (_currentUserId == null) return;
    
    setState(() {
      _isLoading = true;
    });
    // print('****************Fetching bookings for user: $_currentUserId **************************');
    try {
      // final bookings = await _bookingService.getUserBookings(_currentUserId!);
      final bookings = await _bookingService.getUserBookings();
      setState(() {
        _bookings = bookings;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load bookings: $e')),
      );
    }
  }

  void _applyFilter() {
    if (_currentFilter == 'All') {
      _filteredBookings = List.from(_bookings);
    } else {
      _filteredBookings = _bookings.where((booking) {
        return _getBookingStatusFromOrder(booking.orderStatus) == _currentFilter;
      }).toList();
    }
  }

  String _getBookingStatusFromOrder(String orderStatus) {
    switch (orderStatus.toLowerCase()) {
      case 'booked':
        return 'Confirmed';
      case 'sample_collected':
        return 'Processing';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.green;
      case 'Processing':
        return Colors.blue;
      case 'Completed':
        return Colors.teal;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Confirmed':
        return Icons.check_circle;
      case 'Processing':
        return Icons.hourglass_empty;
      case 'Completed':
        return Icons.done_all;
      case 'Cancelled':
        return Icons.cancel;
      default:
        return Icons.schedule;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'My Bookings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: () {
              _showFilterDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _fetchBookings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredBookings.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchBookings,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = _filteredBookings[index];
                      return _buildBookingCard(booking);
                    },
                  ),
                ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     Navigator.pushNamed(context, '/booking');
      //   },
      //   backgroundColor: Colors.teal,
      //   icon: const Icon(Icons.add),
      //   label: const Text('Book Test'),
      // ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    final status = _getBookingStatusFromOrder(booking.orderStatus);
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    
    // Get the main package name
    final mainPackageName = booking.items.isNotEmpty 
        ? booking.items.first.packageName ?? 'Health Package'
        : 'Health Package';
    
    // Format date
    final dateFormatter = DateFormat('MMM dd, yyyy');
    final formattedDate = dateFormatter.format(booking.bookingDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    mainPackageName,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Row(
            //   children: [
            //     Icon(
            //       Icons.medical_services,
            //       size: 16,
            //       color: Colors.grey.shade600,
            //     ),
            //     const SizedBox(width: 4),
            //     Text(
            //       '${booking.items.length} package${booking.items.length > 1 ? 's' : ''}',
            //       style: TextStyle(
            //         color: Colors.grey.shade600,
            //         fontSize: 14,
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '$formattedDate at ${booking.timeSlot}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.home,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Home Collection - ${booking.address.city}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            // if (booking.paymentStatus == 'pending') ...[
            //   const SizedBox(height: 8),
            //   Row(
            //     children: [
            //       Icon(
            //         Icons.warning,
            //         size: 16,
            //         color: Colors.orange,
            //       ),
            //       const SizedBox(width: 4),
            //       Text(
            //         'Payment pending',
            //         style: TextStyle(
            //           color: Colors.orange,
            //           fontSize: 12,
            //           fontWeight: FontWeight.w500,
            //         ),
            //       ),
            //     ],
            //   ),
            // ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${booking.priceBreakdown.total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                Row(
                  children: [
                    // if (booking.paymentStatus == 'pending')
                    //   OutlinedButton(
                    //     onPressed: () {
                    //       _payNow(booking);
                    //     },
                    //     style: OutlinedButton.styleFrom(
                    //       foregroundColor: Colors.orange,
                    //       side: const BorderSide(color: Colors.orange),
                    //     ),
                    //     child: const Text('Pay Now'),
                    //   ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        _viewBookingDetails(booking);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('View Details'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Bookings Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Book your first health test to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          // ElevatedButton.icon(
          //   onPressed: () {
          //     Navigator.pushNamed(context, '/booking');
          //   },
          //   icon: const Icon(Icons.add),
          //   label: const Text('Book Test'),
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: Colors.teal,
          //     foregroundColor: Colors.white,
          //     padding: const EdgeInsets.symmetric(
          //       horizontal: 24,
          //       vertical: 12,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Bookings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption('All'),
              _buildFilterOption('Confirmed'),
              _buildFilterOption('Processing'),
              _buildFilterOption('Completed'),
              _buildFilterOption('Cancelled'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterOption(String option) {
    return ListTile(
      title: Text(option),
      leading: Radio<String>(
        value: option,
        groupValue: _currentFilter,
        onChanged: (value) {
          setState(() {
            _currentFilter = value!;
            _applyFilter();
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  // void _payNow(Booking booking) {
  //   // Navigate to payment page or show payment options
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Payment'),
  //       content: Text('Pay ₹${booking.priceBreakdown.total.toStringAsFixed(0)} for your booking?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () async {
  //             Navigator.pop(context);
  //             // Here you would integrate with your payment gateway
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               const SnackBar(
  //                 content: Text('Payment functionality will be implemented'),
  //                 backgroundColor: Colors.blue,
  //               ),
  //             );
  //           },
  //           child: const Text('Pay Now'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // void _viewBookingDetails(Booking booking) {
  //   final status = _getBookingStatusFromOrder(booking.orderStatus);
  //   final dateFormatter = DateFormat('MMM dd, yyyy');
  //   final formattedDate = dateFormatter.format(booking.bookingDate);

  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => Container(
  //       height: MediaQuery.of(context).size.height * 0.8,
  //       decoration: const BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //       ),
  //       child: Padding(
  //         padding: const EdgeInsets.all(20),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Center(
  //               child: Container(
  //                 width: 40,
  //                 height: 4,
  //                 decoration: BoxDecoration(
  //                   color: Colors.grey.shade300,
  //                   borderRadius: BorderRadius.circular(2),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 20),
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: Text(
  //                     'Booking Details',
  //                     style: const TextStyle(
  //                       fontSize: 20,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                 ),
  //                 Container(
  //                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //                   decoration: BoxDecoration(
  //                     color: _getStatusColor(status).withOpacity(0.1),
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                   child: Text(
  //                     status,
  //                     style: TextStyle(
  //                       color: _getStatusColor(status),
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 20),
              
  //             // Booking Information
  //             _buildDetailSection('Booking Information', [
  //               _buildDetailRow('Booking ID', booking.id),
  //               _buildDetailRow('Date & Time', '$formattedDate at ${booking.timeSlot}'),
  //               _buildDetailRow('Status', status),
  //               _buildDetailRow('Payment Status', booking.paymentStatus.toUpperCase()),
  //             ]),
              
  //             const SizedBox(height: 20),
              
  //             // Packages
  //             _buildDetailSection('Packages (${booking.items.length})', 
  //               booking.items.map((item) => 
  //                 _buildDetailRow(
  //                   item.packageName ?? 'Health Package',
  //                   '${item.members.length} member${item.members.length > 1 ? 's' : ''}',
  //                 )
  //               ).toList(),
  //             ),
              
  //             const SizedBox(height: 20),
              
  //             // Address
  //             _buildDetailSection('Collection Address', [
  //               _buildDetailRow('Address', booking.address.toString()),
  //               _buildDetailRow('City', booking.address.city),
  //               _buildDetailRow('State', booking.address.state),
  //               _buildDetailRow('Postal Code', booking.address.postalCode),
  //             ]),
              
  //             const SizedBox(height: 20),
              
  //             // Price Breakdown
  //             _buildDetailSection('Price Breakdown', [
  //               _buildDetailRow('Subtotal', '₹${booking.priceBreakdown.subtotal.toStringAsFixed(0)}'),
  //               _buildDetailRow('Discount', '- ₹${booking.priceBreakdown.discount.toStringAsFixed(0)}'),
  //               _buildDetailRow('Total', '₹${booking.priceBreakdown.total.toStringAsFixed(0)}', isTotal: true),
  //             ]),
              
  //             const Spacer(),
              
  //             // Action Buttons
  //             if (status == 'Confirmed' || status == 'Pending')
  //               Row(
  //                 children: [
  //                   if (booking.paymentStatus == 'pending')
  //                     Expanded(
  //                       child: ElevatedButton(
  //                         onPressed: () {
  //                           Navigator.pop(context);
  //                           _payNow(booking);
  //                         },
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: Colors.orange,
  //                           foregroundColor: Colors.white,
  //                         ),
  //                         child: const Text('Pay Now'),
  //                       ),
  //                     ),
  //                   if (booking.paymentStatus == 'pending') const SizedBox(width: 12),
  //                   Expanded(
  //                     child: OutlinedButton(
  //                       onPressed: () {
  //                         Navigator.pop(context);
  //                         _cancelBooking(booking);
  //                       },
  //                       style: OutlinedButton.styleFrom(
  //                         foregroundColor: Colors.red,
  //                         side: const BorderSide(color: Colors.red),
  //                       ),
  //                       child: const Text('Cancel Booking'),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
void _viewBookingDetails(Booking booking) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BookingDetailsPage(
        bookingId: booking.id,
        // onPayNow: _payNow,
        onCancel: _cancelBooking,
      ),
    ),
  );
}

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                fontSize: isTotal ? 16 : 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                fontSize: isTotal ? 16 : 14,
                color: isTotal ? Colors.teal : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _cancelBooking(Booking booking) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Booking'),
          content: const Text('Are you sure you want to cancel this booking? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Here you would call the API to cancel the booking
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking cancellation functionality will be implemented'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }
}
