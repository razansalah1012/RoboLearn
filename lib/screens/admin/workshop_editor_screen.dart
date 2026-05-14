import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/workshop_model.dart';
import '../../services/workshop_service.dart';
import '../../theme/app_colors.dart';

class WorkshopEditorScreen extends StatefulWidget {
  final Workshop? workshop;
  const WorkshopEditorScreen({super.key, this.workshop});

  @override
  State<WorkshopEditorScreen> createState() => _WorkshopEditorScreenState();
}

class _WorkshopEditorScreenState extends State<WorkshopEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final WorkshopService _workshopService = WorkshopService();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _locController;
  late TextEditingController _capController;
  late DateTime _selectedDate;
  late String _category;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.workshop?.title ?? '');
    _descController = TextEditingController(text: widget.workshop?.description ?? '');
    _locController = TextEditingController(text: widget.workshop?.location ?? 'Innovation Hub, UTM');
    _capController = TextEditingController(text: widget.workshop?.capacity.toString() ?? '20');
    _selectedDate = widget.workshop?.date ?? DateTime.now().add(const Duration(days: 7));
    _category = widget.workshop?.category ?? 'Robotics';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final workshop = Workshop(
      id: widget.workshop?.id ?? '',
      title: _titleController.text,
      description: _descController.text,
      date: _selectedDate,
      location: _locController.text,
      category: _category,
      capacity: int.parse(_capController.text),
      registeredUserIds: widget.workshop?.registeredUserIds ?? [],
    );

    try {
      await _workshopService.saveWorkshop(workshop);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Deployment Error: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text(widget.workshop == null ? 'Schedule Workshop' : 'Edit Session', style: GoogleFonts.orbitron(fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.cranberry,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Session Details", style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.cranberry)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Workshop Title', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Title required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Technical Description', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildDropdowns(),
              const SizedBox(height: 16),
              _buildDatePicker(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locController,
                decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on)),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.plum, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : Text("DEPLOY SESSION", style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdowns() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
            items: ['Programming', 'Robotics', 'Drones', 'Mechanics', 'Engineering']
                .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12)))).toList(),
            onChanged: (v) => setState(() => _category = v!),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: _capController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Capacity', border: OutlineInputBorder()),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade400)),
      title: Text("Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}"),
      trailing: const Icon(Icons.calendar_today, color: AppColors.cranberry),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
    );
  }
}
