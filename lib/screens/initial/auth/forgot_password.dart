import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <--- IMPORT SUPABASE
import '../../../../main.dart'; // <--- IMPORT YOUR MAIN CLIENT
import '../../../routes/app_routes.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // 1. CONTROLLERS
  final emailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // --- LOGIC STATE ---
  bool _isLoading = false; // To show loading spinners

  // --- Style Constants ---
  static const Color pupRed = Color((0xFF850909));
  static const Color lightGreyFill = Color(0xFFE0E0E0);
  static const Color hintTextColor = Colors.grey;
  static const double fieldRadius = 50.0;
  static const double outerVerticalMargin = 20.0;
  static const double innerVerticalPadding = 15.0;
  static const double totalVerticalSpaceReserved =
      (outerVerticalMargin * 2) + (innerVerticalPadding * 2);

  // --- [LOGIC START] BACKEND FUNCTIONS ---

  // Step 1: Send the Recovery OTP
  Future<void> _handlePasswordReset() async {
    final email = emailController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();

    // Basic Validation
    if (email.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      _showError("Please fill in all fields.");
      return;
    }
    if (newPass != confirmPass) {
      _showError("Passwords do not match.");
      return;
    }
    if (newPass.length < 6) {
      _showError("Password must be at least 6 characters.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Tell Supabase to send the recovery email
      await supabase.auth.resetPasswordForEmail(email);

      if (mounted) {
        setState(() => _isLoading = false);
        // Show the OTP Dialog
        _showOtpDialog(context, email, newPass);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("Error: ${e.toString()}");
    }
  }

  // Step 2: The OTP Dialog
  void _showOtpDialog(BuildContext context, String email, String newPassword) {
    final otpController = TextEditingController();
    bool isVerifying = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Enter Verification Code"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "We've sent a code to $email. Enter it below to confirm your new password.",
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      labelText: "6-Digit Code",
                      border: OutlineInputBorder(),
                      counterText: "",
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: pupRed),
                  onPressed: isVerifying
                      ? null
                      : () async {
                          setDialogState(() => isVerifying = true);
                          final token = otpController.text.trim();

                          try {
                            // A. Verify the Recovery OTP
                            final AuthResponse res = await supabase.auth
                                .verifyOTP(
                                  email: email,
                                  token: token,
                                  type: OtpType.recovery,
                                );

                            // B. If verification works, Update the Password
                            if (res.session != null) {
                              await supabase.auth.updateUser(
                                UserAttributes(password: newPassword),
                              );

                              if (context.mounted) {
                                Navigator.pop(dialogContext); // Close Dialog
                                _showSuccessAndExit(); // Go to Login
                              }
                            }
                          } catch (e) {
                            setDialogState(() => isVerifying = false);
                            // Show error inside dialog (using a simple print or snackbar on parent)
                            print("Error: $e");
                            // Ideally, show a small error text in the dialog here
                          }
                        },
                  child: isVerifying
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text(
                          "Confirm & Change",
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

  void _showSuccessAndExit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Success!"),
        content: const Text("Your password has been updated. Please login."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close Success Dialog
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            child: const Text("Go to Login"),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // --- [LOGIC END] ---

  InputDecoration _getInputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: hintTextColor,
        fontWeight: FontWeight.normal,
        fontSize: 16,
      ),
      filled: true,
      fillColor: lightGreyFill,
      contentPadding: const EdgeInsets.fromLTRB(20, 3, 20, 3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(fieldRadius),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _label(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth * 0.90;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxHeight =
                    constraints.maxHeight - totalVerticalSpaceReserved;

                return Container(
                  width: containerWidth,
                  margin: const EdgeInsets.symmetric(
                    vertical: outerVerticalMargin,
                  ),
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(innerVerticalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/images/pup_logo.png',
                            width: 100,
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "Forgot Password",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: pupRed,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Secure Account Recovery & Password Reset",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _label("Email Address"),
                        ),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _getInputDecoration(
                            hintText: "user@example.com",
                          ),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _label("New Password"),
                        ),
                        TextField(
                          controller: newPasswordController,
                          obscureText: true,
                          decoration: _getInputDecoration(hintText: "••••••••"),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _label("Confirm Password"),
                        ),
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: true,
                          decoration: _getInputDecoration(hintText: "••••••••"),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 35,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : _handlePasswordReset, // <--- WIRED BUTTON TO LOGIC
                            style: ElevatedButton.styleFrom(
                              backgroundColor: pupRed,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 15,
                                    height: 15,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Reset Password",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
