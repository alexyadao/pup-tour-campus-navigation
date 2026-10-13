import 'dart:ui'; // Required for Blur
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DraggableCustomerServiceButton extends StatefulWidget {
  final double iconSize;

  const DraggableCustomerServiceButton({super.key, this.iconSize = 55.0});

  @override
  State<DraggableCustomerServiceButton> createState() =>
      _DraggableCustomerServiceButtonState();
}

class _DraggableCustomerServiceButtonState
    extends State<DraggableCustomerServiceButton> {
  // Position variables
  double? top;
  double? left;
  
  // Style Constants
  static const Color pupMaroon = Color(0xFF800000);
  static const Color neonYellow = Color(0xFFFFEA00);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize position only once
    if (top == null || left == null) {
      final screenSize = MediaQuery.of(context).size;
      // Positioned nicely above the footer on the right
      top = screenSize.height - widget.iconSize - 120; 
      left = screenSize.width - widget.iconSize - 20; 
    }
  }

  // --- LOGIC: Show Input Dialog & Send to Supabase ---
  void _showCustomerService(BuildContext context) {
    final TextEditingController messageController = TextEditingController();
    bool isSending = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: AlertDialog(
                backgroundColor: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Row(
                  children: const [
                    Icon(Icons.support_agent_rounded, color: neonYellow),
                    SizedBox(width: 10),
                    Text("Support", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "How can we help you today?",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: messageController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Type your concern here...",
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
                  ),
                  ElevatedButton(
                    onPressed: isSending
                        ? null
                        : () async {
                            final msg = messageController.text.trim();
                            if (msg.isEmpty) return;

                            setState(() => isSending = true);

                            try {
                              final user = Supabase.instance.client.auth.currentUser;
                              if (user != null) {
                                // SEND TO SUPABASE
                                await Supabase.instance.client.from('support_tickets').insert({
                                  'user_id': user.id,
                                  'message': msg,
                                });

                                if (context.mounted) {
                                  Navigator.pop(ctx); // Close Dialog
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Message sent! An admin will review it shortly."),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                                );
                              }
                            } finally {
                              if (context.mounted) {
                                setState(() => isSending = false);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pupMaroon,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isSending
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Send", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        // Drag Logic
        onPanUpdate: (details) {
          setState(() {
            final screenSize = MediaQuery.of(context).size;
            top = (top! + details.delta.dy)
                .clamp(50.0, screenSize.height - widget.iconSize - 50);
            left = (left! + details.delta.dx)
                .clamp(0.0, screenSize.width - widget.iconSize);
          });
        },
        // Button UI
        child: GestureDetector(
          onTap: () => _showCustomerService(context),
          child: Container(
            width: widget.iconSize,
            height: widget.iconSize,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8E0E00), Color(0xFF5a0000)], // Deep Maroon Gradient
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(-2, -2),
                ),
              ],
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
            ),
            child: Icon(
              Icons.support_agent_rounded, // Modern Icon               color: neonYellow,
              size: widget.iconSize * 0.6,
            ),
          ),
        ),
      ),
    );
  }
}