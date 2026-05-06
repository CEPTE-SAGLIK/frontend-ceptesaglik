enum FacilityType { hospital, clinic, pharmacy }

class HealthFacility {
  final String id;
  final String name;
  final String subtitle;
  final FacilityType type;
  final String distanceText; // Örn: "2.4 km"
  final double distanceValue; // Sıralama için metre cinsinden (örn: 2400)
  final bool isDuty; // Nöbetçi mi?
  final double? latitude;
  final double? longitude;

  HealthFacility({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.type,
    required this.distanceText,
    required this.distanceValue,
    this.isDuty = false,
    this.latitude,
    this.longitude,
  });
}
