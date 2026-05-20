import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:health_asistants/data/model/health_facility.dart';
import 'package:http/http.dart' as http;

enum FacilityFilter { all, hospital, clinic, pharmacy }

class NearbyFacilitiesViewModel extends ChangeNotifier {
  // 1. DEĞİŞİKLİK: Haritanın ilk açılışta boş kalmaması için varsayılan filtreyi 'all' yaptık.
  FacilityFilter _selectedFilter = FacilityFilter.all;
  FacilityFilter get selectedFilter => _selectedFilter;

  GoogleMapController? mapController;
  Position? currentPosition;
  Set<Marker> markers = {};

  bool isLoadingLocation = true;
  bool isLoadingFacilities = false;
  bool hasLocationPermission = false;
  String? locationErrorMessage;

  final String _googlePlacesApiKey = 'AIzaSyDekHWs_XJCtcq733HEdl9Qt6xNsSLG-3k';

  final List<HealthFacility> _allFacilities = [];

  // Sabit başlangıç konumu (Konya) - Konum alınamazsa veya gecikirse diye
  CameraPosition get initialCameraPosition {
    if (currentPosition != null) {
      return CameraPosition(
        target: LatLng(currentPosition!.latitude, currentPosition!.longitude),
        zoom: 14.0,
      );
    }
    return const CameraPosition(
      target: LatLng(37.8667, 32.4833), // Konya
      zoom: 13.0,
    );
  }

  NearbyFacilitiesViewModel() {
    _init();
  }

  Future<void> _init() async {
    await determinePosition();
    if (currentPosition != null) {
      await fetchNearbyFacilities();
    }
  }

  // GoogleMap onMapCreated çağrısı
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (currentPosition != null) {
      // 2. DEĞİŞİKLİK: Harita çizilir çizilmez kameranın hareket edebilmesi için ufak bir gecikme eklendi.
      Future.delayed(const Duration(milliseconds: 300), () {
        _animateToCurrentPosition();
      });
    }
  }

  // Konum bulma
  Future<void> determinePosition() async {
    isLoadingLocation = true;
    locationErrorMessage = null;
    notifyListeners();

    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setLocationFailure('Konum servisleri kapalı.');
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setLocationFailure('Konum izinleri reddedildi.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setLocationFailure('Konum izinleri kalıcı olarak reddedildi.');
        return;
      }

      hasLocationPermission = true;

      try {
        currentPosition = await Geolocator.getCurrentPosition();
      } catch (e) {
        debugPrint("Konum alınamadı: $e");
        locationErrorMessage = 'Konum alınamadı. Harita varsayılan konumda açıldı.';
      }

      isLoadingLocation = false;
      notifyListeners();

      if (mapController != null && currentPosition != null) {
        _animateToCurrentPosition();
      }
    } catch (e) {
      _setLocationFailure('Konum servisi kullanılamıyor.');
    }
  }

  void _setLocationFailure(String message) {
    hasLocationPermission = false;
    locationErrorMessage = message;
    isLoadingLocation = false;
    notifyListeners();
  }

  void _animateToCurrentPosition() {
    if (mapController == null || currentPosition == null) return;
    mapController!.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(currentPosition!.latitude, currentPosition!.longitude),
      ),
    );
  }

  // Animasyonla marker'a kaydırma
  void animateToFacility(HealthFacility facility) {
    if (facility.latitude != null && facility.longitude != null) {
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(facility.latitude!, facility.longitude!),
          15.0,
        ),
      );
    }
  }

  // Google Places API'den veri çekme
  Future<void> fetchNearbyFacilities() async {
    if (currentPosition == null) return;

    isLoadingFacilities = true;
    notifyListeners();

    _allFacilities.clear();
    markers.clear();

    final lat = currentPosition!.latitude;
    final lng = currentPosition!.longitude;
    final radius = 5000; // 5 km yarıçap

    await _fetchPlaces(lat, lng, radius, 'hospital', FacilityType.hospital);
    await _fetchPlaces(lat, lng, radius, 'clinic', FacilityType.clinic);
    await _fetchPlaces(lat, lng, radius, 'pharmacy', FacilityType.pharmacy);

    _updateMarkers();

    isLoadingFacilities = false;
    notifyListeners();
  }

  Future<void> _fetchPlaces(
    double lat,
    double lng,
    int radius,
    String type,
    FacilityType facilityType,
  ) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=$lat,$lng'
      '&radius=$radius'
      '&type=$type'
      '&language=tr'
      '&key=$_googlePlacesApiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final results = data['results'] as List;

          for (var result in results) {
            final geo = result['geometry']['location'];
            final pLat = geo['lat'];
            final pLng = geo['lng'];
            final name = result['name'];
            final subtitle = result['vicinity'] ?? '';
            final placeId = result['place_id'];

            final distanceMeters = Geolocator.distanceBetween(
              lat,
              lng,
              pLat,
              pLng,
            );
            final distanceText = distanceMeters > 1000
                ? '${(distanceMeters / 1000).toStringAsFixed(1)} km'
                : '${distanceMeters.toStringAsFixed(0)} m';

            if (!_allFacilities.any((f) => f.id == placeId)) {
              _allFacilities.add(
                HealthFacility(
                  id: placeId,
                  name: name,
                  subtitle: subtitle,
                  type: facilityType,
                  distanceText: distanceText,
                  distanceValue: distanceMeters,
                  isDuty: facilityType == FacilityType.pharmacy ? true : false,
                  latitude: pLat,
                  longitude: pLng,
                ),
              );
            }
          }
        } else if (data['status'] != 'ZERO_RESULTS') {
          debugPrint(
            "API Hatası: ${data['status']} - ${data['error_message']}",
          );
          locationErrorMessage = 'Google Places API Hatası: ${data['status']}';
          // 3. DEĞİŞİKLİK: Hata durumunda UI'ın tepki vermesi için notifyListeners eklendi.
          notifyListeners(); 
        }
      } else {
        debugPrint("API Hatası: ${response.statusCode}");
        locationErrorMessage =
            'Harita Servisine Ulaşılamadı (${response.statusCode})';
        notifyListeners(); // Eklendi
      }
    } catch (e) {
      debugPrint("İstek hatası: $e");
      locationErrorMessage = 'Harita isteği başarısız oldu.';
      notifyListeners(); // Eklendi
    }
  }

  // Filtrelenmiş listeyi döndür
  List<HealthFacility> get filteredFacilities {
    List<HealthFacility> filtered = [];
    switch (_selectedFilter) {
      case FacilityFilter.hospital:
        filtered = _allFacilities
            .where((f) => f.type == FacilityType.hospital)
            .toList();
        break;
      case FacilityFilter.clinic:
        filtered = _allFacilities
            .where((f) => f.type == FacilityType.clinic)
            .toList();
        break;
      case FacilityFilter.pharmacy:
        // Nöbetçi eczaneler filtresi
        filtered = _allFacilities
            .where((f) => f.type == FacilityType.pharmacy && f.isDuty)
            .toList();
        break;
      case FacilityFilter.all:
        filtered = _allFacilities;
    }

    filtered.sort((a, b) => a.distanceValue.compareTo(b.distanceValue));
    return filtered;
  }
  
  void _updateMarkers() {
    markers.clear();
    for (var facility in filteredFacilities) {
      if (facility.latitude != null && facility.longitude != null) {
        markers.add(
          Marker(
            markerId: MarkerId(facility.id),
            position: LatLng(facility.latitude!, facility.longitude!),
            infoWindow: InfoWindow(
              title: facility.name,
              snippet: facility.distanceText,
            ),
          ),
        );
      }
    }
  }

  void setFilter(FacilityFilter filter) {
    _selectedFilter = filter;
    _updateMarkers(); // Filtre değişince haritadaki markerları da güncelliyoruz
    notifyListeners();
  }
}