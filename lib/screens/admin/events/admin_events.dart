import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:puptourapp/routes/app_routes.dart';
import 'package:intl/intl.dart'; // Needed for date formatting

// Required Custom Widget Imports
import 'package:puptourapp/widgets/app_header.dart';
import 'package:puptourapp/screens/admin/dashboard/navigation_drawer_admin.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  final _supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Cache for landmark names so we show "Main Bldg" instead of "12"
  Map<int, String> _landmarkNames = {};

  @override
  void initState() {
    super.initState();
    _fetchLandmarkNames();
  }

  // Fetch all landmarks once to create a lookup map (ID -> Name)
  Future<void> _fetchLandmarkNames() async {
    try {
      final data = await _supabase.from('landmarks').select('landmark_id, name');
      final Map<int, String> mapping = {};
      for (var item in data) {
        mapping[item['landmark_id'] as int] = item['name'] as String;
      }
      if (mounted) {
        setState(() {
          _landmarkNames = mapping;
        });
      }
    } catch (e) {
      debugPrint('Error fetching landmarks: $e');
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await _supabase.auth.signOut();
      if (context.mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- Delete using the correct 'event_id' ---
  Future<void> _deleteEvent(int eventId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Updated to use 'event_id'
        await _supabase.from('events').delete().eq('event_id', eventId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  // --- Stream using 'event_id' as primary key ---
  Stream<List<Map<String, dynamic>>> _eventsStream() {
    return _supabase
        .from('events')
        .stream(primaryKey: ['event_id']) // Correct PK
        .order('start_time', ascending: true);
  }

  DataRow _buildDataRow(Map<String, dynamic> event, BuildContext context) {
    // 1. Title
    final title = event['title'] ?? 'No Title';
    
    // 2. Organizer (Showing ID or generic text since we don't have users table details)
    // We truncate the UUID to make it look cleaner
    final orgId = event['organizer_id'].toString();
    final shortOrg = orgId.length > 8 ? 'User...${orgId.substring(0,6)}' : orgId;

    // 3. Location (Map ID to Name)
    final landmarkId = event['landmark_id'] as int?;
    final locationName = _landmarkNames[landmarkId] ?? 'Unknown Location';

    // 4. Date & Time (Split start_time)
    String dateStr = 'TBA';
    String timeStr = 'TBA';
    if (event['start_time'] != null) {
      final startTime = DateTime.parse(event['start_time']).toLocal();
      dateStr = DateFormat('MMM dd, yyyy').format(startTime);
      timeStr = DateFormat('hh:mm a').format(startTime);
    }

    // 5. Status
    final status = event['status'] ?? 'Pending';
    final id = event['event_id']; // Correct PK

    return DataRow(
      cells: [
        DataCell(Text(title, style: const TextStyle(fontWeight: FontWeight.w500))),
        DataCell(Text(shortOrg, style: const TextStyle(fontSize: 12))),
        DataCell(Text(locationName)),
        DataCell(Text(dateStr)),
        DataCell(Text(timeStr)),
        DataCell(StatusIndicator(status: status.toString())),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: () => _deleteEvent(id)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppHeader(),
      ),
      drawer: NavigationDrawerAdmin(
        onSignOut: () => _signOut(context),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header ---
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Event Management',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Search by Title',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- Table ---
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _eventsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(color: Color(0xFF8B0000)),
                  ));
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final events = snapshot.data ?? [];
                
                // Client-side filtering
                final filteredEvents = events.where((event) {
                  final title = (event['title'] ?? '').toString().toLowerCase();
                  return title.contains(_searchQuery);
                }).toList();

                if (filteredEvents.isEmpty) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text("No events found."),
                  ));
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20,
                    headingRowColor: WidgetStateProperty.resolveWith(
                        (states) => Colors.grey.shade200),
                    columns: const [
                      DataColumn(label: Text('Title', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Organizer', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Location', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: filteredEvents
                        .map((event) => _buildDataRow(event, context))
                        .toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// --- Status Widget ---
class StatusIndicator extends StatelessWidget {
  final String status;
  const StatusIndicator({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    Color color;
    final s = status.toLowerCase();
    if (s == 'active' || s == 'approved') {
      color = Colors.green.shade700;
    } else if (s == 'pending') {
      color = Colors.orange.shade700;
    } else {
      color = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}