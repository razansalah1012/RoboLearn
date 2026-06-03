import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/workshop_model.dart';
import '../services/workshop_service.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import 'workshop_detail_screen.dart';

class WorkshopScreen extends StatefulWidget {
  const WorkshopScreen({super.key});

  @override
  State<WorkshopScreen> createState() => _WorkshopScreenState();
}

class _WorkshopScreenState extends State<WorkshopScreen> {
  final WorkshopService _workshopService = WorkshopService();
  final AuthService _authService = AuthService();
  
  String? _selectedCategory;
  WorkshopDifficulty? _selectedDifficulty;

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildFilters(),
          Expanded(
            child: StreamBuilder<List<Workshop>>(
              stream: _workshopService.getUpcomingWorkshops(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            "Failed to load workshops",
                            style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.exo2(fontSize: 12, color: AppColors.taupe),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => setState(() {}),
                            child: const Text("RETRY"),
                          )
                        ],
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var workshops = snapshot.data ?? [];
                
                // Client-side filtering
                if (_selectedCategory != null) {
                  workshops = workshops.where((w) => w.category == _selectedCategory).toList();
                }
                if (_selectedDifficulty != null) {
                  workshops = workshops.where((w) => w.difficulty == _selectedDifficulty).toList();
                }

                if (workshops.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 48, color: AppColors.taupe),
                        const SizedBox(height: 16),
                        Text(
                          _selectedCategory != null || _selectedDifficulty != null 
                            ? "No workshops match your criteria." 
                            : "No upcoming workshops found.", 
                          style: GoogleFonts.exo2(color: AppColors.taupe)
                        ),
                        if (_selectedCategory != null || _selectedDifficulty != null)
                          TextButton(
                            onPressed: () => setState(() {
                              _selectedCategory = null;
                              _selectedDifficulty = null;
                            }),
                            child: const Text("Clear Filters"),
                          )
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: workshops.length,
                  itemBuilder: (context, index) {
                    final workshop = workshops[index];
                    final isRegistered = user != null && workshop.registeredUserIds.contains(user.uid);

                    return _WorkshopCard(
                      workshop: workshop,
                      isRegistered: isRegistered,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => WorkshopDetailScreen(workshop: workshop)),
                        );
                      },
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      decoration: const BoxDecoration(
        color: AppColors.cranberry,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "UPCOMING WORKSHOPS",
            style: GoogleFonts.orbitron(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Hands-on technical sessions at the Hub",
            style: GoogleFonts.exo2(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _FilterChip(
            label: "All Categories",
            isSelected: _selectedCategory == null,
            onTap: () => setState(() => _selectedCategory = null),
          ),
          ...['Robotics', 'Programming', 'Drones', 'Engineering'].map((cat) => _FilterChip(
            label: cat,
            isSelected: _selectedCategory == cat,
            onTap: () => setState(() => _selectedCategory = cat),
          )),
          const VerticalDivider(width: 20),
          ...WorkshopDifficulty.values.map((diff) => _FilterChip(
            label: diff.name.toUpperCase(),
            isSelected: _selectedDifficulty == diff,
            onTap: () => setState(() => _selectedDifficulty = diff),
          )),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label, style: GoogleFonts.exo2(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.plum.withOpacity(0.2),
        checkmarkColor: AppColors.plum,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? AppColors.plum : Colors.black12)),
      ),
    );
  }
}

class _WorkshopCard extends StatelessWidget {
  final Workshop workshop;
  final bool isRegistered;
  final VoidCallback onTap;
  final VoidCallback onToggleRegister;

  const _WorkshopCard({
    required this.workshop,
    required this.isRegistered,
    required this.onTap,
    required this.onToggleRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.plum.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: workshop.imageUrl != null && workshop.imageUrl!.isNotEmpty
                  ? DecorationImage(image: NetworkImage(workshop.imageUrl!), fit: BoxFit.cover)
                  : null,
              ),
              child: workshop.imageUrl == null || workshop.imageUrl!.isEmpty
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
                        DateFormat('dd/MM HH:mm').format(workshop.date),
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
                        onPressed: () {
                          // Prevent triggering InkWell onTap
                          onToggleRegister();
                        },
                        child: Text(isRegistered ? "Registered" : "Register"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
