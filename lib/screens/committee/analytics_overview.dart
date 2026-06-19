import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../services/analytics_service.dart';
import '../../widgets/animated_interactive_card.dart';

class AnalyticsOverview extends StatefulWidget {
  const AnalyticsOverview({super.key});

  @override
  State<AnalyticsOverview> createState() => _AnalyticsOverviewState();
}

class _AnalyticsOverviewState extends State<AnalyticsOverview> {
  final AnalyticsService _analyticsService = AnalyticsService();
  
  // Data variables
  int totalUsers = 0;
  int activeUsers = 0;
  int newUsersThisMonth = 0;
  int totalWorkshops = 0;
  int totalCourses = 0;
  double engagementRate = 0.0;
  double attendanceRate = 0.0;
  Map<String, int> weeklyActivity = {};
  List<Map<String, dynamic>> recentActivities = [];
  List<Map<String, dynamic>> monthlyGrowth = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    
    try {
      final results = await Future.wait([
        _analyticsService.getTotalUsers(),
        _analyticsService.getActiveUsers(),
        _analyticsService.getNewUsersThisMonth(),
        _analyticsService.getTotalWorkshops(),
        _analyticsService.getTotalCourses(),
        _analyticsService.getEngagementRate(),
        _analyticsService.getWorkshopAttendanceRate(),
        _analyticsService.getWeeklyActivity(),
        _analyticsService.getRecentActivities(),
        _analyticsService.getMonthlyGrowth(),
      ]);

      setState(() {
        totalUsers = results[0] as int;
        activeUsers = results[1] as int;
        newUsersThisMonth = results[2] as int;
        totalWorkshops = results[3] as int;
        totalCourses = results[4] as int;
        engagementRate = results[5] as double;
        attendanceRate = results[6] as double;
        weeklyActivity = results[7] as Map<String, int>;
        recentActivities = results[8] as List<Map<String, dynamic>>;
        monthlyGrowth = results[9] as List<Map<String, dynamic>>;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error loading data: ${e.toString()}';
      });
      print('Error loading analytics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.cranberry),
            SizedBox(height: 16),
            Text('Loading analytics data...'),
          ],
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.exo2(fontSize: 16, color: AppColors.taupe),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cranberry,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analytics Dashboard',
                    style: GoogleFonts.orbitron(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.cranberry,
                    ),
                  ),
                  Text(
                    'Last updated: ${DateFormat('MMM d, h:mm a').format(DateTime.now())}',
                    style: GoogleFonts.exo2(
                      fontSize: 12,
                      color: AppColors.taupe,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.plum),
                onPressed: _loadData,
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // KPI Cards - Row 1
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Users',
                  totalUsers.toString(),
                  Icons.people_rounded,
                  Colors.blue,
                  '${totalUsers > 0 ? '+' : ''}${totalUsers} members',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Active Users',
                  activeUsers.toString(),
                  Icons.person_rounded,
                  Colors.green,
                  '${engagementRate.toStringAsFixed(1)}% engagement',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // KPI Cards - Row 2
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'New This Month',
                  newUsersThisMonth.toString(),
                  Icons.person_add_rounded,
                  Colors.orange,
                  'New signups',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Workshops',
                  totalWorkshops.toString(),
                  Icons.workspaces_rounded,
                  Colors.purple,
                  '$attendanceRate% attendance',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // KPI Cards - Row 3
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Courses',
                  totalCourses.toString(),
                  Icons.school_rounded,
                  Colors.teal,
                  'Total courses',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Attendance Rate',
                  '${attendanceRate.toStringAsFixed(1)}%',
                  Icons.trending_up_rounded,
                  attendanceRate > 70 ? Colors.green : Colors.orange,
                  'Workshop attendance',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Engagement Card
          _buildEngagementCard(),
          const SizedBox(height: 24),

          // Monthly Growth Chart
          _buildMonthlyGrowthChart(),
          const SizedBox(height: 24),

          // Weekly Activity Chart
          _buildActivityChart(),
          const SizedBox(height: 24),

          // Recent Activities
          _buildRecentActivities(),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String subtitle) {
    return AnimatedInteractiveCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.cranberry,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.exo2(
              fontSize: 12,
              color: AppColors.taupe,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.exo2(
              fontSize: 10,
              color: AppColors.taupe.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementCard() {
    return AnimatedInteractiveCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'User Engagement',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cranberry,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: engagementRate > 70 ? Colors.green.withOpacity(0.1) : 
                         engagementRate > 40 ? Colors.orange.withOpacity(0.1) : 
                         Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${engagementRate.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: engagementRate > 70 ? Colors.green : 
                           engagementRate > 40 ? Colors.orange : 
                           Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 7,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: engagementRate / 100,
                    backgroundColor: Colors.grey[200],
                    color: engagementRate > 70 ? Colors.green : 
                           engagementRate > 40 ? Colors.orange : 
                           Colors.red,
                    minHeight: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$activeUsers / $totalUsers',
                      style: GoogleFonts.orbitron(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.cranberry,
                      ),
                    ),
                    Text(
                      'active users',
                      style: GoogleFonts.exo2(
                        fontSize: 11,
                        color: AppColors.taupe,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${newUsersThisMonth} new users this month',
                style: GoogleFonts.exo2(
                  fontSize: 11,
                  color: AppColors.taupe,
                ),
              ),
              Text(
                '${totalWorkshops} workshops',
                style: GoogleFonts.exo2(
                  fontSize: 11,
                  color: AppColors.taupe,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyGrowthChart() {
    final maxValue = monthlyGrowth.isEmpty ? 10 : 
                     monthlyGrowth.map((e) => e['count'] as int).reduce((a, b) => a > b ? a : b) + 5;

    return AnimatedInteractiveCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly User Growth',
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.cranberry,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'New users per month (last 6 months)',
            style: GoogleFonts.exo2(
              fontSize: 12,
              color: AppColors.taupe,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < monthlyGrowth.length) {
                          return Text(
                            monthlyGrowth[index]['month'] ?? '',
                            style: GoogleFonts.exo2(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.taupe,
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: GoogleFonts.exo2(
                            fontSize: 10,
                            color: AppColors.taupe,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (monthlyGrowth.length - 1).toDouble(),
                minY: 0,
                maxY: maxValue.toDouble(),
                lineBarsData: [
                  LineChartBarData(
                    spots: monthlyGrowth.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        (entry.value['count'] as int).toDouble(),
                      );
                    }).toList(),
                    isCurved: true,
                    color: AppColors.cranberry,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.cranberry.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChart() {
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxValue = weeklyActivity.values.isEmpty ? 10 : 
                     weeklyActivity.values.reduce((a, b) => a > b ? a : b) + 5;

    final List<Color> barColors = [
      Colors.blue.shade400,
      Colors.blue.shade300,
      Colors.purple.shade300,
      Colors.purple.shade400,
      Colors.deepPurple.shade300,
      Colors.deepPurple.shade400,
      Colors.purple.shade700,
    ];

    return AnimatedInteractiveCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly User Activity',
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.cranberry,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'User logins and actions over the past 7 days',
            style: GoogleFonts.exo2(
              fontSize: 12,
              color: AppColors.taupe,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxValue.toDouble(),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()} activities',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < weekDays.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              weekDays[index],
                              style: GoogleFonts.exo2(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.taupe,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value % 5 == 0) {
                          return Text(
                            value.toInt().toString(),
                            style: GoogleFonts.exo2(
                              fontSize: 10,
                              color: AppColors.taupe,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: weekDays.asMap().entries.map((entry) {
                  final index = entry.key;
                  final day = entry.value;
                  final count = weeklyActivity[day] ?? 0;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: count.toDouble(),
                        color: barColors[index % barColors.length],
                        width: 28,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities() {
    return AnimatedInteractiveCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activities',
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.cranberry,
            ),
          ),
          const SizedBox(height: 12),
          if (recentActivities.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text('No recent activities'),
              ),
            )
          else
            ...recentActivities.map((activity) {
              final timestamp = activity['timestamp'] as DateTime;
              final timeAgo = _getTimeAgo(timestamp);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getActionColor(activity['action']),
                  radius: 18,
                  child: Icon(
                    _getActionIcon(activity['action']),
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                title: Text(
                  activity['userEmail'] ?? 'Unknown User',
                  style: GoogleFonts.exo2(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.cranberry,
                  ),
                ),
                subtitle: Text(
                  '${activity['action']}${activity['details'] != null ? ' - ${activity['details']}' : ''}',
                  style: GoogleFonts.exo2(
                    fontSize: 12,
                    color: AppColors.taupe,
                  ),
                ),
                trailing: Text(
                  timeAgo,
                  style: GoogleFonts.exo2(
                    fontSize: 11,
                    color: AppColors.taupe,
                  ),
                ),
                dense: true,
              );
            }),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inDays > 7) return '${difference.inDays}d ago';
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }

  Color _getActionColor(String action) {
    if (action.contains('Login') || action.contains('Logged')) return Colors.green;
    if (action.contains('Registered')) return Colors.blue;
    if (action.contains('Completed') || action.contains('Finished')) return Colors.purple;
    if (action.contains('Started')) return Colors.orange;
    return Colors.grey;
  }

  IconData _getActionIcon(String action) {
    if (action.contains('Login') || action.contains('Logged')) return Icons.login;
    if (action.contains('Registered')) return Icons.person_add;
    if (action.contains('Completed') || action.contains('Finished')) return Icons.check_circle;
    if (action.contains('Started')) return Icons.play_arrow;
    return Icons.circle;
  }
}