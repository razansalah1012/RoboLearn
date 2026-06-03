import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/content_service.dart';
import '../models/announcement_model.dart';
import '../theme/app_colors.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ContentService _contentService = ContentService();

    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text(
          'Announcements',
          style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.cranberry,
      ),
      body: StreamBuilder<List<Announcement>>(
        stream: _contentService.getAllAnnouncements(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.cranberry));
          }

          final announcements = snapshot.data!;

          if (announcements.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.announcement, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No announcements yet', style: GoogleFonts.exo2(fontSize: 16, color: Colors.grey[600])),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final item = announcements[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.cranberry),
                      ),
                      const SizedBox(height: 8),
                      Text(item.content, style: GoogleFonts.exo2(fontSize: 14, color: Colors.grey[700])),
                      const SizedBox(height: 8),
                      Text(
                        'By ${item.authorName} • ${_formatDate(item.createdAt)}',
                        style: GoogleFonts.exo2(fontSize: 10, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

 String _formatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);
  
  if (difference.inDays > 7) {
    return '${date.day}/${date.month}/${date.year}';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
  } else {
    return 'Just now';
  }
}
}