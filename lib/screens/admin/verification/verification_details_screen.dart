import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:puptourapp/widgets/app_header.dart';
import 'package:puptourapp/screens/admin/dashboard/navigation_drawer_admin.dart'; // Import Drawer
import 'package:puptourapp/routes/app_routes.dart'; // Import Routes

class VerificationDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const VerificationDetailsScreen({super.key, required this.userData});

  @override
  State<VerificationDetailsScreen> createState() =>
      _VerificationDetailsScreenState();
}

class _VerificationDetailsScreenState extends State<VerificationDetailsScreen> {
  static const Color pupRedDark = Color(0xFF850909);
  bool _isProcessing = false;
  String? _idImageUrl;
  bool _imageLoadingError = false;

  @override
  void initState() {
    super.initState();
    _fetchIdImage();
  }

  // --- Fetch the specific ID image for this user ---
  Future<void> _fetchIdImage() async {
    try {
      final data = await Supabase.instance.client
          .from('users')
          .select('id_image_url')
          .eq('user_id', widget.userData['user_id'])
          .single();

      String? rawPath = data['id_image_url'];

      if (rawPath != null) {
        // --- SMART PATH HANDLING ---
        String cleanPath = rawPath;

        // If it looks like a full URL, try to extract just the filename
        if (rawPath.contains('/id_cards/')) {
          final parts = rawPath.split('/id_cards/');
          if (parts.length > 1) {
            cleanPath = parts[1];
          }
        }

        // Remove any URL encoding (e.g. %20 -> space)
        cleanPath = Uri.decodeComponent(cleanPath);

        try {
          // 1. Try to get a Signed URL (Secure way)
          final signedUrl = await Supabase.instance.client.storage
              .from('id_cards')
              .createSignedUrl(cleanPath, 3600);

          if (mounted) {
            setState(() {
              _idImageUrl = signedUrl;
              _imageLoadingError = false;
            });
          }
        } catch (storageError) {
          debugPrint("Signed URL failed for '$cleanPath': $storageError");

          // 2. Fallback to raw URL
          if (mounted) {
            setState(() {
              _idImageUrl = rawPath;
              _imageLoadingError = false;
            });
          }
        }
      } else {
        if (mounted) setState(() => _imageLoadingError = true);
      }
    } catch (e) {
      debugPrint("Error fetching ID image: $e");
      if (mounted) setState(() => _imageLoadingError = true);
    }
  }

  // --- Approve / Reject Logic ---
  Future<void> _updateStatus(String status) async {
    setState(() => _isProcessing = true);

    try {
      // 1. Attempt Update
      final response = await Supabase.instance.client
          .from('users')
          .update({'verification_status': status})
          .eq('user_id', widget.userData['user_id'])
          .select(); // <--- IMPORTANT: Request return data to confirm update

      // 2. Check if update actually happened
      if (response.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("User marked as $status"),
              backgroundColor: status == 'Verified' ? Colors.green : Colors.red,
            ),
          );
          Navigator.pop(context); // Go back to list
        }
      } else {
        // Response empty = RLS Blocked the update (Permission Denied)
        throw "Update blocked. Are you an Admin?";
      }
    } catch (e) {
      debugPrint("Status Update Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Update Failed: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
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
    final name =
        "${widget.userData['first_name']} ${widget.userData['last_name']}";
    final studentNo = widget.userData['student_number'] ?? "N/A";

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
            // Header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  "Review Request",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: pupRedDark),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // User Info Card
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Applicant Details",
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text("Student #: $studentNo",
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // ID Photo Section
            const Text("Submitted ID Photo",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _idImageUrl == null
                  ? _imageLoadingError
                      ? const Center(
                          child: Text(
                              "Error loading image. File may be missing or permissions blocked."))
                      : const Center(
                          child: CircularProgressIndicator(color: pupRedDark))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        _idImageUrl!,
                        fit: BoxFit
                            .contain, // Contain ensures the whole ID is visible
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                              child:
                                  CircularProgressIndicator(color: pupRedDark));
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                                child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image,
                                size: 50, color: Colors.grey),
                            Text("Could not load image"),
                          ],
                        )),
                      ),
                    ),
            ),

            const SizedBox(height: 40),

            // Action Buttons
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
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text("Reject",
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _isProcessing ? null : () => _updateStatus('Verified'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text("Approve",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
