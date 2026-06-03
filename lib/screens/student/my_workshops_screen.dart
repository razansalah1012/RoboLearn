import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/workshop_model.dart';
import '../../services/workshop_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../workshop_detail_screen.dart';

class MyWorkshopsScreen extends StatelessWidget {
  const MyWorkshopsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WorkshopService workshopService = WorkshopService();
    final AuthService authService = AuthService();
    final user = authService.currentUser;

    if (user == null) return const Scaffold(body: Center(child: Text("Please login")));

    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text("MY WORKSHOPS", style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.cranberry,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Workshop>>(
        stream: workshopService.getUserWorkshops(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final workshops = snapshot.data ?? [];
          if (workshops.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.event_note, size: 64, color: AppColors.taupe),
                  const SizedBox(height: 16),
                  Text("You haven't registered for any workshops.", style: GoogleFonts.exo2(color: AppColors.taupe)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.plum, foregroundColor: Colors.white),
                    child: const Text("BROWSE WORKSHOPS"),
                  ),
                ],
              ),
            );
          }

          final upcoming = workshops.where((w) => !w.isCompleted).toList();
          final completed = workshops.where((w) => w.isCompleted).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (upcoming.isNotEmpty) ...[
                _buildSectionHeader("UPCOMING"),
                ...upcoming.map((w) => _MyWorkshopTile(workshop: w)),
              ],
              if (completed.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildSectionHeader("COMPLETED"),
                ...completed.map((w) => _MyWorkshopTile(workshop: w, isCompleted: true)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.plum, letterSpacing: 1.5),
      ),
    );
  }
}

class _MyWorkshopTile extends StatelessWidget {
  final Workshop workshop;
  final bool isCompleted;

  const _MyWorkshopTile({required this.workshop, this.isCompleted = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isCompleted ? Colors.grey.shade200 : AppColors.cranberry.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isCompleted ? Icons.check_circle_outline : Icons.event,
            color: isCompleted ? Colors.grey : AppColors.cranberry,
          ),
        ),
        title: Text(workshop.title, style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text(
          "${workshop.date.day}/${workshop.date.month} • ${workshop.location}",
          style: GoogleFonts.exo2(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WorkshopDetailScreen(workshop: workshop)),
          );
        },
      ),
    );
  }
}
