import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_model.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animated_interactive_card.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String _searchQuery = "";
  String _selectedRole = "All";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text("User Management", style: GoogleFonts.orbitron(fontSize: 16)),
        backgroundColor: AppColors.cranberry,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search name or email...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _selectedRole,
                  items: ["All", "student", "committee", "admin"]
                      .map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase(), style: const TextStyle(fontSize: 12))))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedRole = val!),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final users = snapshot.data!.docs
                    .map((d) => UserModel.fromMap(d.data() as Map<String, dynamic>))
                    .where((u) {
                      bool matchesSearch = u.name.toLowerCase().contains(_searchQuery) || u.email.toLowerCase().contains(_searchQuery);
                      bool matchesRole = _selectedRole == "All" || u.role == _selectedRole;
                      return matchesSearch && matchesRole;
                    })
                    .toList();

                return ListView.builder(
                  itemCount: users.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.profilePhotoUrl != null ? NetworkImage(user.profilePhotoUrl!) : null,
                          child: user.profilePhotoUrl == null ? const Icon(Icons.person) : null,
                        ),
                        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${user.role.toUpperCase()} • ${user.email}"),
                        trailing: Icon(
                          user.isBlocked ? Icons.block : Icons.check_circle,
                          color: user.isBlocked ? Colors.red : Colors.green,
                        ),
                        onTap: () => _showUserActions(context, user),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showUserActions(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(user.name, style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(user.isBlocked ? Icons.lock_open : Icons.block, color: user.isBlocked ? Colors.green : Colors.red),
              title: Text(user.isBlocked ? "Unblock User" : "Block User"),
              onTap: () async {
                await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'isBlocked': !user.isBlocked});
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.badge_outlined, color: AppColors.plum),
              title: const Text("Change Role"),
              onTap: () => _showRolePicker(context, user),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text("Delete User Data"),
              onTap: () async {
                // In a real app, use a Cloud Function for Auth deletion. 
                // Here we just delete Firestore data.
                await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRolePicker(BuildContext context, UserModel user) {
    Navigator.pop(context); // Close actions sheet
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select New Role"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ["student", "committee", "admin"].map((r) => ListTile(
            title: Text(r.toUpperCase()),
            onTap: () async {
              await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'role': r});
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }
}
