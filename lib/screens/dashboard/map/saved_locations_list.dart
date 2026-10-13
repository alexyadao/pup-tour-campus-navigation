import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:puptourapp/widgets/app_header.dart';
import 'package:puptourapp/widgets/app_navigation_drawer.dart'; // IMPORTED: Your Navigation Drawer
import 'package:puptourapp/screens/dashboard/map/interactive_map.dart';

class SavedLocationsListScreen extends StatefulWidget {
  const SavedLocationsListScreen({super.key});

  @override
  State<SavedLocationsListScreen> createState() =>
      _SavedLocationsListScreenState();
}

class _SavedLocationsListScreenState extends State<SavedLocationsListScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _savedPlaces = [];

  // Constants
  static const Color pupRedDark = Color(0xFF850909);

  @override
  void initState() {
    super.initState();
    _fetchSavedLocations();
  }

  Future<void> _fetchSavedLocations() async {
    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId != null) {
        final data = await supabase
            .from('saved_locations')
            .select('*')
            .eq('user_id', userId)
            .order('saved_at', ascending: false);

        if (mounted) {
          setState(() {
            _savedPlaces = List<Map<String, dynamic>>.from(data);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching saved locations: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteLocation(int id, String name) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('saved_locations').delete().eq('saved_id', id);

      setState(() {
        _savedPlaces.removeWhere((item) => item['saved_id'] == id);
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("$name removed from bookmarks")));
      }
    } catch (e) {
      debugPrint("Error deleting: $e");
    }
  }

  // NAVIGATION LOGIC: This redirects the user to the specific view on the map
  void _navigateToMap(String targetLocation) {
    debugPrint("Navigating to map with target: $targetLocation");

    Navigator.push(
      context,
      MaterialPageRoute(
        // We pass the location name to 'initialTarget'.
        // Ensure your InteractiveMapScreen uses this to move the camera!
        builder: (context) =>
            InteractiveMapScreen(initialTarget: targetLocation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppNavigationDrawer(),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppHeader(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Saved Locations",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: pupRedDark,
                      ),
                    ),
                    Text(
                      "Your bookmarked places",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // List Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: pupRedDark),
                  )
                : _savedPlaces.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "No saved places yet.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _savedPlaces.length,
                    itemBuilder: (context, index) {
                      final place = _savedPlaces[index];

                      // LOGIC CHECK: Use the official location name if available, fallback to custom name
                      // This ensures the map finds the correct coordinate even if the user nicknamed it.
                      final displayName = place['custom_name'] ?? "Unknown";
                      final mapTargetName =
                          place['location_name'] ?? displayName;

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: pupRedDark.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: pupRedDark,
                            ),
                          ),
                          title: Text(
                            displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: const Text(
                            "Tap to view on map",
                            style: TextStyle(fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.grey,
                            ),
                            onPressed: () =>
                                _deleteLocation(place['saved_id'], displayName),
                          ),
                          // 2. REDIRECTION TRIGGER
                          // Passes the correct name to the map screen
                          onTap: () => _navigateToMap(mapTargetName),
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
