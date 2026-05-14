import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animated_interactive_card.dart';

class CommitteeProfileScreen extends StatefulWidget {
  const CommitteeProfileScreen({super.key});

  @override
  State<CommitteeProfileScreen> createState() => _CommitteeProfileScreenState();
}

class _CommitteeProfileScreenState extends State<CommitteeProfileScreen> {
  final AuthService _auth = AuthService();
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Scaffold(body: Center(child: Text("Error loading profile")));
        if (!snapshot.hasData || !snapshot.data!.exists) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        
        final userData = UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);
        _nameController.text = userData.name;

        return Scaffold(
          backgroundColor: AppColors.beige,
          appBar: AppBar(
            title: Text("MY PROFILE", style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold)),
            backgroundColor: AppColors.cranberry,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(_isEditing ? Icons.close : Icons.edit),
                onPressed: () => setState(() => _isEditing = !_isEditing),
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildHeader(userData),
                  const SizedBox(height: 30),
                  if (_isEditing) _buildEditForm(userData) else _buildStatsGrid(userData),
                  const SizedBox(height: 30),
                  _buildSettingsSection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(UserModel user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.ivory,
          backgroundImage: user.profilePhotoUrl != null ? NetworkImage(user.profilePhotoUrl!) : null,
          child: user.profilePhotoUrl == null ? const Icon(Icons.person, size: 60, color: AppColors.cranberry) : null,
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: GoogleFonts.orbitron(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.cranberry),
        ),
        Text(
          user.roleTitle ?? "Committee Member",
          style: GoogleFonts.exo2(color: AppColors.taupe, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(user.email, style: GoogleFonts.exo2(color: AppColors.taupe.withOpacity(0.7))),
      ],
    );
  }

  Widget _buildEditForm(UserModel user) {
    return AnimatedInteractiveCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.person_outline)),
            validator: (val) => val == null || val.isEmpty ? "Required" : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                  'name': _nameController.text.trim(),
                });
                setState(() => _isEditing = false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.cranberry, foregroundColor: Colors.white),
            child: const Text("UPDATE PROFILE"),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(UserModel user) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1, // Increased to fix the "Bottom Overflowed by 16 pixels" error
      children: [
        _StatItem(label: "Courses Managed", value: "${user.coursesManaged}", icon: Icons.architecture),
        _StatItem(label: "XP Issued", value: "${user.xpIssued}", icon: Icons.bolt, color: Colors.orange),
        _StatItem(label: "Events", value: "${user.eventsParticipated}", icon: Icons.event, color: Colors.blue),
        _StatItem(label: "Status", value: "Active", icon: Icons.check_circle, color: Colors.green),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("ACCOUNT SETTINGS", style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.plum)),
        const SizedBox(height: 16),
        _SettingsTile(icon: Icons.lock_outline, label: "Change Password", onTap: () {}),
        _SettingsTile(icon: Icons.notifications_none, label: "Notification Preferences", onTap: () {}),
        _SettingsTile(icon: Icons.logout, label: "Sign Out", color: Colors.red, onTap: () => _auth.logout()),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color? color;
  const _StatItem({required this.label, required this.value, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedInteractiveCard(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color ?? AppColors.cranberry),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: GoogleFonts.exo2(fontSize: 10, color: AppColors.taupe), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _SettingsTile({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.cranberry),
        title: Text(label, style: GoogleFonts.exo2(color: color)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}
