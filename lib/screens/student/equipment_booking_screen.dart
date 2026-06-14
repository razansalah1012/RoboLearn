import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/equipment_model.dart';
import '../../models/equipment_booking_model.dart';
import '../../models/user_model.dart';
import '../../services/equipment_service.dart';
import '../../services/equipment_booking_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animated_interactive_card.dart';

class EquipmentBookingScreen extends StatefulWidget {
  const EquipmentBookingScreen({super.key});

  @override
  State<EquipmentBookingScreen> createState() => _EquipmentBookingScreenState();
}

class _EquipmentBookingScreenState extends State<EquipmentBookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final EquipmentService _equipmentService = EquipmentService();
  final EquipmentBookingService _bookingService = EquipmentBookingService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Returned':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  void _showBookingSheet(BuildContext context, Equipment equipment, UserModel user) {
    final formKey = GlobalKey<FormState>();
    final quantityController = TextEditingController(text: '1');
    final notesController = TextEditingController();
    DateTime bookingDate = DateTime.now().add(const Duration(days: 1));
    DateTime returnDate = DateTime.now().add(const Duration(days: 2));
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "BOOK EQUIPMENT",
                    style: GoogleFonts.orbitron(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.plum,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    equipment.name,
                    style: GoogleFonts.exo2(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cranberry,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: "Quantity*",
                      prefixIcon: Icon(Icons.numbers_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return "Enter quantity";
                      final q = int.tryParse(val.trim());
                      if (q == null || q < 1) return "Must be at least 1";
                      if (q > equipment.quantity) return "Only ${equipment.quantity} available";
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _DatePickerField(
                          label: "Booking Date",
                          date: bookingDate,
                          firstDate: DateTime.now(),
                          onChanged: (d) => setSheetState(() => bookingDate = d),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DatePickerField(
                          label: "Return Date",
                          date: returnDate,
                          firstDate: bookingDate.add(const Duration(days: 1)),
                          onChanged: (d) => setSheetState(() => returnDate = d),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: "Notes (optional)",
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              if (returnDate.isBefore(bookingDate)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Return date must be after booking date")),
                                );
                                return;
                              }
                              setSheetState(() => isSaving = true);
                              try {
                                final booking = EquipmentBooking(
                                  id: '',
                                  equipmentId: equipment.id,
                                  equipmentName: equipment.name,
                                  equipmentImageUrl: equipment.imageUrl,
                                  studentId: user.uid,
                                  studentName: user.name,
                                  studentEmail: user.email,
                                  quantity: int.parse(quantityController.text.trim()),
                                  bookingDate: bookingDate,
                                  returnDate: returnDate,
                                  requestedAt: DateTime.now(),
                                  status: 'Pending',
                                  notes: notesController.text.trim(),
                                );
                                await _bookingService.createBooking(booking);
                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Booking request submitted!"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  _tabController.animateTo(1);
                                }
                              } catch (e) {
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent),
                                  );
                                }
                              } finally {
                                setSheetState(() => isSaving = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cranberry,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "SUBMIT REQUEST",
                              style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _authService.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text(
          "LAB EQUIPMENT",
          style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.cranberry,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "BROWSE"),
            Tab(text: "MY BOOKINGS"),
          ],
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, userSnap) {
          final user = userSnap.hasData && userSnap.data!.exists
              ? UserModel.fromMap(userSnap.data!.data() as Map<String, dynamic>)
              : null;

          return TabBarView(
            controller: _tabController,
            children: [
              // --- BROWSE TAB ---
              StreamBuilder<List<Equipment>>(
                stream: _equipmentService.getEquipmentStream(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.cranberry));
                  }
                  final items = snap.data ?? [];
                  if (items.isEmpty) {
                    return Center(
                      child: Text("No equipment available.", style: GoogleFonts.exo2(color: AppColors.taupe)),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: AnimatedInteractiveCard(
                          padding: EdgeInsets.zero,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                                child: item.imageUrl.isNotEmpty
                                    ? Image.network(
                                        item.imageUrl,
                                        width: 100,
                                        height: 110,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, e, s) => _imagePlaceholder(),
                                      )
                                    : _imagePlaceholder(),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: GoogleFonts.orbitron(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.cranberry,
                                        ),
                                      ),
                                      if (item.description.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          item.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.exo2(fontSize: 11, color: AppColors.taupe),
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Qty: ${item.quantity}",
                                            style: GoogleFonts.exo2(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.plum,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 30,
                                            child: ElevatedButton(
                                              onPressed: item.quantity > 0 && user != null
                                                  ? () => _showBookingSheet(context, item, user)
                                                  : null,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.cranberry,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                                textStyle: GoogleFonts.orbitron(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              child: Text(item.quantity > 0 ? "BOOK" : "UNAVAILABLE"),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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
              ),

              // --- MY BOOKINGS TAB ---
              StreamBuilder<List<EquipmentBooking>>(
                stream: _bookingService.getUserBookingsStream(uid),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.cranberry));
                  }
                  final bookings = snap.data ?? [];
                  if (bookings.isEmpty) {
                    return Center(
                      child: Text("No bookings yet.", style: GoogleFonts.exo2(color: AppColors.taupe)),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final b = bookings[index];
                      final statusColor = _statusColor(b.status);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: AnimatedInteractiveCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      b.equipmentName,
                                      style: GoogleFonts.orbitron(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.cranberry,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      b.status.toUpperCase(),
                                      style: GoogleFonts.orbitron(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.numbers_outlined, size: 13, color: AppColors.taupe),
                                  const SizedBox(width: 4),
                                  Text("Qty: ${b.quantity}", style: GoogleFonts.exo2(fontSize: 12, color: AppColors.taupe)),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.taupe),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${DateFormat.MMMd().format(b.bookingDate)} → ${DateFormat.MMMd().format(b.returnDate)}",
                                    style: GoogleFonts.exo2(fontSize: 12, color: AppColors.taupe),
                                  ),
                                ],
                              ),
                              if (b.notes.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  b.notes,
                                  style: GoogleFonts.exo2(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.taupe),
                                ),
                              ],
                              if (b.status == 'Pending') ...[
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: Text("Cancel Booking", style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
                                          content: const Text("Cancel this booking request?"),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("NO")),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(ctx, true),
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                              child: const Text("YES, CANCEL"),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await _bookingService.cancelBooking(b.id);
                                      }
                                    },
                                    icon: const Icon(Icons.cancel_outlined, size: 16),
                                    label: Text("Cancel Request", style: GoogleFonts.exo2(fontSize: 12)),
                                    style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                                  ),
                                ),
                              ],
                              if (b.status == 'Approved') ...[
                                const SizedBox(height: 12),
                                const Divider(height: 1),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.info_outline, size: 14, color: Colors.green),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        "Approved — please return the item when done.",
                                        style: GoogleFonts.exo2(fontSize: 11, color: Colors.green),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: Text("Return Item", style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
                                          content: Text(
                                            "Confirm return of ${b.quantity} × ${b.equipmentName}? The quantity will be restored.",
                                          ),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("NOT YET")),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(ctx, true),
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                              child: const Text("CONFIRM RETURN"),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await _bookingService.updateStatus(b, 'Returned');
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text("Item returned successfully. Thank you!"),
                                              backgroundColor: Colors.blue,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.assignment_return_outlined, size: 16),
                                    label: Text("Return Item", style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    ),
                                  ),
                                ),
                              ],
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
        },
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 100,
      height: 110,
      color: AppColors.plum.withValues(alpha: 0.08),
      child: const Icon(Icons.build_outlined, color: AppColors.taupe, size: 32),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime date;
  final DateTime firstDate;
  final ValueChanged<DateTime> onChanged;

  const _DatePickerField({
    required this.label,
    required this.date,
    required this.firstDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date.isBefore(firstDate) ? firstDate : date,
          firstDate: firstDate,
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onChanged(picked);
      },
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Text(
          DateFormat.MMMd().format(date),
          style: GoogleFonts.exo2(fontSize: 13),
        ),
      ),
    );
  }
}
