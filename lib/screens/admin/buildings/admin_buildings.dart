import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:puptourapp/routes/app_routes.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Required Custom Widget Imports
import 'package:puptourapp/widgets/app_header.dart';
import 'package:puptourapp/widgets/app_footer.dart';
import 'package:puptourapp/screens/admin/dashboard/navigation_drawer_admin.dart';

class BuildingData {
  final int id; // landmark_id
  final int nodeId;
  final String name;
  final String type; // From map_nodes
  final String description;
  final String historicalSignificance;
  final String? imageUrl;
  final double latitude;
  final double longitude;
  final List<LatLng> waypoints; // The custom path points

  const BuildingData({
    required this.id,
    required this.nodeId,
    required this.name,
    required this.type,
    required this.description,
    required this.historicalSignificance,
    this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.waypoints,
  });
}

class AdminBuildingsScreen extends StatefulWidget {
  const AdminBuildingsScreen({super.key});

  @override
  State<AdminBuildingsScreen> createState() => _AdminBuildingsScreenState();
}

class _AdminBuildingsScreenState extends State<AdminBuildingsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<BuildingData> _buildings = [];
  bool _isLoading = true;

  // --- FORM CONTROLLERS ---
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _historyController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _imageController = TextEditingController();

  // --- MAP EDITOR STATE ---
  List<LatLng> _currentPathPoints = [];
  final MapController _dialogMapController = MapController();

  @override
  void initState() {
    super.initState();
    _fetchBuildings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    _historyController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  // --- 1. FETCH LOGIC: JOINED DATA ---
  Future<void> _fetchBuildings() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final List<dynamic> response = await supabase
          .from('landmarks')
          .select('*, map_nodes(*)');

      final loadedBuildings = response.map((data) {
        final node = data['map_nodes'];
        final List<dynamic> rawWps = data['waypoints'] ?? [];
        
        return BuildingData(
          id: data['landmark_id'],
          nodeId: data['node_id'],
          name: data['name'] ?? 'Unnamed',
          type: node != null ? node['type'] ?? 'Landmark' : 'Landmark',
          description: data['description'] ?? '',
          historicalSignificance: data['historical_significance'] ?? '',
          imageUrl: data['image_url'],
          latitude: node != null ? (node['latitude'] as num).toDouble() : 0.0,
          longitude: node != null ? (node['longitude'] as num).toDouble() : 0.0,
          waypoints: rawWps.map((w) => LatLng((w['lat'] as num).toDouble(), (w['lng'] as num).toDouble())).toList(),
        );
      }).toList();

      if (mounted) {
        setState(() {
          _buildings = loadedBuildings;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching buildings: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 2. SAVE / UPDATE LOGIC ---
  Future<void> _saveBuilding({BuildingData? existing}) async {
    if (_nameController.text.isEmpty || _latController.text.isEmpty || _lngController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name and Coordinates are required.")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Convert current UI points to JSON for Supabase
      final waypointsJson = _currentPathPoints.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList();

      if (existing == null) {
        // --- INSERT NEW ---
        final nodeResponse = await supabase.from('map_nodes').insert({
          'name': _nameController.text.trim(),
          'latitude': double.parse(_latController.text),
          'longitude': double.parse(_lngController.text),
          'type': _typeController.text.trim(),
        }).select().single();

        await supabase.from('landmarks').insert({
          'node_id': nodeResponse['node_id'],
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'historical_significance': _historyController.text.trim(),
          'image_url': _imageController.text.trim().isEmpty ? null : _imageController.text.trim(),
          'waypoints': waypointsJson,
        });
      } else {
        // --- UPDATE EXISTING ---
        await supabase.from('map_nodes').update({
          'name': _nameController.text.trim(),
          'latitude': double.parse(_latController.text),
          'longitude': double.parse(_lngController.text),
          'type': _typeController.text.trim(),
        }).eq('node_id', existing.nodeId);

        await supabase.from('landmarks').update({
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'historical_significance': _historyController.text.trim(),
          'image_url': _imageController.text.trim().isEmpty ? null : _imageController.text.trim(),
          'waypoints': waypointsJson,
        }).eq('landmark_id', existing.id);
      }

      if (mounted) {
        Navigator.pop(context);
        _fetchBuildings();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(existing == null ? 'Building added!' : 'Building updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Save Error: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 3. UI: THE VISUAL EDITOR DIALOG ---
  void _showBuildingDialog({BuildingData? building}) {
    if (building != null) {
      _nameController.text = building.name;
      _typeController.text = building.type;
      _descriptionController.text = building.description;
      _historyController.text = building.historicalSignificance;
      _latController.text = building.latitude.toString();
      _lngController.text = building.longitude.toString();
      _imageController.text = building.imageUrl ?? '';
      _currentPathPoints = List.from(building.waypoints);
    } else {
      _nameController.clear();
      _typeController.text = "Landmark";
      _descriptionController.clear();
      _historyController.clear();
      _latController.clear();
      _lngController.clear();
      _imageController.clear();
      _currentPathPoints = [];
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(building == null ? 'Add Building' : 'Edit Building', 
              style: const TextStyle(color: Color(0xFF8B0000), fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: _latController, decoration: const InputDecoration(labelText: 'Latitude'), keyboardType: TextInputType.number)),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: _lngController, decoration: const InputDecoration(labelText: 'Longitude'), keyboardType: TextInputType.number)),
                    ],
                  ),
                  const Divider(height: 30),
                  const Text("Visual Path Editor", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF8B0000))),
                  const Text("Tap map to draw/edit the custom walking path", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 10),
                  
                  // --- THE INTERACTIVE MAP EDITOR ---
                  Container(
                    height: 300,
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: FlutterMap(
                        mapController: _dialogMapController,
                        options: MapOptions(
                          initialCenter: building != null 
                              ? LatLng(building.latitude, building.longitude) 
                              : const LatLng(14.59709, 121.01080),
                          initialZoom: 17.0,
                          onTap: (tapPos, point) {
                            setDialogState(() {
                              _currentPathPoints.add(point);
                            });
                          },
                        ),
                        children: [
                          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                          PolylineLayer(polylines: [
                            Polyline(
                              points: _currentPathPoints, 
                              color: Colors.blue, 
                              strokeWidth: 4, 
                              strokeCap: StrokeCap.round,
                              pattern: const StrokePattern.dotted(), // Clean dashed style for editor
                            ),
                          ]),
                          MarkerLayer(markers: [
                            // Main Destination Marker
                            if (_latController.text.isNotEmpty && _lngController.text.isNotEmpty)
                              Marker(
                                point: LatLng(double.tryParse(_latController.text) ?? 0, double.tryParse(_lngController.text) ?? 0),
                                child: const Icon(Icons.location_on, color: Color(0xFF8B0000), size: 35),
                              ),
                            // Path Waypoint Markers
                            ..._currentPathPoints.asMap().entries.map((entry) => Marker(
                              point: entry.value,
                              child: Container(
                                decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                                child: Center(child: Text("${entry.key + 1}", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                              ),
                            )),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Map Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: _currentPathPoints.isEmpty ? null : () {
                          setDialogState(() {
                            _currentPathPoints.removeLast();
                          });
                        },
                        icon: const Icon(Icons.undo, size: 18),
                        label: const Text("Undo"),
                      ),
                      TextButton.icon(
                        onPressed: _currentPathPoints.isEmpty ? null : () {
                          setDialogState(() {
                            _currentPathPoints.clear();
                          });
                        },
                        icon: const Icon(Icons.clear_all, size: 18, color: Colors.red),
                        label: const Text("Clear Path", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 30),
                  TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
                  const SizedBox(height: 10),
                  TextField(controller: _imageController, decoration: const InputDecoration(labelText: 'Asset Image Path')),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => _saveBuilding(existing: building),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B0000)),
              child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteBuilding(int nodeId) async {
    try {
      await supabase.from('map_nodes').delete().eq('node_id', nodeId);
      _fetchBuildings();
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await supabase.auth.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(preferredSize: Size.fromHeight(60), child: AppHeader()),
      drawer: NavigationDrawerAdmin(onSignOut: () => _signOut(context)),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Buildings Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('Edit buildings and draw custom walking paths visually.', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showBuildingDialog(),
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: const Text('Add Building', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B0000)),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _isLoading
                ? const Padding(padding: EdgeInsets.only(top: 50.0), child: Center(child: CircularProgressIndicator(color: Color(0xFF8B0000))))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 40,
                      headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                      columns: const [
                        DataColumn(label: Text('Building Name', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Path Points', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: _buildings.map((b) => DataRow(
                        cells: [
                          DataCell(Text(b.name)),
                          DataCell(Text('${b.waypoints.length} points')),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue, size: 18), 
                                  onPressed: () => _showBuildingDialog(building: b),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 18), 
                                  onPressed: () => _deleteBuilding(b.nodeId),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )).toList(),
                    ),
                  ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: const [AppFooter()]),
          ),
        ],
      ),
    );
  }
}