import 'package:flutter/material.dart';
import 'package:puptourapp/routes/app_routes.dart';
import 'package:puptourapp/screens/guest/navigation_drawer_guest.dart';
import 'package:puptourapp/widgets/app_header.dart';
import 'package:puptourapp/widgets/app_footer.dart';
import 'package:puptourapp/widgets/customer_service.dart'; // Movable button
import 'dart:ui';

class GuestFoodBazaarsScreen extends StatefulWidget {
  const GuestFoodBazaarsScreen({super.key});

  @override
  State<GuestFoodBazaarsScreen> createState() => _GuestFoodBazaarsScreenState();
}

class _GuestFoodBazaarsScreenState extends State<GuestFoodBazaarsScreen> {
  static const Color pupRedDark = Color(0xFF850909);
  static const Color whiteText = Colors.white;
  static const Color greyText = Colors.grey;

  String? selectedCategory = 'All Categories';
  List<String> categories = [
    'All Categories',
    'Food & Drinks',
    'Printing Shop',
    'School Supplies'
  ];
  bool isDropdownOpen = false;
  bool _isLoggedIn = false;

  Widget _buildCategoryDropdown() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isDropdownOpen = !isDropdownOpen;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(top: 10, bottom: 5),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1.0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/icons/category.png',
                  width: 30,
                  height: 30,
                  color: pupRedDark,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectedCategory!,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                Icon(
                  isDropdownOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: pupRedDark,
                ),
              ],
            ),
          ),
        ),
        if (isDropdownOpen)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: whiteText,
              border: Border.all(color: Colors.grey.shade300, width: 1.0),
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: categories.map((category) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                      isDropdownOpen = false;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 15.0),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: selectedCategory == category
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: selectedCategory == category
                            ? pupRedDark
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search...",
          contentPadding:
          const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
          border: InputBorder.none,
          suffixIcon: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Image.asset(
              'assets/icons/search.png',
              width: 24,
              height: 24,
              color: pupRedDark,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppHeader(),
      drawer: const NavigationDrawerGuest(),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight, // Make content fill screen
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSearchBar(),
                              _buildCategoryDropdown(),
                              const SizedBox(height: 20),
                              const Text(
                                "Available Campus Stalls",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 25),
                              // 🔑 START OF TARGET CONTAINER MODIFICATION
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: pupRedDark, width: 2),
                                ),
                                // 🔑 KEY CHANGE 1: Use a Stack to layer the blur and button
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // --- Base Layer: Original Card Content ---
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "PUP Main Campus Food Information",
                                          style: TextStyle(
                                            color: pupRedDark,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          "Please visit CampusCrave to view the current list and sort of stalls available in PUP Campus Main.",
                                          style: TextStyle(
                                            color: greyText,
                                            fontSize: 16,
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 30),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 45,
                                          child: ElevatedButton(
                                            // Button disabled if not logged in
                                            onPressed: _isLoggedIn
                                                ? () {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Navigating to Food Website... (Placeholder)')),
                                              );
                                            }
                                                : null, // Disabled when logged out
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: pupRedDark,
                                              foregroundColor: whiteText,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(30),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: const Text(
                                              "Go to CampusCrave",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),

                                    // 🔑 KEY CHANGE 2: Blur and Lock Overlay
                                    if (!_isLoggedIn) // Show only if NOT logged in
                                      Positioned.fill(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10), // Match container's border radius
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 5.0, sigmaY: 5.0), // Apply blur
                                            child: Container(
                                              // Semi-transparent overlay
                                              color: Colors.black.withOpacity(0.3),
                                              alignment: Alignment.center,
                                              child: SizedBox(
                                                width: 250,
                                                height: 50,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pushNamed(context, AppRoutes.login);
                                                    // Example: Navigator.pushNamed(context, AppRoutes.login);
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: pupRedDark,
                                                    foregroundColor: whiteText,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(10),
                                                    ),
                                                    elevation: 5,
                                                  ),
                                                  child: const Text(
                                                    "Log-in to Visit CampusCrave", // 🔑 Updated button text
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // 🔑 END OF TARGET CONTAINER MODIFICATION
                            ],
                          ),
                        ),
                        const Spacer(), // Push footer to bottom if content is short
                        const AppFooter(), // Footer untouched
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const DraggableCustomerServiceButton(iconSize: 50), // Floating button
        ],
      ),
    );
  }
}