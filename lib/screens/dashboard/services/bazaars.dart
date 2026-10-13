import 'dart:ui'; // Required for Blur effects
import 'package:flutter/material.dart';

// Import path based on your folder structure
import 'package:puptourapp/widgets/main_layout.dart';
import '../../../../widgets/app_footer.dart'; // We need to add Footer manually inside the scroll view now

class FoodBazaarsScreen extends StatefulWidget {
  const FoodBazaarsScreen({super.key});

  @override
  State<FoodBazaarsScreen> createState() => _FoodBazaarsScreenState();
}

class _FoodBazaarsScreenState extends State<FoodBazaarsScreen> {
  // --- Style Constants ---
  static const Color neonYellow = Color(0xFFFFEA00);
  static const Color pupMaroon = Color(0xFF800000); 
  static const Color pupRedBright = Color(0xFFAA0000); 
  static const Color whiteText = Colors.white;
  static const Color whiteText70 = Colors.white70;

  String? selectedCategory = 'All Categories';
  List<String> categories = [
    'All Categories',
    'Food & Drinks',
    'Printing Shop',
    'School Supplies'
  ];
  bool isDropdownOpen = false;

  // --- Background Widget ---
  Widget _buildBackground() {
    return Container(
      color: const Color(0xFF1A0505), // Very Dark Maroon/Black Base
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: neonYellow.withOpacity(0.15),
                boxShadow: [
                  BoxShadow(color: neonYellow.withOpacity(0.2), blurRadius: 100, spreadRadius: 20)
                ],
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: pupMaroon.withOpacity(0.4),
                boxShadow: [
                  BoxShadow(color: pupMaroon.withOpacity(0.4), blurRadius: 100, spreadRadius: 40)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Dropdown Widget ---
  Widget _buildCategoryDropdown() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isDropdownOpen = !isDropdownOpen;
            });
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 5),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Image.asset('assets/icons/category.png', width: 24, height: 24, color: neonYellow),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        selectedCategory!,
                        style: const TextStyle(fontSize: 16, color: whiteText, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Icon(
                      isDropdownOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: whiteText70,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isDropdownOpen)
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.0),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categories.map((category) {
                    final isSelected = selectedCategory == category;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                          isDropdownOpen = false;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
                        decoration: BoxDecoration(
                          color: isSelected ? pupMaroon.withOpacity(0.5) : Colors.transparent,
                          border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? neonYellow : whiteText,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // --- Search Bar Widget ---
  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
          ),
          child: TextField(
            style: const TextStyle(color: whiteText),
            cursorColor: neonYellow,
            decoration: InputDecoration(
              hintText: "Search...",
              hintStyle: const TextStyle(color: whiteText70),
              contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
              border: InputBorder.none,
              suffixIcon: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset('assets/icons/search.png', width: 24, height: 24, color: neonYellow),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      // --- IMPORTANT: WE FLIP THE SWITCHES HERE ---
      // 1. Disable standard scrolling (Bazaars handles its own scroll view)
      enableScroll: false, 
      // 2. Disable white background (Bazaars uses Dark Cinematic)
      useStandardBackground: false,
      // 3. Extend body behind app bar (For glassmorphism)
      extendBodyBehindAppBar: true, 
      // 4. We still want the header (but now it floats over our dark background)
      showHeader: true,

      child: Stack(
        children: [
          // 1. Background Layer
          _buildBackground(),

          // 2. Scrollable Content
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: SafeArea(
                      // SafeArea keeps content below the status bar/app bar
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSearchBar(),
                                const SizedBox(height: 10),
                                _buildCategoryDropdown(),
                                const SizedBox(height: 30),
                                const Text(
                                  "Available Campus Stalls",
                                  style: TextStyle(color: whiteText, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                ),
                                const SizedBox(height: 20),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(25),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "PUP Main Campus Food Information",
                                            style: TextStyle(color: neonYellow, fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 10),
                                          const Text(
                                            "Please visit CampusCrave to view the current list and sort of stalls available in PUP Campus Main.",
                                            style: TextStyle(color: whiteText70, fontSize: 15, height: 1.5),
                                          ),
                                          const SizedBox(height: 25),
                                          SizedBox(
                                            width: double.infinity,
                                            height: 50,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Navigating to Food Website... (Placeholder)')),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: pupRedBright,
                                                foregroundColor: whiteText,
                                                shadowColor: pupRedBright.withOpacity(0.5),
                                                elevation: 8,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                              ),
                                              child: const Text("Go to CampusCrave", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Manually adding AppFooter because we disabled MainLayout's automatic footer
                          const AppFooter(),
                        ],
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