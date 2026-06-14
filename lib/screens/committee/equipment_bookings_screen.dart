import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/equipment_booking_model.dart';
import '../../services/equipment_booking_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animated_interactive_card.dart';

class EquipmentBookingsScreen extends StatefulWidget {
  const EquipmentBookingsScreen({super.key});

  @override
  State<EquipmentBookingsScreen> createState() => _EquipmentBookingsScreenState();
}

class _EquipmentBookingsScreenState extends State<EquipmentBookingsScreen> {
  final EquipmentBookingService _service = EquipmentBookingService();
  String? _selectedStatus; // null = All

  static const _statuses = ['Pending', 'Approved', 'Rejected', 'Returned'];

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

  Future<void> _updateStatus(EquipmentBooking booking, String newStatus) async {
    await _service.updateStatus(booking, newStatus);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Booking marked as $newStatus"),
          backgroundColor: _statusColor(newStatus),
        ),
      );
    }
  }

  void _showActions(BuildContext context, EquipmentBooking booking) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
              booking.equipmentName,
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.cranberry,
              ),
            ),
            Text(
              "Requested by ${booking.studentName}",
              style: GoogleFonts.exo2(fontSize: 13, color: AppColors.taupe),
            ),
            const SizedBox(height: 20),
            if (booking.status == 'Pending') ...[
              _ActionTile(
                icon: Icons.check_circle_outline,
                label: "Approve",
                color: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  _updateStatus(booking, 'Approved');
                },
              ),
              _ActionTile(
                icon: Icons.cancel_outlined,
                label: "Reject",
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _updateStatus(booking, 'Rejected');
                },
              ),
            ],
            if (booking.status == 'Approved')
              _ActionTile(
                icon: Icons.assignment_return_outlined,
                label: "Mark as Returned",
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  _updateStatus(booking, 'Returned');
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text(
          "EQUIPMENT BOOKINGS",
          style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.cranberry,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<EquipmentBooking>>(
        stream: _service.getAllBookingsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.cranberry));
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading bookings"));
          }

          final all = snapshot.data ?? [];
          final filtered = _selectedStatus == null
              ? all
              : all.where((b) => b.status == _selectedStatus).toList();

          return Column(
            children: [
              _buildFilter(),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          "No bookings found.",
                          style: GoogleFonts.exo2(color: AppColors.taupe),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) =>
                            _buildBookingCard(context, filtered[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildChip(label: "All", value: null),
            ..._statuses.map((s) => _buildChip(label: s, value: s)),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({required String label, required String? value}) {
    final isSelected = _selectedStatus == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.exo2(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : AppColors.plum,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedStatus = value),
        selectedColor: AppColors.cranberry,
        backgroundColor: AppColors.beige,
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected ? AppColors.cranberry : AppColors.taupe.withValues(alpha: 0.3),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, EquipmentBooking b) {
    final statusColor = _statusColor(b.status);
    final canAct = b.status == 'Pending' || b.status == 'Approved';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: AnimatedInteractiveCard(
        padding: const EdgeInsets.all(18),
        onTap: canAct ? () => _showActions(context, b) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.equipmentName,
                        style: GoogleFonts.orbitron(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.cranberry,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        b.studentName,
                        style: GoogleFonts.exo2(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.plum,
                        ),
                      ),
                      Text(
                        b.studentEmail,
                        style: GoogleFonts.exo2(fontSize: 11, color: AppColors.taupe),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
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
                    if (canAct) ...[
                      const SizedBox(height: 6),
                      Text(
                        "Tap to manage",
                        style: GoogleFonts.exo2(fontSize: 10, color: AppColors.taupe),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                const Icon(Icons.numbers_outlined, size: 14, color: AppColors.taupe),
                const SizedBox(width: 4),
                Text("Qty: ${b.quantity}", style: GoogleFonts.exo2(fontSize: 12, color: AppColors.taupe)),
                const SizedBox(width: 16),
                const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.taupe),
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.exo2(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: AppColors.taupe.withValues(alpha: 0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: GoogleFonts.exo2(fontWeight: FontWeight.w600, color: color)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
