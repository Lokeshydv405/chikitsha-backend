import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/config/app_config.dart';
import 'AddMemberPage.dart';
import 'EditMembersPage.dart';

class FamilyMembersPage extends StatefulWidget {
  final String userId;

  const FamilyMembersPage({super.key, required this.userId});

  @override
  State<FamilyMembersPage> createState() => _FamilyMembersPageState();
}

class _FamilyMembersPageState extends State<FamilyMembersPage> {
  List<Map<String, dynamic>> members = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    final url = '${AppConfig.serverUrl}/api/users/${widget.userId}';
    print('Fetching User details from: $url');
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          members = List<Map<String, dynamic>>.from(data['members']);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load members');
      }
    } catch (e) {
      print('Error fetching members: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteMember(String memberId) async {
    final url = '${AppConfig.serverUrl}/api/members/$memberId';
    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member deleted successfully')),
        );
        fetchMembers();
      } else {
        throw Exception('Delete failed');
      }
    } catch (e) {
      print('Delete error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting member')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Members'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : members.isEmpty
              ? const Center(child: Text("No members found."))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: members.length,
                  itemBuilder: (context, index) =>
                      _buildMemberCard(context, members[index]),
                ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AddMemberPage(userId: widget.userId)),
              ).then((_) => fetchMembers());
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text('+ Add New Member'),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, Map<String, dynamic> member) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2E2C) : const Color(0xFFDFF3F0),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member['name'] ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Age: ${member['age'] ?? ''} years'),
                Text('Relation: ${member['relation'] ?? ''}'),
                Text('Gender: ${member['gender'] ?? ''}'),
              ],
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                    MaterialPageRoute(
                      builder: (_) => EditMemberPage(
                        userId: widget.userId,
                        member: member,
                      ),
                    ),
                  ).then((_) => fetchMembers());
                },
                child: const Text('Edit',
                    style: TextStyle(color: Colors.teal)),
              ),
            
            
          )
        ],
      ),
    );
  }
}

