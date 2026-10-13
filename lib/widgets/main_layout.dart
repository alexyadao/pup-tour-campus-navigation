import 'package:flutter/material.dart';
import 'package:puptourapp/widgets/app_header.dart';
import 'package:puptourapp/widgets/app_navigation_drawer.dart';
import 'package:puptourapp/widgets/app_footer.dart';
import 'package:puptourapp/widgets/customer_service.dart';

class MainLayout extends StatelessWidget {
  final Widget child; // The unique content for each page
  final bool showHeader; // Option to hide header if needed
  final bool showFooter; // Option to hide footer if needed
  
  // --- NEW PARAMETERS (With Defaults to Protect Old Pages) ---
  final bool enableScroll; // Default: true. Set to false if the child handles scrolling.
  final bool useStandardBackground; // Default: true. Set to false for custom backgrounds.
  final bool extendBodyBehindAppBar; // Default: false. Set to true for glassmorphism.

  const MainLayout({
    super.key,
    required this.child,
    this.showHeader = true,
    this.showFooter = true,
    // Defaults ensure existing pages don't break:
    this.enableScroll = true, 
    this.useStandardBackground = true,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Allow transparent background if we turn off the standard one
      backgroundColor: useStandardBackground ? Colors.white : Colors.transparent,
      // Crucial for Glassmorphism (allows content to go behind header)
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      
      appBar: showHeader ? const AppHeader() : null,
      drawer: const AppNavigationDrawer(),
      
      body: Stack(
        children: [
          // 1. GLOBAL BACKGROUND
          // Only show this if useStandardBackground is true (default)
          if (useStandardBackground)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF9F9F9), Color(0xFFEEEEEE)],
                ),
              ),
            ),
          
          // 2. PAGE CONTENT LOGIC
          if (enableScroll)
            // OLD LOGIC: For pages that rely on MainLayout for scrolling/footer
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          child, 
                          if (showFooter) ...[
                            const Spacer(),
                            const AppFooter(),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          else
            // NEW LOGIC: Just render the child directly.
            // This lets Bazaars.dart handle its own background, scrolling, and footer.
            child,

          // 3. Customer Service Floating Button
          const DraggableCustomerServiceButton(iconSize: 50),
        ],
      ),
    );
  }
}