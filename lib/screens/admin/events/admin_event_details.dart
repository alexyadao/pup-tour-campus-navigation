import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:puptourapp/widgets/app_header.dart';
import 'package:puptourapp/screens/admin/dashboard/navigation_drawer_admin.dart'; // Import Drawer
import 'package:puptourapp/routes/app_routes.dart'; // Import Routes

class AdminEventDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> eventData;

  const AdminEventDetailsScreen({super.key, required this.eventData});

  @override
  State<AdminEventDetailsScreen> createState() =>
      _AdminEventDetailsScreenState();
}

class _AdminEventDetailsScreenState extends State<AdminEventDetailsScreen> {
  static const Color pupRedDark = Color(0xFF850909);
  bool _isProcessing = false;

  Future<void> _updateStatus(String status) async {
    setState(() => _isProcessing = true);
    try {
      await Supabase.instance.client.from('events').update(
          {'status': status}).eq('event_id', widget.eventData['event_id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Event marked as $status"),
            backgroundColor: status == 'Approved' ? Colors.green : Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      setState(() => _isProcessing = false);
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
    final event = widget.eventData;
    final imagePath = event['image_url'];
    final start = DateTime.parse(event['start_time']);
    final end = DateTime.parse(event['end_time']);
    final dateStr = DateFormat('MMMM d, yyyy').format(start);
    final timeStr =
        "${DateFormat('h:mm a').format(start)} - ${DateFormat('h:mm a').format(end)}";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(60), child: AppHeader()),
      // --- ADDED DRAWER ---
      drawer: NavigationDrawerAdmin(onSignOut: _signOut),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text("Review Event",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: pupRedDark)),
              ],
            ),
            const SizedBox(height: 20),

            // Image Preview
            if (imagePath != null && imagePath.startsWith('http'))
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imagePath,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Center(
                        child: Icon(Icons.broken_image,
                            size: 50, color: Colors.grey)),
                  ),
                ),
              )
            else
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Center(child: Text("No Image Uploaded")),
              ),

            const SizedBox(height: 20),

            Text(event['title'] ?? 'No Title',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text("$dateStr  |  $timeStr",
                style: const TextStyle(fontSize: 16, color: Colors.grey)),

            const Divider(height: 30),

            const Text("Description",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(event['description'] ?? "No description provided.",
                style: const TextStyle(fontSize: 16, height: 1.5)),

            const SizedBox(height: 40),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isProcessing ? null : () => _updateStatus('Rejected'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text("Reject",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _isProcessing ? null : () => _updateStatus('Approved'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text("Approve",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
