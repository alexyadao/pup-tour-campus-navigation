import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:puptourapp/routes/app_routes.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:puptourapp/widgets/app_header.dart';
import 'package:puptourapp/widgets/app_footer.dart';
import 'package:puptourapp/screens/admin/dashboard/navigation_drawer_admin.dart';
import 'package:puptourapp/screens/admin/verification/admin_verification_requests.dart';
import 'package:puptourapp/screens/admin/events/admin_pending_events.dart';

// --- Dashboard Stat Card (Unchanged) ---
class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtext;
  final Widget iconWidget;

  const DashboardStatCard({
    required this.title,
    required this.value,
    required this.subtext,
    required this.iconWidget,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B0000))),
                const SizedBox(height: 4),
                Text(subtext,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            iconWidget,
          ],
        ),
      ),
    );
  }
}

// --- Quick Action Card (Unchanged) ---
class QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget icon;
  final VoidCallback onTap;

  const QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              icon,
            ],
          ),
        ),
      ),
    );
  }
}

// --- User Growth Chart (Dynamic) ---
class UserGrowthChart extends StatelessWidget {
  final List<FlSpot> spots;

  const UserGrowthChart({required this.spots, super.key});

  @override
  Widget build(BuildContext context) {
    // Calculate dynamic maxY for the chart so lines don't go off screen
    double maxY = 10;
    if (spots.isNotEmpty) {
      maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 5;
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('User Growth (Monthly)',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              width: double.infinity,
              child: spots.isEmpty
                  ? const Center(child: Text("No user data yet"))
                  : LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const style =
                                    TextStyle(color: Colors.grey, fontSize: 10);
                                const months = [
                                  '',
                                  'Jan',
                                  'Feb',
                                  'Mar',
                                  'Apr',
                                  'May',
                                  'Jun',
                                  'Jul',
                                  'Aug',
                                  'Sep',
                                  'Oct',
                                  'Nov',
                                  'Dec'
                                ];
                                int index = value.toInt();
                                if (index > 0 && index < months.length) {
                                  return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      space: 8,
                                      child: Text(months[index], style: style));
                                }
                                return Container();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval:
                                  maxY > 20 ? maxY / 5 : 1, // Dynamic interval
                              getTitlesWidget: (value, meta) {
                                const style =
                                    TextStyle(color: Colors.grey, fontSize: 10);
                                if (value % 1 == 0) {
                                  return Text(value.toInt().toString(),
                                      style: style);
                                }
                                return Container();
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 1,
                        maxX: 12,
                        minY: 0,
                        maxY: maxY,
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: const Color(0xFF8B0000),
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, bar, index) =>
                                  FlDotCirclePainter(
                                      radius: 4,
                                      color: const Color(0xFF8B0000),
                                      strokeColor: Colors.white,
                                      strokeWidth: 2),
                            ),
                            belowBarData: BarAreaData(
                                show: true,
                                color:
                                    const Color(0xFF8B0000).withOpacity(0.3)),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- NEW: Support Ticket Chart (Real Data) ---
class SupportTicketChart extends StatelessWidget {
  final int openCount;
  final int pendingCount;
  final int resolvedCount;

  const SupportTicketChart({
    required this.openCount,
    required this.pendingCount,
    required this.resolvedCount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final total = openCount + pendingCount + resolvedCount;

    if (total == 0) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: const Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: Text("No support tickets recorded yet.")),
        ),
      );
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Support Ticket Status',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 4),
            Text('Total Concerns: $total',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              width: double.infinity,
              child: AspectRatio(
                aspectRatio: 1.0,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: [
                      // OPEN (Red)
                      PieChartSectionData(
                        color: const Color(0xFFD32F2F),
                        value: openCount.toDouble(),
                        title: '$openCount',
                        radius: 60,
                        titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        badgeWidget: _Badge('Open', const Color(0xFFD32F2F)),
                        badgePositionPercentageOffset: 1.3,
                      ),
                      // PENDING (Orange)
                      PieChartSectionData(
                        color: const Color(0xFFFFA000),
                        value: pendingCount.toDouble(),
                        title: '$pendingCount',
                        radius: 60,
                        titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        badgeWidget: _Badge('Pending', const Color(0xFFFFA000)),
                        badgePositionPercentageOffset: 1.3,
                      ),
                      // RESOLVED (Green)
                      PieChartSectionData(
                        color: const Color(0xFF388E3C),
                        value: resolvedCount.toDouble(),
                        title: '$resolvedCount',
                        radius: 60,
                        titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        badgeWidget: _Badge('Done', const Color(0xFF388E3C)),
                        badgePositionPercentageOffset: 1.3,
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

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 2)
        ],
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }
}

// --- Admin Dashboard Screen ---
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final supabase = Supabase.instance.client;

  int _userCount = 0;
  int _landmarkCount = 0;
  int _eventCount = 0;
  int _interactionCount = 0;
  
  // Ticket Stats
  int _ticketOpen = 0;
  int _ticketPending = 0;
  int _ticketResolved = 0;

  List<FlSpot> _growthSpots = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRealData();
  }

  Future<void> _fetchRealData() async {
    try {
      // 1. Fetch Users Data (Count, Interactions, Growth)
      final usersResponse = await supabase
          .from('users')
          .select('created_at, map_view_count');
      final usersList = usersResponse as List<dynamic>;

      // A. Count
      final userCount = usersList.length;

      // B. Interactions (Sum of map_view_count)
      final interactionCount = usersList.fold<int>(
          0, (sum, user) => sum + ((user['map_view_count'] as int?) ?? 0));

      // C. Growth Graph
      final spots = _calculateGrowthSpots(usersList);

      // 2. Fetch Landmarks Count
      final landmarksResponse = await supabase.from('landmarks').count();
      final landmarkCount = landmarksResponse;

      // 3. Fetch Events Count
      final eventsResponse = await supabase.from('events').count();
      final eventCount = eventsResponse;

      // 4. Fetch Support Tickets
      // Assumes table 'support_tickets' with a 'status' column
      final ticketsResponse = await supabase.from('support_tickets').select('status');
      final ticketsList = ticketsResponse as List<dynamic>;

      int open = 0;
      int pending = 0;
      int resolved = 0;

      for (var ticket in ticketsList) {
        final status = (ticket['status'] as String? ?? 'open').toLowerCase();
        
        if (status.contains('done') || status.contains('closed') || status.contains('resolved')) {
          resolved++;
        } else if (status.contains('pending') || status.contains('progress')) {
          pending++;
        } else {
          open++;
        }
      }

      if (mounted) {
        setState(() {
          _userCount = userCount;
          _interactionCount = interactionCount;
          _growthSpots = spots;
          _landmarkCount = landmarkCount;
          _eventCount = eventCount;
          
          _ticketOpen = open;
          _ticketPending = pending;
          _ticketResolved = resolved;
          
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("ADMIN_DEBUG: Error fetching data: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<FlSpot> _calculateGrowthSpots(List<dynamic> users) {
    Map<int, int> monthlyCounts = {};

    for (var user in users) {
      if (user['created_at'] != null) {
        final createdDate = DateTime.parse(user['created_at']);
        final month = createdDate.month;
        monthlyCounts[month] = (monthlyCounts[month] ?? 0) + 1;
      }
    }

    List<FlSpot> spots = [];
    double runningTotal = 0;
    final currentMonth = DateTime.now().month;

    for (int i = 1; i <= 12; i++) {
      // Only plot up to the current month for realism
      if (i <= currentMonth) {
        runningTotal += (monthlyCounts[i] ?? 0);
        spots.add(FlSpot(i.toDouble(), runningTotal));
      }
    }
    return spots;
  }

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error signing out: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppHeader(),
      ),
      drawer: NavigationDrawerAdmin(onSignOut: _signOut),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF8B0000)))
          : LayoutBuilder(builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Dashboard',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)),
                        ),

                        // --- LIVE STAT CARDS ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              DashboardStatCard(
                                title: 'Total Registered Users',
                                value: '$_userCount',
                                subtext: 'Total accounts in database',
                                iconWidget: const ImageIcon(
                                  AssetImage(
                                      'assets/admin_icons/profile_red.png'),
                                  size: 40,
                                  color: Color(0xFF8B0000),
                                ),
                              ),
                              DashboardStatCard(
                                title: 'Total Landmarks',
                                value: '$_landmarkCount',
                                subtext: 'Registered map locations',
                                iconWidget: const ImageIcon(
                                  AssetImage(
                                      'assets/admin_icons/building_red.png'),
                                  size: 40,
                                  color: Color(0xFF8B0000),
                                ),
                              ),
                              DashboardStatCard(
                                title: 'Total Events',
                                value: '$_eventCount',
                                subtext: 'Posted campus activities',
                                iconWidget: const ImageIcon(
                                  AssetImage('assets/admin_icons/event.png'),
                                  size: 40,
                                  color: Color(0xFF8B0000),
                                ),
                              ),
                              DashboardStatCard(
                                title: 'Total Map Interactions',
                                value: '$_interactionCount',
                                subtext: 'Total tour logs recorded',
                                iconWidget: const ImageIcon(
                                  AssetImage('assets/admin_icons/map_red.png'),
                                  size: 40,
                                  color: Color(0xFF8B0000),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('Quick Actions',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87)),
                        ),
                        const SizedBox(height: 12),

                        // --- QUICK ACTIONS ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              QuickActionCard(
                                title: 'Verify Students',
                                subtitle: 'Review pending ID verifications',
                                icon: Icon(Icons.verified_user,
                                    size: 32,
                                    color: const Color(0xFF8B0000)
                                        .withOpacity(0.7)),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const AdminVerificationRequestsScreen()));
                                },
                              ),
                              QuickActionCard(
                                title: 'Review Events',
                                subtitle: 'Approve or reject student events',
                                icon: Icon(Icons.event_available,
                                    size: 32,
                                    color: const Color(0xFF8B0000)
                                        .withOpacity(0.7)),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const AdminPendingEventsScreen()));
                                },
                              ),
                              QuickActionCard(
                                title: 'Add Landmark',
                                subtitle: 'Register a new map location',
                                icon: Icon(Icons.add_location_alt,
                                    size: 32,
                                    color: const Color(0xFF8B0000)
                                        .withOpacity(0.7)),
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, AppRoutes.adminBuildings);
                                },
                              ),
                              QuickActionCard(
                                title: 'View Users',
                                subtitle: 'Manage all accounts on the platform',
                                icon: Icon(Icons.group,
                                    size: 32,
                                    color: const Color(0xFF8B0000)
                                        .withOpacity(0.7)),
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, AppRoutes.adminUser);
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // --- LIVE GRAPHS SECTION ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: UserGrowthChart(spots: _growthSpots),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                // This is the new Real-Time Ticket Chart
                                child: SupportTicketChart(
                                  openCount: _ticketOpen,
                                  pendingCount: _ticketPending,
                                  resolvedCount: _ticketResolved,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),
                        const AppFooter(),
                      ],
                    ),
                  ),
                ),
              );
            }),
    );
  }
}