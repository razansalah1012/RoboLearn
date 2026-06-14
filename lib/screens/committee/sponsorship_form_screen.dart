import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/sponsorship_model.dart';
import '../../models/workshop_model.dart';
import '../../services/sponsorship_service.dart';
import '../../services/workshop_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animated_interactive_card.dart';

class SponsorshipFormScreen extends StatefulWidget {
  final Sponsorship? sponsorship;

  const SponsorshipFormScreen({super.key, this.sponsorship});

  @override
  State<SponsorshipFormScreen> createState() => _SponsorshipFormScreenState();
}

class _SponsorshipFormScreenState extends State<SponsorshipFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final SponsorshipService _sponsorshipService = SponsorshipService();
  final WorkshopService _workshopService = WorkshopService();
  final AuthService _authService = AuthService();

  late TextEditingController _companyNameController;
  late TextEditingController _contactPersonController;
  late TextEditingController _contactEmailController;
  late TextEditingController _contactPhoneController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;

  String _status = 'Pending';
  bool _isSaving = false;
  List<Workshop> _workshops = [];
  Workshop? _selectedWorkshop;

  bool get _isEditMode => widget.sponsorship != null;

  @override
  void initState() {
    super.initState();
    _companyNameController = TextEditingController(text: widget.sponsorship?.companyName ?? '');
    _contactPersonController = TextEditingController(text: widget.sponsorship?.contactPerson ?? '');
    _contactEmailController = TextEditingController(text: widget.sponsorship?.contactEmail ?? '');
    _contactPhoneController = TextEditingController(text: widget.sponsorship?.contactPhone ?? '');
    _amountController = TextEditingController(
      text: widget.sponsorship != null ? widget.sponsorship!.amount.toStringAsFixed(2) : '',
    );
    _notesController = TextEditingController(text: widget.sponsorship?.notes ?? '');
    _status = widget.sponsorship?.status ?? 'Pending';
    _loadWorkshops();
  }

  Future<void> _loadWorkshops() async {
    _workshopService.getAllWorkshopsStream().first.then((workshops) {
      if (!mounted) return;
      setState(() {
        _workshops = workshops;
        if (_isEditMode && widget.sponsorship!.workshopId.isNotEmpty) {
          _selectedWorkshop = workshops.firstWhere(
            (w) => w.id == widget.sponsorship!.workshopId,
            orElse: () => workshops.first,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _contactPersonController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final double amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
      final String uid = _authService.currentUser?.uid ?? '';

      final sponsorship = Sponsorship(
        id: widget.sponsorship?.id ?? '',
        companyName: _companyNameController.text.trim(),
        contactPerson: _contactPersonController.text.trim(),
        contactEmail: _contactEmailController.text.trim(),
        contactPhone: _contactPhoneController.text.trim(),
        amount: amount,
        purpose: _selectedWorkshop?.title ?? '',
        workshopId: _selectedWorkshop?.id ?? '',
        status: _status,
        notes: _notesController.text.trim(),
        appliedDate: widget.sponsorship?.appliedDate ?? DateTime.now(),
        lastUpdated: DateTime.now(),
        createdBy: widget.sponsorship?.createdBy ?? uid,
      );

      await _sponsorshipService.saveSponsorship(sponsorship);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? "Sponsorship updated successfully" : "Sponsorship saved successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving record: $e"),
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

  Future<void> _deleteRecord() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Record", style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to delete this sponsorship record? This action cannot be undone."),
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
        await _sponsorshipService.deleteSponsorship(widget.sponsorship!.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Sponsorship record deleted"),
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
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text(
          _isEditMode ? "EDIT SPONSORSHIP" : "NEW SPONSORSHIP",
          style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.cranberry,
        foregroundColor: Colors.white,
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _isSaving ? null : _deleteRecord,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: AnimatedInteractiveCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "SPONSOR DETAILS",
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.plum,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _companyNameController,
                  decoration: const InputDecoration(
                    labelText: "Company/Sponsor Name*",
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? "Please enter company name" : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Workshop>(
                  value: _selectedWorkshop,
                  decoration: const InputDecoration(
                    labelText: "Workshop*",
                    prefixIcon: Icon(Icons.event_outlined),
                    hintText: "Select a workshop",
                  ),
                  items: _workshops
                      .map((workshop) => DropdownMenuItem<Workshop>(
                            value: workshop,
                            child: Text(
                              workshop.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedWorkshop = val),
                  validator: (val) => val == null ? "Please select a workshop" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: "Amount (RM)*",
                    prefixIcon: Icon(Icons.monetization_on_outlined),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return "Please enter amount";
                    if (double.tryParse(val.trim()) == null) return "Please enter a valid amount";
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  "STATUS PROFILE",
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.plum,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: "Status",
                    prefixIcon: Icon(Icons.rule_rounded),
                  ),
                  items: ['Pending', 'Approved', 'Rejected', 'Received']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _status = val);
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  "CONTACT INFORMATION",
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.plum,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactPersonController,
                  decoration: const InputDecoration(
                    labelText: "Contact Person*",
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? "Please enter contact person name" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactEmailController,
                  decoration: const InputDecoration(
                    labelText: "Contact Email*",
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return "Please enter email";
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                      return "Please enter a valid email address";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactPhoneController,
                  decoration: const InputDecoration(
                    labelText: "Contact Phone",
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "ADDITIONAL NOTES",
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.plum,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: "Notes",
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                  maxLines: 3,
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
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isEditMode ? "UPDATE RECORD" : "CREATE RECORD",
                            style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
