import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:puptourapp/routes/app_routes.dart';
import 'package:puptourapp/widgets/app_header.dart';
import 'package:puptourapp/widgets/app_footer.dart';
import 'package:puptourapp/screens/admin/dashboard/navigation_drawer_admin.dart';

// --- Data Model ---
class SavedLocationData {
  final String userName;
  final String locationSaved;
  final String type;
  final String dateTime;

  const SavedLocationData({
    required this.userName,
    required this.locationSaved,
    required this.type,
    required this.dateTime,
  });
}

// --- Sample Data ---
final List<SavedLocationData> sampleSavedLocations = const [
  SavedLocationData(
      userName: 'Juan Dela Cruz',
      locationSaved: 'Main Library',
      type: 'Building',
      dateTime: 'Nov 25, 2025 10:30 AM'),
  SavedLocationData(
      userName: 'Maria Santos',
      locationSaved: 'Coffee Hub',
      type: 'Stall',
      dateTime: 'Nov 25, 2025 9:15 AM'),
  SavedLocationData(
      userName: 'Pedro Reyes',
      locationSaved: 'Engineering Week 2025',
      type: 'Event',
      dateTime: 'Nov 24, 2025 3:45 PM'),
  SavedLocationData(
      userName: 'Ana Garcia',
      locationSaved: 'North Wing Building',
      type: 'Building',
      dateTime: 'Nov 24, 2025 2:20 PM'),
  SavedLocationData(
      userName: 'Carlos Mendoza',
      locationSaved: 'PUP Canteen A',
      type: 'Stall',
      dateTime: 'Nov 24, 2025 12:00 PM'),
  SavedLocationData(
      userName: 'Lisa Cruz',
      locationSaved: 'Gymnasium',
      type: 'Building',
      dateTime: 'Nov 23, 2025 4:30 PM'),
];

// --- Type Indicator ---
class TypeIndicator extends StatelessWidget {
  final String type;

  const TypeIndicator({required this.type, super.key});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (type) {
      case 'Building':
        color = Colors.blue.shade700;
        break;
      case 'Stall':
        color = Colors.green.shade700;
        break;
      case 'Event':
        color = Colors.purple.shade700;
        break;
      default:
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
        type,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// --- Main Screen ---
class AdminSavedLocationsScreen extends StatelessWidget {
  const AdminSavedLocationsScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  DataRow _buildDataRow(SavedLocationData location, BuildContext context) {
    return DataRow(
      cells: [
        DataCell(Text(location.userName)),
        DataCell(Text(location.locationSaved)),
        DataCell(TypeIndicator(type: location.type)),
        DataCell(Text(location.dateTime)),
      ],
    );
  }

  Widget _buildPaginationSection(double tableWidth) {
    const String statusText = 'Showing 1 to 6 of 3,421 saved locations';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: SizedBox(
        width: tableWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              statusText,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black54,
                    side: const BorderSide(color: Colors.black26),
                  ),
                  child: const Text("Previous"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8B0000),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Next"),
                ),
              ],
            ),
          ],
        ),
      ),
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
      drawer: NavigationDrawerAdmin(onSignOut: () => _signOut(context)),

      // *** FIXED LAYOUT: ONE SCROLL VIEW ***
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saved Locations',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manage all saved locations',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // DataTable inside horizontal scroll
            LayoutBuilder(
              builder: (context, constraints) {
                const double minWidth = 550;
                final tableWidth =
                constraints.maxWidth > minWidth ? constraints.maxWidth : minWidth;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: Column(
                      children: [
                        DataTable(
                          columnSpacing: 30,
                          headingRowHeight: 50,
                          dataRowHeight: 50,
                          headingRowColor: WidgetStateProperty.all(Colors.white),
                          columns: const [
                            DataColumn(label: Text('User Name', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Location Saved', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Date & Time', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: sampleSavedLocations
                              .map((loc) => _buildDataRow(loc, context))
                              .toList(),
                        ),

                        const Divider(height: 1, color: Colors.black12),

                        _buildPaginationSection(tableWidth),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 190),

            // Footer (scrolls with content, stays bottom)
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
