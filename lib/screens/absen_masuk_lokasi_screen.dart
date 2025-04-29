import 'package:ujk/services/absen_services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AbsenMasukLokasiScreen extends StatefulWidget {
  const AbsenMasukLokasiScreen({super.key});

  @override
  State<AbsenMasukLokasiScreen> createState() => _AbsenMasukLokasiScreenState();
}

class _AbsenMasukLokasiScreenState extends State<AbsenMasukLokasiScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final LatLng kantorLocation = const LatLng(-6.2109, 106.8129);
  bool isInsideRadius = false;
  double distance = 0.0;
  static const double allowedRadius = 15; // dalam meter

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    double jarak = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      kantorLocation.latitude,
      kantorLocation.longitude,
    );

    setState(() {
      _currentPosition = position;
      distance = jarak;
      isInsideRadius = jarak <= allowedRadius;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Absen Masuk via Lokasi')),
      body:
          _currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: kantorLocation,
                        zoom: 20,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('kantor'),
                          position: kantorLocation,
                          infoWindow: const InfoWindow(
                            title: 'Titik Lokasi Kantor',
                          ),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRed,
                          ), // kantor = merah
                        ),
                        Marker(
                          markerId: const MarkerId('user'),
                          position: LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          ),
                          infoWindow: const InfoWindow(title: 'Posisi Kamu'),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueAzure,
                          ), // user = biru muda
                        ),
                      },
                      circles: {
                        Circle(
                          circleId: const CircleId('radius'),
                          center: kantorLocation,
                          radius: allowedRadius, // radius dalam meter
                          fillColor: Colors.green.withOpacity(0.3),
                          strokeColor: Colors.green,
                          strokeWidth: 2,
                        ),
                      },
                      onMapCreated: (controller) => _mapController = controller,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Jarak ke kantor: ${distance.toStringAsFixed(1)} meter',
                          style: TextStyle(
                            fontSize: 16,
                            color: isInsideRadius ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Absen Sekarang'),
                          onPressed:
                              isInsideRadius
                                  ? () async {
                                    await AbsenServices.absenMasuk(context);
                                    if (context.mounted) Navigator.pop(context);
                                  }
                                  : null,

                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
