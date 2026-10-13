import 'dart:ui'; // Required for Blur
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../main.dart'; // For Supabase client access

// --- IMPORTS ---
import 'package:puptourapp/widgets/main_layout.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  // --- Style Constants ---
  static const Color neonYellow = Color(0xFFFFEA00);
  static const Color pupMaroon = Color(0xFF800000); 
  static const Color whiteText = Colors.white;
  static const Color whiteText70 = Colors.white70;

  // --- Controllers ---
  final emailController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmNewPasswordVisible = false;
  bool _isLoading = false;

  // --- Init ---
  @override
  void initState() {
    super.initState();
    final user = supabase.auth.currentUser;
    if (user != null && user.email != null) {
      emailController.text = user.email!;
    }
  }

  // --- Backend Logic ---
  Future<void> _changePassword() async {
    final currentPass = currentPasswordController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();
    final email = emailController.text.trim();

    if (currentPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      _showError("Please fill in all fields");
      return;
    }
    if (newPass != confirmPass) {
      _showError("New passwords do not match");
      return;
    }
    if (newPass.length < 6) {
      _showError("New password must be at least 6 characters");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Re-authenticate
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: currentPass,
      );

      // 2. Update Password
      if (res.user != null) {
        await supabase.auth.updateUser(UserAttributes(password: newPass));

        if (mounted) {
          _showSuccess();
          currentPasswordController.clear();
          newPasswordController.clear();
          confirmPasswordController.clear();
        }
      }
    } on AuthException {
      _showError("Incorrect current password.");
    } catch (e) {
      _showError("An unexpected error occurred.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Success", style: TextStyle(color: neonYellow, fontWeight: FontWeight.bold)),
          content: const Text("Your password has been changed successfully.", style: TextStyle(color: whiteText)),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: pupMaroon),
              onPressed: () => Navigator.pop(context),
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
            top: -50, right: -50,
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
  Widget _buildGlassTextField({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    bool isPassword = false,
    bool isVisible = false,
    Function(bool)? toggleVisibility,
    bool isReadOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: whiteText, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: isReadOnly ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: TextField(
                  controller: controller,
                  obscureText: isPassword && !isVisible,
                  readOnly: isReadOnly,
                  style: TextStyle(color: isReadOnly ? whiteText70 : whiteText),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: const TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    suffixIcon: isPassword
                        ? IconButton(
                            icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: whiteText70),
                            onPressed: () => toggleVisibility?.call(!isVisible),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      // MainLayout Configuration
      enableScroll: false,
      useStandardBackground: false,
      extendBodyBehindAppBar: true,
      showHeader: false, // Hide header to use custom Back Button

      child: Stack(
        children: [
          _buildBackground(),

          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            
                            // Header
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.arrow_back_ios_new, color: whiteText, size: 20),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                const Text("Reset Password", style: TextStyle(color: whiteText, fontSize: 24, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            
                            const SizedBox(height: 30),

                            // Form
                            _buildGlassTextField(
                              label: "Email Address",
                              placeholder: "Your email",
                              controller: emailController,
                              isReadOnly: true,
                            ),
                            _buildGlassTextField(
                              label: "Current Password",
                              placeholder: "Enter current password",
                              controller: currentPasswordController,
                              isPassword: true,
                              isVisible: _isCurrentPasswordVisible,
                              toggleVisibility: (v) => setState(() => _isCurrentPasswordVisible = v),
                            ),
                            _buildGlassTextField(
                              label: "New Password",
                              placeholder: "Enter new password",
                              controller: newPasswordController,
                              isPassword: true,
                              isVisible: _isNewPasswordVisible,
                              toggleVisibility: (v) => setState(() => _isNewPasswordVisible = v),
                            ),
                            _buildGlassTextField(
                              label: "Confirm New Password",
                              placeholder: "Re-enter new password",
                              controller: confirmPasswordController,
                              isPassword: true,
                              isVisible: _isConfirmNewPasswordVisible,
                              toggleVisibility: (v) => setState(() => _isConfirmNewPasswordVisible = v),
                            ),

                            const SizedBox(height: 20),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _changePassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: pupMaroon,
                                  foregroundColor: whiteText,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  elevation: 5,
                                  shadowColor: pupMaroon.withOpacity(0.5),
                                ),
                                child: _isLoading
                                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: whiteText, strokeWidth: 2))
                                    : const Text("Update Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                              ),
                            ),

                            const Spacer(),
                            const SizedBox(height: 40), // Extra space at bottom since footer is gone
                          ],
                        ),
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