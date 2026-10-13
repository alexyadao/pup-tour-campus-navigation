import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:puptourapp/routes/app_routes.dart';
import 'package:puptourapp/widgets/app_header.dart';
import 'package:puptourapp/widgets/app_footer.dart';
import 'package:puptourapp/screens/admin/dashboard/navigation_drawer_admin.dart';

// --- Data Model ---
class UserData {
  final String id;
  final String name;
  final String studentNumber;
  final String email;
  final String department;
  final int savedLocations;
  final String lastActive;
  final String status;

  const UserData({
    required this.id,
    required this.name,
    required this.studentNumber,
    required this.email,
    required this.department,
    required this.savedLocations,
    required this.lastActive,
    required this.status,
  });
}

// --- Status Indicator Widget ---
class StatusIndicator extends StatelessWidget {
  final String status;
  const StatusIndicator({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    Color color = (status == 'Active')
        ? Colors.green.shade700
        : Colors.red.shade700;

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

// --- Main Admin User Account Screen ---
class AdminUserAccountScreen extends StatefulWidget {
  const AdminUserAccountScreen({super.key});

  @override
  State<AdminUserAccountScreen> createState() => _AdminUserAccountScreenState();
}

class _AdminUserAccountScreenState extends State<AdminUserAccountScreen> {
  // Variables
  List<UserData> _users = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- 1. Fetch Users from Supabase ---
  Future<void> _fetchUsers([String? query]) async {
    setState(() => _isLoading = true);

    try {
      final client = Supabase.instance.client;
      var dbQuery = client.from('users').select();

      // Apply Search Filter
      if (query != null && query.isNotEmpty) {
        dbQuery = dbQuery.or(
          'first_name.ilike.%$query%,last_name.ilike.%$query%,student_id.ilike.%$query%',
        );
      }

      final List<dynamic> response = await dbQuery;

      final List<UserData> loadedUsers = response.map((data) {
        String fName = data['first_name'] ?? '';
        String lName = data['last_name'] ?? '';
        String fullName = '$fName $lName'.trim();
        if (fullName.isEmpty) fullName = 'No Name';

        return UserData(
          id: data['user_id'].toString(),
          name: fullName,
          studentNumber: data['student_id'] ?? 'N/A',
          email: data['email'] ?? '',
          department: data['department'] ?? 'Unassigned',
          savedLocations: 0,
          lastActive: data['last_active'] != null
              ? DateTime.parse(data['last_active']).toString().split(' ')[0]
              : 'N/A',
          status: data['status'] ?? 'Active',
        );
      }).toList();

      if (mounted) {
        setState(() {
          _users = loadedUsers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        print('Error fetch: $e');
      }
    }
  }

  // --- 2. Delete User Function ---
  Future<void> _deleteUser(String userId) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text('Are you sure you want to delete this user?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      await Supabase.instance.client
          .from('users')
          .delete()
          .eq('user_id', userId);
      _fetchUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting: $e')));
      }
    }
  }

  // --- 3. CSV Export Function ---
  Future<void> _exportCSV() async {
    if (_users.isEmpty) return;

    try {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }

      List<List<dynamic>> rows = [];
      rows.add([
        'Name',
        'Student Number',
        'Email',
        'Department',
        'Last Active',
        'Status',
      ]);

      for (var user in _users) {
        rows.add([
          user.name,
          user.studentNumber,
          user.email,
          user.department,
          user.lastActive,
          user.status,
        ]);
      }

      String csvData = const ListToCsvConverter().convert(rows);
      final directory = await getApplicationDocumentsDirectory();
      final path = "${directory.path}/puptour_users_export.csv";
      final File file = File(path);
      await file.writeAsString(csvData);
      await OpenFile.open(path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  // --- 4. Edit User Function (Updated with Dropdown) ---
  Future<void> _showEditDialog(UserData user) async {
    String selectedDepartment = user.department;
    String selectedStatus = user.status;

    // List of PUP Departments
    final List<String> pupDepartments = [
      'Unassigned',
      'College of Engineering',
      'College of Computer and Information Sciences',
      'College of Science',
      'College of Business Administration',
      'College of Accountancy and Finance',
      'College of Education',
      'College of Arts and Letters',
      'College of Architecture and Fine Arts',
      'College of Social Sciences and Development',
      'College of Communication',
      'Institute of Technology',
      'College of Political Science and Public Administration',
      'College of Tourism, Hospitality and Transportation Management',
    ];

    // Ensure the current user's department is in the list; if not, add it temporarily so dropdown works
    if (!pupDepartments.contains(selectedDepartment)) {
      pupDepartments.add(selectedDepartment);
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Edit User Details'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name Field (Read Only)
                    TextField(
                      decoration: const InputDecoration(labelText: 'Full Name'),
                      controller: TextEditingController(text: user.name),
                      enabled: false,
                    ),
                    const SizedBox(height: 20),

                    // DEPARTMENT DROPDOWN
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 12.0),
                          child: Text(
                            'Dept: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedDepartment,
                            items: pupDepartments.map((String dept) {
                              return DropdownMenuItem<String>(
                                value: dept,
                                child: Text(
                                  dept,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setStateDialog(
                                  () => selectedDepartment = value,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // STATUS DROPDOWN
                    Row(
                      children: [
                        const Text(
                          'Status: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: selectedStatus,
                          items: const [
                            DropdownMenuItem(
                              value: 'Active',
                              child: Text(
                                'Active',
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Suspended',
                              child: Text(
                                'Suspended',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setStateDialog(() => selectedStatus = value);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B0000),
                  ),
                  onPressed: () async {
                    try {
                      // Update Supabase
                      await Supabase.instance.client
                          .from('users')
                          .update({
                            'department': selectedDepartment,
                            'status': selectedStatus,
                          })
                          .eq('user_id', user.id);

                      if (mounted) {
                        Navigator.pop(context);
                        _fetchUsers(); // Refresh the list
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User updated!')),
                        );
                      }
                    } catch (e) {
                      print('Update Error: $e');
                    }
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- 5. View Details Function (Link/Chain Icon) ---
  void _showDetailsDialog(UserData user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Student No: ${user.studentNumber}"),
            const SizedBox(height: 8),
            Text("Email: ${user.email}"),
            const SizedBox(height: 8),
            Text("Department: ${user.department}"),
            const SizedBox(height: 8),
            Text("Last Active: ${user.lastActive}"),
            const SizedBox(height: 8),
            Text("Status: ${user.status}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      }
    } catch (e) {
      print(e);
    }
  }

  // --- Build Row ---
  DataRow _buildDataRow(UserData user, BuildContext context) {
    return DataRow(
      cells: [
        DataCell(Text(user.name)),
        DataCell(Text(user.studentNumber)),
        DataCell(Text(user.email)),
        DataCell(
          Tooltip(
            message: user.department, // Shows full name on long press/hover
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 160,
              ), // Limits width so table doesn't break
              child: Text(
                user.department,
                maxLines: 1,
                overflow: TextOverflow
                    .ellipsis, // Adds "..." if text is too long (e.g., "College of Engin...")
                style: TextStyle(
                  // Dynamic Style: Grey & Italic if "Unassigned", Black & Medium if Assigned
                  color: user.department == 'Unassigned'
                      ? Colors.grey
                      : Colors.black87,
                  fontStyle: user.department == 'Unassigned'
                      ? FontStyle.italic
                      : FontStyle.normal,
                  fontWeight: user.department != 'Unassigned'
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
        DataCell(Text(user.savedLocations.toString())),
        DataCell(Text(user.lastActive)),
        DataCell(StatusIndicator(status: user.status)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // EDIT BUTTON
              IconButton(
                icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                onPressed: () => _showEditDialog(user),
              ),
              // DETAILS BUTTON (Link Icon)
              IconButton(
                icon: const Icon(Icons.link, size: 18, color: Colors.grey),
                onPressed: () => _showDetailsDialog(user),
              ),
              // DELETE BUTTON
              IconButton(
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                onPressed: () => _deleteUser(user.id),
              ),
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
      drawer: NavigationDrawerAdmin(onSignOut: () => _signOut(context)),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header ---
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'User Accounts Management',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Manage all registered users and their activities.',
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
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Search Bar
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 400,
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onSubmitted: (value) => _fetchUsers(value),
                                  decoration: InputDecoration(
                                    hintText: 'Search by Name or Student No.',
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      color: Colors.grey,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: const Icon(
                                        Icons.clear,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        _fetchUsers();
                                      },
                                    ),
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(30.0),
                                      ),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 0,
                                      horizontal: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Export Button
  
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Table ---
                  _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _users.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(child: Text("No users found.")),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 30,
                              headingRowColor: WidgetStateProperty.resolveWith(
                                (states) => Colors.grey[200],
                              ),
                              columns: const [
                                DataColumn(
                                  label: Text(
                                    'Name',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Student\nNumber',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Email',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Department',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Saved\nLocations',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Last\nActive',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Status',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Actions',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                              rows: _users
                                  .map((u) => _buildDataRow(u, context))
                                  .toList(),
                            ),
                          ),
                        ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }
}
