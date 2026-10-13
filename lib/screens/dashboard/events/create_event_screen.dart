import 'dart:io';
import 'dart:ui'; // Required for Blur
import 'dart:typed_data'; // Required for bytes
import 'package:flutter/foundation.dart' show kIsWeb; // Web check
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- IMPORTS ---
import 'package:puptourapp/widgets/main_layout.dart'; 

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  // --- Style Constants for Dark Theme ---
  static const Color neonYellow = Color(0xFFFFEA00);
  static const Color pupMaroon = Color(0xFF800000); 
  static const Color pupRedBright = Color(0xFFAA0000); 
  static const Color whiteText = Colors.white;
  static const Color whiteText70 = Colors.white70;

  // --- Controllers & State ---
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  // Date & Time Variables
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // Location Data
  List<Map<String, dynamic>> _landmarks = [];
  int? _selectedLandmarkId;

  // --- Image Picker Variables ---
  XFile? _pickedFile;
  Uint8List? _webImageBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchLandmarks();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- 1. Fetch Landmarks ---
  Future<void> _fetchLandmarks() async {
    try {
      final data = await Supabase.instance.client
          .from('landmarks')
          .select('landmark_id, name')
          .order('name', ascending: true);

      if (mounted) {
        setState(() {
          _landmarks = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      debugPrint("Error fetching landmarks: $e");
    }
  }

  // --- 2. Pick Image Logic ---
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

  // --- 3. Date/Time Selectors ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: neonYellow,
              onPrimary: Colors.black,
              onSurface: whiteText,
              surface: Color(0xFF1E1E1E),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: neonYellow,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: neonYellow,
              onPrimary: Colors.black,
              onSurface: whiteText,
              surface: Color(0xFF1E1E1E),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: neonYellow),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  // --- 4. Submit Event ---
  Future<void> _createEvent() async {
    if (_titleController.text.isEmpty ||
        _selectedDate == null ||
        _startTime == null ||
        _endTime == null ||
        _selectedLandmarkId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in all required fields.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      String? imageUrl;
      if (_pickedFile != null) {
        final bytes = await _pickedFile!.readAsBytes();
        final fileExt = _pickedFile!.name.split('.').last;
        final fileName =
            '${user.id}_event_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

        await Supabase.instance.client.storage
            .from('event_images')
            .uploadBinary(
              fileName,
              bytes,
              fileOptions:
                  FileOptions(contentType: 'image/$fileExt', upsert: true),
            );

        imageUrl = Supabase.instance.client.storage
            .from('event_images')
            .getPublicUrl(fileName);
      }

      final DateTime startDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );

      final DateTime endDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      await Supabase.instance.client.from('events').insert({
        'organizer_id': user.id,
        'landmark_id': _selectedLandmarkId,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'start_time': startDateTime.toIso8601String(),
        'end_time': endDateTime.toIso8601String(),
        'status': 'Pending',
        'image_url': imageUrl,
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text("Event Submitted", style: TextStyle(color: neonYellow)),
            content: const Text(
                "Your event has been successfully submitted and is now pending approval. Please wait for an admin to review it.",
                style: TextStyle(color: whiteText70)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("OK", style: TextStyle(color: neonYellow, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- WIDGETS ---
  
  Widget _buildBackground() {
    return Container(
      color: const Color(0xFF1A0505), 
      child: Stack(
        children: [
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

  Widget _buildGlassInputField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: whiteText)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
              ),
              child: TextField(
                controller: controller,
                maxLines: maxLines,
                style: const TextStyle(color: whiteText),
                decoration: InputDecoration(
                  hintText: 'Enter $label',
                  hintStyle: const TextStyle(color: whiteText70),
                  prefixIcon: icon != null ? Icon(icon, color: neonYellow) : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGlassSelectorButton({
    required String label,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: whiteText)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        color: value.contains('Select') ? whiteText70 : whiteText,
                      ),
                    ),
                    Icon(icon, color: neonYellow),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      enableScroll: false, 
      useStandardBackground: false,
      extendBodyBehindAppBar: true, 
      showHeader: false, // Hide MainLayout header so we can put back button in body

      child: Scaffold(
        backgroundColor: Colors.transparent,
        // Removed AppBar from Scaffold so content goes to top
        body: Stack(
          children: [
            // 1. Background
            _buildBackground(),
            
            // 2. Scrollable Content
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create New Event',
                    style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold, color: neonYellow),
                  ),
                  const Text(
                    'Fill in the details below.',
                    style: TextStyle(fontSize: 16, color: whiteText70),
                  ),
                  const SizedBox(height: 30),

                  // Image Picker
                  const Text("Event Poster/Image (Optional)",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: whiteText)),
                  const SizedBox(height: 10),
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
                            color: Colors.white.withOpacity(0.1),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: _pickedFile == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.add_photo_alternate_rounded,
                                        size: 50, color: whiteText70),
                                    SizedBox(height: 10),
                                    Text("Tap to upload image", style: TextStyle(color: whiteText70)),
                                  ],
                                )
                              : kIsWeb
                                  ? Image.memory(_webImageBytes!, fit: BoxFit.cover)
                                  : Image.file(File(_pickedFile!.path), fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Fields
                  _buildGlassInputField(
                      controller: _titleController, label: 'Event Title', icon: Icons.title),
                  _buildGlassInputField(
                      controller: _descriptionController,
                      label: 'Description',
                      maxLines: 3,
                      icon: Icons.description),

                  _buildGlassSelectorButton(
                    label: 'Date',
                    icon: Icons.calendar_today,
                    value: _selectedDate == null
                        ? 'Select Date'
                        : DateFormat('MMMM d, yyyy').format(_selectedDate!),
                    onTap: () => _selectDate(context),
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: _buildGlassSelectorButton(
                          label: 'Start Time',
                          icon: Icons.access_time,
                          value: _startTime == null
                              ? 'Select'
                              : _startTime!.format(context),
                          onTap: () => _selectTime(context, true),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildGlassSelectorButton(
                          label: 'End Time',
                          icon: Icons.access_time_filled,
                          value: _endTime == null ? 'Select' : _endTime!.format(context),
                          onTap: () => _selectTime(context, false),
                        ),
                      ),
                    ],
                  ),

                  const Text('Location (Landmark)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: whiteText)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            dropdownColor: const Color(0xFF1E1E1E),
                            style: const TextStyle(color: whiteText, fontSize: 16),
                            icon: const Icon(Icons.arrow_drop_down, color: neonYellow),
                            hint: const Text('Select Location', style: TextStyle(color: whiteText70)),
                            value: _selectedLandmarkId,
                            items: _landmarks.map((landmark) {
                              return DropdownMenuItem<int>(
                                value: landmark['landmark_id'] as int,
                                child: Text(landmark['name'] ?? 'Unknown'),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedLandmarkId = val),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pupRedBright,
                        foregroundColor: whiteText,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 10,
                        shadowColor: pupRedBright.withOpacity(0.5),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator(color: whiteText, strokeWidth: 2))
                          : const Text('SUBMIT EVENT',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),

            // 3. FLOATING BACK BUTTON (Positioned Top Left in SafeArea)
            Positioned(
              top: 50, // Adjust for safe area
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
      ),
    );
  }
}