import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:tilikjalan/core/core.dart';
import 'package:tilikjalan/gen/assets.gen.dart';
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
  final Set<RoadCondition> _selectedConditions = RoadCondition.values.toSet();

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  List<String> _searchSuggestions = [];
  Timer? _searchTimer;

  // Voice input functionality
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  bool _speechEnabled = true;
  String _voiceResult = '';

  // Animation controllers
  late AnimationController _fabAnimationController;
  late AnimationController _cardAnimationController;
  late AnimationController _voicePulseAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<Offset> _cardSlideAnimation;
  late Animation<double> _voicePulseAnimation;

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
    RoadConditionData(
      position: const LatLng(-6.2100, 106.8470),
      condition: RoadCondition.damaged,
      description: 'Jalan berlubang besar, berbahaya',
      reportedAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2075, 106.8440),
      condition: RoadCondition.smooth,
      description: 'Jalan aspal baru, sangat mulus',
      reportedAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2105, 106.8455),
      condition: RoadCondition.medium,
      description: 'Retak-retak kecil di permukaan',
      reportedAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2070, 106.8475),
      condition: RoadCondition.damaged,
      description: 'Genangan air dan jalan rusak',
      reportedAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2110, 106.8450),
      condition: RoadCondition.smooth,
      description: 'Jalan protokol dalam kondisi prima',
      reportedAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2082, 106.8462),
      condition: RoadCondition.medium,
      description: 'Aspal mulai mengelupas sedikit',
      reportedAt: DateTime.now().subtract(const Duration(hours: 7)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2092, 106.8448),
      condition: RoadCondition.damaged,
      description: 'Jalan bergelombang dan tidak rata',
      reportedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2078, 106.8468),
      condition: RoadCondition.smooth,
      description: 'Jalan perumahan terawat baik',
      reportedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2098, 106.8442),
      condition: RoadCondition.medium,
      description: 'Bekas tambalan aspal terlihat',
      reportedAt: DateTime.now().subtract(const Duration(hours: 9)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2073, 106.8458),
      condition: RoadCondition.damaged,
      description: 'Lubang dalam di tengah jalan',
      reportedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2103, 106.8463),
      condition: RoadCondition.smooth,
      description: 'Jalan raya utama kondisi excellent',
      reportedAt: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2086, 106.8473),
      condition: RoadCondition.medium,
      description: 'Marka jalan mulai pudar',
      reportedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2091, 106.8437),
      condition: RoadCondition.damaged,
      description: 'Jalan ambles di beberapa titik',
      reportedAt: DateTime.now().subtract(const Duration(hours: 10)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2076, 106.8452),
      condition: RoadCondition.smooth,
      description: 'Jalan gang sudah dipaving block',
      reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2107, 106.8467),
      condition: RoadCondition.medium,
      description: 'Permukaan kasar tapi masih layak',
      reportedAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    // Very close locations - within 1km radius
    RoadConditionData(
      position: const LatLng(-6.2090, 106.8470),
      condition: RoadCondition.smooth,
      description: 'Jalan gang kecil sudah diaspal ulang',
      reportedAt: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2085, 106.8465),
      condition: RoadCondition.medium,
      description: 'Trotoar rusak, jalan masih ok',
      reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2095, 106.8450),
      condition: RoadCondition.damaged,
      description: 'Lubang besar di depan warung',
      reportedAt: DateTime.now().subtract(const Duration(minutes: 40)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2080, 106.8460),
      condition: RoadCondition.smooth,
      description: 'Jalan komplek perumahan bersih',
      reportedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2100, 106.8445),
      condition: RoadCondition.medium,
      description: 'Marka jalan hampir hilang',
      reportedAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2070, 106.8450),
      condition: RoadCondition.damaged,
      description: 'Jalan berlubang, hati-hati motor',
      reportedAt: DateTime.now().subtract(const Duration(minutes: 50)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2110, 106.8470),
      condition: RoadCondition.smooth,
      description: 'Jalan baru selesai pengaspalan',
      reportedAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2075, 106.8465),
      condition: RoadCondition.medium,
      description: 'Bekas galian PAM belum rata',
      reportedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2105, 106.8440),
      condition: RoadCondition.damaged,
      description: 'Genangan air saat hujan',
      reportedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2085, 106.8475),
      condition: RoadCondition.smooth,
      description: 'Jalur sepeda dalam kondisi baik',
      reportedAt: DateTime.now().subtract(const Duration(minutes: 35)),
    ),
    // Medium distance - within 2km radius
    RoadConditionData(
      position: const LatLng(-6.2120, 106.8480),
      condition: RoadCondition.medium,
      description: 'Jalan menuju stasiun sedikit rusak',
      reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2060, 106.8430),
      condition: RoadCondition.damaged,
      description: 'Jalan rusak akibat pohon tumbang',
      reportedAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2130, 106.8440),
      condition: RoadCondition.smooth,
      description: 'Jalan utama kondisi sangat baik',
      reportedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2050, 106.8480),
      condition: RoadCondition.medium,
      description: 'Jalan sekolah perlu perbaikan kecil',
      reportedAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2125, 106.8420),
      condition: RoadCondition.damaged,
      description: 'Jalan pasar berlubang dalam',
      reportedAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2045, 106.8465),
      condition: RoadCondition.smooth,
      description: 'Jalan taman kota terawat rapi',
      reportedAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2135, 106.8485),
      condition: RoadCondition.medium,
      description: 'Jalan menuju mall sedikit retak',
      reportedAt: DateTime.now().subtract(const Duration(hours: 7)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2040, 106.8440),
      condition: RoadCondition.damaged,
      description: 'Jalan industri banyak lubang',
      reportedAt: DateTime.now().subtract(const Duration(hours: 9)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2140, 106.8460),
      condition: RoadCondition.smooth,
      description: 'Jalan menuju rumah sakit lancar',
      reportedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2035, 106.8455),
      condition: RoadCondition.medium,
      description: 'Jalan kantor pemerintah cukup baik',
      reportedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    // Further locations - North Jakarta area
    RoadConditionData(
      position: const LatLng(-6.1800, 106.8300),
      condition: RoadCondition.damaged,
      description: 'Jalan tol rusak, banyak kerusakan struktur',
      reportedAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    RoadConditionData(
      position: const LatLng(-6.1750, 106.8350),
      condition: RoadCondition.smooth,
      description: 'Jalan raya Ancol baru diaspal',
      reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    RoadConditionData(
      position: const LatLng(-6.1820, 106.8280),
      condition: RoadCondition.medium,
      description: 'Jalan pelabuhan dengan retakan minor',
      reportedAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    // South Jakarta area
    RoadConditionData(
      position: const LatLng(-6.2400, 106.8200),
      condition: RoadCondition.smooth,
      description: 'Jalan Sudirman kondisi prima',
      reportedAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2500, 106.8100),
      condition: RoadCondition.damaged,
      description: 'Jalan Senayan berlubang parah',
      reportedAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2350, 106.8250),
      condition: RoadCondition.medium,
      description: 'Jalan Blok M perlu perawatan',
      reportedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    // East Jakarta area
    RoadConditionData(
      position: const LatLng(-6.2200, 106.9000),
      condition: RoadCondition.damaged,
      description: 'Jalan Bekasi Timur rusak berat',
      reportedAt: DateTime.now().subtract(const Duration(hours: 10)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2100, 106.9200),
      condition: RoadCondition.smooth,
      description: 'Jalan tol Cakung baru diperbaiki',
      reportedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2300, 106.8900),
      condition: RoadCondition.medium,
      description: 'Jalan Pulogadung dengan beberapa lubang',
      reportedAt: DateTime.now().subtract(const Duration(hours: 7)),
    ),
    // West Jakarta area
    RoadConditionData(
      position: const LatLng(-6.1900, 106.7800),
      condition: RoadCondition.smooth,
      description: 'Jalan Grogol Petamburan terawat baik',
      reportedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2000, 106.7600),
      condition: RoadCondition.damaged,
      description: 'Jalan Cengkareng banjir dan rusak',
      reportedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    RoadConditionData(
      position: const LatLng(-6.1850, 106.7900),
      condition: RoadCondition.medium,
      description: 'Jalan Tanjung Duren butuh perbaikan',
      reportedAt: DateTime.now().subtract(const Duration(hours: 9)),
    ),
    // Central Jakarta extended area
    RoadConditionData(
      position: const LatLng(-6.1600, 106.8400),
      condition: RoadCondition.smooth,
      description: 'Jalan Thamrin kondisi excellent',
      reportedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    RoadConditionData(
      position: const LatLng(-6.1700, 106.8200),
      condition: RoadCondition.medium,
      description: 'Jalan Medan Merdeka dengan keausan ringan',
      reportedAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    RoadConditionData(
      position: const LatLng(-6.1500, 106.8500),
      condition: RoadCondition.damaged,
      description: 'Jalan Kemayoran berlubang dalam',
      reportedAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    // Outer areas - Tangerang direction
    RoadConditionData(
      position: const LatLng(-6.2200, 106.7200),
      condition: RoadCondition.medium,
      description: 'Jalan menuju Tangerang dengan retakan',
      reportedAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2400, 106.7000),
      condition: RoadCondition.smooth,
      description: 'Jalan tol Bintaro baru selesai renovasi',
      reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    // Bogor direction
    RoadConditionData(
      position: const LatLng(-6.3000, 106.8400),
      condition: RoadCondition.damaged,
      description: 'Jalan menuju Bogor rusak parah',
      reportedAt: DateTime.now().subtract(const Duration(hours: 15)),
    ),
    RoadConditionData(
      position: const LatLng(-6.2800, 106.8600),
      condition: RoadCondition.medium,
      description: 'Jalan Depok dengan tambalan tidak rata',
      reportedAt: DateTime.now().subtract(const Duration(hours: 11)),
    ),
    // Bekasi direction
    RoadConditionData(
      position: const LatLng(-6.2000, 106.9500),
      condition: RoadCondition.smooth,
      description: 'Jalan raya Bekasi kondisi baik',
      reportedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    RoadConditionData(
      position: const LatLng(-6.1800, 106.9800),
      condition: RoadCondition.damaged,
      description: 'Jalan industrial Bekasi berlubang besar',
      reportedAt: DateTime.now().subtract(const Duration(hours: 18)),
    ),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // Initialize speech to text
    _speechToText = stt.SpeechToText();
    // _initSpeech();

    // Initialize animation controllers
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _voicePulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fabScaleAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _fabAnimationController,
            curve: Curves.easeInOut,
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

    _voicePulseAnimation =
        Tween<double>(
          begin: 0.8,
          end: 1.2,
        ).animate(
          CurvedAnimation(
            parent: _voicePulseAnimationController,
            curve: Curves.easeInOut,
          ),
        );

    if (!_hasInitialized) {
      _getCurrentLocation();
      _hasInitialized = true;
    }

    // Add search focus listener
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        setState(() {
          _searchSuggestions.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _cardAnimationController.dispose();
    _voicePulseAnimationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchTimer?.cancel();
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

  // Speech to text functionality
  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) {
        setState(() {
          _isListening = status == 'listening';
        });
        if (status == 'listening') {
          _voicePulseAnimationController.repeat(reverse: true);
        } else {
          _voicePulseAnimationController.stop();
        }
      },
      onError: (error) {
        setState(() {
          _isListening = false;
        });
        _voicePulseAnimationController.stop();
      },
    );
    setState(() {});
  }

  Future<void> _startListening() async {
    if (!_speechEnabled) return;

    setState(() {
      _isListening = true;
      _voiceResult = '';
    });

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _voiceResult = result.recognizedWords;
          // Update search field with interim results
          _searchController.text = _voiceResult;
          _isSearching = _voiceResult.isNotEmpty;

          if (result.finalResult) {
            _isListening = false;
            // Perform search with voice result
            if (_voiceResult.isNotEmpty) {
              _performSearch(_voiceResult);
            }
          }
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'id_ID', // Indonesian locale
      cancelOnError: true,
      listenMode: stt.ListenMode.confirmation,
    );
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _onVoiceInputPressed() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
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

  String _getConditionDescription(RoadCondition condition) {
    switch (condition) {
      case RoadCondition.smooth:
        return 'Kondisi jalan baik dan layak';
      case RoadCondition.medium:
        return 'Kondisi jalan cukup baik';
      case RoadCondition.damaged:
        return 'Jalan rusak perlu perbaikan';
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

  void _showFilterBottomSheet() {
    final colors = context.colors;
    final textTheme = context.textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
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
                  Icon(
                    Icons.filter_list,
                    color: colors.primary[500],
                    size: 24,
                  ),
                  16.horizontal,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filter Kondisi Jalan',
                          style: textTheme.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.neutral[700],
                          ),
                        ),
                        Text(
                          'Pilih kondisi jalan yang ingin ditampilkan',
                          style: textTheme.bodySmall.copyWith(
                            color: colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              24.vertical,

              // Filter toggles
              Column(
                children: RoadCondition.values.map((condition) {
                  final isSelected = _selectedConditions.contains(condition);
                  final conditionCount = _roadConditions
                      .where((road) => road.condition == condition)
                      .length;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.neutral[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colors.neutral[200]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Icon with condition color
                        // Container(
                        //   width: 40,
                        //   height: 40,
                        //   decoration: BoxDecoration(
                        //     color: _getConditionColor(
                        //       condition,
                        //     ).withOpacity(0.15),
                        //     borderRadius: BorderRadius.circular(20),
                        //   ),
                        //   child: Icon(
                        //     _getConditionIcon(condition),
                        //     color: _getConditionColor(condition),
                        //     size: 20,
                        //   ),
                        // ),
                        Icon(
                          _getConditionIcon(condition),
                          color: _getConditionColor(condition),
                          size: 28,
                        ),
                        16.horizontal,

                        // Text content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jalan ${_getConditionText(condition)}',
                                style: textTheme.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colors.neutral[700],
                                ),
                              ),
                              4.vertical,
                              Text(
                                _getConditionDescription(condition),
                                style: textTheme.bodySmall.copyWith(
                                  color: colors.grey[300],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Count badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.neutral[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$conditionCount',
                            style: textTheme.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.neutral[700],
                            ),
                          ),
                        ),
                        16.horizontal,

                        // Toggle switch
                        Switch(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              _toggleConditionFilter(condition);
                            });
                            setModalState(() {}); // Update the modal state
                          },
                          activeColor: _getConditionColor(condition),
                          activeTrackColor: _getConditionColor(
                            condition,
                          ).withOpacity(0.3),
                          inactiveThumbColor: colors.neutral[600],
                          inactiveTrackColor: colors.neutral[500],
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              24.vertical,

              // Action button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary[500],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Terapkan',
                  style: textTheme.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        leading: IconButton(
          onPressed: _showFilterBottomSheet,
          icon: Icon(
            Icons.filter_list,
            color: colors.primary[500],
            size: 24,
          ),
          tooltip: 'Filter Kondisi Jalan',
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (_currentPosition != null) {
                _mapController.move(_currentPosition!, 15);
              }
            },
            icon: Icon(
              Icons.center_focus_strong,
              color: colors.secondary[500],
              size: 24,
            ),
            tooltip: 'Center Map',
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Close search suggestions when tapping outside
          if (_searchFocusNode.hasFocus) {
            _searchFocusNode.unfocus();
            setState(() {
              _searchSuggestions.clear();
            });
          }
        },
        child: Stack(
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

            // Search bar with suggestions
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: SlideTransition(
                position: _cardSlideAnimation,
                child: Column(
                  children: [
                    _buildSearchBar(colors, textTheme),
                    if (_searchSuggestions.isNotEmpty) ...[
                      8.vertical,
                      _buildSearchSuggestions(colors, textTheme),
                    ],
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(AppColors colors, AppTextStyles textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: _isListening
            ? Border.all(
                color: colors.primary[500]!,
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: _isListening
                ? colors.primary[500]!.withOpacity(0.2)
                : Colors.black.withOpacity(0.1),
            blurRadius: _isListening ? 20 : 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            // Search icon
            // Container(
            //   padding: const EdgeInsets.all(12),
            //   decoration: BoxDecoration(
            //     color: colors.primary[100],
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Icon(
            //     Icons.search,
            //     color: colors.primary[500],
            //     size: 20,
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Icon(
                Icons.search,
                color: colors.grey[500],
                size: 22,
              ),
            ),
            12.horizontal,

            // Search input field
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (value) {
                  setState(() {
                    _isSearching = value.isNotEmpty;
                  });
                  _onSearchChanged(value);
                },
                onSubmitted: _performSearch,
                decoration: InputDecoration(
                  hintText: _isListening
                      ? 'Sedang mendengarkan...'
                      : 'Cari lokasi atau alamat...',
                  hintStyle: textTheme.bodyMedium.copyWith(
                    color: _isListening
                        ? colors.primary[500]
                        : colors.grey[500],
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: textTheme.bodyMedium.copyWith(
                  color: colors.neutral[900],
                ),
              ),
            ),

            // Clear/Voice input button
            if (_isSearching)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() {
                    _isSearching = false;
                    _searchSuggestions.clear();
                  });
                  _searchFocusNode.unfocus();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.clear,
                    color: colors.grey[600],
                    size: 16,
                  ),
                ),
              )
            else
              Tooltip(
                message: _speechEnabled
                    ? (_isListening
                          ? 'Sedang mendengarkan...'
                          : 'Sentuh untuk pencarian suara')
                    : 'Pencarian suara tidak tersedia',
                child: GestureDetector(
                  onTap: _speechEnabled ? _onVoiceInputPressed : null,
                  child: AnimatedBuilder(
                    animation: _voicePulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isListening ? _voicePulseAnimation.value : 1.0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            // color: _isListening
                            //     ? colors.primary[500]
                            //     : (_speechEnabled
                            //           ? colors.secondary[100]
                            //           : colors.grey[200]),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _isListening
                                ? [
                                    BoxShadow(
                                      color: colors.primary[500]!.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            _isListening
                                ? Icons.mic
                                : (_speechEnabled
                                      ? Icons.mic_rounded
                                      : Icons.mic_off),
                            color: _isListening
                                ? Colors.white
                                : (_speechEnabled
                                      ? colors.grey[500]
                                      : colors.grey[500]),
                            size: 22,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            4.horizontal,
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions(AppColors colors, AppTextStyles textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _searchSuggestions.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: colors.neutral[200],
        ),
        itemBuilder: (context, index) {
          final suggestion = _searchSuggestions[index];
          return ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.location_on,
                size: 16,
                color: colors.grey[600],
              ),
            ),
            title: Text(
              suggestion,
              style: textTheme.bodyMedium.copyWith(
                color: colors.neutral[900],
              ),
            ),
            trailing: Icon(
              Icons.north_west,
              size: 16,
              color: colors.grey[500],
            ),
            onTap: () {
              _searchController.text = suggestion;
              _performSearch(suggestion);
            },
          );
        },
      ),
    );
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchSuggestions.clear();
      });
      return;
    }

    // Cancel previous timer
    _searchTimer?.cancel();

    // Start new timer for debouncing
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      // Mock search suggestions - in real app this would come from geocoding API
      final mockSuggestions = [
        'Jakarta Pusat, DKI Jakarta',
        'Jakarta Selatan, DKI Jakarta',
        'Jakarta Barat, DKI Jakarta',
        'Jakarta Utara, DKI Jakarta',
        'Jakarta Timur, DKI Jakarta',
        'Bandung, Jawa Barat',
        'Surabaya, Jawa Timur',
        'Yogyakarta, D.I. Yogyakarta',
      ];

      setState(() {
        _searchSuggestions = mockSuggestions
            .where(
              (suggestion) =>
                  suggestion.toLowerCase().contains(query.toLowerCase()),
            )
            .take(5)
            .toList();
      });
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    try {
      // Simulate search with geocoding
      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final newPosition = LatLng(location.latitude, location.longitude);

        setState(() {
          _currentPosition = newPosition;
          _isSearching = false;
          _searchSuggestions.clear();
        });

        _mapController.move(newPosition, 15);
        _searchFocusNode.unfocus();

        // Get address for the new location
        final address = await _getAddressFromCoordinates(
          location.latitude,
          location.longitude,
        );
        setState(() {
          _currentAddress = address;
        });
      }
    } catch (e) {
      // Handle search error
      setState(() {
        _errorMessage = 'Lokasi tidak ditemukan: $query';
      });
    }
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
                Icon(
                  _getConditionIcon(roadData.condition),
                  color: _getConditionColor(roadData.condition),
                  size: 36,
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
                      Row(
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
                    ],
                  ),
                ),
              ],
            ),
            24.vertical,

            // Photo section
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
                        Icons.photo_camera,
                        size: 18,
                        color: colors.neutral[600],
                      ),
                      8.horizontal,
                      Text(
                        'Foto Kondisi Jalan',
                        style: textTheme.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.neutral[700],
                        ),
                      ),
                    ],
                  ),
                  12.vertical,
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Assets.images.damagedRoad.image(
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback UI when image fails to load
                        return Container(
                          color: colors.neutral[100],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                size: 48,
                                color: colors.neutral[400],
                              ),
                              8.vertical,
                              Text(
                                'Foto tidak tersedia',
                                style: textTheme.bodySmall.copyWith(
                                  color: colors.neutral[500],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  12.vertical,
                  // Photo metadata
                  Row(
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 14,
                        color: colors.neutral[600],
                      ),
                      4.horizontal,
                      Text(
                        'Diambil ${_formatTime(roadData.reportedAt)}',
                        style: textTheme.bodySmall.copyWith(
                          color: colors.neutral[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            16.vertical,

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
                          color: colors.neutral[700],
                        ),
                      ),
                    ],
                  ),
                  8.vertical,
                  Text(
                    roadData.description,
                    style: textTheme.bodyMedium.copyWith(
                      color: colors.neutral[900],
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
                              color: colors.neutral[700],
                            ),
                            6.horizontal,
                            Text(
                              'Waktu Laporan',
                              style: textTheme.bodySmall.copyWith(
                                color: colors.neutral[700],
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
                                color: colors.neutral[700],
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
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _mapController.move(roadData.position, 18);
                    },
                    icon: const Icon(Icons.zoom_in),
                    label: const Text('Zoom Ke Lokasi'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: colors.primary[500]!),
                      backgroundColor: Colors.white,
                      elevation: 0,
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
