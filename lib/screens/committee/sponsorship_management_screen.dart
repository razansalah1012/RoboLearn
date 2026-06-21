import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/sponsorship_model.dart';
import '../../services/sponsorship_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animated_interactive_card.dart';
import 'sponsorship_form_screen.dart';

class SponsorshipManagementScreen extends StatefulWidget {
  const SponsorshipManagementScreen({super.key});

  @override
  State<SponsorshipManagementScreen> createState() => _SponsorshipManagementScreenState();
}

class _SponsorshipManagementScreenState extends State<SponsorshipManagementScreen> {
  final SponsorshipService _sponsorshipService = SponsorshipService();
  String? _selectedWorkshopId; // null = "All"

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Received':
        return Colors.green;
      case 'Approved':
        return Colors.blue;
      case 'Pending':
        return Colors.orange;
      case 'Rejected':
        return Colors.red;
      default:
        return AppColors.taupe;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text(
          "SPONSORSHIPS",
          style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.cranberry,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Sponsorship>>(
        stream: _sponsorshipService.getSponsorshipsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.cranberry));
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading sponsorships"));
          }

          final sponsorships = snapshot.data ?? [];

          // Compute stats across all sponsorships
          double totalReceived = 0.0;
          double totalRequested = 0.0;
          int pendingCount = 0;

          for (var item in sponsorships) {
            if (item.status == 'Received') totalReceived += item.amount;
            if (item.status == 'Pending') pendingCount++;
            if (item.status != 'Rejected') totalRequested += item.amount;
          }

          // Build unique workshop map from linked sponsorships: workshopId -> title
          final workshopMap = <String, String>{};
          for (var s in sponsorships) {
            if (s.workshopId.isNotEmpty && s.purpose.isNotEmpty) {
              workshopMap[s.workshopId] = s.purpose;
            }
          }

          // Guard: reset selection if selected workshop no longer exists
          if (_selectedWorkshopId != null && !workshopMap.containsKey(_selectedWorkshopId)) {
            _selectedWorkshopId = null;
          }

          // Filter by selected workshop
          final filteredSponsorships = _selectedWorkshopId == null
              ? sponsorships
              : sponsorships.where((s) => s.workshopId == _selectedWorkshopId).toList();

          return Column(
            children: [
              _buildStatsHeader(totalReceived, totalRequested, pendingCount),
              _buildWorkshopFilter(workshopMap),
              Expanded(
                child: filteredSponsorships.isEmpty
                    ? Center(
                        child: Text(
                          "No sponsorships found.",
                          style: GoogleFonts.exo2(color: AppColors.taupe),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: filteredSponsorships.length,
                        itemBuilder: (context, index) {
                          return _buildSponsorshipCard(filteredSponsorships[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.cranberry,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          "Add Record",
          style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SponsorshipFormScreen()),
          );
        },
      ),
    );
  }

  Widget _buildStatsHeader(double totalReceived, double totalRequested, int pending) {
    final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "FUNDING METRICS",
            style: GoogleFonts.orbitron(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.plum,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  label: "Received",
                  value: currencyFormat.format(totalReceived),
                  color: Colors.green,
                  icon: Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStat(
                  label: "Target Funding",
                  value: currencyFormat.format(totalRequested),
                  color: AppColors.cranberry,
                  icon: Icons.monetization_on_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStat(
                  label: "Pending Apps",
                  value: "$pending",
                  color: Colors.orange,
                  icon: Icons.hourglass_empty,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.exo2(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.taupe,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.orbitron(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkshopFilter(Map<String, String> workshopMap) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 10),
          Text(
            "FILTER BY PROGRAMME",
            style: GoogleFonts.orbitron(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.taupe,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(label: "All", id: null),
                ...workshopMap.entries.map(
                  (entry) => _buildFilterChip(label: entry.value, id: entry.key),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({required String label, required String? id}) {
    final isSelected = _selectedWorkshopId == id;
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
        onSelected: (_) => setState(() => _selectedWorkshopId = id),
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

  Widget _buildSponsorshipCard(Sponsorship item) {
    final statusColor = _getStatusColor(item.status);
    final currencyFormat = NumberFormat.simpleCurrency();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: AnimatedInteractiveCard(
        padding: EdgeInsets.zero,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SponsorshipFormScreen(sponsorship: item),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                          item.companyName,
                          style: GoogleFonts.orbitron(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.cranberry,
                          ),
                        ),
                        if (item.purpose.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.purpose,
                            style: GoogleFonts.exo2(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.plum,
                            ),
                          ),
                        ],
                      ],
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
                      item.status.toUpperCase(),
                      style: GoogleFonts.orbitron(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 14, color: AppColors.taupe),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.contactPerson,
                                style: GoogleFonts.exo2(fontSize: 12, color: AppColors.taupe),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.email_outlined, size: 14, color: AppColors.taupe),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.contactEmail,
                                style: GoogleFonts.exo2(fontSize: 12, color: AppColors.taupe),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(item.amount),
                        style: GoogleFonts.orbitron(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.cranberry,
                        ),
                      ),
                      Text(
                        DateFormat.yMMMd().format(item.appliedDate),
                        style: GoogleFonts.exo2(
                          fontSize: 10,
                          color: AppColors.taupe.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (item.notes.isNotEmpty) ...[
                const Divider(height: 24),
                Text(
                  item.notes,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.exo2(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: AppColors.taupe.withOpacity(0.85),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
