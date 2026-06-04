import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/notification_model.dart';
import '../../models/workshop_model.dart';
import '../../services/notification_service.dart';
import '../../services/workshop_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animated_interactive_card.dart';

class WorkshopFormScreen extends StatefulWidget {
  final Workshop? workshop;

  const WorkshopFormScreen({super.key, this.workshop});

  @override
  State<WorkshopFormScreen> createState() => _WorkshopFormScreenState();
}

class _WorkshopFormScreenState extends State<WorkshopFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final WorkshopService _workshopService = WorkshopService();
  final NotificationService _notificationService = NotificationService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _capacityController;
  late TextEditingController _imageUrlController;
  late TextEditingController _prerequisitesController;
  late TextEditingController _objectivesController;
  late TextEditingController _instructorController;

  final List<String> _categories = [
    'Robotics',
    'Programming',
    'Drones',
    'Engineering',
  ];
  late String _selectedCategory;

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  DateTime _registrationDeadline = DateTime.now().add(const Duration(days: 5));
  WorkshopDifficulty _difficulty = WorkshopDifficulty.beginner;
  bool _isSaving = false;

  bool get _isEditMode => widget.workshop != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.workshop?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.workshop?.description ?? '',
    );
    _locationController = TextEditingController(
      text: widget.workshop?.location ?? '',
    );
    _capacityController = TextEditingController(
      text: widget.workshop?.capacity.toString() ?? '',
    );
    _imageUrlController = TextEditingController(
      text: widget.workshop?.imageUrl ?? '',
    );
    _prerequisitesController = TextEditingController(
      text: widget.workshop?.prerequisites ?? '',
    );
    _objectivesController = TextEditingController(
      text: widget.workshop?.objectives ?? '',
    );
    _instructorController = TextEditingController(
      text: widget.workshop?.instructorName ?? '',
    );

    _selectedCategory = widget.workshop?.category ?? _categories.first;
    if (!_categories.contains(_selectedCategory)) {
      _selectedCategory = _categories.first;
    }

    if (_isEditMode) {
      _selectedDate = widget.workshop!.date;
      _registrationDeadline = widget.workshop!.registrationDeadline;
      _difficulty = widget.workshop!.difficulty;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    _imageUrlController.dispose();
    _prerequisitesController.dispose();
    _objectivesController.dispose();
    _instructorController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isEventDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isEventDate ? _selectedDate : _registrationDeadline,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isEventDate) {
          _selectedDate = picked;
          // Ensure deadline is before event
          if (_registrationDeadline.isAfter(_selectedDate)) {
            _registrationDeadline = _selectedDate.subtract(
              const Duration(days: 1),
            );
          }
        } else {
          _registrationDeadline = picked;
        }
      });
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final workshop = Workshop(
        id: widget.workshop?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        location: _locationController.text.trim(),
        category: _selectedCategory,
        capacity: int.parse(_capacityController.text.trim()),
        difficulty: _difficulty,
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        prerequisites: _prerequisitesController.text.trim(),
        registrationDeadline: _registrationDeadline,
        objectives: _objectivesController.text.trim(),
        instructorName: _instructorController.text.trim(),
        registeredUserIds: widget.workshop?.registeredUserIds ?? [],
        isCompleted: widget.workshop?.isCompleted ?? false,
      );

      await _workshopService.saveWorkshop(workshop);
      await _sendWorkshopNotification(workshop);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? "Workshop updated successfully"
                  : "Workshop created successfully",
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving workshop: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteWorkshop() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Delete Workshop",
          style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to delete this workshop? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("DELETE"),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isSaving = true);
      try {
        await _workshopService.deleteWorkshop(widget.workshop!.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Workshop deleted"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error deleting: $e"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text(
          _isEditMode ? "EDIT WORKSHOP" : "NEW WORKSHOP",
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.cranberry,
        foregroundColor: Colors.white,
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _isSaving ? null : _deleteWorkshop,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AnimatedInteractiveCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("BASIC INFORMATION"),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: "Workshop Title*",
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: "Category*",
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _categories
                          .map(
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedCategory = val!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: "Brief Description*",
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 2,
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 24),

                    _buildSectionHeader("LOGISTICS"),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              "Date",
                              style: TextStyle(fontSize: 12),
                            ),
                            subtitle: Text(
                              DateFormat('yyyy-MM-dd').format(_selectedDate),
                            ),
                            trailing: const Icon(
                              Icons.calendar_today,
                              size: 20,
                            ),
                            onTap: () => _pickDate(context, true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              "Reg. Deadline",
                              style: TextStyle(fontSize: 12),
                            ),
                            subtitle: Text(
                              DateFormat(
                                'yyyy-MM-dd',
                              ).format(_registrationDeadline),
                            ),
                            trailing: const Icon(
                              Icons.event_available,
                              size: 20,
                            ),
                            onTap: () => _pickDate(context, false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: "Venue / Location*",
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _capacityController,
                            decoration: const InputDecoration(
                              labelText: "Max Capacity*",
                              prefixIcon: Icon(Icons.people),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val == null || val.isEmpty) return "Required";
                              if (int.tryParse(val) == null) return "Invalid";
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<WorkshopDifficulty>(
                            initialValue: _difficulty,
                            decoration: const InputDecoration(
                              labelText: "Difficulty",
                            ),
                            items: WorkshopDifficulty.values
                                .map(
                                  (d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(d.name.toUpperCase()),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _difficulty = val!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AnimatedInteractiveCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("EXTENDED DETAILS"),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _instructorController,
                      decoration: const InputDecoration(
                        labelText: "Instructor Name",
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _objectivesController,
                      decoration: const InputDecoration(
                        labelText: "Learning Objectives",
                        prefixIcon: Icon(Icons.list_alt),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _prerequisitesController,
                      decoration: const InputDecoration(
                        labelText: "Prerequisites",
                        prefixIcon: Icon(Icons.fact_check),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: "Poster URL",
                        prefixIcon: Icon(Icons.image),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cranberry,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isEditMode ? "UPDATE WORKSHOP" : "PUBLISH WORKSHOP",
                          style: GoogleFonts.orbitron(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendWorkshopNotification(Workshop workshop) async {
    final isNewWorkshop = !_isEditMode;
    final title = isNewWorkshop
        ? 'New workshop published'
        : 'Workshop schedule updated';
    final message = isNewWorkshop
        ? '${workshop.title} is now scheduled for ${DateFormat('dd MMM yyyy').format(workshop.date)} at ${workshop.location}. Check the student portal for details.'
        : _buildUpdateMessage(workshop);
    final meta = isNewWorkshop
        ? 'Category: ${workshop.category} • Register by ${DateFormat('dd MMM yyyy').format(workshop.registrationDeadline)}'
        : 'Venue: ${workshop.location} • Date: ${DateFormat('dd MMM yyyy').format(workshop.date)}';

    try {
      await _notificationService.saveNotification(
        NotificationItem(
          id: '',
          title: title,
          message: message,
          category: NotificationCategory.workshop,
          createdAt: DateTime.now(),
          meta: meta,
        ),
      );
    } catch (_) {
      // Notification creation failure should not block workshop save.
    }
  }

  String _buildUpdateMessage(Workshop workshop) {
    final changes = <String>[];
    if (widget.workshop?.location != workshop.location) {
      changes.add('venue');
    }
    if (widget.workshop?.date != workshop.date) {
      changes.add('date');
    }
    if (widget.workshop?.description != workshop.description) {
      changes.add('details');
    }
    if (widget.workshop?.title != workshop.title) {
      changes.add('title');
    }

    if (changes.isEmpty) {
      return '${workshop.title} has been updated. Please review the latest workshop details in the student portal.';
    }

    final changeList = changes.join(', ');
    return 'The $changeList for ${workshop.title} have been updated. Please review the latest workshop details.';
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.orbitron(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppColors.plum,
        letterSpacing: 1.5,
      ),
    );
  }
}
