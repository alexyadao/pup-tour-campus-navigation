import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:puptourapp/widgets/app_header.dart';
import 'package:puptourapp/screens/admin/verification/verification_details_screen.dart';
import 'package:puptourapp/screens/admin/dashboard/navigation_drawer_admin.dart'; // Import Drawer
import 'package:puptourapp/routes/app_routes.dart'; // Import Routes

class AdminVerificationRequestsScreen extends StatefulWidget {
  const AdminVerificationRequestsScreen({super.key});

  @override
  State<AdminVerificationRequestsScreen> createState() =>
      _AdminVerificationRequestsScreenState();
}

class _AdminVerificationRequestsScreenState
    extends State<AdminVerificationRequestsScreen> {
  static const Color pupRedDark = Color(0xFF850909);
  List<Map<String, dynamic>> _pendingRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPendingRequests();
  }

  // --- Fetch Pending Users ---
  Future<void> _fetchPendingRequests() async {
    try {
      final data = await Supabase.instance.client
          .from('users')
          .select('user_id, first_name, last_name, student_number, created_at')
          .eq('verification_status', 'Pending')
          .order('created_at', ascending: false); // Newest first

      if (mounted) {
        setState(() {
          _pendingRequests = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching requests: $e");
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
        preferredSize: Size.fromHeight(60),
        child: AppHeader(),
      ),
      // --- ADDED DRAWER ---
      drawer: NavigationDrawerAdmin(onSignOut: _signOut),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "Pending Verifications",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: pupRedDark,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: pupRedDark))
                : _pendingRequests.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 10),
                            const Text("No pending requests",
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _pendingRequests.length,
                        itemBuilder: (context, index) {
                          final user = _pendingRequests[index];
                          final name =
                              "${user['first_name']} ${user['last_name']}";
                          final studentNo = user['student_number'] ?? "No ID";

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              leading: CircleAvatar(
                                backgroundColor: Colors.orange.withOpacity(0.2),
                                child: const Icon(Icons.priority_high,
                                    color: Colors.orange),
                              ),
                              title: Text(
                                name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text("Student #: $studentNo"),
                              trailing: const Icon(Icons.arrow_forward_ios,
                                  size: 16, color: Colors.grey),
                              onTap: () async {
                                // Navigate to Details Screen
                                // We await the result so we can refresh the list when we come back
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        VerificationDetailsScreen(
                                      userData:
                                          user, // Pass the whole user object
                                    ),
                                  ),
                                );
                                // Refresh list after returning (in case they approved/rejected someone)
                                _fetchPendingRequests();
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
