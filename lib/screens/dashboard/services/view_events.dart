import 'dart:ui'; // Required for Blur effects
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:puptourapp/routes/app_routes.dart';

// --- IMPORTS ---
import 'package:puptourapp/widgets/main_layout.dart';
import '../events/organizer_event_dashboard.dart'; 

// --- NOTIFICATION IMPORTS ---
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ViewEventScreen extends StatefulWidget {
  const ViewEventScreen({super.key});

  @override
  State<ViewEventScreen> createState() => _ViewEventScreenState();
}

class _ViewEventScreenState extends State<ViewEventScreen> {
  // --- Style Constants ---
  static const Color neonYellow = Color(0xFFFFEA00);
  static const Color pupMaroon = Color(0xFF800000);
  static const Color pupRedBright = Color(0xFFAA0000);
  static const Color whiteText = Colors.white;
  static const Color whiteText70 = Colors.white70;

  // --- State Variables ---
  bool _isJoined = false;
  bool _isReminderSet = false;
  bool _isLoading = true;
  bool _isOrganizer = false;
  int? _eventId;
  String? _eventStartTime;
  Map<String, dynamic>? _eventData;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Map<String, dynamic>? args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _eventId = args['event_id'];
        _eventStartTime = args['start_time'];
        _eventData = args;
        _checkStatus(args['title']); 
      }
    });
  }

  // --- NOTIFICATION LOGIC ---
  Future<void> _initNotifications() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> _scheduleNotification(String title) async {
    if (_eventId == null || _eventStartTime == null) return;
    try {
      final DateTime start = DateTime.parse(_eventStartTime!);
      final DateTime scheduledDate = start.subtract(const Duration(days: 2));

      if (scheduledDate.isBefore(DateTime.now())) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Event is too soon for a 2-day reminder."),
            backgroundColor: Colors.orange,
          ));
        }
        return;
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        _eventId!,
        'Upcoming Event: $title',
        'Reminder: This event starts in 2 days!',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'event_reminders',
            'Event Reminders',
            channelDescription: 'Notifications for joined events',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint("Error scheduling notification: $e");
    }
  }

  Future<void> _cancelNotification() async {
    if (_eventId != null) {
      await flutterLocalNotificationsPlugin.cancel(_eventId!);
    }
  }

  Future<void> _toggleReminder() async {
    final user = Supabase.instance.client.auth.currentUser;
    final String title = _eventData?['title'] ?? "Event";

    if (user == null || _eventId == null) return;

    try {
      final userData = await Supabase.instance.client
          .from('users')
          .select('preferences')
          .eq('user_id', user.id)
          .maybeSingle();

      bool globalNotificationsEnabled = true;
      if (userData != null && userData['preferences'] != null) {
        final prefs = userData['preferences'];
        if (prefs is Map) {
          globalNotificationsEnabled = prefs['notifications'] ?? true;
        }
      }

      if (!globalNotificationsEnabled) {
        if (mounted) _showSettingsAlert(context);
        return;
      }

      if (_isReminderSet) {
        await Supabase.instance.client
            .from('event_reminders')
            .delete()
            .eq('event_id', _eventId!)
            .eq('user_id', user.id);
        await _cancelNotification();
        if (mounted) {
          setState(() => _isReminderSet = false);
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Reminder removed.")));
        }
      } else {
        await Supabase.instance.client.from('event_reminders').insert({
          'event_id': _eventId!,
          'user_id': user.id,
        });
        await _scheduleNotification(title);
        if (mounted) {
          setState(() => _isReminderSet = true);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Reminder set for 2 days before event!"),
              backgroundColor: Colors.green));
        }
      }
    } catch (e) {
      debugPrint("Reminder Error: $e");
    }
  }

  void _showSettingsAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Notifications Disabled", style: TextStyle(color: neonYellow)),
        content: const Text(
            "You have disabled Notifications in Settings. To set a reminder, please enable them.",
            style: TextStyle(color: whiteText)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, AppRoutes.settings);
            },
            child: const Text("Go to Settings", style: TextStyle(fontWeight: FontWeight.bold, color: neonYellow)),
          ),
        ],
      ),
    );
  }

  // --- CHECK STATUS LOGIC ---
  Future<void> _checkStatus(String? eventTitle) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || _eventId == null) return;

    try {
      if (_eventData != null && _eventData!['organizer_id'] == user.id) {
        setState(() => _isOrganizer = true);
      }

      final participation = await Supabase.instance.client
          .from('event_participants')
          .select()
          .eq('event_id', _eventId!)
          .eq('user_id', user.id)
          .maybeSingle();

      final reminder = await Supabase.instance.client
          .from('event_reminders')
          .select()
          .eq('event_id', _eventId!)
          .eq('user_id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _isJoined = participation != null;
          _isReminderSet = reminder != null;
        });
      }
    } catch (e) {
      debugPrint("Error checking status: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- REGISTRATION LOGIC ---
  void _showRegistrationForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController courseController = TextEditingController();
    final TextEditingController contactController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E).withOpacity(0.95),
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.2))),
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Container(width: 40, height: 4, color: Colors.grey, margin: const EdgeInsets.only(bottom: 20))),
                      const Text("Event Registration",
                          style: TextStyle(color: neonYellow, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      const Text("Please fill in your details to secure a slot.",
                          style: TextStyle(color: whiteText70, fontSize: 14)),
                      const SizedBox(height: 20),
                      _buildGlassTextField(nameController, "Full Name", Icons.person),
                      const SizedBox(height: 15),
                      _buildGlassTextField(courseController, "Course & Year", Icons.school),
                      const SizedBox(height: 15),
                      _buildGlassTextField(contactController, "Contact Number", Icons.phone, isNumber: true),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Navigator.pop(ctx);
                              _submitRegistration(nameController.text, courseController.text, contactController.text);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: pupRedBright,
                            foregroundColor: whiteText,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text("Confirm Registration", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitRegistration(String name, String course, String contact) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || _eventId == null) return;

    setState(() => _isLoading = true);

    try {
      final guestInfo = {
        'full_name': name,
        'course': course,
        'contact_number': contact,
      };

      await Supabase.instance.client.from('event_participants').insert({
        'event_id': _eventId!,
        'user_id': user.id,
        'status': 'Registered',
        'joined_at': DateTime.now().toIso8601String(),
        'guest_info': guestInfo, 
      });

      if (mounted) {
        setState(() {
          _isJoined = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration Successful!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (e.toString().contains("duplicate")) {
        if (mounted) {
           setState(() => _isJoined = true);
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You are already registered.")));
        }
      } else {
        debugPrint("Join Error: $e");
      }
    }
  }

  // --- UI WIDGETS ---
  Widget _buildGlassTextField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      style: const TextStyle(color: whiteText),
      validator: (value) => value == null || value.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: whiteText70),
        prefixIcon: Icon(icon, color: neonYellow),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      color: const Color(0xFF1A0505),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: neonYellow.withOpacity(0.15),
                boxShadow: [BoxShadow(color: neonYellow.withOpacity(0.2), blurRadius: 100, spreadRadius: 20)],
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: pupMaroon.withOpacity(0.4),
                boxShadow: [BoxShadow(color: pupMaroon.withOpacity(0.4), blurRadius: 100, spreadRadius: 40)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_eventData == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final String title = _eventData!['title'] ?? 'No Title';
    final String description = _eventData!['description'] ?? 'No description.';
    final String? imageUrl = _eventData!['image_url'];
    final DateTime start = DateTime.parse(_eventData!['start_time']);
    final DateTime end = DateTime.parse(_eventData!['end_time']);
    final String dateStr = DateFormat('MMMM d, yyyy').format(start);
    final String timeStr = "${DateFormat('h:mm a').format(start)} - ${DateFormat('h:mm a').format(end)}";

    return MainLayout(
      enableScroll: false,
      useStandardBackground: false,
      extendBodyBehindAppBar: true,
      showHeader: false, // 1. TURN OFF HEADER so we can custom build one inside Body
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // 2. NO APP BAR HERE either. We will use Stack.
        body: Stack(
          children: [
            _buildBackground(),
            
            // 3. IMAGE LAYER (Bottom)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 350,
              child: ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Colors.transparent],
                    stops: [0.5, 1.0],
                  ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                },
                blendMode: BlendMode.dstIn,
                child: imageUrl != null 
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : Image.asset('assets/images/pup.png', fit: BoxFit.cover),
              ),
            ),

            // 4. SCROLLABLE CONTENT (Middle)
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 280),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                Expanded(child: Text(title, style: const TextStyle(color: whiteText, fontSize: 26, fontWeight: FontWeight.bold))),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(color: pupRedBright, borderRadius: BorderRadius.circular(15)),
                                  child: const Text("EVENT", style: TextStyle(color: whiteText, fontSize: 10, fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                            const SizedBox(height: 15),
                            
                            // Date/Time
                            Row(
                              children: [
                                const Icon(Icons.calendar_month, color: neonYellow, size: 20),
                                const SizedBox(width: 8),
                                Text(dateStr, style: const TextStyle(color: whiteText70, fontSize: 15)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.access_time, color: neonYellow, size: 20),
                                const SizedBox(width: 8),
                                Text(timeStr, style: const TextStyle(color: whiteText70, fontSize: 15)),
                              ],
                            ),
                            const SizedBox(height: 25),

                            // Description
                            const Text("About Event", style: TextStyle(color: whiteText, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Text(description, style: const TextStyle(color: whiteText70, fontSize: 15, height: 1.5)),
                            const SizedBox(height: 25),

                            // Action Button
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: _isLoading 
                                ? Center(child: CircularProgressIndicator(color: neonYellow))
                                : ElevatedButton(
                                  onPressed: _isOrganizer 
                                    ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrganizerEventDashboard(event: _eventData!)))
                                    : _isJoined 
                                      ? null 
                                      : () => _showRegistrationForm(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isOrganizer ? Colors.blueAccent : (_isJoined ? Colors.green : neonYellow),
                                    foregroundColor: _isOrganizer || _isJoined ? whiteText : Colors.black,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    elevation: 10,
                                  ),
                                  child: Text(
                                    _isOrganizer ? "MANAGE EVENT" : (_isJoined ? "YOU ARE REGISTERED" : "REGISTER NOW"),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                                  ),
                                ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 5. FLOATING BUTTONS ROW (Top Layer)
            // Sits over the image, safe from status bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea( // Ensures it respects the notch/status bar
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: whiteText, size: 20),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                      ),

                      // Bell Notification Button
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: IconButton(
                              icon: Icon(
                                _isReminderSet ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                                color: _isReminderSet ? neonYellow : whiteText,
                                size: 24,
                              ),
                              onPressed: _toggleReminder,
                            ),
                          ),
                        ),
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