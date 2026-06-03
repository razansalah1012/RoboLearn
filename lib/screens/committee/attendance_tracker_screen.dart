import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/attendance_record_model.dart';
import '../../models/workshop_model.dart';
import '../../services/attendance_service.dart';
import '../../services/workshop_service.dart';
import '../../theme/app_colors.dart';

class AttendanceTrackerScreen extends StatefulWidget {
  const AttendanceTrackerScreen({super.key});

  @override
  State<AttendanceTrackerScreen> createState() =>
      _AttendanceTrackerScreenState();
}

class _AttendanceTrackerScreenState extends State<AttendanceTrackerScreen> {
  final WorkshopService _workshopService = WorkshopService();
  final AttendanceService _attendanceService = AttendanceService();
  Workshop? _selectedWorkshop;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text(
          'ATTENDANCE TRACKER',
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.cranberry,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Workshop>>(
        stream: _workshopService.getAllWorkshopsStream(),
        builder: (context, workshopSnapshot) {
          if (workshopSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.cranberry),
            );
          }

          final workshops = workshopSnapshot.data ?? [];
          if (workshops.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.event_busy,
                      size: 64,
                      color: AppColors.taupe,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Create a workshop first to start tracking attendance.',
                      style: GoogleFonts.exo2(color: AppColors.taupe),
                    ),
                  ],
                ),
              ),
            );
          }

          _selectedWorkshop ??= workshops.first;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroCard(),
                const SizedBox(height: 16),
                _buildWorkshopPicker(workshops),
                const SizedBox(height: 16),
                _buildRegistrationSummary(),
                const SizedBox(height: 16),
                _buildRecentAttendanceList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SELF CHECK-IN',
            style: GoogleFonts.orbitron(
              fontSize: 10,
              letterSpacing: 1.5,
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Committee attendance tracker',
            style: GoogleFonts.orbitron(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Mark registered members as present for each workshop in one place.',
            style: GoogleFonts.exo2(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkshopPicker(List<Workshop> workshops) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workshop',
              style: GoogleFonts.orbitron(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.cranberry,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Workshop>(
              initialValue: _selectedWorkshop,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: workshops
                  .map((w) => DropdownMenuItem(value: w, child: Text(w.title)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedWorkshop = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationSummary() {
    if (_selectedWorkshop == null) return const SizedBox.shrink();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: _SummaryTile(
                label: 'Registered',
                value: '${_selectedWorkshop!.registeredUserIds.length}',
                icon: Icons.group_outlined,
                color: AppColors.plum,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryTile(
                label: 'Available',
                value: '${_selectedWorkshop!.availableSlots}',
                icon: Icons.event_available_outlined,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAttendanceList() {
    if (_selectedWorkshop == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attendance Verification',
          style: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.cranberry,
          ),
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<AttendanceRecord>>(
          stream: _attendanceService.getAttendanceStream(_selectedWorkshop!.id),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: GoogleFonts.exo2(color: Colors.red),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.cranberry),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    'No attendance has been recorded yet for this workshop.',
                    style: GoogleFonts.exo2(color: AppColors.taupe),
                  ),
                ),
              );
            }

            final records = snapshot.data!;
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final record = records[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                              backgroundColor: AppColors.plum,
                              child: Icon(Icons.check_circle, color: Colors.white),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    record.userName,
                                    style: GoogleFonts.exo2(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${record.email ?? 'No email'} • ${record.checkedInAt.toLocal().toString().substring(0, 16)}',
                                    style: GoogleFonts.exo2(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: record.status == 'Verified'
                                    ? Colors.green.shade50
                                    : record.status == 'Rejected'
                                        ? Colors.red.shade50
                                        : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                record.status.toUpperCase(),
                                style: GoogleFonts.exo2(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: record.status == 'Verified'
                                      ? Colors.green.shade700
                                      : record.status == 'Rejected'
                                          ? Colors.red.shade700
                                          : Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await _attendanceService.verifyAttendance(record.id);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                                  minimumSize: const Size(0, 32),
                                ),
                                child: const Text('Verify', style: TextStyle(fontSize: 12)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await _attendanceService.rejectAttendance(record.id);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                                  minimumSize: const Size(0, 32),
                                ),
                                child: const Text('Reject', style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.14),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.orbitron(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cranberry,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.exo2(fontSize: 12, color: AppColors.taupe),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
