import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/workshop_model.dart';
import '../../services/auth_service.dart';
import '../../services/attendance_service.dart';
import '../../services/workshop_service.dart';
import '../../theme/app_colors.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState
    extends State<StudentAttendanceScreen> {
  final WorkshopService _workshopService = WorkshopService();
  final AttendanceService _attendanceService = AttendanceService();

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().currentUser;

    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text(
          'MY ATTENDANCE',
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: AppColors.cranberry,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Workshop>>(
        stream: _workshopService.getAllWorkshopsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final workshops = (snapshot.data ?? [])
              .where(
                (workshop) => workshop.registeredUserIds.contains(
                  currentUser?.uid,
                ),
              )
              .toList();

          if (workshops.isEmpty) {
            return Center(
              child: Text(
                'No registered workshops.',
                style: GoogleFonts.exo2(),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: workshops.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final workshop = workshops[index];

              return FutureBuilder<Map<String, dynamic>?>(
                future: _attendanceService.getAttendanceForUser(
                  workshop.id,
                  currentUser!.uid,
                ),
                builder: (context, attendanceSnapshot) {
                  final attendance = attendanceSnapshot.data;
                  final status =
                      attendance?['status'] ?? 'Not Checked In';

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            workshop.title,
                            style: GoogleFonts.orbitron(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.cranberry,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            workshop.location,
                            style: GoogleFonts.exo2(),
                          ),

                          const SizedBox(height: 12),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: status == 'Verified'
                                  ? Colors.green.shade50
                                  : status == 'Rejected'
                                      ? Colors.red.shade50
                                      : status ==
                                              'Pending Verification'
                                          ? Colors.orange.shade50
                                          : Colors.grey.shade200,
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: GoogleFonts.exo2(
                                fontWeight: FontWeight.bold,
                                color: status == 'Verified'
                                    ? Colors.green.shade700
                                    : status == 'Rejected'
                                        ? Colors.red.shade700
                                        : status ==
                                                'Pending Verification'
                                            ? Colors.orange.shade700
                                            : Colors.black54,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed:
                                  attendance != null
                                      ? null
                                      : () async {
                                          await _attendanceService
                                              .markCheckedIn(
                                            workshopId:
                                                workshop.id,
                                            workshopTitle:
                                                workshop.title,
                                            userId:
                                                currentUser.uid,
                                            userName:
                                                currentUser
                                                        .displayName ??
                                                    'Student',
                                            email:
                                                currentUser.email,
                                          );

                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Check-in submitted for verification.',
                                                ),
                                              ),
                                            );

                                            setState(() {});
                                          }
                                        },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppColors.cranberry,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              icon: const Icon(
                                Icons.check_circle_outline,
                              ),
                              label: Text(
                                attendance != null
                                    ? 'Already Checked In'
                                    : 'Check In',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}