import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:puptourapp/widgets/app_header.dart';
import 'package:puptourapp/screens/admin/events/admin_event_details.dart';
import 'package:puptourapp/screens/admin/dashboard/navigation_drawer_admin.dart'; // Import Drawer
import 'package:puptourapp/routes/app_routes.dart'; // Import Routes

class AdminPendingEventsScreen extends StatefulWidget {
  const AdminPendingEventsScreen({super.key});

  @override
  State<AdminPendingEventsScreen> createState() =>
      _AdminPendingEventsScreenState();
}

class _AdminPendingEventsScreenState extends State<AdminPendingEventsScreen> {
  static const Color pupRedDark = Color(0xFF850909);
  List<Map<String, dynamic>> _pendingEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPendingEvents();
  }

  Future<void> _fetchPendingEvents() async {
    try {
      final data = await Supabase.instance.client
          .from('events')
          .select()
          .eq('status', 'Pending')
          .order('start_time', ascending: true);

      if (mounted) {
        setState(() {
          _pendingEvents = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching pending events: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Sign Out Logic (Required for Drawer) ---
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
          preferredSize: Size.fromHeight(60), child: AppHeader()),
      // --- ADDED DRAWER ---
      drawer: NavigationDrawerAdmin(onSignOut: _signOut),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text("Pending Events",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: pupRedDark)),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: pupRedDark))
                : _pendingEvents.isEmpty
                    ? const Center(child: Text("No pending events."))
                    : ListView.builder(
                        itemCount: _pendingEvents.length,
                        itemBuilder: (context, index) {
                          final event = _pendingEvents[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            child: ListTile(
                              title: Text(event['title'] ?? 'No Title',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(event['status'] ?? 'Unknown'),
                              trailing:
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AdminEventDetailsScreen(
                                            eventData: event),
                                  ),
                                );
                                _fetchPendingEvents(); // Refresh on return
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
