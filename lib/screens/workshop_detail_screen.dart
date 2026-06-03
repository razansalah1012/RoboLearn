import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/workshop_model.dart';
import '../services/workshop_service.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';

class WorkshopDetailScreen extends StatefulWidget {
  final Workshop workshop;

  const WorkshopDetailScreen({super.key, required this.workshop});

  @override
  State<WorkshopDetailScreen> createState() => _WorkshopDetailScreenState();
}

class _WorkshopDetailScreenState extends State<WorkshopDetailScreen> {
  final WorkshopService _workshopService = WorkshopService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final isRegistered = user != null && widget.workshop.registeredUserIds.contains(user.uid);
    final isPastDeadline = DateTime.now().isAfter(widget.workshop.registrationDeadline);

    return Scaffold(
      backgroundColor: AppColors.beige,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickInfo(),
                  const SizedBox(height: 32),
                  _buildSection("Description", widget.workshop.description),
                  const SizedBox(height: 24),
                  if (widget.workshop.objectives.isNotEmpty)
                    _buildSection("Objectives", widget.workshop.objectives),
                  const SizedBox(height: 24),
                  if (widget.workshop.prerequisites.isNotEmpty)
                    _buildSection("Prerequisites", widget.workshop.prerequisites),
                  const SizedBox(height: 24),
                  _buildInstructorInfo(),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildRegisterButton(isRegistered, isPastDeadline, user?.uid),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: AppColors.cranberry,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.workshop.title.toUpperCase(),
          style: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [const Shadow(blurRadius: 10, color: Colors.black)],
          ),
        ),
        background: widget.workshop.imageUrl != null
            ? Image.network(widget.workshop.imageUrl!, fit: BoxFit.cover)
            : Container(
                color: AppColors.plum.withOpacity(0.2),
                child: const Icon(Icons.handyman, size: 80, color: AppColors.plum),
              ),
      ),
    );
  }

  Widget _buildQuickInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.calendar_today, "Date", DateFormat('EEEE, d MMMM yyyy').format(widget.workshop.date)),
          const Divider(height: 24),
          _buildInfoRow(Icons.access_time, "Time", DateFormat('h:mm a').format(widget.workshop.date)),
          const Divider(height: 24),
          _buildInfoRow(Icons.location_on, "Venue", widget.workshop.location),
          const Divider(height: 24),
          _buildInfoRow(Icons.layers, "Level", widget.workshop.difficulty.name.toUpperCase()),
          const Divider(height: 24),
          _buildInfoRow(Icons.people, "Slots", "${widget.workshop.availableSlots} remaining of ${widget.workshop.capacity}"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.plum),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.exo2(fontSize: 12, color: AppColors.taupe)),
            Text(value, style: GoogleFonts.exo2(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.cranberry)),
        const SizedBox(height: 8),
        Text(content, style: GoogleFonts.exo2(fontSize: 15, height: 1.6, color: Colors.black87)),
      ],
    );
  }

  Widget _buildInstructorInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.plum.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.beige,
            child: Icon(Icons.person, color: AppColors.plum),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Facilitator", style: GoogleFonts.exo2(fontSize: 12, color: AppColors.taupe)),
              Text(widget.workshop.instructorName.isNotEmpty ? widget.workshop.instructorName : "Club Committee", 
                style: GoogleFonts.exo2(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(bool isRegistered, bool isPastDeadline, String? userId) {
    String buttonText = "REGISTER NOW";
    Color buttonColor = AppColors.cranberry;
    bool canAct = true;

    if (isRegistered) {
      buttonText = "CANCEL REGISTRATION";
      buttonColor = Colors.redAccent;
    } else if (isPastDeadline) {
      buttonText = "REGISTRATION CLOSED";
      buttonColor = Colors.grey;
      canAct = false;
    } else if (widget.workshop.isFull) {
      buttonText = "WORKSHOP FULL";
      buttonColor = Colors.grey;
      canAct = false;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: (canAct && !_isLoading) ? () => _handleRegistration(userId, isRegistered) : null,
          child: _isLoading 
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(buttonText, style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Future<void> _handleRegistration(String? userId, bool isRegistered) async {
    if (userId == null) return;
    
    setState(() => _isLoading = true);
    try {
      if (isRegistered) {
        await _workshopService.cancelRegistration(userId, widget.workshop.id);
      } else {
        await _workshopService.registerForWorkshop(userId, widget.workshop.id);
      }
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isRegistered ? "Registration cancelled" : "Successfully registered!"),
            backgroundColor: isRegistered ? Colors.orange : Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
