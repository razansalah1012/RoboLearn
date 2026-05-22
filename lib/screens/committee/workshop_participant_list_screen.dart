import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/workshop_model.dart';
import '../../services/workshop_service.dart';
import '../../theme/app_colors.dart';

class WorkshopParticipantListScreen extends StatelessWidget {
  final Workshop workshop;

  const WorkshopParticipantListScreen({super.key, required this.workshop});

  @override
  Widget build(BuildContext context) {
    final WorkshopService workshopService = WorkshopService();

    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text("PARTICIPANTS", style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.cranberry,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workshop.title, style: GoogleFonts.orbitron(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.people, size: 20, color: AppColors.plum),
                    const SizedBox(width: 8),
                    Text(
                      "${workshop.registeredUserIds.length} / ${workshop.capacity} Slots Filled",
                      style: GoogleFonts.exo2(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Remaining: ${workshop.availableSlots}",
                  style: GoogleFonts.exo2(color: AppColors.taupe),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: workshopService.getParticipants(workshop.registeredUserIds),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                final participants = snapshot.data ?? [];
                if (participants.isEmpty) {
                  return Center(
                    child: Text("No students registered yet.", style: GoogleFonts.exo2(color: AppColors.taupe)),
                  );
                }

                return ListView.separated(
                  itemCount: participants.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final p = participants[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.plum,
                        child: Text(
                          (p['displayName'] ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(p['displayName'] ?? 'Unknown User', style: GoogleFonts.exo2(fontWeight: FontWeight.bold)),
                      subtitle: Text(p['email'] ?? 'No email', style: GoogleFonts.exo2(fontSize: 12)),
                      trailing: const Icon(Icons.info_outline, size: 20, color: AppColors.taupe),
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
}
