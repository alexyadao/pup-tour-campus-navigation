import 'dart:io';
import 'dart:typed_data'; // Required for Uint8List
import 'dart:ui'; // Required for Blur
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- IMPORTS ---
// Removed AppFooter and MainLayout imports for a cleaner, standalone screen

class VerifyAccountScreen extends StatefulWidget {
  const VerifyAccountScreen({super.key});

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  // --- Style Constants ---
  static const Color neonYellow = Color(0xFFFFEA00);
  static const Color pupMaroon = Color(0xFF800000); 
  static const Color whiteText = Colors.white;
  static const Color whiteText70 = Colors.white70;

  // --- Controllers & State ---
  final TextEditingController _studentNoController = TextEditingController();
  XFile? _pickedFile;
  Uint8List? _webImageBytes;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // --- BACKEND LOGIC ---
  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _pickedFile = picked;
          _webImageBytes = bytes;
        });
      } else {
        setState(() {
          _pickedFile = picked;
        });
      }
    }
  }

  Future<void> _submitVerification() async {
    if (_studentNoController.text.isEmpty || _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide Student Number and ID Photo."), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // 1. Prepare File
      final bytes = await _pickedFile!.readAsBytes();
      final fileExt = _pickedFile!.name.split('.').last;
      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // 2. Upload Binary
      await Supabase.instance.client.storage.from('id_cards').uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(contentType: 'image/$fileExt', upsert: true),
          );

      // 3. Update User Table
      await Supabase.instance.client.from('users').update({
        'student_number': _studentNoController.text.trim(),
        'id_image_url': fileName,
        'verification_status': 'Pending',
      }).eq('user_id', user.id);

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      debugPrint("Verification Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Verification Submitted", style: TextStyle(color: neonYellow, fontWeight: FontWeight.bold)),
          content: const Text(
              "Your request has been sent for approval. Please wait for an admin to review your ID.",
              style: TextStyle(color: whiteText)),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: pupMaroon),
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to Profile
              },
              child: const Text("OK", style: TextStyle(color: whiteText)),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET: Background ---
  Widget _buildBackground() {
    return Container(
      color: const Color(0xFF1A0505),
      child: Stack(
        children: [
          Positioned(
            top: -100, right: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: neonYellow.withOpacity(0.1),
                boxShadow: [BoxShadow(color: neonYellow.withOpacity(0.15), blurRadius: 100, spreadRadius: 20)],
              ),
            ),
          ),
          Positioned(
            bottom: 50, left: -50,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: pupMaroon.withOpacity(0.3),
                boxShadow: [BoxShadow(color: pupMaroon.withOpacity(0.3), blurRadius: 100, spreadRadius: 40)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: Glass Text Field ---
  Widget _buildGlassTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Student Number", style: TextStyle(color: whiteText, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: TextField(
                controller: _studentNoController,
                style: const TextStyle(color: whiteText),
                decoration: const InputDecoration(
                  hintText: "202X-XXXXX-MN-0",
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  prefixIcon: Icon(Icons.badge_outlined, color: whiteText70),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET: Image Picker Area ---
  Widget _buildImagePickerArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Upload School ID", style: TextStyle(color: whiteText, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.2), style: BorderStyle.solid),
                ),
                child: _pickedFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_a_photo_outlined, size: 40, color: whiteText70),
                          SizedBox(height: 10),
                          Text("Tap to upload photo", style: TextStyle(color: whiteText70)),
                        ],
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          kIsWeb
                              ? Image.memory(_webImageBytes!, fit: BoxFit.cover)
                              : Image.file(File(_pickedFile!.path), fit: BoxFit.cover),
                          Container(color: Colors.black26), // Dim overlay
                          const Center(child: Icon(Icons.check_circle, color: neonYellow, size: 40)),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Background
          _buildBackground(),

          // 2. Content
          SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // --- Header ---
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.arrow_back_ios_new, color: whiteText, size: 20),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Text("Get Verified", style: TextStyle(color: whiteText, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    
                    const SizedBox(height: 30),

                    // --- Description Card ---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: pupMaroon.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: pupMaroon.withOpacity(0.6)),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.verified, color: neonYellow, size: 30),
                              SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  "Unlock exclusive features like Event Scheduling by verifying your student status.",
                                  style: TextStyle(color: whiteText, fontSize: 13, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- Form Fields ---
                    _buildGlassTextField(),
                    const SizedBox(height: 25),
                    _buildImagePickerArea(),

                    const SizedBox(height: 40),

                    // --- Submit Button ---
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitVerification,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pupMaroon,
                          foregroundColor: whiteText,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 5,
                          shadowColor: pupMaroon.withOpacity(0.5),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: whiteText, strokeWidth: 2))
                            : const Text("Submit Verification", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}