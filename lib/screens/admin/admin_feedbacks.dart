import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:puptourapp/routes/app_routes.dart';
import 'package:puptourapp/widgets/app_header.dart';
import 'package:puptourapp/widgets/app_footer.dart';
import 'package:puptourapp/screens/admin/dashboard/navigation_drawer_admin.dart';

// --- Data Model ---
class FeedbackData {
  final String id;
  final String userName;
  final String subject;
  final String category;
  final String dateReceived;
  final String status;

  const FeedbackData({
    required this.id,
    required this.userName,
    required this.subject,
    required this.category,
    required this.dateReceived,
    required this.status,
  });
}

// --- Sample Feedbacks ---
final List<FeedbackData> sampleFeedbacks = const [
  FeedbackData(
      id: 'FB001',
      userName: 'Juan Dela Cruz',
      subject: 'Error in routing to Library',
      category: 'Bug Report',
      dateReceived: '1 hour ago',
      status: 'New'),
  FeedbackData(
      id: 'FB002',
      userName: 'Maria Santos',
      subject: 'Suggestion for dark mode feature',
      category: 'Suggestion',
      dateReceived: '1 day ago',
      status: 'In Progress'),
  FeedbackData(
      id: 'FB003',
      userName: 'Pedro Reyes',
      subject: 'Question about map data updates',
      category: 'Inquiry',
      dateReceived: '2 days ago',
      status: 'Resolved'),
  FeedbackData(
      id: 'FB004',
      userName: 'Ana Garcia',
      subject: 'Map marker incorrect for Gymnasium',
      category: 'Bug Report',
      dateReceived: '3 days ago',
      status: 'New'),
  // Added extra data to ensure scrolling is necessary
  FeedbackData(id: 'FB005', userName: 'Alex Tan', subject: 'Loading time slow', category: 'Bug Report', dateReceived: '4 days ago', status: 'New'),
  FeedbackData(id: 'FB006', userName: 'Ben Lee', subject: 'Add more food stalls', category: 'Suggestion', dateReceived: '5 days ago', status: 'In Progress'),
  FeedbackData(id: 'FB007', userName: 'Cathy Wu', subject: 'Map zoom glitch', category: 'Bug Report', dateReceived: '6 days ago', status: 'Resolved'),
  FeedbackData(id: 'FB008', userName: 'David Kim', subject: 'Missing landmark: Field', category: 'Inquiry', dateReceived: '7 days ago', status: 'New'),
  FeedbackData(id: 'FB009', userName: 'Eva Chen', subject: 'Wrong building name', category: 'Bug Report', dateReceived: '8 days ago', status: 'In Progress'),
  FeedbackData(id: 'FB010', userName: 'Frank Liu', subject: 'Feature: Save routes', category: 'Suggestion', dateReceived: '9 days ago', status: 'New'),
];

// --- Status Indicator ---
class StatusIndicator extends StatelessWidget {
  final String status;
  const StatusIndicator({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (status == 'New') {
      color = Colors.red.shade700;
    } else if (status == 'In Progress') {
      color = Colors.orange.shade700;
    } else {
      color = Colors.green.shade700;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// --- Main Admin Feedback Screen ---
class AdminFeedbacksScreen extends StatelessWidget {
  const AdminFeedbacksScreen({super.key});

  // --- Sign-out logic (Unchanged) ---
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

  // --- Show Feedback Details Dialog (Unchanged) ---
  void _showFeedbackDetails(BuildContext context, FeedbackData feedback) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Feedback Details: ${feedback.subject}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('ID: ${feedback.id}'),
                Text('User: ${feedback.userName}'),
                Text('Category: ${feedback.category}'),
                Text('Date: ${feedback.dateReceived}'),
                const Divider(),
                const Text('Message (Placeholder for actual content):'),
                const SizedBox(height: 8),
                const Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement Mark as Resolved/In Progress logic
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Change Status', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // --- Build DataRow (Unchanged) ---
  DataRow _buildDataRow(FeedbackData feedback, BuildContext context) {
    return DataRow(
      cells: [
        DataCell(Text(feedback.id)),
        DataCell(Text(feedback.userName)),
        DataCell(Text(feedback.subject)),
        DataCell(Text(feedback.category)),
        DataCell(Text(feedback.dateReceived)),
        DataCell(StatusIndicator(status: feedback.status)),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, size: 18, color: Colors.blue),
              onPressed: () => _showFeedbackDetails(context, feedback),
              tooltip: 'View Details',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 18, color: Colors.red),
              onPressed: () {
                // TODO: Implement Delete Feedback action
              },
              tooltip: 'Delete Feedback',
            ),
          ],
        )),
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
      // --- MODIFICATION: Replace Stack and Expanded with SingleChildScrollView ---
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(24.0),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Feedback and Support',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Manage user bug reports, suggestions, and inquiries.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 300,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search by Name',
                              prefixIcon: Icon(Icons.search, color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.upload, size: 20, color: Colors.white),
                            label: const Text(
                              'Export CSV',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B0000),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Data Table Container
            // The DataTable now just needs to be within a horizontal scroll view
            Padding(
              padding: const EdgeInsets.all(0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 30,
                  dataRowMinHeight: 50,
                  dataRowMaxHeight: 50,
                  headingRowColor: WidgetStateProperty.resolveWith((states) => Colors.grey.shade200),
                  columns: const [
                    DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('User Name', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Date Received', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: sampleFeedbacks.map((f) => _buildDataRow(f, context)).toList(),
                ),
              ),
            ),

            // Spacing before the footer
            const SizedBox(height: 180),

            // Movable Footer (Now the last child of the SingleChildScrollView)
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}