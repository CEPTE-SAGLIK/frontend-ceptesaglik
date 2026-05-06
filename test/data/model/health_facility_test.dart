import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/data/model/health_facility.dart';

void main() {
  group('FacilityType Enum', () {
    test('should have all expected values', () {
      expect(FacilityType.values.length, 3);
      expect(FacilityType.values, contains(FacilityType.hospital));
      expect(FacilityType.values, contains(FacilityType.clinic));
      expect(FacilityType.values, contains(FacilityType.pharmacy));
    });
  });

  group('HealthFacility Model', () {
    test('should create HealthFacility with all fields', () {
      final facility = HealthFacility(
        id: '1',
        name: 'Konya Şehir Hastanesi',
        subtitle: 'Devlet Hastanesi',
        type: FacilityType.hospital,
        distanceText: '2.4 km',
        distanceValue: 2400,
        isDuty: false,
      );

      expect(facility.id, '1');
      expect(facility.name, 'Konya Şehir Hastanesi');
      expect(facility.subtitle, 'Devlet Hastanesi');
      expect(facility.type, FacilityType.hospital);
      expect(facility.distanceText, '2.4 km');
      expect(facility.distanceValue, 2400);
      expect(facility.isDuty, false);
    });

    test('should have isDuty default to false', () {
      final facility = HealthFacility(
        id: '2',
        name: 'Test Eczane',
        subtitle: 'Eczane',
        type: FacilityType.pharmacy,
        distanceText: '1.0 km',
        distanceValue: 1000,
      );

      expect(facility.isDuty, false);
    });

    test('should create pharmacy with isDuty true', () {
      final dutyPharmacy = HealthFacility(
        id: '3',
        name: 'Nöbetçi Eczane',
        subtitle: 'Eczane',
        type: FacilityType.pharmacy,
        distanceText: '500 m',
        distanceValue: 500,
        isDuty: true,
      );

      expect(dutyPharmacy.isDuty, true);
    });

    test('should correctly differentiate facility types', () {
      final hospital = HealthFacility(
        id: '1',
        name: 'Hastane',
        subtitle: 'Hastane',
        type: FacilityType.hospital,
        distanceText: '1 km',
        distanceValue: 1000,
      );

      final clinic = HealthFacility(
        id: '2',
        name: 'Klinik',
        subtitle: 'Klinik',
        type: FacilityType.clinic,
        distanceText: '500 m',
        distanceValue: 500,
      );

      final pharmacy = HealthFacility(
        id: '3',
        name: 'Eczane',
        subtitle: 'Eczane',
        type: FacilityType.pharmacy,
        distanceText: '200 m',
        distanceValue: 200,
      );

      expect(hospital.type, FacilityType.hospital);
      expect(clinic.type, FacilityType.clinic);
      expect(pharmacy.type, FacilityType.pharmacy);
    });
  });
}
