import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:puptourapp/widgets/main_layout.dart';

// --- Data Models ---
class BuildingInfo {
  final String title;
  final String subtitle;
  final String imagePath;
  final List<String> tags;
  // Map connects a specific TAG to a specific List of Sections
  final Map<String, List<BuildingSection>> content;

  BuildingInfo({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.tags,
    required this.content,
  });
}

class BuildingSection {
  final String header;
  final List<String> items;

  BuildingSection(this.header, this.items);
}

class BuildingListScreen extends StatefulWidget {
  const BuildingListScreen({super.key});

  static const String routeName = '/buildings';

  @override
  State<BuildingListScreen> createState() => _BuildingListScreenState();
}

class _BuildingListScreenState extends State<BuildingListScreen> {
  // --- Constants ---
  static const double horizontalPadding = 20.0;
  static const Color titleColor = Color(0xFF2D2D2D);
  static const Color subtitleColor = Color(0xFF555555);

  // --- THE COMPLETE DATA REPOSITORY ---
  final List<BuildingInfo> buildings = [
    // 1. MAIN BUILDING
    BuildingInfo(
      title: "Main Building",
      subtitle: "The heart of the campus. Home to administrative offices and the iconic Dome.",
      imagePath: "assets/images/main_building.png",
      tags: const ["Historic", "Offices"],
      content: {
        // BUTTON A: HISTORIC INFO
        "Historic": [
          BuildingSection("Mabini Memorial Wing", [
            "Chronology: Evolution from Manila Business School (1904) to University (1978).",
            "The Four Wings: Uniquely designed with North, South, East, and West wings converging at a center.",
            "Landmark: Flanked by the Mabini Obelisk, symbolizing 'sublime' intellect.",
            "Significance: The administrative brain and most enduring symbol of the university."
          ]),
        ],
        // BUTTON B: OFFICES (Detailed List)
        "Offices": [
          BuildingSection("South Wing - 1st Floor", [
            "S101 Fund Management Office", 
            "S103 Budget Service Office", 
            "S104-S105 Office of the University Registrar", 
            "S106 Payroll Section", 
            "S107 Accounting Division Student Service Section",
            "S108-S109 Accounting Office"
          ]),
          BuildingSection("South Wing - 2nd Floor", [
            "S215 VP for Student Services",
            "S214 VP for Admission",
            "S213 Dr. Ofelia M. Carague Conference Room",
            "S212 VP for Academic Affairs",
            "S211 VP for Branches and Campuses",
            "S210 Office of the Executive VP",
            "S209 Dr. Pablo T. Mateo Jr. Conference Room",
            "S208 Office of the President",
            "S206 Office of the University/Board Secretary",
            "S205 Dr. Zenaida A. Olonan Conference Room",
            "S204 VP for Research, Extension and Development",
            "S203 VP for Finance",
            "S202 Network Operations Center (Server Room)"
          ]),
          BuildingSection("South Wing - 3rd Floor", [
            "S302 Special Programs and Projects Office (SPPO)",
            "S303 Provident Fund Office",
            "S304 Office of the International Affairs",
            "S305 Human Resource Management Department",
            "S309 University Legal Counsel Office",
            "S311 General Administrative Support Services",
            "S312 Physical Planning and Development Office (PPDO)",
            "S314 Institutional Planning Office",
            "S315 BAC Conference Room",
            "S316 PMO - BAC Secretariat Section",
            "S318 Procurement Management Office"
          ]),
          BuildingSection("South Wing - 4th Floor", [
            "S401 Nemesio E. Prudente Room",
            "S402 Dr. Nemesio E. Prudente Conference Room",
            "S404 Center for Language and Literature Studies",
            "S405 Institute for Culture and Language Studies",
            "S406 Research Institute for Sustainable Engineering",
            "S407 Intellectual Property Management Office",
            "S408 Institute for Science and Technology Research",
            "S409 Gender and Development Office",
            "S410 Center for Economics and Business Studies",
            "S411 Center for Social Inclusivity Studies",
            "S412 Research Institute for Human and Social Development",
            "S413 Research Institute for Strategic Foresight",
            "S415 Institutional Quality Management System Office",
            "S418-419 CAL Laboratory Pangwika / Language Lab",
            "S420-421 Extension Management Office",
            "S422 Innovations and Technology Support",
            "S423 Research Management and Intellectual Property",
            "S424 Office of the Director",
            "S425 Publications Office"
          ]),
          BuildingSection("South Wing - 5th Floor", [
            "S518 College of Accountancy and Finance",
            "S517 College of Accountancy and Finance Faculty Room",
            "S515 Department of Mathematics and Statistics",
            "S514 College of Science Faculty Room",
            "S512 CCIS Dean and Chairperson’s Office",
            "S507 CCIS Laboratory Operations Office",
            "S506 CCIS Faculty Room"
          ]),
          BuildingSection("South Wing - 6th Floor", [
            "S614 Psychology and Human Services Laboratory",
            "S613 CSSD Office of the Dean",
            "S612 College of Social Sciences and Development",
            "S610 Institute for Data and Statistical Analysis",
            "S601 College of Arts and Letters Office of the Dean",
            "S602 CPSPA Graduate Studies",
            "S603 CPSPA Dean’s and Chairperson’s Office",
            "S604 College of Education Graduate Studies",
            "S605 CBA Graduate Studies",
            "S607 College of Arts and Letters Chairpersons Office",
            "Claro M. Recto Hall"
          ]),
          BuildingSection("East Wing", [
            "E608 CS Laboratory Office (6th Floor)",
            "E205 CC Academic Research and Administration (2nd Floor)",
            "E203 CC Extension Service Office",
            "E201 College of Cooperatives / PUP iKonsumo",
            "E204 CSSD Faculty Sociology and Anthropology",
            "E202 National Service Training Program Office",
            "E200 Office of the Unyon ng mga Guro sa PUP",
            "E208 Unaka PUP Office",
            "E101 FREE - PUP Office (1st Floor)",
            "E102 HRD Records Office",
            "E103 Department of Military Science and Tactics",
            "E104 Corps of Cadets Headquarters",
            "E105 Medical Clinic Services",
            "E106 Dental Clinic Services",
            "E107 Office of the Director Medical Health Services",
            "E108 Office of the Director Public Affairs Office"
          ]),
          BuildingSection("West Wing", [
            "W119 Office of Scholarship and Financial Assistance",
            "Admission and Registration Services Section",
            "Public Assistance and Complaint Desk",
            "W201 Disaster Resilience Institute",
            "W209 SHS Department Admission’s Office",
            "W211 SHA Department Office of the Principal",
            "W300 College of Education Faculty Room",
            "Department of Elementary and Secondary Education",
            "Department of Business Teacher Education",
            "Department of Library and Information Science"
          ]),
          BuildingSection("The Dome", [
            "6th Floor: College of Science",
            "5th Floor: College of Accountancy",
            "4th Floor: College of Business Administration",
            "3rd Floor: College of Education",
            "2nd Floor: Resource Generation Office",
            "1st Floor: Internal Audit Office"
          ]),
        ]
      },
    ),

    // 2. CHARLIE DEL ROSARIO
    BuildingInfo(
      title: "Charlie Del Rosario",
      subtitle: "A central hub for student organizations, events, and student services.",
      imagePath: "assets/images/charlie.png",
      tags: const ["Events", "Offices"],
      content: {
        // BUTTON A: EVENTS INFO
        "Events": [
          BuildingSection("The Student Hub", [
             "Official home of the Central Student Council (CSC) and Commission on Elections (USCE)."
          ]),
          BuildingSection("A Sanctuary for Activism", [
             "Named after martyr Charlie Del Rosario (1971).",
             "Hosts forums on human rights and national issues."
          ]),
          BuildingSection("Workshops", [
             "Primary venue for leadership training and organizational planning."
          ]),
        ],
        // BUTTON B: OFFICES LIST
        "Offices": [
          BuildingSection("1st Floor", [
             "DOST SEI Satellite Office", 
             "University Security and Safety Office", 
             "Scholar’s Lounge Conference Room", 
             "Campus Ministry Office"
          ]),
          BuildingSection("2nd Floor", [
             "Student Constitutional Commission", 
             "Sentral Na Konseho ng Mag-Aaral (SKM)", 
             "Commission on Student Org Accreditation",
             "Commission on Audit / Elections",
             "Office of the Student Regent",
             "Rm 203 Office of Counseling and Psychological Services",
             "Rm 205 Guidance and Counseling Services", 
             "Rm 208 Office of Student Services",
             "Rm 210 Office of the Director for Student Services",
             "Rm 212 Center for Creative Writing"
          ]),
          BuildingSection("Sampaguita Building", [
             "1st Floor: University Records Management Office", 
             "2nd Floor: Communication Management Office (CMO)",
             "3rd Floor: Alumni Relations and Career Development"
          ]),
        ]
      },
    ),

    // 3. NINOY AQUINO LIBRARY
    BuildingInfo(
      title: "Ninoy Aquino LRC",
      subtitle: "Comprehensive resources, quiet study halls, and research archives.",
      imagePath: "assets/images/library.png",
      tags: const ["Law", "Offices"],
      content: {
        // BUTTON A: LAW INFO
        "Law": [
          BuildingSection("PUP College of Law", [
             "Houses specialized law libraries and research facilities for jurisprudence."
          ]),
          BuildingSection("Technological Integration", [
             "3rd Floor E-Learning Center and DOST-STARBOOKS (Digital Library)."
          ]),
          BuildingSection("Heritage Preservation", [
             "Permanent home of the restored Apolinario Mabini Shrine."
          ]),
          BuildingSection("Open University", [
             "Accommodates distance learners and graduate students."
          ]),
        ],
        // BUTTON B: OFFICES/LOCATIONS
        "Offices": [
          BuildingSection("1st Floor - College of Law", [
             "PUP COLLEGE OF LAW",
             "Student Lounge", 
             "Faculty Lounge", 
             "Office of the Dean", 
             "Registrar Office (for Law)", 
             "Recap Office"
          ]),
          BuildingSection("3rd Floor", ["PUP University Library"]),
          BuildingSection("4th Floor", [
             "Bulwagang Balagtas", 
             "University Library Multimedia Services", 
             "Technology Business Incubation and Development",
             "Bulwagang Bonifacio"
          ]),
        ]
      },
    ),

    // 4. PUP GYM
    BuildingInfo(
      title: "PUP Gymnasium",
      subtitle: "The center for sports development and physical fitness.",
      imagePath: "assets/images/gym.png",
      tags: const ["Events", "Location"],
      content: {
        // BUTTON A: EVENTS INFO
        "Events": [
          BuildingSection("Multipurpose Facility", [
             "Expanded Capacity: Accommodates up to 2,000 people with improved ventilation.",
             "FIBA Standards: Professional flooring and wireless scoring for inter-collegiate sports.",
             "Accessibility: Equipped with elevators and ramps for PWDs."
          ]),
        ],
        // BUTTON B: LOCATION/FACILITIES
        "Location": [
          BuildingSection("Facilities", [
             "Basketball Court", 
             "Badminton Court", 
             "CELX (Community Extension Learning Center)", 
             "Judo/Karate Room (2nd Floor)", 
             "Lights and Sounds Control Room (2nd Floor)",
             "Electrical Room (Authorized only)",
             "Sports Development Program Office"
          ]),
        ]
      },
    ),

    // 5. NUTRITION & FOOD SCIENCE
    BuildingInfo(
      title: "College of Nutrition & Food Science",
      subtitle: "Dedicated to food technology and nutritional sciences.",
      imagePath: "assets/images/cnfs.png", 
      tags: const ["Nutrition", "Labs"],
      content: {
        // BUTTON A: NUTRITION INFO
        "Nutrition": [
          BuildingSection("College of Science", [
             "Nutrition and Dietetics (ND): Clinical nutrition research and therapeutic diet planning.",
             "Food Technology (FT): Focus on food processing, safety, and pilot plants.",
             "Research Institute (RIST): Studies on biotechnology and environmental science."
          ]),
        ],
        // BUTTON B: LABS/ROOMS
        "Labs": [
          BuildingSection("1st Floor", [
             "FT/ND Chair’s Office", 
             "Nutrition Clinic", 
             "Reading Room", 
             "Gen Laboratory Stockroom", 
             "Faculty Room",
             "Lab Rooms: FS 101, 102, 103"
          ]),
          BuildingSection("2nd Floor", [
             "FT Lecture Rooms: 101, 102, 103",
             "FT Locker Area",
             "Student Lounge / Study Area",
             "ND Lecture Rooms: 101, 102, 103"
          ]),
          BuildingSection("Extension", ["PILOT FOOD PLANT: RM -ES 104"]),
        ]
      },
    ),

    // 6. LINEAR PARK
    BuildingInfo(
      title: "Linear Park Building",
      subtitle: "Services for university records and catering.",
      imagePath: "assets/images/linear_park.png",
      tags: const ["Services"],
      content: {
        "Services": [
          BuildingSection("Offices", [
             "University Records Management Office", 
             "University Catering Services Section"
          ]),
        ]
      },
    ),

    // 7. OVAL
    BuildingInfo(
      title: "PUP Grandstand/Oval",
      subtitle: "Outdoor track and field for athletic training.",
      imagePath: "assets/images/oval.png",
      tags: const ["Events", "Outdoor"],
      content: {
        // BUTTON A: EVENTS INFO
        "Events": [
          BuildingSection("The Grand Open-Air Theater", [
             "The Pylon Run: Venue for the annual 'Oblation-style' run in October.",
             "Founding Anniversary: Site of grand parades and cultural performances.",
             "Sintang Lakbay Path: Historical tour stop featuring mural reliefs."
          ]),
        ],
        // BUTTON B: OUTDOOR FACILITIES
        "Outdoor": [
          BuildingSection("Facilities", ["PUP Tahanan ng Atleta"]),
        ]
      },
    ),

    // 8. TAHANAN NG ALUMNI
    BuildingInfo(
      title: "Tahanan ng Alumni",
      subtitle: "Gathering place for the Federation of Alumni Associations.",
      imagePath: "assets/images/pup_tahanan_ng_alumni.png",
      tags: const ["Offices"],
      content: {
        "Offices": [
           BuildingSection("1st Floor", ["Federation of Alumni Associations in PUP, Inc."]),
           BuildingSection("2nd Floor", ["FAMO"]),
        ]
      },
    ),

    // 9. PE BUILDING (CHK)
    BuildingInfo(
      title: "PE Building (CHK)",
      subtitle: "College of Human Kinetics and sports training.",
      imagePath: "assets/images/chk.png", 
      tags: const ["Training", "Classrooms"],
      content: {
        // BUTTON A: TRAINING INFO
        "Training": [
           BuildingSection("College of Human Kinetics", [
             "Ladderized Programs: BPEd with certificates in coaching and officiating.",
             "Sports Science: Oversees Swimming Pool and tennis courts as laboratories.",
             "Pathways: Training for Sports Medics, Facility Managers, and Research Analysts."
           ]),
        ],
        // BUTTON B: CLASSROOMS/FACILITIES
        "Classrooms": [
           BuildingSection("1st Floor", [
             "College of Human Kinetics", 
             "Faculty Room", 
             "CHK Judo Room"
           ]),
           BuildingSection("2nd Floor", [
             "Naturopathy Training Room", 
             "Instructional Materials Center"
           ]),
        ]
      },
    ),
  ];

  // --- Helper: Icon Generator based on Keywords ---
  IconData _getIconForText(String text) {
    String lower = text.toLowerCase();
    if (lower.contains("office") || lower.contains("admin") || lower.contains("dean") || lower.contains("president")) return Icons.business;
    if (lower.contains("court") || lower.contains("gym") || lower.contains("oval") || lower.contains("dojo") || lower.contains("judo")) return Icons.sports_basketball;
    if (lower.contains("clinic") || lower.contains("medical") || lower.contains("dental")) return Icons.medical_services;
    if (lower.contains("library") || lower.contains("reading")) return Icons.local_library;
    if (lower.contains("lab") || lower.contains("science")) return Icons.science;
    if (lower.contains("food") || lower.contains("catering") || lower.contains("nutrition")) return Icons.restaurant;
    if (lower.contains("room") || lower.contains("lecture") || lower.contains("hall") || lower.contains("class") || lower.contains("center")) return Icons.meeting_room;
    if (lower.contains("security") || lower.contains("police")) return Icons.security;
    if (lower.contains("student") || lower.contains("council") || lower.contains("org") || lower.contains("alumni")) return Icons.school;
    return Icons.arrow_right; 
  }

  // --- Interaction: Show Details Modal ---
  void _showBuildingDetails(BuildContext context, BuildingInfo building, String activeTag) {
    
    // FETCH DATA STRICTLY FOR THE CLICKED TAG
    List<BuildingSection> sections = building.content[activeTag] ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: const Color.fromARGB(100, 0, 0, 0),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(125, 255, 255, 255), //Glass Screen Drag Display
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 15, bottom: 10),
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                building.title,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
                              ),
                              // VISUAL FEEDBACK: SHOWING WHICH CATEGORY IS OPEN
                              Text(
                                "Viewing: $activeTag", 
                                style: const TextStyle(fontSize: 14, color: Color(0xFF800000), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color.fromARGB(255, 0, 0, 0)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),

                  // Scrollable Content
                  Expanded(
                    child: sections.isEmpty
                    ? const Center(child: Text("No information available."))
                    : ListView.builder(
                      controller: controller,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      itemCount: sections.length,
                      itemBuilder: (context, sectionIndex) {
                        final section = sections[sectionIndex];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section Header 
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF800000).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  section.header,
                                  style: const TextStyle(
                                    color: Color(0xFF800000),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              
                              // List Items
                              ...section.items.map((text) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(_getIconForText(text), size: 20, color: const Color.fromARGB(255, 0, 0, 0)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          text,
                                          style: const TextStyle(fontSize: 15, color: Color.fromARGB(255, 0, 0, 0), height: 1.3),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- Widget: Glass Building Card ---
  Widget _buildGlassBuildingCard({required BuildingInfo building}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          width: double.infinity,
          child: Stack(
            children: [
              // 1. Blur Effect
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(color: Colors.transparent),
              ),

              // 2. Gradient White Surface
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white, width: 1.5),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color.fromARGB(41, 255, 255, 255).withValues(alpha: 0.90),
                      Colors.white.withValues(alpha: 0.75),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),

              // 3. Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        building.imagePath,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                           return Container(
                             height: 180,
                             color: Colors.grey[300],
                             child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                           );
                        },
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          building.title,
                          style: const TextStyle(
                            color: titleColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          building.subtitle,
                          style: const TextStyle(
                            color: subtitleColor,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Clickable Glass Tags
                        Wrap(
                          spacing: 10.0,
                          runSpacing: 10.0,
                          children: building.tags.map((tag) => InkWell(
                            // PASS THE SPECIFIC TAG TO THE FUNCTION
                            onTap: () => _showBuildingDetails(context, building, tag),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(69, 255, 255, 255).withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color.fromARGB(255, 0, 0, 0), width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  color: Color(0xFF2D2D2D),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Building Directory",
              style: TextStyle(
                color: titleColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Campus facilities information",
              style: TextStyle(
                color: subtitleColor,
                fontSize: 15
              ),
            ),
            const SizedBox(height: 25),

            ...buildings.map((b) => _buildGlassBuildingCard(building: b)),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}