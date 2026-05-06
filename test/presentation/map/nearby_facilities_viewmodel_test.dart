import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/data/model/health_facility.dart';
import 'package:health_asistants/presentation/map/viewmodel/nearby_facilities_viewmodel.dart';

void main() {
  group('NearbyFacilitiesViewModel', () {
    late NearbyFacilitiesViewModel viewModel;

    setUp(() {
      viewModel = NearbyFacilitiesViewModel();
    });

    test('should start with pharmacy filter', () {
      expect(viewModel.selectedFilter, FacilityFilter.pharmacy);
    });

    group('setFilter', () {
      test('should change filter', () {
        viewModel.setFilter(FacilityFilter.hospital);
        expect(viewModel.selectedFilter, FacilityFilter.hospital);
      });

      test('should notify listeners', () {
        int notifyCount = 0;
        viewModel.addListener(() => notifyCount++);

        viewModel.setFilter(FacilityFilter.all);

        expect(notifyCount, 1);
      });
    });

    group('filteredFacilities', () {
      test('should return all facilities when filter is all', () {
        viewModel.setFilter(FacilityFilter.all);
        final facilities = viewModel.filteredFacilities;

        expect(facilities.length, 4);
      });

      test('should filter hospitals', () {
        viewModel.setFilter(FacilityFilter.hospital);
        final facilities = viewModel.filteredFacilities;

        expect(facilities, isNotEmpty);
        for (final f in facilities) {
          expect(f.type, FacilityType.hospital);
        }
      });

      test('should filter clinics', () {
        viewModel.setFilter(FacilityFilter.clinic);
        final facilities = viewModel.filteredFacilities;

        expect(facilities, isNotEmpty);
        for (final f in facilities) {
          expect(f.type, FacilityType.clinic);
        }
      });

      test('should filter only duty pharmacies', () {
        viewModel.setFilter(FacilityFilter.pharmacy);
        final facilities = viewModel.filteredFacilities;

        expect(facilities, isNotEmpty);
        for (final f in facilities) {
          expect(f.type, FacilityType.pharmacy);
          expect(f.isDuty, true);
        }
      });

      test('should sort by distance', () {
        viewModel.setFilter(FacilityFilter.all);
        final facilities = viewModel.filteredFacilities;

        for (int i = 0; i < facilities.length - 1; i++) {
          expect(
            facilities[i].distanceValue,
            lessThanOrEqualTo(facilities[i + 1].distanceValue),
          );
        }
      });
    });
  });
}
