import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/presentation/map/viewmodel/nearby_facilities_viewmodel.dart';

void main() {
  group('NearbyFacilitiesViewModel', () {
    late NearbyFacilitiesViewModel viewModel;

    setUp(() {
      viewModel = NearbyFacilitiesViewModel();
    });

    test('should start with all filter', () {
      expect(viewModel.selectedFilter, FacilityFilter.all);
    });

    group('setFilter', () {
      test('should change filter to hospital', () {
        viewModel.setFilter(FacilityFilter.hospital);
        expect(viewModel.selectedFilter, FacilityFilter.hospital);
      });

      test('should change filter to pharmacy', () {
        viewModel.setFilter(FacilityFilter.pharmacy);
        expect(viewModel.selectedFilter, FacilityFilter.pharmacy);
      });

      test('should notify listeners on filter change', () {
        int notifyCount = 0;
        viewModel.addListener(() => notifyCount++);

        viewModel.setFilter(FacilityFilter.hospital);

        expect(notifyCount, greaterThanOrEqualTo(1));
      });
    });

    group('filteredFacilities', () {
      test('should return empty list when no facilities are loaded', () {
        viewModel.setFilter(FacilityFilter.all);
        expect(viewModel.filteredFacilities, isEmpty);
      });

      test('should return empty when filter is hospital and no data', () {
        viewModel.setFilter(FacilityFilter.hospital);
        expect(viewModel.filteredFacilities, isEmpty);
      });

      test('should return empty when filter is clinic and no data', () {
        viewModel.setFilter(FacilityFilter.clinic);
        expect(viewModel.filteredFacilities, isEmpty);
      });

      test('should return empty when filter is pharmacy and no data', () {
        viewModel.setFilter(FacilityFilter.pharmacy);
        expect(viewModel.filteredFacilities, isEmpty);
      });

      test('filteredFacilities is sorted (empty list is trivially sorted)', () {
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
