import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'package:tilikjalan/core/core.dart';
import 'package:tilikjalan/utils/utils.dart';
import 'package:tilikjalan/widgets/widgets.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Image handling
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Location handling
  final loc.Location _location = loc.Location();
  LatLng? _selectedLocation;
  String? _selectedAddress;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      // Check if location service is enabled
      var serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      // Check location permissions
      var permissionGranted = await _location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      // Get current location
      final locationData = await _location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        final newPosition = LatLng(
          locationData.latitude!,
          locationData.longitude!,
        );

        final address = await _getAddressFromCoordinates(
          locationData.latitude!,
          locationData.longitude!,
        );

        setState(() {
          _selectedLocation = newPosition;
          _selectedAddress = address;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<String> _getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        return '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.postalCode ?? ''}, ${place.country ?? ''}'
            .replaceAll(RegExp(r'^,\s*|,\s*,'), ',')
            .replaceAll(RegExp(r'^,\s*'), '')
            .replaceAll(RegExp(r',\s*$'), '');
      }
      return 'Address not found';
    } catch (e) {
      return 'Error getting address: $e';
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    final colors = context.colors;
    final textTheme = context.textTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            16.vertical,
            Text(
              'Pilih Sumber Foto',
              style: textTheme.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            8.vertical,
            Text(
              'Pilih dari mana Anda ingin mengambil foto',
              style: textTheme.bodySmall.copyWith(
                color: colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            24.vertical,
            Row(
              children: [
                Expanded(
                  child: _ImageSourceButton(
                    icon: Icons.camera_alt,
                    label: 'Kamera',
                    onTap: () async {
                      Navigator.pop(context);
                      await _captureImage();
                    },
                  ),
                ),
                16.horizontal,
                Expanded(
                  child: _ImageSourceButton(
                    icon: Icons.photo_library,
                    label: 'Galeri',
                    onTap: () async {
                      Navigator.pop(context);
                      await _pickImage();
                    },
                  ),
                ),
              ],
            ),
            16.vertical,
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: textTheme.titleSmall.copyWith(
                  color: colors.grey[600],
                ),
              ),
            ),
            8.vertical,
          ],
        ),
      ),
    );
  }

  void _showLocationPicker() {
    context.push(
      LocationPickerPage(
        initialLocation: _selectedLocation,
        onLocationSelected: (location, address) {
          setState(() {
            _selectedLocation = location;
            _selectedAddress = address;
          });
        },
      ),
    );
  }

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      if (_selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mohon pilih lokasi terlebih dahulu'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // TODO: Implement report submission logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil dikirim!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedImage = null;
      });
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
          'Buat Laporan',
          style: textTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section
              Text(
                'Judul Laporan',
                style: textTheme.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              8.vertical,
              CustomTextField(
                label: 'Masukkan judul laporan',
                controller: _titleController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul laporan tidak boleh kosong';
                  }
                  if (value.trim().length < 5) {
                    return 'Judul laporan minimal 5 karakter';
                  }
                  return null;
                },
              ),
              24.vertical,

              // Description Section
              Text(
                'Deskripsi',
                style: textTheme.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              8.vertical,
              CustomTextField(
                label: 'Jelaskan kondisi jalan secara detail',
                controller: _descriptionController,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  if (value.trim().length < 10) {
                    return 'Deskripsi minimal 10 karakter';
                  }
                  return null;
                },
              ),
              24.vertical,

              // Photo Section
              Text(
                'Foto Dokumentasi',
                style: textTheme.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              8.vertical,
              _PhotoSection(
                selectedImage: _selectedImage,
                onPickImage: _showImagePickerOptions,
                onRemoveImage: () => setState(() => _selectedImage = null),
              ),
              24.vertical,

              // Location Section
              Text(
                'Lokasi',
                style: textTheme.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              8.vertical,
              _LocationSection(
                selectedLocation: _selectedLocation,
                selectedAddress: _selectedAddress,
                isLoading: _isLoadingLocation,
                onSelectLocation: _showLocationPicker,
                onRefreshLocation: _getCurrentLocation,
              ),
              32.vertical,

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary[500],
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Kirim Laporan',
                    style: textTheme.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              24.vertical,
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageSourceButton extends StatefulWidget {
  const _ImageSourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_ImageSourceButton> createState() => _ImageSourceButtonState();
}

class _ImageSourceButtonState extends State<_ImageSourceButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: _isPressed ? colors.grey[50] : Colors.white,
          border: Border.all(
            color: _isPressed ? colors.primary[500]! : colors.grey[200]!,
            width: _isPressed ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: colors.primary[500]!.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              widget.icon,
              size: 32,
              color: _isPressed ? colors.primary[600] : colors.primary[500],
            ),
            8.vertical,
            Text(
              widget.label,
              style: textTheme.titleSmall.copyWith(
                fontWeight: FontWeight.w500,
                color: _isPressed ? colors.primary[600] : colors.neutral[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoSection extends StatelessWidget {
  const _PhotoSection({
    required this.selectedImage,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  final XFile? selectedImage;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.grey[200]!),
      ),
      child: selectedImage != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(selectedImage!.path),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onRemoveImage,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : InkWell(
              onTap: onPickImage,
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: colors.grey[400],
                  ),
                  12.vertical,
                  Text(
                    'Tambah Foto',
                    style: textTheme.titleSmall.copyWith(
                      color: colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  4.vertical,
                  Text(
                    'Tap untuk memilih foto',
                    style: textTheme.bodySmall.copyWith(
                      color: colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _LocationSection extends StatefulWidget {
  const _LocationSection({
    required this.selectedLocation,
    required this.selectedAddress,
    required this.isLoading,
    required this.onSelectLocation,
    required this.onRefreshLocation,
  });

  final LatLng? selectedLocation;
  final String? selectedAddress;
  final bool isLoading;
  final VoidCallback onSelectLocation;
  final VoidCallback onRefreshLocation;

  @override
  State<_LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends State<_LocationSection> {
  final MapController _mapController = MapController();

  @override
  void didUpdateWidget(_LocationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update map center when location changes
    if (widget.selectedLocation != null &&
        widget.selectedLocation != oldWidget.selectedLocation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(widget.selectedLocation!, 15);
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Map preview
          Container(
            height: 200,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: widget.selectedLocation != null
                  ? FlutterMap(
                      mapController: _mapController,
                      key: ValueKey(
                        'location_${widget.selectedLocation!.latitude}_${widget.selectedLocation!.longitude}',
                      ),
                      options: MapOptions(
                        initialCenter: widget.selectedLocation!,
                        initialZoom: 15,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName:
                              'dev.fleaflet.flutter_map.example',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: widget.selectedLocation!,
                              child: Icon(
                                Icons.location_pin,
                                color: colors.primary[500],
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Container(
                      color: colors.grey[100],
                      child: Center(
                        child: widget.isLoading
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colors.primary[500],
                                    ),
                                  ),
                                  8.vertical,
                                  Text(
                                    'Mendapatkan lokasi...',
                                    style: textTheme.bodySmall,
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_off,
                                    size: 48,
                                    color: colors.grey[400],
                                  ),
                                  8.vertical,
                                  Text(
                                    'Lokasi belum dipilih',
                                    style: textTheme.bodySmall.copyWith(
                                      color: colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
            ),
          ),

          // Location info and actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.selectedLocation != null) ...[
                  Text(
                    'Koordinat:',
                    style: textTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  4.vertical,
                  Text(
                    'Lat: ${widget.selectedLocation!.latitude.toStringAsFixed(6)}, '
                    'Lng: ${widget.selectedLocation!.longitude.toStringAsFixed(6)}',
                    style: textTheme.bodySmall.copyWith(
                      color: colors.neutral[800],
                    ),
                  ),
                  if (widget.selectedAddress != null) ...[
                    12.vertical,
                    Text(
                      'Alamat:',
                      style: textTheme.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    4.vertical,
                    Text(
                      widget.selectedAddress!,
                      style: textTheme.bodySmall.copyWith(
                        color: colors.neutral[800],
                      ),
                    ),
                  ],
                  16.vertical,
                ],

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.onSelectLocation,
                        icon: const Icon(Icons.map_outlined),
                        label: Text(
                          widget.selectedLocation != null
                              ? 'Ubah Lokasi'
                              : 'Pilih Lokasi',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.primary[500],
                          side: BorderSide(color: colors.primary[500]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    if (widget.selectedLocation != null) ...[
                      12.horizontal,
                      IconButton(
                        onPressed: widget.onRefreshLocation,
                        icon: const Icon(Icons.refresh),
                        style: IconButton.styleFrom(
                          foregroundColor: colors.primary[500],
                        ),
                        tooltip: 'Refresh lokasi saat ini',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({
    super.key,
    this.initialLocation,
    required this.onLocationSelected,
  });

  final LatLng? initialLocation;
  final void Function(LatLng location, String address) onLocationSelected;

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  String? _selectedAddress;
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation =
        widget.initialLocation ??
        const LatLng(-6.2088, 106.8456); // Default to Jakarta
    if (_selectedLocation != null) {
      _loadAddress(_selectedLocation!);
    }
  }

  Future<void> _loadAddress(LatLng location) async {
    setState(() => _isLoadingAddress = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        final address =
            '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.postalCode ?? ''}, ${place.country ?? ''}'
                .replaceAll(RegExp(r'^,\s*|,\s*,'), ',')
                .replaceAll(RegExp(r'^,\s*'), '')
                .replaceAll(RegExp(r',\s*$'), '');
        setState(() {
          _selectedAddress = address;
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      setState(() {
        _selectedAddress = 'Error getting address';
        _isLoadingAddress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pilih Lokasi',
          style: textTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: colors.neutral[900],
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _selectedLocation != null
                ? () {
                    widget.onLocationSelected(
                      _selectedLocation!,
                      _selectedAddress ?? 'Address not found',
                    );
                    Navigator.pop(context);
                  }
                : null,
            child: Text(
              'Pilih',
              style: textTheme.titleSmall.copyWith(
                color: _selectedLocation != null
                    ? colors.primary[500]
                    : colors.grey[400],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation!,
              initialZoom: 15,
              onTap: (tapPosition, point) {
                setState(() => _selectedLocation = point);
                _loadAddress(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'dev.fleaflet.flutter_map.example',
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      child: Icon(
                        Icons.location_pin,
                        color: colors.primary[500],
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Address info card
          if (_selectedLocation != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lokasi Terpilih',
                        style: textTheme.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      8.vertical,
                      Text(
                        'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, '
                        'Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                        style: textTheme.bodySmall.copyWith(
                          color: colors.neutral[800],
                        ),
                      ),
                      if (_isLoadingAddress)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: colors.primary[500],
                                ),
                              ),
                              8.horizontal,
                              Text(
                                'Mendapatkan alamat...',
                                style: textTheme.bodySmall,
                              ),
                            ],
                          ),
                        )
                      else if (_selectedAddress != null) ...[
                        8.vertical,
                        Text(
                          'Alamat:',
                          style: textTheme.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        4.vertical,
                        Text(
                          _selectedAddress!,
                          style: textTheme.bodySmall.copyWith(
                            color: colors.neutral[800],
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
