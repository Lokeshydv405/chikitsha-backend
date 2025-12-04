import 'package:flutter/material.dart';
import 'package:chikitsha_munshi/screens/profile/address/AddAddressPage.dart';
import 'package:chikitsha_munshi/core/services/userRelatedServices.dart';

class AddressPage extends StatefulWidget {
  final String? userId;
  const AddressPage({Key? key, this.userId}) : super(key: key);

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  List<dynamic> addresses = [];
  bool isLoading = true;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final userDetails = await _userService.getUserDetails();
      final fetchedAddresses = userDetails != null && userDetails['addresses'] != null
          ? List<dynamic>.from(userDetails['addresses'])
          : [];
      if (!mounted) return;
      setState(() {
        addresses = fetchedAddresses;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load addresses: $e')),
      );
    }
  }
void _editAddress(int index) async {
  final edited = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AddAddressPage(
        userId: widget.userId ?? '',
        onAddressAdded: (updatedAddress) {},
      ),
      settings: RouteSettings(
        arguments: {
          "index": index,
          "address": addresses[index],
        },
      ),
    ),
  );

  if (edited != null) {
    _fetchAddresses();
  }
}


  void _deleteAddress(int index) async {
    setState(() {
      addresses.removeAt(index);
    });
    try {
      List<dynamic> updatedAddresses = List.from(addresses);
      await _userService.updateUserProfile(addresses: updatedAddresses);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete address: $e')),
        );
      }
      _fetchAddresses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Addresses',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.teal,
        elevation: 3,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey.shade100,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : addresses.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_off, size: 80, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'No addresses found',
                      style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to add your first address.',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: addresses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                      shadowColor: Colors.teal.shade100,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.home, color: Colors.teal),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    address['line1'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    [
                                      if ((address['line2'] ?? '').isNotEmpty) address['line2'],
                                      address['city'],
                                      address['state'],
                                      address['postalCode'],
                                      address['country'] ?? 'India',
                                    ].where((e) => e != null && e.isNotEmpty).join(', '),
                                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.teal),
                              onPressed: () => _editAddress(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteAddress(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddAddressPage(userId: widget.userId ?? ''),
            ),
          );
          if (added != null) {
            _fetchAddresses();
          }
        },
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
      ),
    );
  }
}
