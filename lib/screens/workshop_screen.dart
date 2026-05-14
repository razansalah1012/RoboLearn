import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/workshop_model.dart';
import '../services/workshop_service.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';

class WorkshopScreen extends StatelessWidget {
  const WorkshopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WorkshopService _workshopService = WorkshopService();
    final AuthService _authService = AuthService();
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent, // Handled by Home Stack
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Upcoming Workshops",
                  style: GoogleFonts.orbitron(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cranberry,
                  ),
                ),
                Text(
                  "Hands-on technical sessions at the Hub",
                  style: GoogleFonts.exo2(color: AppColors.taupe),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Workshop>>(
              stream: _workshopService.getUpcomingWorkshops(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final workshops = snapshot.data ?? [];
                if (workshops.isEmpty) {
                  return Center(
                    child: Text("No upcoming workshops found.", style: GoogleFonts.exo2()),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: workshops.length,
                  itemBuilder: (context, index) {
                    final workshop = workshops[index];
                    final isRegistered = user != null && workshop.registeredUserIds.contains(user.uid);

                    return _WorkshopCard(
                      workshop: workshop,
                      isRegistered: isRegistered,
                      onToggleRegister: () {
                        if (user == null) return;
                        if (isRegistered) {
                          _workshopService.cancelRegistration(user.uid, workshop.id);
                        } else {
                          _workshopService.registerForWorkshop(user.uid, workshop.id);
                        }
                      },
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

class _WorkshopCard extends StatelessWidget {
  final Workshop workshop;
  final bool isRegistered;
  final VoidCallback onToggleRegister;

  const _WorkshopCard({
    required this.workshop,
    required this.isRegistered,
    required this.onToggleRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.plum.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              image: workshop.imageUrl != null 
                ? DecorationImage(image: NetworkImage(workshop.imageUrl!), fit: BoxFit.cover)
                : null,
            ),
            child: workshop.imageUrl == null 
              ? Icon(Icons.handyman, size: 48, color: AppColors.plum.withOpacity(0.5))
              : null,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.cranberry.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        workshop.category,
                        style: GoogleFonts.exo2(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.cranberry),
                      ),
                    ),
                    Text(
                      "${workshop.date.day}/${workshop.date.month} @ ${workshop.date.hour}:00",
                      style: GoogleFonts.exo2(fontSize: 12, color: AppColors.taupe),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  workshop.title,
                  style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  workshop.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.exo2(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: AppColors.taupe),
                        const SizedBox(width: 4),
                        Text(workshop.location, style: GoogleFonts.exo2(fontSize: 12, color: AppColors.taupe)),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRegistered ? Colors.green : AppColors.cranberry,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: onToggleRegister,
                      child: Text(isRegistered ? "Registered" : "Register"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
