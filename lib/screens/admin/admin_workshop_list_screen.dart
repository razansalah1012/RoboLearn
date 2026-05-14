import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/workshop_model.dart';
import '../../services/workshop_service.dart';
import '../../theme/app_colors.dart';
import 'workshop_editor_screen.dart';

class AdminWorkshopListScreen extends StatefulWidget {
  const AdminWorkshopListScreen({super.key});

  @override
  State<AdminWorkshopListScreen> createState() => _AdminWorkshopListScreenState();
}

class _AdminWorkshopListScreenState extends State<AdminWorkshopListScreen> {
  final WorkshopService _workshopService = WorkshopService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text('Workshop Architect', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.cranberry,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task_rounded, size: 28),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WorkshopEditorScreen()),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: StreamBuilder<List<Workshop>>(
        stream: _workshopService.getAllWorkshopsStream(),
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
                  const Icon(Icons.event_busy_rounded, size: 64, color: AppColors.taupe),
                  const SizedBox(height: 16),
                  Text("No workshops scheduled.", style: GoogleFonts.exo2()),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: workshops.length,
            itemBuilder: (context, index) {
              final workshop = workshops[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.plum.withOpacity(0.1),
                    child: const Icon(Icons.handyman, color: AppColors.plum),
                  ),
                  title: Text(workshop.title, style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: Text("${workshop.category} • ${workshop.date.day}/${workshop.date.month}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("${workshop.registeredUserIds.length}/${workshop.capacity}", 
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WorkshopEditorScreen(workshop: workshop)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
