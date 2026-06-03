import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/workshop_model.dart';
import '../../services/workshop_service.dart';
import '../../theme/app_colors.dart';
import 'workshop_form_screen.dart';
import 'workshop_participant_list_screen.dart';

class WorkshopManagementScreen extends StatelessWidget {
  const WorkshopManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WorkshopService workshopService = WorkshopService();

    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text("WORKSHOP ARCHITECT", style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.cranberry,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Workshop>>(
        stream: workshopService.getAllWorkshopsStream(),
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
                  const Icon(Icons.event_busy, size: 64, color: AppColors.taupe),
                  const SizedBox(height: 16),
                  Text("No workshops created yet.", style: GoogleFonts.exo2(color: AppColors.taupe)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: workshops.length,
            itemBuilder: (context, index) {
              final workshop = workshops[index];
              return _WorkshopManagementCard(workshop: workshop);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WorkshopFormScreen()),
          );
        },
        backgroundColor: AppColors.cranberry,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text("NEW WORKSHOP", style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}

class _WorkshopManagementCard extends StatelessWidget {
  final Workshop workshop;
  const _WorkshopManagementCard({required this.workshop});

  @override
  Widget build(BuildContext context) {
    final workshopService = WorkshopService();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(workshop.title, style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text("${workshop.category} • ${workshop.difficulty.name.toUpperCase()}", 
                  style: const TextStyle(color: AppColors.plum, fontWeight: FontWeight.bold, fontSize: 12)),
                Text("Registered: ${workshop.registeredUserIds.length} / ${workshop.capacity}"),
                Text("Status: ${workshop.isCompleted ? 'COMPLETED' : 'ACTIVE'}", 
                  style: TextStyle(color: workshop.isCompleted ? Colors.grey : Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkshopParticipantListScreen(workshop: workshop),
                ),
              );
            },
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WorkshopFormScreen(workshop: workshop)),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text("Edit"),
                ),
                const SizedBox(width: 8),
                if (!workshop.isCompleted)
                  TextButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Complete Workshop"),
                          content: const Text("Mark this workshop as completed? This will move it to the past events list."),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
                            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("MARK COMPLETED")),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await workshopService.markAsCompleted(workshop.id, true);
                      }
                    },
                    icon: const Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
                    label: const Text("Mark Completed", style: TextStyle(color: Colors.green)),
                  )
                else
                   TextButton.icon(
                    onPressed: () async {
                      await workshopService.markAsCompleted(workshop.id, false);
                    },
                    icon: const Icon(Icons.settings_backup_restore, size: 18),
                    label: const Text("Re-open"),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
