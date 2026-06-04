import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/notification_model.dart';
import '../../models/workshop_model.dart';
import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';

class NotificationAnnouncementScreen extends StatefulWidget {
  final Workshop? workshop;
  const NotificationAnnouncementScreen({super.key, this.workshop});

  @override
  State<NotificationAnnouncementScreen> createState() =>
      _NotificationAnnouncementScreenState();
}

class _NotificationAnnouncementScreenState
    extends State<NotificationAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notificationService = NotificationService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _metaController = TextEditingController();
  NotificationCategory _category = NotificationCategory.update;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    final workshop = widget.workshop;
    if (workshop != null) {
      _category = NotificationCategory.workshop;
      _titleController.text = 'Update: ${workshop.title}';
      _messageController.text =
          'Please note the latest details for ${workshop.title} scheduled on ${DateFormat('dd MMM yyyy').format(workshop.date)} at ${workshop.location}.';
      _metaController.text =
          'Category: ${workshop.category} • Register by ${DateFormat('dd MMM yyyy').format(workshop.registrationDeadline)}';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _metaController.dispose();
    super.dispose();
  }

  Future<void> _sendAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);

    final notification = NotificationItem(
      id: '',
      title: _titleController.text.trim(),
      message: _messageController.text.trim(),
      category: _category,
      createdAt: DateTime.now(),
      meta: _metaController.text.trim(),
    );

    try {
      await _notificationService.saveNotification(notification);
      if (!mounted) return;
      _titleController.clear();
      _messageController.clear();
      _metaController.clear();
      setState(() => _category = NotificationCategory.update);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement sent to students.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send announcement: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text(
          'Publish Announcement',
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.cranberry,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notify students about workshop changes or club updates.',
              style: GoogleFonts.exo2(
                fontSize: 14,
                color: AppColors.taupe,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildCategoryPicker(),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Announcement Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Please add a title'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Please add a message'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _metaController,
                    decoration: const InputDecoration(
                      labelText: 'Extra details (optional)',
                      border: OutlineInputBorder(),
                      hintText:
                          'Venue change, date update, registration details',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _sendAnnouncement,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cranberry,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSending
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'SEND ANNOUNCEMENT',
                              style: GoogleFonts.orbitron(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPicker() {
    return Row(
      children: NotificationCategory.values.map((category) {
        final isSelected = _category == category;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: isSelected,
              label: Text(
                category.name.toUpperCase(),
                style: GoogleFonts.exo2(
                  color: isSelected ? Colors.white : AppColors.cranberry,
                ),
              ),
              selectedColor: AppColors.cranberry,
              backgroundColor: Colors.white,
              side: BorderSide(color: AppColors.cranberry.withValues(alpha: 61)),
              onSelected: (_) => setState(() => _category = category),
            ),
          ),
        );
      }).toList(),
    );
  }
}
