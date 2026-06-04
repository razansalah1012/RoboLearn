import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';

enum NotificationFilter { all, workshop, update }

class NotificationFeedScreen extends StatefulWidget {
  const NotificationFeedScreen({super.key});

  @override
  State<NotificationFeedScreen> createState() => _NotificationFeedScreenState();
}

class _NotificationFeedScreenState extends State<NotificationFeedScreen> {
  final NotificationService _notificationService = NotificationService();
  NotificationFilter _selectedFilter = NotificationFilter.all;

  void _selectFilter(NotificationFilter filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  bool _matchesFilter(NotificationItem item) {
    if (_selectedFilter == NotificationFilter.all) return true;
    if (_selectedFilter == NotificationFilter.workshop) {
      return item.category == NotificationCategory.workshop;
    }
    return item.category == NotificationCategory.update;
  }

  String _filterLabel(NotificationFilter filter) {
    switch (filter) {
      case NotificationFilter.workshop:
        return 'Workshops';
      case NotificationFilter.update:
        return 'Updates';
      default:
        return 'All';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text(
          'RoboLearn Notifications',
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.cranberry,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          _buildBackgroundLines(),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroCard(),
                const SizedBox(height: 20),
                _buildFilterRow(),
                const SizedBox(height: 20),
                _buildFeedHeader(),
                const SizedBox(height: 14),
                StreamBuilder<List<NotificationItem>>(
                  stream: _notificationService.getNotificationsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.cranberry,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Failed to load notifications.',
                          style: GoogleFonts.exo2(color: Colors.red),
                        ),
                      );
                    }

                    final allNotifications = snapshot.data ?? [];
                    final filtered = allNotifications
                        .where(_matchesFilter)
                        .toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            Icon(
                              Icons.notifications_off_outlined,
                              size: 64,
                              color: AppColors.taupe,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No updates yet.',
                              style: GoogleFonts.exo2(
                                fontSize: 14,
                                color: AppColors.taupe,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'The latest announcements and workshops will appear here.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.exo2(
                                fontSize: 12,
                                color: AppColors.taupe,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: List.generate(filtered.length, (index) {
                        final item = filtered[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildNotificationCard(item, index),
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'You will receive the latest workshop and club update announcements here automatically.',
                  style: GoogleFonts.exo2(fontSize: 12, color: AppColors.taupe),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundLines() {
    return Stack(
      children: [
        Positioned(
          left: 24,
          top: 60,
          child: Container(
            height: 1,
            width: 120,
            color: AppColors.plum.withOpacity(0.12),
          ),
        ),
        Positioned(
          left: 72,
          top: 60,
          child: Transform.rotate(
            angle: 1.5708,
            child: Container(
              height: 1,
              width: 70,
              color: AppColors.plum.withOpacity(0.12),
            ),
          ),
        ),
        Positioned(
          right: 24,
          top: 140,
          child: Container(
            height: 1,
            width: 150,
            color: AppColors.plum.withOpacity(0.12),
          ),
        ),
        Positioned(
          right: 56,
          top: 160,
          child: Transform.rotate(
            angle: 1.5708,
            child: Container(
              height: 1,
              width: 60,
              color: AppColors.plum.withOpacity(0.12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CLUB ANNOUNCEMENTS',
            style: GoogleFonts.exo2(
              fontSize: 11,
              color: Colors.white70,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Never miss a workshop or club update',
            style: GoogleFonts.orbitron(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'View the latest events, announcements and workshop reminders in one place.',
            style: GoogleFonts.exo2(
              fontSize: 13,
              color: Colors.white.withOpacity(0.92),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today, color: Colors.white, size: 14),
                const SizedBox(width: 8),
                Text(
                  'Club updates & workshops',
                  style: GoogleFonts.exo2(fontSize: 11, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    final filters = NotificationFilter.values;
    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: filters.map((filter) {
              final isActive = filter == _selectedFilter;
              return GestureDetector(
                onTap: () => _selectFilter(filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: isActive ? AppColors.cranberry : Colors.white,
                    border: Border.all(
                      color: isActive
                          ? Colors.transparent
                          : AppColors.taupe.withOpacity(0.25),
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.cranberry.withOpacity(0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 12),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    _filterLabel(filter),
                    style: GoogleFonts.exo2(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isActive ? Colors.white : AppColors.taupe,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Latest updates',
              style: GoogleFonts.orbitron(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.cranberry,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Swipe through the newest club notifications',
              style: GoogleFonts.exo2(fontSize: 11, color: AppColors.taupe),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.ivory,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.taupe.withOpacity(0.14)),
          ),
          child: StreamBuilder<List<NotificationItem>>(
            stream: _notificationService.getNotificationsStream(),
            builder: (context, snapshot) {
              final count = snapshot.data?.where(_matchesFilter).length ?? 0;
              return Text(
                count.toString(),
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cranberry,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(NotificationItem item, int index) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: 0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFF0E6DD).withOpacity(0.9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.badgeColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    item.iconData,
                    color: item.badgeTextColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: item.badgeColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              item.categoryLabel.toUpperCase(),
                              style: GoogleFonts.exo2(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: item.badgeTextColor,
                              ),
                            ),
                          ),
                          Text(
                            _formatTime(item.createdAt),
                            style: GoogleFonts.exo2(
                              fontSize: 10,
                              color: AppColors.taupe,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.title,
                        style: GoogleFonts.orbitron(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cranberry,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.message,
                        style: GoogleFonts.exo2(
                          fontSize: 12,
                          color: AppColors.taupe,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (item.meta.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF0E6DD)),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 14,
                    color: AppColors.taupe,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.meta,
                      style: GoogleFonts.exo2(
                        fontSize: 11,
                        color: AppColors.taupe,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
