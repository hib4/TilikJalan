import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:tilikjalan/core/theme/app_theme.dart';
import 'package:tilikjalan/utils/utils.dart';

// Model class for road segment data
class RoadSegment {
  RoadSegment({
    required this.latitude,
    required this.longitude,
    required this.roughnessIndex,
    required this.timestamp,
    required this.accelerometerReadings,
  });

  final double latitude;
  final double longitude;
  final double roughnessIndex;
  final DateTime timestamp;
  final List<double> accelerometerReadings;
}

// Service class for road roughness detection
class RoadRoughnessService {
  // Streams for sensor data
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<Position>? _positionSubscription;

  // Data collection variables
  final List<double> _recentAccelerations = [];
  Position? _currentPosition;
  Timer? _analysisTimer;
  final loc.Location _location = loc.Location();

  // Callbacks
  void Function(RoadSegment)? onSegmentAnalyzed;
  void Function(String)? onError;

  // Configuration
  static const int _samplingWindowMs =
      3000; // 3 seconds window for better responsiveness
  static const double _accelerometerThreshold =
      0.8; // Increased threshold for significant bumps
  static const int _minSamples = 30; // Reduced for faster response
  static const double _gravityFilter =
      0.8; // Low-pass filter for gravity removal
  static const double _speedThreshold =
      5; // Minimum speed (km/h) for valid readings

  // Additional data for improved accuracy
  final List<double> _filteredAccelerations = [];
  final List<double> _speedReadings = [];
  double _previousFilteredAccel = 0;

  // Start monitoring road conditions
  Future<void> startMonitoring() async {
    try {
      // Request permissions
      await _requestPermissions();

      // Start accelerometer monitoring
      _startAccelerometerMonitoring();

      // Start GPS monitoring
      _startGPSMonitoring();

      // Start periodic analysis
      _startPeriodicAnalysis();

      // Confirm successful start
      print('RoadRoughnessService: Monitoring started successfully');
    } catch (e) {
      print('RoadRoughnessService: Failed to start monitoring: $e');
      onError?.call('Failed to start monitoring: $e');
      rethrow;
    }
  }

  // Stop monitoring
  void stopMonitoring() {
    _accelerometerSubscription?.cancel();
    _positionSubscription?.cancel();
    _analysisTimer?.cancel();
    _recentAccelerations.clear();
    _filteredAccelerations.clear();
    _speedReadings.clear();
    _previousFilteredAccel = 0.0;
  }

  // Request necessary permissions
  Future<void> _requestPermissions() async {
    // Check if location service is enabled
    var serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }
    }

    // Check location permissions
    var permissionGranted = await _location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        throw Exception('Location permission denied');
      }
    }
  }

  // Start accelerometer monitoring
  void _startAccelerometerMonitoring() {
    _accelerometerSubscription = accelerometerEvents.listen(
      (event) {
        // Apply high-pass filter to remove gravity and low-frequency noise
        final rawMagnitude = sqrt(
          pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2),
        );

        // High-pass filter to remove gravity (9.8 m/s²) and device orientation effects
        final filteredAccel = _applyHighPassFilter(rawMagnitude);

        // Store both raw and filtered acceleration data
        _recentAccelerations.add(rawMagnitude);
        _filteredAccelerations.add(filteredAccel);

        // Keep only recent data (based on sampling window)
        final maxSamples = (_samplingWindowMs / 50)
            .round(); // Assuming ~20Hz sampling
        if (_recentAccelerations.length > maxSamples) {
          _recentAccelerations.removeAt(0);
          _filteredAccelerations.removeAt(0);
        }
      },
      onError: (Object error) {
        onError?.call('Accelerometer error: $error');
      },
    );
  }

  // Apply high-pass filter to remove gravity and low-frequency components
  double _applyHighPassFilter(double currentAccel) {
    // Simple high-pass filter implementation
    const alpha = _gravityFilter;
    _previousFilteredAccel =
        alpha * _previousFilteredAccel +
        alpha * (currentAccel - _previousFilteredAccel);
    return currentAccel - _previousFilteredAccel;
  }

  // Start GPS monitoring
  void _startGPSMonitoring() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update every 5 meters for better speed tracking
    );

    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: locationSettings,
        ).listen(
          (position) {
            _currentPosition = position;

            // Track speed for better accuracy (convert m/s to km/h)
            final speedKmh = position.speed * 3.6;
            _speedReadings.add(speedKmh);

            // Keep only recent speed readings
            if (_speedReadings.length > 20) {
              _speedReadings.removeAt(0);
            }
          },
          onError: (Object error) {
            onError?.call('GPS error: $error');
          },
        );
  }

  // Start periodic analysis of collected data
  void _startPeriodicAnalysis() {
    _analysisTimer = Timer.periodic(
      const Duration(milliseconds: _samplingWindowMs),
      (_) => _analyzeRoadSegment(),
    );
  }

  // Analyze current road segment
  void _analyzeRoadSegment() {
    if (_currentPosition == null ||
        _recentAccelerations.length < _minSamples ||
        _filteredAccelerations.length < _minSamples) {
      return;
    }

    // Check if vehicle is moving at reasonable speed
    final currentSpeed = _speedReadings.isNotEmpty ? _speedReadings.last : 0.0;
    if (currentSpeed < _speedThreshold) {
      // Vehicle is stationary or moving too slowly for accurate readings
      return;
    }

    // Calculate roughness index using improved algorithm
    final roughnessIndex = _calculateRoughnessIndex(_filteredAccelerations);

    // Create road segment
    final segment = RoadSegment(
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      roughnessIndex: roughnessIndex,
      timestamp: DateTime.now(),
      accelerometerReadings: List.from(_filteredAccelerations),
    );

    // Notify callback
    onSegmentAnalyzed?.call(segment);

    // Clear old data
    _recentAccelerations.clear();
    _filteredAccelerations.clear();
  }

  // Calculate roughness index from acceleration data using improved algorithm
  double _calculateRoughnessIndex(List<double> accelerations) {
    if (accelerations.isEmpty) return 0;

    // 1. Statistical measures
    final mean = accelerations.reduce((a, b) => a + b) / accelerations.length;
    final variance =
        accelerations.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) /
        accelerations.length;
    final stdDev = sqrt(variance);

    // 2. Root Mean Square (RMS) - better for vibration analysis
    final rms = sqrt(
      accelerations.map((x) => pow(x, 2)).reduce((a, b) => a + b) /
          accelerations.length,
    );

    // 3. Peak detection and analysis
    final peaks = _detectPeaks(accelerations);
    final peakFrequency =
        peaks.length /
        (accelerations.length / 20.0); // peaks per second (assuming 20Hz)

    // 4. International Roughness Index (IRI) inspired calculation
    final iri = _calculateIRI(accelerations);

    // 5. Crest factor (peak-to-RMS ratio) for road surface characterization
    final maxAccel = accelerations.reduce(max);
    final crestFactor = rms > 0 ? maxAccel / rms : 0;

    // 6. Power spectral density for frequency analysis
    final psd = _calculatePowerSpectralDensity(accelerations);

    // 7. Adjust for vehicle speed if available
    final speedFactor = _getSpeedAdjustmentFactor();

    // Weighted combination of all metrics for final roughness index
    double roughnessIndex = 0;

    // Standard deviation (road surface irregularity) - 25%
    roughnessIndex += (stdDev * 100).clamp(0, 25);

    // RMS acceleration (overall vibration level) - 20%
    roughnessIndex += (rms * 50).clamp(0, 20);

    // Peak frequency (bump frequency) - 20%
    roughnessIndex += (peakFrequency * 10).clamp(0, 20);

    // IRI-inspired metric - 20%
    roughnessIndex += (iri * 2).clamp(0, 20);

    // Crest factor (surface texture) - 10%
    roughnessIndex += (crestFactor * 5).clamp(0, 10);

    // Power spectral density (frequency content) - 5%
    roughnessIndex += (psd * 20).clamp(0, 5);

    // Apply speed adjustment
    roughnessIndex *= speedFactor;

    // Normalize to 0-100 scale with non-linear scaling for better differentiation
    roughnessIndex = roughnessIndex.clamp(0, 100);

    // Apply logarithmic scaling for better human perception
    if (roughnessIndex > 0) {
      roughnessIndex = 100 * (1 - exp(-roughnessIndex / 30));
    }

    return roughnessIndex.clamp(0, 100);
  }

  // Detect peaks in acceleration data for bump counting
  List<int> _detectPeaks(List<double> data) {
    final peaks = <int>[];
    const threshold = _accelerometerThreshold;

    for (int i = 1; i < data.length - 1; i++) {
      if (data[i] > threshold &&
          data[i] > data[i - 1] &&
          data[i] > data[i + 1]) {
        peaks.add(i);
      }
    }

    return peaks;
  }

  // Calculate International Roughness Index inspired metric
  double _calculateIRI(List<double> accelerations) {
    if (accelerations.length < 2) return 0;

    // Calculate cumulative absolute differences (similar to IRI calculation)
    double cumulativeDeviation = 0;
    for (int i = 1; i < accelerations.length; i++) {
      cumulativeDeviation += (accelerations[i] - accelerations[i - 1]).abs();
    }

    return cumulativeDeviation / accelerations.length;
  }

  // Calculate simplified power spectral density
  double _calculatePowerSpectralDensity(List<double> data) {
    if (data.isEmpty) return 0;

    // Simple approximation of PSD by calculating energy in different frequency bands
    final mean = data.reduce((a, b) => a + b) / data.length;
    final centered = data.map((x) => x - mean).toList();

    // Calculate energy (sum of squares)
    final energy = centered.map((x) => pow(x, 2)).reduce((a, b) => a + b);

    return energy / data.length;
  }

  // Get speed adjustment factor for roughness calculation
  double _getSpeedAdjustmentFactor() {
    if (_speedReadings.isEmpty) return 1;

    final averageSpeed =
        _speedReadings.reduce((a, b) => a + b) / _speedReadings.length;

    // Adjust roughness based on speed (higher speeds amplify road roughness perception)
    if (averageSpeed < 20) return 0.8; // Low speed, reduce sensitivity
    if (averageSpeed < 40) return 1; // Normal speed
    if (averageSpeed < 60) return 1.1; // Medium speed, slight increase
    if (averageSpeed < 80) return 1.2; // High speed, moderate increase
    return 1.3; // Very high speed, significant increase
  }
}

class SensingPage extends StatefulWidget {
  const SensingPage({super.key});

  @override
  State<SensingPage> createState() => _SensingPageState();
}

class _SensingPageState extends State<SensingPage> {
  final RoadRoughnessService _service = RoadRoughnessService();
  bool _isMonitoring = false;
  RoadSegment? _latestSegment;
  final List<RoadSegment> _roadSegments = [];
  String _statusMessage = 'TAP TO START';

  @override
  void initState() {
    super.initState();
    _setupService();
  }

  void _setupService() {
    _service.onSegmentAnalyzed = (segment) {
      setState(() {
        _latestSegment = segment;
        _roadSegments.add(segment);
        if (_roadSegments.length > 100) {
          _roadSegments.removeAt(0);
        }
      });
    };

    _service.onError = (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    };
  }

  @override
  void dispose() {
    _service.stopMonitoring();
    super.dispose();
  }

  Color _getRoughnessColor(double roughness, AppColors colors) {
    if (roughness < 20) return colors.support[500]!; // Green - Smooth
    if (roughness < 40) return colors.secondary[500]!; // Orange - Fair
    if (roughness < 60) return colors.secondary[700]!; // Dark Orange - Rough
    return const Color(0xFFFF3B30); // Red - Very Rough
  }

  String _getRoughnessLabel(double roughness) {
    if (roughness < 20) return 'SMOOTH';
    if (roughness < 40) return 'FAIR';
    if (roughness < 60) return 'ROUGH';
    return 'VERY ROUGH';
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final colors = context.colors;

    // Calculate dynamic sizes based on screen
    final circleSize = screenWidth * 0.45;
    final roughnessValue = _latestSegment?.roughnessIndex ?? 0.0;
    final roughnessColor = _getRoughnessColor(roughnessValue, colors);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.grey[900]!, // Dark background
                colors.grey[800]!, // Slightly lighter dark
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Minimal top bar
                Padding(
                  padding: const EdgeInsets.only(
                    left: 6,
                    right: 24,
                    top: 16,
                    bottom: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: colors.neutral[50],
                            ),
                            onPressed: () {
                              Navigator.of(context).maybePop();
                            },
                          ),
                          6.horizontal,
                          Text(
                            'TilikJalan',
                            style: TextStyle(
                              color: colors.neutral[50],
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
      
                      // Status indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _isMonitoring
                              ? colors.support[500]!.withOpacity(0.2)
                              : colors.neutral[200]!.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _isMonitoring
                                ? colors.support[500]!
                                : colors.neutral[300]!.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _isMonitoring
                                    ? colors.support[500]!
                                    : colors.neutral[400]!.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isMonitoring ? 'MONITORING' : 'READY',
                              style: TextStyle(
                                color: _isMonitoring
                                    ? colors.support[500]!
                                    : colors.neutral[50]!.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      
                // Main content area
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Circular indicator with car icon - now clickable for monitoring
                        GestureDetector(
                          onTap: () async {
                            try {
                              if (!_isMonitoring) {
                                setState(() {
                                  _statusMessage = 'Starting...';
                                });
                                await _service.startMonitoring();
                                setState(() {
                                  _isMonitoring = true;
                                  _statusMessage = 'MONITORING';
                                });
                              } else {
                                _service.stopMonitoring();
                                setState(() {
                                  _isMonitoring = false;
                                  _statusMessage = 'TAP TO START';
                                });
                              }
                            } catch (e) {
                              setState(() {
                                _isMonitoring = false;
                                _statusMessage = 'ERROR';
                              });
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: circleSize,
                            height: circleSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isMonitoring
                                  ? roughnessColor.withOpacity(0.15)
                                  : colors.primary[500]!.withOpacity(0.15),
                              border: Border.all(
                                color: _isMonitoring
                                    ? roughnessColor
                                    : colors.primary[500]!,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (_isMonitoring
                                              ? roughnessColor
                                              : colors.primary[500]!)
                                          .withOpacity(0.3),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.directions_car,
                                size: circleSize * 0.4,
                                color: colors.neutral[50],
                              ),
                            ),
                          ),
                        ),
      
                        const SizedBox(height: 40),
      
                        // Large numeric display
                        Text(
                          roughnessValue.toStringAsFixed(1),
                          style: TextStyle(
                            color: colors.neutral[50],
                            fontSize: screenWidth * 0.25, // Responsive font size
                            fontWeight: FontWeight.w300,
                            height: 1,
                            letterSpacing: -2,
                          ),
                        ),
      
                        const SizedBox(height: 16),
      
                        // Road condition label
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _isMonitoring
                                ? roughnessColor.withOpacity(0.2)
                                : colors.neutral[700]!.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isMonitoring
                                  ? roughnessColor.withOpacity(0.5)
                                  : colors.neutral[600]!.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _getRoughnessLabel(roughnessValue),
                            style: TextStyle(
                              color: _isMonitoring
                                  ? roughnessColor
                                  : colors.neutral[400],
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      
                // Bottom status bar
                Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: colors.grey[900]!.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.neutral[200]!.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'STATUS',
                            style: TextStyle(
                              color: colors.neutral[400],
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _statusMessage,
                            style: TextStyle(
                              color: colors.neutral[100],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (_latestSegment != null) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'READINGS',
                              style: TextStyle(
                                color: colors.neutral[400],
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_roadSegments.length}',
                              style: TextStyle(
                                color: colors.neutral[100],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
