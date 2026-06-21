import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/equipment_model.dart';
import '../../services/equipment_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animated_interactive_card.dart';
import 'equipment_form_screen.dart';
import 'equipment_bookings_screen.dart';

class EquipmentManagementScreen extends StatelessWidget {
  const EquipmentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EquipmentService service = EquipmentService();

    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text(
          "LAB EQUIPMENT",
          style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.cranberry,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_outlined),
            tooltip: "View Bookings",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EquipmentBookingsScreen()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Equipment>>(
        stream: service.getEquipmentStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.cranberry));
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading equipment"));
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.build_outlined, size: 64, color: AppColors.taupe.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text(
                    "No equipment added yet.",
                    style: GoogleFonts.exo2(color: AppColors.taupe),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: items.length,
            itemBuilder: (context, index) => _EquipmentCard(item: items[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.cranberry,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          "Add Equipment",
          style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EquipmentFormScreen()),
        ),
      ),
    );
  }
}

class _EquipmentCard extends StatelessWidget {
  final Equipment item;

  const _EquipmentCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: AnimatedInteractiveCard(
        padding: EdgeInsets.zero,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EquipmentFormScreen(equipment: item)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image panel
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: item.imageUrl.isNotEmpty
                  ? Image.network(
                      item.imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),
            // Info panel
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
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
                            color: AppColors.plum.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.plum.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            "Qty: ${item.quantity}",
                            style: GoogleFonts.orbitron(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.plum,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.exo2(
                          fontSize: 12,
                          color: AppColors.taupe,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 100,
      height: 100,
      color: AppColors.plum.withValues(alpha: 0.08),
      child: const Icon(Icons.build_outlined, color: AppColors.taupe, size: 36),
    );
  }
}
