import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_model.dart';
import '../../theme/app_colors.dart';

class CommitteeDirectoryScreen extends StatefulWidget {
  const CommitteeDirectoryScreen({super.key});

  @override
  State<CommitteeDirectoryScreen> createState() => _CommitteeDirectoryScreenState();
}

class _CommitteeDirectoryScreenState extends State<CommitteeDirectoryScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text("Committee Directory", style: GoogleFonts.orbitron(fontSize: 16)),
        backgroundColor: AppColors.cranberry,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by name or title...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'committee')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text("Error loading directory", style: GoogleFonts.exo2(fontWeight: FontWeight.bold)),
                          Text(snapshot.error.toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                }
                
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.cranberry));
                }
                
                final docs = snapshot.data?.docs ?? [];
                final members = docs
                    .map((d) => UserModel.fromMap(d.data() as Map<String, dynamic>))
                    .where((m) => m.name.toLowerCase().contains(_searchQuery) || 
                                 (m.roleTitle ?? "").toLowerCase().contains(_searchQuery))
                    .toList();

                if (members.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search_rounded, size: 64, color: AppColors.taupe.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text("No committee members found.", style: GoogleFonts.exo2(color: AppColors.taupe)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: members.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.cranberry.withOpacity(0.1),
                          backgroundImage: member.profilePhotoUrl != null 
                            ? NetworkImage(member.profilePhotoUrl!) 
                            : null,
                          child: member.profilePhotoUrl == null ? const Icon(Icons.person, color: AppColors.cranberry) : null,
                        ),
                        title: Text(member.name, style: GoogleFonts.exo2(fontWeight: FontWeight.bold)),
                        subtitle: Text(member.roleTitle ?? "Technical Lead", style: GoogleFonts.exo2(fontSize: 12)),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () => _showMemberDetails(context, member),
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

  void _showMemberDetails(BuildContext context, UserModel member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.beige,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(32, 12, 32, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.ivory,
              backgroundImage: member.profilePhotoUrl != null ? NetworkImage(member.profilePhotoUrl!) : null,
              child: member.profilePhotoUrl == null ? const Icon(Icons.person, size: 50, color: AppColors.cranberry) : null,
            ),
            const SizedBox(height: 16),
            Text(member.name, style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.cranberry)),
            Text(member.roleTitle ?? "Committee Member", style: GoogleFonts.exo2(color: AppColors.taupe, fontWeight: FontWeight.w600)),
            const Divider(height: 48),
            _detailRow(Icons.email_outlined, member.email),
            _detailRow(Icons.calendar_today_outlined, "Member since ${member.joinDate.year}"),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cranberry,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("CLOSE", style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.cranberry.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 20, color: AppColors.cranberry),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: GoogleFonts.exo2(fontSize: 14))),
        ],
      ),
    );
  }
}
