import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_model.dart';
import '../../theme/app_colors.dart';

class LabAccessTrackingScreen extends StatefulWidget {
  const LabAccessTrackingScreen({super.key});

  @override
  State<LabAccessTrackingScreen> createState() =>
      _LabAccessTrackingScreenState();
}

class _LabAccessTrackingScreenState extends State<LabAccessTrackingScreen> {
  final List<String> _labRooms = const ['Lab 1', 'Lab 2', 'Lab 3'];

  String _selectedMember = '';
  String _selectedAction = 'Enter';
  String _selectedRoom = 'Lab 1';
  String _filter = 'All';

  final List<_LabAccessEntry> _entries = [];

  @override
  Widget build(BuildContext context) {
    final filteredEntries = _filter == 'All'
        ? _entries
        : _entries.where((entry) => entry.action == _filter).toList();

    return Scaffold(
      backgroundColor: AppColors.beige,
      appBar: AppBar(
        title: Text(
          'LAB ACCESS TRACKER',
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.cranberry,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCard(),
            const SizedBox(height: 16),
            _buildEntryForm(),
            const SizedBox(height: 18),
            _buildFilterBar(filteredEntries.length),
            const SizedBox(height: 14),
            Text(
              'Recent Access Log',
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.cranberry,
              ),
            ),
            const SizedBox(height: 10),
            if (filteredEntries.isEmpty)
              _buildEmptyState()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredEntries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final entry = filteredEntries[index];
                  return _buildLogCard(entry);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LAB ACCESS',
            style: GoogleFonts.orbitron(
              fontSize: 10,
              letterSpacing: 1.5,
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Log access activity',
            style: GoogleFonts.orbitron(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Track who enters or exits the robotics labs in real time.',
            style: GoogleFonts.exo2(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cranberry,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New log entry',
            style: GoogleFonts.orbitron(
              fontSize: 12,
              letterSpacing: 1.2,
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder<List<UserModel>>(
            stream: _memberStream(),
            builder: (context, snapshot) {
              final members = snapshot.data ?? const <UserModel>[];
              final memberNames =
                  members
                      .map((user) => user.name.trim())
                      .where((name) => name.isNotEmpty)
                      .toSet()
                      .toList()
                    ..sort();

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }

              if (snapshot.hasError || memberNames.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No registered members available',
                    style: GoogleFonts.exo2(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                );
              }

              return DropdownButtonFormField<String>(
                value: memberNames.contains(_selectedMember)
                    ? _selectedMember
                    : null,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                hint: const Text('Select member'),
                items: memberNames
                    .map(
                      (name) =>
                          DropdownMenuItem(value: name, child: Text(name)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedMember = value ?? _selectedMember),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  label: 'Action',
                  child: DropdownButtonFormField<String>(
                    value: _selectedAction,
                    decoration: _inputDecoration(),
                    items: const ['Enter', 'Exit']
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(
                      () => _selectedAction = value ?? _selectedAction,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFormField(
                  label: 'Room',
                  child: DropdownButtonFormField<String>(
                    value: _selectedRoom,
                    decoration: _inputDecoration(),
                    items: _labRooms
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedRoom = value ?? _selectedRoom),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.cranberry,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _addEntry,
              child: Text(
                'Add Entry',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Stream<List<UserModel>> _memberStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('name', isNotEqualTo: '')
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .where((user) => user.name.trim().isNotEmpty)
              .toList(),
        );
  }

  Widget _buildFormField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.exo2(
            fontSize: 11,
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return const InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  Widget _buildFilterBar(int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Filter',
              style: GoogleFonts.orbitron(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.cranberry,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.plum.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.orbitron(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.plum,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['All', 'Enter', 'Exit']
              .map(
                (value) => ChoiceChip(
                  label: Text(value),
                  selected: _filter == value,
                  onSelected: (_) => setState(() => _filter = value),
                  selectedColor: AppColors.cranberry,
                  labelStyle: GoogleFonts.exo2(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _filter == value ? Colors.white : AppColors.taupe,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildLogCard(_LabAccessEntry entry) {
    final isEnter = entry.action == 'Enter';
    final accentColor = isEnter ? Colors.green.shade700 : AppColors.cranberry;
    final background = isEnter
        ? Colors.green.shade50
        : AppColors.plum.withValues(alpha: 0.08);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.plum.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEnter ? Icons.login_rounded : Icons.logout_rounded,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        entry.action.toUpperCase(),
                        style: GoogleFonts.orbitron(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDateTime(entry.timestamp),
                      style: GoogleFonts.exo2(
                        fontSize: 10,
                        color: AppColors.taupe,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  entry.memberName,
                  style: GoogleFonts.exo2(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cranberry,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.taupe,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entry.room,
                      style: GoogleFonts.exo2(
                        fontSize: 11,
                        color: AppColors.taupe,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _deleteEntry(entry.id),
            icon: const Icon(Icons.delete_outline_rounded),
            color: Colors.red.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'No records match this filter yet.',
        textAlign: TextAlign.center,
        style: GoogleFonts.exo2(fontSize: 12, color: AppColors.taupe),
      ),
    );
  }

  void _addEntry() {
    final newEntry = _LabAccessEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      memberName: _selectedMember,
      action: _selectedAction,
      room: _selectedRoom,
      timestamp: DateTime.now(),
    );

    setState(() {
      _entries.insert(0, newEntry);
    });
  }

  void _deleteEntry(String id) {
    setState(() {
      _entries.removeWhere((entry) => entry.id == id);
    });
  }

  String _formatDateTime(DateTime value) {
    final now = DateTime.now();
    final difference = now.difference(value);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    }

    return '${value.day}/${value.month}/${value.year}';
  }
}

class _LabAccessEntry {
  final String id;
  final String memberName;
  final String action;
  final String room;
  final DateTime timestamp;

  const _LabAccessEntry({
    required this.id,
    required this.memberName,
    required this.action,
    required this.room,
    required this.timestamp,
  });
}
