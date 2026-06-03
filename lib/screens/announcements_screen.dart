import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/content_service.dart';
import '../models/announcement_model.dart';
import '../theme/app_colors.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final ContentService _contentService = ContentService();
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text(
          'Announcements',
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.cranberry,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Filter Button
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _selectedFilter = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'announcement', child: Text('Announcements')),
              const PopupMenuItem(value: 'update', child: Text('Updates')),
              const PopupMenuItem(value: 'material', child: Text('Materials')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<Announcement>>(
        stream: _selectedFilter == 'all'
            ? _contentService.getAllAnnouncements()
            : _contentService.getAnnouncementsByType(_selectedFilter),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.cranberry),
            );
          }

          final announcements = snapshot.data!;

          if (announcements.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.announcement, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No announcements yet',
                    style: GoogleFonts.exo2(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for updates!',
                    style: GoogleFonts.exo2(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final item = announcements[index];
              return _AnnouncementCard(announcement: item);
            },
          );
        },
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;

  const _AnnouncementCard({required this.announcement});

  Color getTypeColor() {
    switch (announcement.type) {
      case 'announcement':
        return Colors.orange;
      case 'update':
        return Colors.blue;
      case 'material':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData getTypeIcon() {
    switch (announcement.type) {
      case 'announcement':
        return Icons.campaign;
      case 'update':
        return Icons.update;
      case 'material':
        return Icons.menu_book;
      default:
        return Icons.info;
    }
  }

  String getTypeLabel() {
    switch (announcement.type) {
      case 'announcement':
        return 'ANNOUNCEMENT';
      case 'update':
        return 'UPDATE';
      case 'material':
        return 'MATERIAL';
      default:
        return 'INFO';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: announcement.priority == 'high'
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange, width: 2),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Type Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: getTypeColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(getTypeIcon(), color: getTypeColor(), size: 20),
                  ),
                  const SizedBox(width: 12),
                  
                  // Type Label & Date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getTypeLabel(),
                          style: GoogleFonts.exo2(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: getTypeColor(),
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(announcement.createdAt),
                          style: GoogleFonts.exo2(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Priority Badge
                  if (announcement.priority == 'high')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'HIGH',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Title
              Text(
                announcement.title,
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cranberry,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Content
              Text(
                announcement.content,
                style: GoogleFonts.exo2(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Author
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'By ${announcement.authorName}',
                    style: GoogleFonts.exo2(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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