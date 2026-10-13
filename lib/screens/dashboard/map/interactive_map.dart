import 'dart:async';
import 'dart:convert';
import 'dart:ui'; // Required for ImageFilter (Glassmorphism)

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as maplibre;
import 'package:supabase_flutter/supabase_flutter.dart';

class InteractiveMapScreen extends StatefulWidget {
  final String? initialTarget;
  const InteractiveMapScreen({super.key, this.initialTarget});

  @override
  State<InteractiveMapScreen> createState() => _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends State<InteractiveMapScreen> with TickerProviderStateMixin {
  maplibre.MapLibreMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();

  // --- CONFIGURATION ---
  final String _styleString =
      "https://maps.geoapify.com/v1/styles/osm-carto/style.json?apiKey=93894e5594cc472683e35d02028a07a5";
  final String _geoapifyApiKey = "93894e5594cc472683e35d02028a07a5";

  // --- LOCATION & DATA STATE ---
  static const maplibre.LatLng _defaultLocation =
      maplibre.LatLng(14.59917, 121.01173);
  List<Map<String, dynamic>> _landmarks = [];

  bool _isSearching = false;
  List<dynamic> _searchResults = [];
  Timer? _debounce;
  bool _isLoadingRoute = false;
  String _travelTime = "";
  String _travelDistance = "";
  bool _hasActiveRoute = false;

  // --- UI STATE ---
  bool _showSearchGuide = false;

  // --- STATIC SEARCH GUIDE DATA ---
  final List<Map<String, String>> _searchGuideItems = [
    {
      "common": "PUP Interfaith Ecumenical Chapel, Interfaith Chapel Road, Manila, 1016 Metro Manila, Philippines",
      "exact": "Campus Chapel"
    },
    {
      "common": "PUP Gymnasium, Road 11, Manila, 1016 Metro Manila, Philippines",
      "exact": "Campus Gym"
    },
    {
      "common": "Pylon, Anonas Street, Manila, 1016 Metro Manila, Philippines",
      "exact": "Main Gate / Pylon"
    },
    {
      "common": "PUP Grandstand, PUP Catwalk, Manila, 1016 Metro Manila, Philippines",
      "exact": "Campus Oval"
    },
    {
      "common": "Ninoy Aquino Learning Resource Center, PUP Catwalk, Manila, 1016 Metro Manila, Philippines",
      "exact": "Campus Library"
    },
    {
      "common": "Charlie Del Rosario Hall, Interfaith Chapel Road, Manila, 1016 Metro Manila, Philippines",
      "exact": "Charlie Del Rosario Hall"
    },
    {
      "common": "PUP Obelisk, Tanque, Manila, National Capital District, Philippines",
      "exact": "Main Statue / Obelisk"
    },
    {
      "common": "Apolinario Mabini Shrine, PUP Catwalk, Manila, 1016 Metro Manila, Philippines",
      "exact": "Campus Shrine"
    },
    {
      "common": "PUP Linear Park, Santa Mesa, Manila, Capital District, Philippines",
      "exact": "Campus Park"
    },
    {
      "common": "Tahanan ng Alumni, PUP Catwalk, Manila, 1016 Metro Manila, Philippines",
      "exact": "Tahanan ng Alumni"
    },
    {
      "common": "PUP Auditorium, Interfaith Chapel Road, Manila, 1016 Metro Manila, Philippines",
      "exact": "Amphitheater / Auditorium"
    },
    {
      "common": "Museo ni Apolinario Mabini – PUP, PUP Catwalk, Manila, 1016 Metro Manila, Philippines",
      "exact": "Campus Museum"
    },
    {
      "common": "Main Building - Dome, Interfaith Chapel Road, Manila, 1016 Metro Manila, Philippines",
      "exact": "Main Building - Dome"
    },
    {
      "common": "Luntiang Pilipinas Forest Park, Manila, 1016 Metro Manila, Philippines",
      "exact": "Campus Lagoon"
    },
    {
      "common": "P.U.P. College of Engineering and Architechture, Anonas Street, Manila, 1016 Metro Manila, Philippines",
      "exact": "CEA"
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _loadLandmarks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // --- 1. INITIALIZATION LOGIC ---

  Future<void> _checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

  Future<void> _loadLandmarks() async {
    try {
      final response =
          await Supabase.instance.client.from('landmarks').select();

      if (mounted) {
        setState(() {
          _landmarks = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      debugPrint("Supabase Fetch Error: $e");
    }
  }

  // --- CATEGORY MAPPING HELPER ---
  Map<String, dynamic> _getCategoryInfo(String name) {
    String n = name.toLowerCase();
    if (n.contains('chapel')) {
      return {'label': 'Religious', 'icon': Icons.church, 'color': Colors.purple};
    } else if (n.contains('mabini') || n.contains('shrine') || n.contains('museum') || n.contains('museo') || n.contains('obelisk') || n.contains('pylon')) {
      return {'label': 'Heritage', 'icon': Icons.account_balance, 'color': Colors.orange[900]};
    } else if (n.contains('gym') || n.contains('grandstand') || n.contains('oval')) {
      return {'label': 'Sports', 'icon': Icons.sports_basketball, 'color': Colors.green[800]};
    } else {
      return {'label': 'Administrative', 'icon': Icons.business, 'color': Colors.blue[900]};
    }
  }

  // --- 2. MAP & SYMBOL LOGIC ---

  void _onMapCreated(maplibre.MapLibreMapController controller) async {
    _mapController = controller;

    for (var landmark in _landmarks) {
      final List<dynamic> waypoints = landmark['waypoints'] ?? [];
      if (waypoints.isNotEmpty) {
        final double lat = waypoints[0]['lat'];
        final double lng = waypoints[0]['lng'];

        await _mapController?.addSymbol(
          maplibre.SymbolOptions(
            geometry: maplibre.LatLng(lat, lng),
            iconImage: "marker-15",
            iconSize: 1.5,
            textField: landmark['name'],
            textOffset: const Offset(0, 2),
            textSize: 12.0,
          ),
          {'landmark_id': landmark['landmark_id']},
        );
      }
    }

    _mapController?.onSymbolTapped.add(_onSymbolTapped);
  }

  void _onSymbolTapped(maplibre.Symbol symbol) {
    final landmarkId = symbol.data?['landmark_id'];
    final clickedLandmark = _landmarks.firstWhere(
      (l) => l['landmark_id'] == landmarkId,
      orElse: () => {},
    );

    if (clickedLandmark.isNotEmpty) {
      _showLandmarkDetails(clickedLandmark);
    }
  }

  // --- 3. SEARCH & ROUTING LOGIC ---

  Future<void> _onSearchChanged(String text) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (text.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() => _isSearching = true);
      final String url =
          "https://api.geoapify.com/v1/geocode/autocomplete?text=$text&apiKey=$_geoapifyApiKey&bias=proximity:${_defaultLocation.longitude},${_defaultLocation.latitude}";

      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (mounted) {
            setState(() {
              _searchResults = data['features'] ?? [];
              _isSearching = false;
            });
          }
        }
      } catch (e) {
        if (mounted) setState(() => _isSearching = false);
      }
    });
  }

  Future<void> _calculateRoute(maplibre.LatLng destination) async {
    if (_mapController == null) return;

    Position position = await Geolocator.getCurrentPosition();
    final start = maplibre.LatLng(position.latitude, position.longitude);

    setState(() {
      _isLoadingRoute = true;
      _hasActiveRoute = false;
    });

    await _mapController!.clearLines();

    final String waypoints =
        "${start.latitude},${start.longitude}|${destination.latitude},${destination.longitude}";
    final String url =
        "https://api.geoapify.com/v1/routing?waypoints=$waypoints&mode=walk&apiKey=$_geoapifyApiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          final feature = data['features'][0];
          final geometry = feature['geometry'];
          final List<maplibre.LatLng> points = [];

          if (geometry['type'] == 'MultiLineString') {
            for (var line in geometry['coordinates']) {
              for (var coord in line) {
                points.add(
                    maplibre.LatLng(coord[1].toDouble(), coord[0].toDouble()));
              }
            }
          } else {
            final List<dynamic> coords = geometry['coordinates'][0];
            for (var c in coords) {
              points.add(maplibre.LatLng(c[1].toDouble(), c[0].toDouble()));
            }
          }

          if (points.isNotEmpty) {
            await _mapController!.addLine(maplibre.LineOptions(
              geometry: points,
              lineColor: "#2196F3",
              lineWidth: 6.0,
              lineOpacity: 0.8,
            ));
            // FIXED: Do not move camera to user (points.first) here if we already animated to building
          }

          if (mounted) {
            setState(() {
              _travelTime =
                  "${(feature['properties']['time'] / 60).round()} mins";
              _travelDistance =
                  "${(feature['properties']['distance']).round()} m";
              _isLoadingRoute = false;
              _hasActiveRoute = true;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingRoute = false);
    }
  }

  void _onResultSelected(dynamic feature) async {
    final coords = feature['geometry']['coordinates'];
    final maplibre.LatLng target =
        maplibre.LatLng(coords[1].toDouble(), coords[0].toDouble());
    final String resultName = feature['properties']['name'] ?? "";

    setState(() {
      _searchResults = [];
      _searchController.text = feature['properties']['formatted'] ?? "";
    });

    FocusScope.of(context).unfocus();

    _mapController?.animateCamera(maplibre.CameraUpdate.newCameraPosition(
      maplibre.CameraPosition(target: target, zoom: 17.0, tilt: 60.0),
    ));

    await _mapController?.clearCircles();
    await _mapController?.clearSymbols();

    final matchedLandmark = _landmarks.firstWhere(
      (l) =>
          l['name']
              .toString()
              .toLowerCase()
              .contains(resultName.toLowerCase()) &&
          resultName.isNotEmpty,
      orElse: () => {},
    );

    if (matchedLandmark.isNotEmpty) {
      _showLandmarkDetails(matchedLandmark);
    } else {
      await _mapController?.addCircle(maplibre.CircleOptions(
          geometry: target,
          circleColor: "#FF0000",
          circleRadius: 10.0,
          circleStrokeWidth: 2.0,
          circleStrokeColor: "#FFFFFF"));
    }

    _calculateRoute(target);
  }

  // --- 4. POPUP UI MODAL ---

  void _showLandmarkDetails(Map<String, dynamic> landmark) {
    final category = _getCategoryInfo(landmark['name'] ?? "");
    final int landmarkId = landmark['landmark_id'];
    final userId = Supabase.instance.client.auth.currentUser?.id;

    // We use a StatefulBuilder to handle the "Is Saved" state inside the popup
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // 1. Variable to track if currently saved
            bool? isSaved; 

            // 2. Function to check initial status (Runs once)
            if (isSaved == null) {
               // We temporarily set it to false while loading
               isSaved = false; 
               // Check Supabase asynchronously
               Supabase.instance.client
                  .from('save_locations')
                  .select()
                  .eq('user_id', userId!)
                  .eq('landmark_id', landmarkId)
                  .maybeSingle()
                  .then((data) {
                    if (data != null && context.mounted) {
                      setModalState(() {
                        isSaved = true;
                      });
                    }
                  });
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- IMAGE SECTION ---
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(30)),
                      child: Image.network(
                        landmark['image_url'] ??
                            'https://via.placeholder.com/400x200',
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                            height: 250,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported)),
                      ),
                    ),

                    // --- CONTENT SECTION ---
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  landmark['name'] ?? "PUP Landmark",
                                  style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF800000)),
                                ),
                              ),
                              
                              // --- WORKING SAVE BUTTON ---
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: IconButton(
                                  iconSize: 26,
                                  // Change Icon based on state
                                  icon: Icon(
                                    isSaved == true 
                                      ? Icons.bookmark 
                                      : Icons.bookmark_border_rounded
                                  ),
                                  // Change Color based on state
                                  color: isSaved == true 
                                      ? const Color(0xFF800000) 
                                      : Colors.grey,
                                  
                                  onPressed: () async {
                                    // 1. Optimistic Update (Change UI immediately)
                                    final bool newState = !(isSaved ?? false);
                                    setModalState(() {
                                      isSaved = newState;
                                    });

                                    try {
                                      if (newState) {
                                        // SAVE: Insert into Supabase
                                        await Supabase.instance.client
                                            .from('save_locations')
                                            .insert({
                                          'user_id': userId,
                                          'landmark_id': landmarkId,
                                          'saved_at': DateTime.now().toIso8601String(), 
                                        });
                                      } else {
                                        // UNSAVE: Delete from Supabase
                                        await Supabase.instance.client
                                            .from('save_locations')
                                            .delete()
                                            .eq('user_id', userId!)
                                            .eq('landmark_id', landmarkId);
                                      }
                                    } catch (e) {
                                      // Revert if error
                                      setModalState(() {
                                        isSaved = !newState;
                                      });
                                      debugPrint("Error saving location: $e");
                                    }
                                  },
                                ),
                              ),
                              // ---------------------------
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(category['icon'],
                                  size: 18, color: category['color']),
                              const SizedBox(width: 8),
                              Text(
                                category['label'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: category['color'],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Text(
                            landmark['description'] ??
                                "No description available.",
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                          const Divider(height: 32),
                          const Text("Historical Significance",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            landmark['historical_significance'] ??
                                "No history recorded.",
                            style: const TextStyle(
                                fontSize: 14, fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF800000),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                final waypoints = landmark['waypoints'][0];
                                final target = maplibre.LatLng(
                                    waypoints['lat'], waypoints['lng']);

                                _mapController?.animateCamera(
                                  maplibre.CameraUpdate.newCameraPosition(
                                    maplibre.CameraPosition(
                                        target: target,
                                        zoom: 17.0,
                                        tilt: 60.0),
                                  ),
                                );

                                _calculateRoute(target);
                              },
                              icon: const Icon(Icons.directions_walk),
                              label: const Text("Navigate to this Building",
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          maplibre.MapLibreMap(
            styleString: _styleString,
            onMapCreated: _onMapCreated,
            initialCameraPosition: const maplibre.CameraPosition(
              target: _defaultLocation,
              zoom: 16.0,
              tilt: 60.0,
            ),
            myLocationEnabled: true,
            myLocationTrackingMode: maplibre.MyLocationTrackingMode.none,
            trackCameraPosition: true,
            compassEnabled: true,
            tiltGesturesEnabled: true,
            rotateGesturesEnabled: true,
          ),

          // BACK BUTTON
          Positioned(
            top: 50,
            left: 15,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1), blurRadius: 10)
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Color(0xFF800000), size: 18),
              ),
            ),
          ),

          // UI: SEARCH BAR
          Positioned(
            top: 50,
            left: 75,
            right: 15,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 10)
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: "Search PUP campus...",
                      prefixIcon:
                          const Icon(Icons.search, color: Color(0xFF800000)),
                      suffixIcon: _isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)))
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _mapController?.clearLines();
                                _mapController?.clearCircles();
                                setState(() {
                                  _hasActiveRoute = false;
                                  _searchResults = [];
                                });
                              }),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final feature = _searchResults[index];
                        return ListTile(
                          title: Text(
                              feature['properties']['formatted'] ?? "Location"),
                          onTap: () => _onResultSelected(feature),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // SEARCH GUIDE TOGGLE
          Positioned(
            top: 110,
            right: 15,
            child: GestureDetector(
              onTap: () => setState(() => _showSearchGuide = true),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF800000).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.help_outline, color: Colors.white, size: 16),
                    SizedBox(width: 5),
                    Text("Search Guide",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),

          // GLASSMORPHISM SEARCH GUIDE OVERLAY
          if (_showSearchGuide)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _showSearchGuide = false),
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        height: MediaQuery.of(context).size.height * 0.65,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3), width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Quick Search Guide",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.black),
                                    onPressed: () => setState(
                                        () => _showSearchGuide = false),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(color: Colors.black26, height: 1),
                            Expanded(
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                itemCount: _searchGuideItems.length,
                                itemBuilder: (ctx, i) {
                                  final info = _getCategoryInfo(_searchGuideItems[i]['exact']!);
                                  return ListTile(
                                    leading: Icon(info['icon'], color: Colors.black87),
                                    title: Text(_searchGuideItems[i]['common']!,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600)),
                                    subtitle: Text(_searchGuideItems[i]['exact']!,
                                        style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 11)),
                                    trailing: const Icon(Icons.touch_app,
                                        color: Colors.black54, size: 18),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // UI: ROUTE INFO
          if (_hasActiveRoute)
            Positioned(
              bottom: 100,
              left: 15,
              right: 15,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 10)
                    ]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      const Icon(Icons.directions_walk,
                          size: 24, color: Colors.blueAccent),
                      const SizedBox(width: 12),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Walking Duration",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            Text(_travelTime,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ]),
                    ]),
                    Text(_travelDistance,
                        style: const TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

          // UI: RECENTER BUTTON
          Positioned(
            bottom: 30,
            left: 15,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () async {
                Position pos = await Geolocator.getCurrentPosition();
                _mapController?.animateCamera(
                    maplibre.CameraUpdate.newLatLngZoom(
                        maplibre.LatLng(pos.latitude, pos.longitude), 17.0));
              },
              child: const Icon(Icons.my_location, color: Color(0xFF800000)),
            ),
          ),

          if (_isLoadingRoute)
            const Center(
                child: CircularProgressIndicator(color: Color(0xFF800000))),
        ],
      ),
    );
  }
}