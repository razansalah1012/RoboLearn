import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/tech_background_animation.dart';
import '../widgets/animated_interactive_card.dart';
import '../services/auth_service.dart';
import '../services/module_service.dart';
import '../models/learning_module_model.dart';
import '../services/gemini_service.dart';
import 'login_screen.dart';

class CommitteeDashboard extends StatefulWidget {
  const CommitteeDashboard({super.key});

  @override
  State<CommitteeDashboard> createState() => _CommitteeDashboardState();
}

class _CommitteeDashboardState extends State<CommitteeDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ModuleService _moduleService = ModuleService();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.beige,
      body: Stack(
        children: [
          // Background Animation
          const Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: TechBackgroundAnimation(),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _OverviewTab(),
                      _ModulesTab(moduleService: _moduleService),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          if (_tabController.index != 1) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            backgroundColor: AppColors.cranberry,
            foregroundColor: AppColors.ivory,
            elevation: 8,
            icon: const Icon(Icons.add_rounded),
            label: Text(
              'Create Module',
              style: GoogleFonts.exo2(fontWeight: FontWeight.w700),
            ),
            onPressed: () => _showCreateModuleSheet(context),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.cranberry, AppColors.plum],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder(
                      future: AuthService().getUserData(
                          AuthService().currentUser?.uid ?? ''),
                      builder: (context, snapshot) {
                        final name = snapshot.data?.name ?? 'Committee Member';
                        return Text(
                          'Welcome, $name',
                          style: GoogleFonts.exo2(
                            fontSize: 14,
                            color: AppColors.ivory.withAlpha(200),
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'COMMITTEE HUB',
                      style: GoogleFonts.orbitron(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ivory,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.ivory.withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: AppColors.ivory,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.logout_rounded,
                          color: AppColors.ivory),
                      tooltip: 'Logout',
                      onPressed: () async {
                        await AuthService().signOut();
                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.ivory,
            indicatorWeight: 4,
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 20),
            labelColor: AppColors.ivory,
            unselectedLabelColor: AppColors.ivory.withAlpha(140),
            labelStyle: GoogleFonts.exo2(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
            unselectedLabelStyle: GoogleFonts.exo2(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.analytics_outlined, size: 20),
                text: 'Analytics',
              ),
              Tab(
                icon: Icon(Icons.auto_stories_outlined, size: 20),
                text: 'Learning Modules',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateModuleSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateModuleSheet(moduleService: _moduleService),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// OVERVIEW / ANALYTICS TAB
// ─────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_rounded, color: AppColors.cranberry, size: 24),
              const SizedBox(width: 12),
              Text(
                'Performance Insights',
                style: GoogleFonts.orbitron(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cranberry,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, constraints) {
            final cols = constraints.maxWidth > 700 ? 4 : 2;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: cols,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: const [
                _StatCard(
                  title: 'Active Students',
                  value: '156',
                  icon: Icons.people_rounded,
                  color: Color(0xFF4A7C59),
                ),
                _StatCard(
                  title: 'Total Modules',
                  value: '12',
                  icon: Icons.library_books_rounded,
                  color: AppColors.plum,
                ),
                _StatCard(
                  title: 'Certificates',
                  value: '42',
                  icon: Icons.verified_user_rounded,
                  color: AppColors.cranberry,
                ),
                _StatCard(
                  title: 'Lab Sessions',
                  value: '8',
                  icon: Icons.biotech_rounded,
                  color: AppColors.taupe,
                ),
              ],
            );
          }),
          const SizedBox(height: 32),
          Text(
            'Quick Management',
            style: GoogleFonts.orbitron(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.cranberry,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              _ActionCard(icon: Icons.person_add_rounded, title: 'Approve User'),
              _ActionCard(icon: Icons.inventory_rounded, title: 'Inventory'),
              _ActionCard(icon: Icons.event_available_rounded, title: 'Schedule'),
              _ActionCard(icon: Icons.file_download_rounded, title: 'Export Data'),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// MODULES TAB
// ─────────────────────────────────────────────────────────────
class _ModulesTab extends StatelessWidget {
  final ModuleService moduleService;
  const _ModulesTab({required this.moduleService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LearningModule>>(
      stream: moduleService.getModulesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.cranberry),
          );
        }
        final modules = snapshot.data ?? [];
        if (modules.isEmpty) {
          return _buildEmptyState();
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
          itemCount: modules.length,
          itemBuilder: (context, i) =>
              _AdminModuleCard(module: modules[i], service: moduleService),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.cranberry.withAlpha(12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_stories_outlined,
              size: 64,
              color: AppColors.cranberry,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Content Yet',
            style: GoogleFonts.orbitron(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.cranberry,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Start by creating your first robotic learning module for the students.',
              textAlign: TextAlign.center,
              style: GoogleFonts.exo2(
                fontSize: 14,
                color: AppColors.taupe,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ADMIN MODULE CARD
// ─────────────────────────────────────────────────────────────
class _AdminModuleCard extends StatelessWidget {
  final LearningModule module;
  final ModuleService service;
  const _AdminModuleCard({required this.module, required this.service});

  Color get _diffColor {
    switch (module.difficulty) {
      case 'Intermediate':
        return const Color(0xFF4A7C59);
      case 'Advanced':
        return AppColors.cranberry;
      default:
        return AppColors.taupe;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedInteractiveCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 6,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusLarge - 2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _SmallChip(
                      module.category.toUpperCase(),
                      AppColors.plum.withAlpha(20),
                      AppColors.plum,
                    ),
                    const SizedBox(width: 10),
                    _SmallChip(
                      module.difficulty.toUpperCase(),
                      _diffColor.withAlpha(20),
                      _diffColor,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: Colors.redAccent, size: 22),
                      tooltip: 'Remove Module',
                      onPressed: () => _confirmDelete(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  module.title,
                  style: GoogleFonts.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cranberry,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  module.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.exo2(
                    fontSize: 13,
                    color: AppColors.taupe,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 14, color: AppColors.taupe.withAlpha(150)),
                    const SizedBox(width: 6),
                    Text(
                      'Published on ${_formatDate(module.createdAt)}',
                      style: GoogleFonts.exo2(
                        fontSize: 12,
                        color: AppColors.taupe.withAlpha(180),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Manage →',
                      style: GoogleFonts.exo2(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.plum,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.ivory,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Module?',
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.cranberry,
          ),
        ),
        content: Text(
          'This will permanently remove "${module.title}" and its content. This action cannot be undone.',
          style: GoogleFonts.exo2(color: AppColors.taupe, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: GoogleFonts.exo2(
                color: AppColors.taupe,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              await service.deleteModule(module.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(
              'DELETE',
              style: GoogleFonts.exo2(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _SmallChip(this.label, this.bg, this.fg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.exo2(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CREATE MODULE SHEET
// ─────────────────────────────────────────────────────────────
class _CreateModuleSheet extends StatefulWidget {
  final ModuleService moduleService;
  const _CreateModuleSheet({required this.moduleService});

  @override
  State<_CreateModuleSheet> createState() => _CreateModuleSheetState();
}

class _CreateModuleSheetState extends State<_CreateModuleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  String _category = 'General';
  String _difficulty = 'Beginner';
  bool _loading = false;
  bool _aiLoading = false;
  List<QuizQuestion> _generatedQuiz = [];
  final GeminiService _gemini = GeminiService();

  static const _categories = [
    'General',
    'Sensors',
    'Actuators',
    'Programming',
    'Mechanics',
    'Electronics',
    'AI & Vision',
  ];
  static const _difficulties = ['Beginner', 'Intermediate', 'Advanced'];

  Color _diffColor(String d) {
    switch (d) {
      case 'Intermediate':
        return const Color(0xFF4A7C59);
      case 'Advanced':
        return AppColors.cranberry;
      default:
        return AppColors.taupe;
    }
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final user = AuthService().currentUser;
      if (user == null) {
        throw 'User is not logged in. Please log in again.';
      }
      final uid = user.uid;
      await widget.moduleService.createModule(LearningModule(
        id: '',
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        category: _category,
        difficulty: _difficulty,
        createdBy: uid,
        createdAt: DateTime.now(),
        quiz: _generatedQuiz,
      ));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Module successfully published to the learning library!',
              style: GoogleFonts.exo2(fontWeight: FontWeight.w500),
            ),
            backgroundColor: const Color(0xFF4A7C59),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('PUBLISH ERROR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to publish module: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.exo2(color: AppColors.taupe, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.plum, size: 20),
      filled: true,
      fillColor: AppColors.beige.withAlpha(100),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.plum.withAlpha(20)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.cranberry, width: 2),
      ),
    );
  }

  Future<void> _runAiResearch() async {
    setState(() => _aiLoading = true);
    final result = await _gemini.researchCategory(_category);
    setState(() {
      _titleCtrl.text = result['title']!;
      _contentCtrl.text = result['content']!;
      _aiLoading = false;
    });
  }

  Future<void> _runAiQuiz() async {
    if (_contentCtrl.text.isEmpty) return;
    setState(() => _aiLoading = true);
    final questions = await _gemini.generateQuiz(_contentCtrl.text);
    setState(() {
      _generatedQuiz = questions;
      _aiLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.94,
      maxChildSize: 0.96,
      minChildSize: 0.6,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.ivory,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -4))
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.plum.withAlpha(40),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.add_task_rounded,
                        color: AppColors.ivory, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'New Module',
                    style: GoogleFonts.orbitron(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.cranberry,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleCtrl,
                        style: GoogleFonts.exo2(
                            fontWeight: FontWeight.w600,
                            color: AppColors.cranberry),
                        decoration: _inputDeco('Title', Icons.title_rounded),
                        validator: (v) => v?.trim().isEmpty ?? true
                            ? 'Title is required'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _category,
                        decoration: _inputDeco('Category', Icons.category_rounded),
                        style: GoogleFonts.exo2(
                            color: AppColors.cranberry,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                        dropdownColor: AppColors.ivory,
                        items: _categories
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => _category = v!),
                      ),
                      const SizedBox(height: 12),
                      
                      // AI Research Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.plum,
                            side: const BorderSide(color: AppColors.plum),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: _aiLoading 
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.plum))
                            : const Icon(Icons.auto_awesome_rounded, size: 18),
                          label: Text(
                            _aiLoading ? 'AI is researching...' : 'Research Category with AI',
                            style: GoogleFonts.exo2(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          onPressed: _aiLoading ? null : _runAiResearch,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Difficulty Level',
                        style: GoogleFonts.exo2(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.plum,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: _difficulties.map((d) {
                          final selected = d == _difficulty;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _difficulty = d),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? _diffColor(d)
                                      : _diffColor(d).withAlpha(15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? _diffColor(d)
                                        : _diffColor(d).withAlpha(60),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  d,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.exo2(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? AppColors.ivory
                                        : _diffColor(d),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _descCtrl,
                        maxLines: 3,
                        style: GoogleFonts.exo2(color: AppColors.cranberry),
                        decoration:
                            _inputDeco('Description', Icons.description_rounded),
                        validator: (v) => v?.trim().isEmpty ?? true
                            ? 'Description is required'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _contentCtrl,
                        maxLines: 10,
                        style: GoogleFonts.exo2(
                            color: AppColors.cranberry, fontSize: 14),
                        decoration: _inputDeco('Content', Icons.article_rounded),
                        validator: (v) => v?.trim().isEmpty ?? true
                            ? 'Content is required'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Quiz Generation Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.plum.withAlpha(10),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.plum.withAlpha(30)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.quiz_rounded, color: AppColors.plum, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  'Assessment (Quiz)',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.plum,
                                  ),
                                ),
                                const Spacer(),
                                if (_generatedQuiz.isNotEmpty)
                                  const Icon(Icons.check_circle_rounded, color: Color(0xFF4A7C59), size: 18),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (_generatedQuiz.isEmpty)
                              Text(
                                'No quiz generated yet. Use the AI to generate questions based on your module content.',
                                style: GoogleFonts.exo2(fontSize: 12, color: AppColors.taupe),
                              )
                            else
                              Text(
                                '${_generatedQuiz.length} questions generated.',
                                style: GoogleFonts.exo2(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.plum),
                              ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.plum,
                                  foregroundColor: AppColors.ivory,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.psychology_rounded, size: 18),
                                label: Text(
                                  _generatedQuiz.isEmpty ? 'Generate AI Quiz' : 'Re-generate Quiz',
                                  style: GoogleFonts.exo2(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                onPressed: _aiLoading ? null : _runAiQuiz,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cranberry,
                            foregroundColor: AppColors.ivory,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _loading ? null : _publish,
                          child: _loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.rocket_launch_rounded),
                                    const SizedBox(width: 12),
                                    Text(
                                      'PUBLISH MODULE',
                                      style: GoogleFonts.orbitron(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STAT CARD
// ─────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedInteractiveCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.cranberry,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.exo2(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.taupe,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ACTION CARD
// ─────────────────────────────────────────────────────────────
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  const _ActionCard({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return AnimatedInteractiveCard(
      padding: const EdgeInsets.all(16),
      onTap: () {},
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: AppColors.plum),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.exo2(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.cranberry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
