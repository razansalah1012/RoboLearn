import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../models/user_model.dart';
import 'learning/certificate_list_screen.dart';
import 'login_screen.dart';
import 'feedback_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _auth = AuthService();
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _matricController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _matricController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _matricController.dispose();
    super.dispose();
  }

  void _saveProfile(UserModel currentUserData) async {
    if (_formKey.currentState!.validate()) {
      UserModel updatedUser = currentUserData.copyWith(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        matricNumber: _matricController.text.trim(),
      );

      bool success = await _auth.updateProfile(updatedUser);
      if (success) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update profile")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Center(child: Text("Unauthorized Access"));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.cranberry));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("User data not found"));
        }

        final userData = UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);
        
        if (!_isEditing) {
          _nameController.text = userData.name;
          _phoneController.text = userData.phoneNumber ?? "";
          _matricController.text = userData.matricNumber ?? "";
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text("MY PROFILE", style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.cranberry)),
            actions: [
              IconButton(
                icon: Icon(_isEditing ? Icons.close : Icons.edit, color: AppColors.cranberry),
                onPressed: () => setState(() => _isEditing = !_isEditing),
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildProfileHeader(userData),
                  const SizedBox(height: 30),
                  if (_isEditing) ...[
                    _buildEditFields(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _saveProfile(userData),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.cranberry),
                      child: const Text("SAVE CHANGES"),
                    ),
                  ] else ...[
                    _buildStatsRow(userData),
                    const SizedBox(height: 30),
                    _buildExperienceCard(userData),
                    const SizedBox(height: 30),
                    _buildAchievementCard(context),
                  ],
                  const SizedBox(height: 20),
                  _buildActionList(context, _auth),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditFields() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.person)),
          validator: (val) => val == null || val.isEmpty ? "Required" : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(labelText: "Phone Number", prefixIcon: Icon(Icons.phone)),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _matricController,
          decoration: const InputDecoration(labelText: "Matric Number", prefixIcon: Icon(Icons.assignment_ind)),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.cranberry, width: 2),
          ),
          child: const CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.ivory,
            child: Icon(Icons.person, size: 60, color: AppColors.cranberry),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: GoogleFonts.orbitron(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.cranberry,
          ),
        ),
        Text(
          user.email,
          style: GoogleFonts.exo2(color: AppColors.taupe, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.plum.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            user.role.replaceAll('_', ' ').toUpperCase(),
            style: GoogleFonts.exo2(
              color: AppColors.plum,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(UserModel user) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(label: "Courses", value: "${user.completedCoursesCount}", icon: Icons.auto_stories_rounded),
          VerticalDivider(color: AppColors.taupe.withOpacity(0.2), thickness: 1),
          // Rank is now calculated based on Level for the reset phase
          _StatItem(label: "Rank", value: "#${user.level}", icon: Icons.leaderboard_rounded),
          VerticalDivider(color: AppColors.taupe.withOpacity(0.2), thickness: 1),
          _StatItem(label: "Total XP", value: "${user.totalXp}", icon: Icons.bolt_rounded),
        ],
      ),
    );
  }

  Widget _buildExperienceCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.ivory,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Level ${user.level} Architect",
                style: GoogleFonts.orbitron(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.cranberry,
                ),
              ),
              Text(
                "${user.totalXp % 500} / 500 XP",
                style: GoogleFonts.exo2(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.taupe,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: user.levelProgress,
              minHeight: 10,
              backgroundColor: AppColors.cranberry.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cranberry),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.ivory,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Specializations",
                style: GoogleFonts.orbitron(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.cranberry,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CertificateListScreen()),
                ),
                child: Text(
                  "Certificates →",
                  style: GoogleFonts.exo2(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.plum,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Clean Start: No hardcoded badges. 
          // This will be populated as the user completes course paths.
          Center(
            child: Text(
              "Complete course paths to earn technical badges.",
              textAlign: TextAlign.center,
              style: GoogleFonts.exo2(
                fontSize: 12,
                color: AppColors.taupe,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionList(BuildContext context, AuthService auth) {
    return Column(
      children: [

        _SettingsTile(
        icon: Icons.rate_review,
        label: "Give Workshop Feedback",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FeedbackScreen()),
          );
        },
      ),
        _SettingsTile(
          icon: Icons.workspace_premium_rounded,
          label: "My Credentials",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CertificateListScreen()),
          ),
        ),
        _SettingsTile(
          icon: Icons.logout_rounded,
          label: "Sign Out",
          color: Colors.redAccent,
          onTap: () async {
            await auth.logout();
            if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            }
          },
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.plum, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.cranberry),
        ),
        Text(
          label,
          style: GoogleFonts.exo2(fontSize: 10, color: AppColors.taupe, fontWeight: FontWeight.w600),
        ),
      ],
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
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.plum.withOpacity(0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? AppColors.cranberry).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color ?? AppColors.cranberry, size: 20),
        ),
        title: Text(
          label,
          style: GoogleFonts.exo2(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: color ?? AppColors.cranberry,
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.taupe.withOpacity(0.5)),
      ),
    );
  }
}
