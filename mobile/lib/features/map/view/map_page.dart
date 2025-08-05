import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:tilikjalan/core/core.dart';
import 'package:tilikjalan/utils/utils.dart';

enum RoadCondition { smooth, medium, damaged }

class RoadConditionData {
  const RoadConditionData({
    required this.position,
    required this.condition,
    required this.description,
    required this.reportedAt,
    this.isVerified = true,
  });

  final LatLng position;
  final RoadCondition condition;
  final String description;
  final DateTime reportedAt;
  final bool isVerified;
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final loc.Location _location = loc.Location();

  LatLng? _currentPosition;
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasInitialized = false;
  String? _currentAddress;

  // Filter states
  Set<RoadCondition> _selectedConditions = RoadCondition.values.toSet();
  bool _showLegend = true;
  bool _showFilters = true;

  // Animation controllers
  late AnimationController _fabAnimationController;
  late AnimationController _cardAnimationController;
  late AnimationController _filterAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<Offset> _cardSlideAnimation;
  late Animation<double> _filterSlideAnimation;

  // Mock road condition data - in real app this would come from API
  final List<RoadConditionData> _roadConditions = [
    RoadConditionData(
      position: const LatLng(-6.2088, 106.8456),
      condition: RoadCondition.smooth,
      description: 'Jalan dalam kondisi baik',
      reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2090, 106.8460),
      condition: RoadCondition.medium,
      description: 'Beberapa lubang kecil',
      reportedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2085, 106.8450),
      condition: RoadCondition.damaged,
      description: 'Jalan rusak parah, banyak lubang',
      reportedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2095, 106.8465),
      condition: RoadCondition.smooth,
      description: 'Jalan baru diperbaiki',
      reportedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2080, 106.8445),
      condition: RoadCondition.medium,
      description: 'Perlu perbaikan minor',
      reportedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fabScaleAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _fabAnimationController,
            curve: Curves.elasticOut,
          ),
        );

    _cardSlideAnimation =
        Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _cardAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _filterSlideAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _filterAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    if (!_hasInitialized) {
      _getCurrentLocation();
      _hasInitialized = true;
    }
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _cardAnimationController.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Check if location service is enabled
      var serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          setState(() {
            _errorMessage = 'Layanan lokasi tidak tersedia';
            _isLoading = false;
          });
          return;
        }
      }

      // Check location permissions
      var permissionGranted = await _location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          setState(() {
            _errorMessage = 'Izin lokasi ditolak';
            _isLoading = false;
          });
          return;
        }
      }

      // Get current location
      final locationData = await _location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        // final newPosition = LatLng(
        //   locationData.latitude!,
        //   locationData.longitude!,
        // );
        const newPosition = LatLng(
          -6.2088,
          106.8456,
        );

        // Get address from coordinates
        // final address = await _getAddressFromCoordinates(
        //   locationData.latitude!,
        //   locationData.longitude!,
        // );
        final address = await _getAddressFromCoordinates(
          -6.2088,
          106.8456,
        );

        setState(() {
          _currentPosition = newPosition;
          _currentAddress = address;
          _isLoading = false;
        });

        // Move map to current location
        _mapController.move(_currentPosition!, 15);

        // Start animations
        await _cardAnimationController.forward();
        await _fabAnimationController.forward();
        await _filterAnimationController.forward();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Kesalahan mendapatkan lokasi: $e';
        _isLoading = false;
      });
    }
  }

  Future<String> _getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        return '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.postalCode ?? ''}, ${place.country ?? ''}'
            .replaceAll(RegExp(r'^,\s*|,\s*,'), ',')
            .replaceAll(RegExp(r'^,\s*'), '')
            .replaceAll(RegExp(r',\s*$'), '');
      }
      return 'Alamat tidak ditemukan';
    } catch (e) {
      return 'Kesalahan mendapatkan alamat: $e';
    }
  }

  Color _getConditionColor(RoadCondition condition) {
    final colors = context.colors;
    switch (condition) {
      case RoadCondition.smooth:
        return colors.support[500]!; // Green
      case RoadCondition.medium:
        return colors.secondary[500]!; // Orange
      case RoadCondition.damaged:
        return const Color(0xFFFF3B30); // Red
    }
  }

  IconData _getConditionIcon(RoadCondition condition) {
    switch (condition) {
      case RoadCondition.smooth:
        return Icons.check_circle;
      case RoadCondition.medium:
        return Icons.warning;
      case RoadCondition.damaged:
        return Icons.error;
    }
  }

  String _getConditionText(RoadCondition condition) {
    switch (condition) {
      case RoadCondition.smooth:
        return 'Mulus';
      case RoadCondition.medium:
        return 'Sedang';
      case RoadCondition.damaged:
        return 'Rusak';
    }
  }

  void _toggleConditionFilter(RoadCondition condition) {
    setState(() {
      if (_selectedConditions.contains(condition)) {
        _selectedConditions.remove(condition);
      } else {
        _selectedConditions.add(condition);
      }
    });
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
    if (_showFilters) {
      _filterAnimationController.forward();
    } else {
      _filterAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Scaffold(
      backgroundColor: colors.neutral[50],
      appBar: AppBar(
        title: Text(
          'Peta Kondisi Jalan',
          style: textTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  _currentPosition ?? const LatLng(-6.2088, 106.8456),
              initialZoom: 15,
              minZoom: 10,
              maxZoom: 18,
              onTap: (tapPosition, point) async {
                final address = await _getAddressFromCoordinates(
                  point.latitude,
                  point.longitude,
                );
                setState(() {
                  _currentPosition = point;
                  _currentAddress = address;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'dev.fleaflet.flutter_map.example',
              ),

              // Road condition markers
              MarkerLayer(
                markers: [
                  // Current position marker
                  if (_currentPosition != null)
                    Marker(
                      point: _currentPosition!,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: colors.primary[500],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary[500]!.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  // Road condition markers
                  ..._roadConditions
                      .where(
                        (condition) =>
                            _selectedConditions.contains(condition.condition),
                      )
                      .map(
                        (roadData) => Marker(
                          point: roadData.position,
                          child: GestureDetector(
                            onTap: () => _showRoadConditionDetails(roadData),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _getConditionColor(roadData.condition),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getConditionColor(
                                      roadData.condition,
                                    ).withOpacity(0.3),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _getConditionIcon(roadData.condition),
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ],
          ),

          // Location info card and filter toggle
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: SlideTransition(
              position: _cardSlideAnimation,
              child: Column(
                children: [
                  _buildLocationCard(colors, textTheme),
                  6.vertical,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Filter toggle button
                      ScaleTransition(
                        scale: _fabScaleAnimation,
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(25),
                                  onTap: _toggleFilters,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _showFilters
                                              ? Icons.filter_list
                                              : Icons.filter_list_off,
                                          color: colors.primary[500],
                                          size: 20,
                                        ),
                                        8.horizontal,
                                        Text(
                                          'Filter',
                                          style: textTheme.bodyMedium.copyWith(
                                            color: colors.primary[500],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        4.horizontal,
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colors.primary[500],
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            '${_selectedConditions.length}',
                                            style: textTheme.bodySmall.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Filter chips
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.5),
                          end: Offset.zero,
                        ).animate(_filterSlideAnimation),
                        child: FadeTransition(
                          opacity: _filterSlideAnimation,
                          child: _showFilters
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: _buildFilterChips(colors, textTheme),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Floating action buttons
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Refresh location button
                ScaleTransition(
                  scale: _fabScaleAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary[500]!.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: FloatingActionButton(
                      heroTag: 'refresh',
                      onPressed: _getCurrentLocation,
                      backgroundColor: colors.primary[500],
                      elevation: 0,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.my_location,
                              color: Colors.white,
                              size: 24,
                            ),
                    ),
                  ),
                ),
                16.vertical,
                // Center map button
                ScaleTransition(
                  scale: _fabScaleAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: colors.secondary[500]!.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: FloatingActionButton(
                      heroTag: 'center',
                      onPressed: () {
                        if (_currentPosition != null) {
                          _mapController.move(_currentPosition!, 15);
                        }
                      },
                      backgroundColor: colors.secondary[500],
                      elevation: 0,
                      child: const Icon(
                        Icons.center_focus_strong,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(AppColors colors, AppTextStyles textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.primary[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: colors.primary[500],
                    size: 18,
                  ),
                ),
                12.horizontal,
                Expanded(
                  child: Text(
                    'Lokasi Saat Ini',
                    style: textTheme.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.neutral[900],
                    ),
                  ),
                ),
                if (!_isLoading &&
                    _errorMessage == null &&
                    _currentPosition != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.support[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 12,
                          color: colors.support[600],
                        ),
                        4.horizontal,
                        Text(
                          'Akurat',
                          style: textTheme.bodySmall.copyWith(
                            color: colors.support[600],
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            12.vertical,

            if (_isLoading)
              Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colors.primary[500]!,
                      ),
                    ),
                  ),
                  12.horizontal,
                  Text(
                    'Mendapatkan lokasi...',
                    style: textTheme.bodySmall.copyWith(
                      color: colors.grey[600],
                    ),
                  ),
                ],
              )
            else if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFFF3B30),
                      size: 18,
                    ),
                    8.horizontal,
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: textTheme.bodySmall.copyWith(
                          color: const Color(0xFFFF3B30),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (_currentPosition != null && _currentAddress != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentAddress!,
                    style: textTheme.bodySmall.copyWith(
                      color: colors.neutral[700],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  6.vertical,
                  Row(
                    children: [
                      Icon(
                        Icons.gps_fixed,
                        size: 12,
                        color: colors.grey[500],
                      ),
                      4.horizontal,
                      Text(
                        '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                        style: textTheme.bodySmall.copyWith(
                          color: colors.grey[500],
                          fontFamily: 'monospace',
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Text(
                'Data lokasi tidak tersedia',
                style: textTheme.bodySmall.copyWith(
                  color: colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(AppColors colors, AppTextStyles textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kondisi Jalan',
            style: textTheme.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.neutral[900],
            ),
          ),
          12.vertical,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: RoadCondition.values.map((condition) {
              final isSelected = _selectedConditions.contains(condition);
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _toggleConditionFilter(condition),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _getConditionColor(condition)
                          : colors.neutral[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? _getConditionColor(condition)
                            : colors.neutral[300]!,
                        width: isSelected ? 0 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getConditionIcon(condition),
                          size: 16,
                          color: isSelected
                              ? Colors.white
                              : _getConditionColor(condition),
                        ),
                        6.horizontal,
                        Text(
                          _getConditionText(condition),
                          style: textTheme.bodySmall.copyWith(
                            color: isSelected
                                ? Colors.white
                                : colors.neutral[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showRoadConditionDetails(RoadConditionData roadData) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            20.vertical,

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getConditionColor(
                      roadData.condition,
                    ).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getConditionIcon(roadData.condition),
                    color: _getConditionColor(roadData.condition),
                    size: 28,
                  ),
                ),
                16.horizontal,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kondisi ${_getConditionText(roadData.condition)}',
                        style: textTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.neutral[900],
                        ),
                      ),
                      4.vertical,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.support[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              size: 14,
                              color: colors.support[600],
                            ),
                            4.horizontal,
                            Text(
                              'Terverifikasi',
                              style: textTheme.bodySmall.copyWith(
                                color: colors.support[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            24.vertical,

            // Description section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.neutral[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description,
                        size: 18,
                        color: colors.neutral[600],
                      ),
                      8.horizontal,
                      Text(
                        'Deskripsi',
                        style: textTheme.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.neutral[900],
                        ),
                      ),
                    ],
                  ),
                  8.vertical,
                  Text(
                    roadData.description,
                    style: textTheme.bodyMedium.copyWith(
                      color: colors.neutral[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            16.vertical,

            // Time and location info
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.neutral[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: colors.neutral[600],
                            ),
                            6.horizontal,
                            Text(
                              'Waktu Laporan',
                              style: textTheme.bodySmall.copyWith(
                                color: colors.neutral[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        4.vertical,
                        Text(
                          _formatTime(roadData.reportedAt),
                          style: textTheme.bodySmall.copyWith(
                            color: colors.neutral[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                12.horizontal,
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.neutral[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: colors.neutral[600],
                            ),
                            6.horizontal,
                            Text(
                              'Koordinat',
                              style: textTheme.bodySmall.copyWith(
                                color: colors.neutral[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        4.vertical,
                        Text(
                          '${roadData.position.latitude.toStringAsFixed(4)}, ${roadData.position.longitude.toStringAsFixed(4)}',
                          style: textTheme.bodySmall.copyWith(
                            color: colors.neutral[800],
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            24.vertical,

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _mapController.move(roadData.position, 18);
                    },
                    icon: const Icon(Icons.zoom_in),
                    label: const Text('Zoom Ke Lokasi'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: colors.primary[500]!),
                      foregroundColor: colors.primary[500],
                    ),
                  ),
                ),
                12.horizontal,
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Could add share or report functionality here
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Bagikan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary[500],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else {
      return '${difference.inDays} hari yang lalu';
    }
  }
}
