import 'dart:ui'; // Required for Blur
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- IMPORTS ---
// Removed AppFooter import since we aren't using it anymore

class MyJoinedEventsScreen extends StatefulWidget {
  const MyJoinedEventsScreen({super.key});

  @override
  State<MyJoinedEventsScreen> createState() => _MyJoinedEventsScreenState();
}

class _MyJoinedEventsScreenState extends State<MyJoinedEventsScreen> {
  // --- Style Constants for Dark Theme ---
  static const Color neonYellow = Color(0xFFFFEA00);
  static const Color pupMaroon = Color(0xFF800000); 
  static const Color whiteText = Colors.white;
  static const Color whiteText70 = Colors.white70;

  bool _isLoading = true;
  List<Map<String, dynamic>> _myEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchJoinedEvents();
  }

  // --- BACKEND LOGIC: Fetch Joined Events ---
  Future<void> _fetchJoinedEvents() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final data = await supabase
          .from('event_participants')
          .select('status, events(*)')
          .eq('user_id', userId)
          .order('joined_at', ascending: false);

      if (mounted) {
        setState(() {
          _myEvents = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching events: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- WIDGET: Background ---
  Widget _buildBackground() {
    return Container(
      color: const Color(0xFF1A0505),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: neonYellow.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(color: neonYellow.withOpacity(0.15), blurRadius: 100, spreadRadius: 20)
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: pupMaroon.withOpacity(0.3),
                boxShadow: [
                  BoxShadow(color: pupMaroon.withOpacity(0.3), blurRadius: 100, spreadRadius: 40)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: Glass Event Card ---
  Widget _buildGlassEventCard(Map<String, dynamic> eventData, String status) {
    final String rawImage = eventData['image_url'] ?? eventData['imagePath'] ?? 'assets/images/pup.png';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Image Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: rawImage.startsWith('http')
                        ? Image.network(
                            rawImage,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(
                              color: Colors.white.withOpacity(0.1),
                              child: const Icon(Icons.broken_image, color: whiteText70),
                            ),
                          )
                        : Image.asset(
                            rawImage,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(
                              color: Colors.white.withOpacity(0.1),
                              child: const Icon(Icons.image, color: whiteText70),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 15),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventData['title'] ?? "Unknown Event",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: whiteText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.withOpacity(0.5)),
                        ),
                        child: Text(
                          "Status: $status",
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      
      body: Stack(
        children: [
          // Background Layer
          _buildBackground(),

          // Content Layer
          SafeArea(
            child: Column(
              children: [
                // --- CUSTOM HEADER (Fixed at top) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                              ),
                              child: const Icon(Icons.arrow_back_ios_new_rounded, color: whiteText, size: 20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Text(
                        "My Joined Events",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: whiteText,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 10),

                // --- SCROLLABLE LIST (Takes remaining space) ---
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: neonYellow))
                      : _myEvents.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.event_busy, size: 50, color: whiteText70),
                                  SizedBox(height: 10),
                                  Text(
                                    "You haven't joined any events yet.",
                                    style: TextStyle(color: whiteText70),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), // Added bottom padding for better scroll feel
                              itemCount: _myEvents.length,
                              itemBuilder: (context, index) {
                                final participantData = _myEvents[index];
                                final eventData = participantData['events'];
                                if (eventData == null) return const SizedBox.shrink();
                                return _buildGlassEventCard(eventData, participantData['status']);
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}