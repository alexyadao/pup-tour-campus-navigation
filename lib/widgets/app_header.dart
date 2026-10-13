// Required for Glassmorphism
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  // State for the Red Dot
  bool _hasUnreadNotifications = false;

  @override
  void initState() {
    super.initState();
    _checkUnreadNotifications();
  }

  // --- BACKEND: Check for unread messages ---
  Future<void> _checkUnreadNotifications() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final count = await Supabase.instance.client
          .from('notifications')
          .count(CountOption.exact)
          .eq('user_id', user.id)
          .eq('is_read', false);

      if (mounted) {
        setState(() {
          _hasUnreadNotifications = count > 0;
        });
      }
    } catch (e) {
      debugPrint("Notification Check Error: $e");
    }
  }

  // --- BACKEND: Fetch Notifications for the Popup ---
  Future<List<Map<String, dynamic>>> _fetchNotifications() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];

    final data = await Supabase.instance.client
        .from('notifications')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(5); // Show top 5 recent

    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 80,
      automaticallyImplyLeading: false,

      // --- Custom Background ---
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8E0E00), Color(0xFF5a0000)],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
      ),

      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // --- LEFT: Menu Button ---
            Builder(
              builder: (context) => GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: _buildGlassIcon(Icons.menu, Colors.white),
              ),
            ),

            // --- CENTER: Logo & Text ---
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36, height: 36,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(
                    'assets/images/pup_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) => const Center(
                      child: Text("PUP", style: TextStyle(color: Color(0xFF8E0E00), fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "PUP Tour",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ],
            ),

            // --- RIGHT: Notification Popup (Option B) ---
            Stack(
              children: [
                // The Button itself
                PopupMenuButton(
                  icon: _buildGlassIcon(Icons.notifications, Colors.white.withOpacity(0.9), isWidget: true),
                  offset: const Offset(0, 50),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 10,
                  
                  // This builds the dropdown list dynamically
                  itemBuilder: (context) {
                    return [
                      // Header of Popup
                      const PopupMenuItem(
                        enabled: false,
                        child: Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
                      ),
                      
                      // FutureBuilder to load data inside the popup
                      PopupMenuItem(
                        enabled: false,
                        child: SizedBox(
                          width: 250, // Popup width
                          height: 200, // Max height
                          child: FutureBuilder(
                            future: _fetchNotifications(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                                return const Center(child: Text("No new notifications", style: TextStyle(color: Colors.grey)));
                              }
                              
                              final notifs = snapshot.data as List<Map<String, dynamic>>;
                              return ListView(
                                padding: EdgeInsets.zero,
                                children: notifs.map((n) => 
                                  // Rebuilding the item here since we are inside a FutureBuilder
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
                                    child: Row(
                                      children: [
                                        Icon(Icons.circle, size: 8, color: n['is_read'] ? Colors.transparent : Colors.redAccent),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(n['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                              Text(n['message'], style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 2),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ).toList(),
                              );
                            },
                          ),
                        ),
                      ),
                    ];
                  },
                  // Mark as read when opened (Simplified logic)
                  onOpened: () {
                    setState(() => _hasUnreadNotifications = false);
                    // Optionally call DB to update 'is_read' = true here
                  },
                ),

                // RED DOT INDICATOR
                if (_hasUnreadNotifications)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      width: 10, height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper for the Glass Bubble Look
  Widget _buildGlassIcon(IconData icon, Color color, {bool isWidget = false}) {
    final inner = Icon(icon, color: color, size: 24);
    
    // If used inside PopupMenuButton's 'icon' property, we just return the container content
    // Otherwise it creates double padding.
    if (isWidget) {
      return Container(
        width: 45, height: 45,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: inner,
      );
    }

    return Container(
      width: 45, height: 45,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: inner,
    );
  }
}