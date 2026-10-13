import 'dart:async'; // Required for Timer
import 'dart:math'; // Required for random number generation
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../main.dart'; // To access 'supabase' client
import '../../../routes/app_routes.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  // --- Username Logic Variables ---
  Timer? _debounce;
  bool _isCheckingUsername = false;
  bool _isUsernameAvailable = true; // Default to true until checked
  String? _usernameErrorText;
  List<String> _usernameSuggestions = [];

  // --- Style Constants ---
  static const Color pupRed = Color(0xFF850909);
  static const Color lightGreyFill = Color(0xFFE0E0E0);
  static const double fieldRadius = 50.0;

  @override
  void dispose() {
    _debounce?.cancel();
    _usernameController.dispose();
    super.dispose();
  }

  // --- 1. USERNAME CHECKING LOGIC ---
  void _onUsernameChanged(String value) {
    setState(() {
      _usernameSuggestions = [];
      _usernameErrorText = null;
      _isUsernameAvailable = true;
    });

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.isNotEmpty && value.length >= 3) {
        _checkUsernameAvailability(value);
      }
    });
  }

  Future<void> _checkUsernameAvailability(String username) async {
    setState(() => _isCheckingUsername = true);

    try {
      final data = await supabase
          .from('users')
          .select('username')
          .eq('username', username)
          .maybeSingle();

      if (data != null) {
        setState(() {
          _isUsernameAvailable = false;
          _usernameErrorText = "Username is already taken.";
          _generateSuggestions(username);
        });
      } else {
        setState(() {
          _isUsernameAvailable = true;
          _usernameErrorText = null;
        });
      }
    } catch (e) {
      debugPrint("Error checking username: $e");
    } finally {
      setState(() => _isCheckingUsername = false);
    }
  }

  void _generateSuggestions(String baseUsername) {
    final random = Random();
    final suggestions = <String>[];
    suggestions.add("$baseUsername${random.nextInt(100) + 1}");
    suggestions.add("${baseUsername}2024");
    suggestions.add("${baseUsername}_pup");

    setState(() {
      _usernameSuggestions = suggestions;
    });
  }

  void _applySuggestion(String suggestion) {
    _usernameController.text = suggestion;
    setState(() {
      _usernameSuggestions = [];
      _isUsernameAvailable = true;
      _usernameErrorText = null;
    });
    _checkUsernameAvailability(suggestion);
  }

  // --- 2. POPUP: EMAIL ALREADY EXISTS ---
  void _showAccountExistsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must choose an option
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          "Email Already Exists",
          style: TextStyle(fontWeight: FontWeight.bold, color: pupRed),
        ),
        content: const Text(
          "This email address is already registered. Please log in instead.",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pushReplacementNamed(
                  context, AppRoutes.login); // Go to Login
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: pupRed,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Go to Login",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- BACKEND LOGIC (UPDATED WITH PRE-CHECK) ---
  Future<void> _signUp() async {
    setState(() => _isLoading = true);

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // --- Validation Checks ---
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        username.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      _showError("Please fill in all required fields.");
      setState(() => _isLoading = false);
      return;
    }

    if (!_isUsernameAvailable) {
      _showError("Please choose a different username.");
      setState(() => _isLoading = false);
      return;
    }

    if (password != confirmPassword) {
      _showError("Passwords do not match.");
      setState(() => _isLoading = false);
      return;
    }

    if (password.length < 6) {
      _showError("Password must be at least 6 characters.");
      setState(() => _isLoading = false);
      return;
    }

    // -------------------------------------------------------------
    // CRITICAL: Check if email exists in 'users' table FIRST
    // -------------------------------------------------------------
    try {
      final existingUser = await supabase
          .from('users')
          .select('email')
          .eq('email', email)
          .maybeSingle();

      if (existingUser != null) {
        // Stop Everything! Show "Email Exists" Popup immediately.
        setState(() => _isLoading = false);
        _showAccountExistsDialog();
        return;
      }
    } catch (e) {
      debugPrint("Pre-check failed (might be network issue): $e");
      // We continue to auth if this check fails, to let auth handle connection errors
    }
    // -------------------------------------------------------------

    int roleId = 2; // Always Guest/General

    try {
      final AuthResponse res = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      // --- SUCCESS FLOW (Only if Auth creates a NEW user) ---
      if (res.user != null) {
        if (mounted) {
          setState(() => _isLoading = false);

          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: const Text("Account Created!"),
                content: const Text(
                  "You have successfully signed up.\n\nPlease check your email for the verification code to activate your account.",
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text(
                      "Verify Now",
                      style: TextStyle(
                        color: pupRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          );

          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => OtpVerificationDialog(
                email: email,
                roleId: roleId,
                firstName: firstName,
                lastName: lastName,
                username: username,
              ),
            );
          }
        }
      }
    } on AuthException catch (e) {
      setState(() => _isLoading = false);
      // Fallback check just in case Supabase returns the error explicitly
      if (e.message.toLowerCase().contains("already registered") ||
          e.message.toLowerCase().contains("user already exists")) {
        _showAccountExistsDialog();
      } else {
        _showError(e.message);
      }
    } catch (e) {
      _showError("An unexpected error occurred: $e");
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  InputDecoration _getInputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey.shade500,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      filled: true,
      fillColor: lightGreyFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth * 0.90;
    const double outerVerticalMargin = 1.0;
    const double innerVerticalPadding = 20.0;
    const double totalVerticalSpaceReserved =
        (outerVerticalMargin * 20) + (innerVerticalPadding * 8);

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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/images/pup_logo.png',
                            width: 100,
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Center(
                          child: Text(
                            'Create Your Account',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: pupRed,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            'Join the PUP Tour community and explore \ncampus',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('First Name'),
                                  TextField(
                                    controller: _firstNameController,
                                    decoration:
                                        _getInputDecoration(hintText: 'Juan'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('Last Name'),
                                  TextField(
                                    controller: _lastNameController,
                                    decoration: _getInputDecoration(
                                        hintText: 'Dela Cruz'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _label('Username'),
                        TextField(
                          controller: _usernameController,
                          onChanged: _onUsernameChanged,
                          decoration: _getInputDecoration(hintText: 'juandc_23')
                              .copyWith(
                            suffixIcon: _isCheckingUsername
                                ? const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : (_isUsernameAvailable &&
                                        _usernameController.text.length >= 3)
                                    ? const Icon(Icons.check_circle,
                                        color: Colors.green)
                                    : null,
                            errorText: _usernameErrorText,
                          ),
                        ),
                        if (_usernameSuggestions.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Wrap(
                              spacing: 8.0,
                              children: [
                                const Text("Suggestions: ",
                                    style: TextStyle(color: Colors.grey)),
                                ..._usernameSuggestions
                                    .map((suggestion) => GestureDetector(
                                          onTap: () =>
                                              _applySuggestion(suggestion),
                                          child: Chip(
                                            label: Text(suggestion),
                                            backgroundColor:
                                                pupRed.withOpacity(0.1),
                                            labelStyle: const TextStyle(
                                                color: pupRed, fontSize: 12),
                                          ),
                                        )),
                              ],
                            ),
                          ),
                        const SizedBox(height: 10),
                        _label('Email Address'),
                        TextField(
                          controller: _emailController,
                          decoration: _getInputDecoration(
                              hintText: 'juandelacruz@gmail.com'),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 10),
                        _label('Password'),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: _getInputDecoration(hintText: '••••••••'),
                        ),
                        const SizedBox(height: 10),
                        _label('Confirm Password'),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: _getInputDecoration(hintText: '••••••••'),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signUp,
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
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account?',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.grey.shade700),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacementNamed(
                                      context, AppRoutes.login);
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 4.0),
                                  child: Text(
                                    'Sign in here',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: pupRed,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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

// --- SEPARATE WIDGET FOR OTP DIALOG ---
class OtpVerificationDialog extends StatefulWidget {
  final String email;
  final int roleId;
  final String firstName;
  final String lastName;
  final String username;

  const OtpVerificationDialog({
    super.key,
    required this.email,
    required this.roleId,
    required this.firstName,
    required this.lastName,
    required this.username,
  });

  @override
  State<OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> {
  final TextEditingController otpController = TextEditingController();
  Timer? _timer;
  int _secondsRemaining = 60;
  bool _canResend = false;
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  Future<void> _resendCode() async {
    setState(() => _isResending = true);
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Code resent! Check your email.")),
        );
        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error resending: $e"),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _verifyOtp() async {
    setState(() => _isVerifying = true);
    final otp = otpController.text.trim();

    try {
      final AuthResponse res = await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.signup,
        token: otp,
        email: widget.email,
      );

      if (res.session != null) {
        await Supabase.instance.client.from('users').insert({
          'user_id': res.user!.id,
          'email': widget.email,
          'first_name': widget.firstName,
          'last_name': widget.lastName,
          'username': widget.username,
          'role_id': widget.roleId,
          'created_at': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          Navigator.of(context).pop();
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Verification Failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Verify Your Email"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Enter the 6-digit code sent to ${widget.email}."),
          const SizedBox(height: 20),
          TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: "Enter 6-Digit Code",
              border: OutlineInputBorder(),
              counterText: "",
            ),
          ),
          const SizedBox(height: 20),
          if (!_canResend)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  "Resend code in $_secondsRemaining s",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isResending ? null : _resendCode,
                icon: _isResending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh),
                label: Text(_isResending ? "Sending..." : "Resend Code"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF850909),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _isVerifying ? null : _verifyOtp,
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF850909)),
          child: _isVerifying
              ? const SizedBox(
                  height: 15,
                  width: 15,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Text("Verify", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
