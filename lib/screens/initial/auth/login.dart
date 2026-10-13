import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../routes/app_routes.dart';
import '../../../../main.dart'; // <--- IMPORTANT: Import main.dart to use 'supabase' client

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // State
  bool _isLoading = false;

  // Colors
  static const Color pupRed = Color(0xFF850909);
  static const Color lightGreyFill = Color(0xFFE0E0E0);

  Future<void> _signIn() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Perform Supabase Auth Login
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final User? user = res.user;

      if (user != null) {
        // 2. Fetch the Role ID
        final Map<String, dynamic> data = await supabase
            .from('users')
            .select('role_id')
            .eq('user_id', user.id)
            .single();

        final int roleId = data['role_id'];

        if (mounted) {
          // 3. Navigate based on Role ID
          if (roleId == 2) {
            // UPDATED: Only explicitly checking Role ID 2 (General User/Guest)
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          } else if (roleId == 3) {
            // Admin
            Navigator.pushReplacementNamed(context, AppRoutes.admin);
          } else {
            // Fallback (Safe default for any other role, including legacy role 1)
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        }
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      debugPrint("LOGIN ERROR: $error");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth * 0.90;

    const double outerVerticalMargin = 20.0;
    const double innerVerticalPadding = 30.0;
    const double totalVerticalSpaceReserved =
        (outerVerticalMargin * 2) + (innerVerticalPadding * 2);

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
                    borderRadius: BorderRadius.circular(30),
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
                        const SizedBox(height: 10),
                        const Center(
                          child: Text(
                            "Welcome to PUP Tour",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: pupRed,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            "Digital Campus Navigation & Virtual Tour \nPlatform",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          "Email Address",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "juandelacruz@gmail.com",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.bold,
                            ),
                            filled: true,
                            fillColor: lightGreyFill,
                            contentPadding: const EdgeInsets.fromLTRB(
                              25,
                              12,
                              25,
                              12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(60),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(60),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(60),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "Password",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "••••••••",
                            hintStyle: TextStyle(
                              fontSize: 20,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.bold,
                            ),
                            filled: true,
                            fillColor: lightGreyFill,
                            contentPadding: const EdgeInsets.fromLTRB(
                              25,
                              12,
                              25,
                              12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(60),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(60),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(60),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.forgotPassword,
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                "Forgot password?",
                                style: TextStyle(
                                  color: pupRed,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signIn,
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
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text(
                                    "Sign In",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.guestHome,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: pupRed,
                              side: const BorderSide(color: pupRed, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              "Continue as guest",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have account? ",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.signup,
                                  );
                                },
                                child: const Text(
                                  "Sign up here",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: pupRed,
                                    fontWeight: FontWeight.bold,
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
