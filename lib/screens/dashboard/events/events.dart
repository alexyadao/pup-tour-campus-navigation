import 'dart:ui'; // Required for Blur effects
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:puptourapp/routes/app_routes.dart';

// Use MainLayout for consistency
import 'package:puptourapp/widgets/main_layout.dart';
import '../../../widgets/app_footer.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  // --- Style Constants for Dark Theme ---
  static const Color neonYellow = Color(0xFFFFEA00);
  static const Color pupMaroon = Color(0xFF800000);
  static const Color whiteText = Colors.white;
  static const Color whiteText70 = Colors.white70;

  // --- WIDGET: Background (Dark Cinematic) ---
  Widget _buildBackground() {
    return Container(
      color: const Color(0xFF1A0505), // Very Dark Maroon/Black Base
      child: Stack(
        children: [
          // Blob 1: Neon Yellow (Top Left)
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: neonYellow.withOpacity(0.15),
                boxShadow: [
                  BoxShadow(
                      color: neonYellow.withOpacity(0.2),
                      blurRadius: 100,
                      spreadRadius: 20)
                ],
              ),
            ),
          ),
          // Blob 2: Maroon/Red (Bottom Right)
          Positioned(
            bottom: 200,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: pupMaroon.withOpacity(0.4),
                boxShadow: [
                  BoxShadow(
                      color: pupMaroon.withOpacity(0.4),
                      blurRadius: 100,
                      spreadRadius: 40)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: Glass Search Bar ---
  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          margin: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
          ),
          child: TextField(
            style: const TextStyle(color: whiteText),
            cursorColor: neonYellow,
            decoration: InputDecoration(
              hintText: "Search Events...",
              hintStyle: const TextStyle(color: whiteText70),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
              border: InputBorder.none,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 10, right: 8),
                child: Icon(Icons.search, color: neonYellow, size: 28),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET: Glass Event Card ---
  Widget _buildEventCard(Map<String, dynamic> event) {
    final String title = event['title'] ?? 'No Title';
    final String description = event['description'] ?? 'No description provided.';
    final String? imageUrl = event['image_url'];

    final DateTime start = DateTime.parse(event['start_time']);
    final DateTime end = DateTime.parse(event['end_time']);
    
    // Date badge format
    final String day = DateFormat('d').format(start);
    final String month = DateFormat('MMM').format(start).toUpperCase();
    
    final String timeStr = "${DateFormat('h:mm a').format(start)} – ${DateFormat('h:mm a').format(end)}";

    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      // Glass Card
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section with Date Badge
                Stack(
                  children: [
                    SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.white.withOpacity(0.1),
                                child: const Center(
                                    child: Icon(Icons.broken_image,
                                        size: 50, color: whiteText70)),
                              ),
                            )
                          : Container(
                              color: Colors.white.withOpacity(0.1),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/pup_logo.png',
                                  width: 80,
                                  opacity: const AlwaysStoppedAnimation(0.5),
                                ),
                              ),
                            ),
                    ),
                    // Date Badge (Floating Top Left)
                    Positioned(
                      top: 15,
                      left: 15,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              day,
                              style: const TextStyle(
                                color: pupMaroon,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              month,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Details Section
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            color: whiteText,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(
                            color: whiteText70, fontSize: 14, height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 15),
                      
                      // Time Row
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, color: neonYellow, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              timeStr,
                              style: const TextStyle(
                                  color: neonYellow,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              AppRoutes.viewEvent,
                              arguments: event,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            foregroundColor: whiteText,
                            shadowColor: Colors.transparent,
                            side: const BorderSide(color: whiteText70, width: 1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.info_outline, size: 20),
                              SizedBox(width: 8),
                              Text("View Details",
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
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
    // UPDATED STREAM: Only fetch 'Approved' events
    final eventsStream = Supabase.instance.client
        .from('events')
        .stream(primaryKey: ['event_id'])
        .eq('status', 'Approved') // <--- FILTER ACTIVE
        .order('start_time', ascending: true);

    return MainLayout(
      // --- IMPORTANT: Flip switches for custom design ---
      enableScroll: false, 
      useStandardBackground: false,
      extendBodyBehindAppBar: true, 
      showHeader: true,

      child: Stack(
        children: [
          // 1. Background
          _buildBackground(),

          // 2. Content
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSearchBar(),
                                const Text(
                                  "Upcoming Campus Events",
                                  style: TextStyle(
                                      color: whiteText,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5),
                                ),
                                const SizedBox(height: 20),
                                
                                // Stream Builder
                                StreamBuilder<List<Map<String, dynamic>>>(
                                  stream: eventsStream,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Center(
                                          child: Text(
                                              'Error loading events: ${snapshot.error}',
                                              style: const TextStyle(color: Colors.redAccent)));
                                    }
                                    if (!snapshot.hasData) {
                                      return const Center(
                                          child: CircularProgressIndicator(
                                              color: neonYellow));
                                    }

                                    final events = snapshot.data!;

                                    if (events.isEmpty) {
                                      return Container(
                                        padding: const EdgeInsets.all(30),
                                        width: double.infinity,
                                        child: Column(
                                          children: [
                                            Icon(Icons.event_busy,
                                                size: 60, color: Colors.white.withOpacity(0.3)),
                                            const SizedBox(height: 10),
                                            Text("No upcoming events found.",
                                                style: TextStyle(color: Colors.white.withOpacity(0.5))),
                                          ],
                                        ),
                                      );
                                    }

                                    return Column(
                                      children: events.map((event) {
                                        return _buildEventCard(event);
                                      }).toList(),
                                    );
                                  },
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                          const Spacer(),
                          const AppFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}