import 'dart:ui'; // Required for Blur
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

// --- Style Constants ---
const Color neonYellow = Color(0xFFFFEA00);
const Color pupMaroon = Color(0xFF800000);
const Color whiteText = Colors.white;
const Color whiteText70 = Colors.white70;

class OrganizerEventDashboard extends StatefulWidget {
  final Map<String, dynamic> event;

  const OrganizerEventDashboard({super.key, required this.event});

  @override
  State<OrganizerEventDashboard> createState() => _OrganizerEventDashboardState();
}

class _OrganizerEventDashboardState extends State<OrganizerEventDashboard> {
  
  // --- Background Widget ---
  Widget _buildBackground() {
    return Container(
      color: const Color(0xFF1A0505), // Deep Dark Maroon Base
      child: Stack(
        children: [
          // Blob 1 (Top Left)
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: neonYellow.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                      color: neonYellow.withOpacity(0.15),
                      blurRadius: 100,
                      spreadRadius: 20)
                ],
              ),
            ),
          ),
          // Blob 2 (Bottom Right)
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: pupMaroon.withOpacity(0.3),
                boxShadow: [
                  BoxShadow(
                      color: pupMaroon.withOpacity(0.3),
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

  @override
  Widget build(BuildContext context) {
    // Query participants
    final participantsStream = Supabase.instance.client
        .from('event_participants')
        .stream(primaryKey: ['participation_id'])
        .eq('event_id', widget.event['event_id'])
        .order('joined_at', ascending: false);

    return Scaffold(
      // Make background transparent so our custom background shows
      backgroundColor: Colors.transparent, 
      body: Stack(
        children: [
          // 1. Background Layer
          _buildBackground(),

          // 2. Main Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60), // Space for Back Button

                // --- Header & Summary Card ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Organizer Dashboard", 
                        style: TextStyle(color: neonYellow, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                      const SizedBox(height: 5),
                      Text(
                        widget.event['title'] ?? "Event Title",
                        style: const TextStyle(color: whiteText, fontSize: 28, fontWeight: FontWeight.bold, height: 1.1),
                      ),
                      const SizedBox(height: 20),
                      
                      // Glass Summary Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.15)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: neonYellow.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.people_alt_rounded, color: neonYellow),
                                ),
                                const SizedBox(width: 15),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Manage Participants", 
                                        style: TextStyle(color: whiteText, fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text("View list of registered students", 
                                        style: TextStyle(color: whiteText70, fontSize: 12)),
                                    ],
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

                const SizedBox(height: 30),

                // --- List Title ---
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Text("RECENT REGISTRATIONS",
                      style: TextStyle(
                          color: whiteText70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5)),
                ),
                const SizedBox(height: 10),

                // --- Participants List ---
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: participantsStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator(color: neonYellow));
                      }

                      final participants = snapshot.data!;

                      if (participants.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_off_rounded, size: 50, color: Colors.white.withOpacity(0.2)),
                              const SizedBox(height: 10),
                              Text("No registrations yet.",
                                  style: TextStyle(color: Colors.white.withOpacity(0.5))),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: participants.length,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemBuilder: (context, index) {
                          final p = participants[index];
                          final guestInfo = p['guest_info'] ?? {};
                          
                          final name = guestInfo['full_name'] ?? "Unknown User";
                          final contact = guestInfo['contact_number'] ?? "No contact";
                          final course = guestInfo['course'] ?? "N/A";
                          final date = DateFormat('MMM d, h:mm a').format(DateTime.parse(p['joined_at']));

                          // Glass List Item
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.white.withOpacity(0.08)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: pupMaroon,
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : "?", 
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                                ),
                              ),
                              title: Text(name, style: const TextStyle(color: whiteText, fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.school, size: 12, color: neonYellow.withOpacity(0.7)),
                                        const SizedBox(width: 4),
                                        Text(course, style: const TextStyle(color: whiteText70, fontSize: 12)),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(Icons.phone, size: 12, color: neonYellow.withOpacity(0.7)),
                                        const SizedBox(width: 4),
                                        Text(contact, style: const TextStyle(color: whiteText70, fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.greenAccent, size: 18),
                                  const SizedBox(height: 4),
                                  Text(date, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 3. Floating Back Button (Top Left)
          Positioned(
            top: 50, // Safe Area padding
            left: 20,
            child: ClipRRect(
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
          ),
        ],
      ),
    );
  }
}