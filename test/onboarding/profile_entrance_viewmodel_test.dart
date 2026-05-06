import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/data/model/person.dart';
import 'package:health_asistants/presentation/onboarding/viewmodel/profile_entrance_viewmodel.dart';

void main() {
  group('ProfileEntranceViewModel', () {
    late ProfileEntranceViewModel viewModel;

    setUp(() {
      viewModel = ProfileEntranceViewModel();
    });

    test('should start with initial status', () {
      expect(viewModel.status, ProfileEntranceStatus.initial);
      expect(viewModel.isLoading, false);
      expect(viewModel.birthDate, isNull);
      expect(viewModel.gender, Gender.female);
      expect(viewModel.height, 158);
      expect(viewModel.weight, 50);
      expect(viewModel.selectedDiseases, isEmpty);
      expect(viewModel.selectedAllergies, isEmpty);
    });

    group('gender', () {
      test('should default to female', () {
        expect(viewModel.isFemale, true);
        expect(viewModel.isMale, false);
      });

      test('setGender should update gender', () {
        viewModel.setGender(Gender.male);
        expect(viewModel.isMale, true);
        expect(viewModel.isFemale, false);
      });

      test('setGenderFromString should map correctly', () {
        viewModel.setGenderFromString('Kadın');
        expect(viewModel.gender, Gender.female);

        viewModel.setGenderFromString('Erkek');
        expect(viewModel.gender, Gender.male);
      });

      test('setGender should not notify if same value', () {
        int count = 0;
        viewModel.addListener(() => count++);
        viewModel.setGender(Gender.female); // Already female
        expect(count, 0);
      });
    });

    group('birthDate', () {
      test('birthDateText should show "Tarih Seçin" when null', () {
        expect(viewModel.birthDateText, 'Tarih Seçin');
      });

      test('setBirthDate should update birthDate', () {
        final date = DateTime(1995, 5, 20);
        viewModel.setBirthDate(date);
        expect(viewModel.birthDate, date);
      });

      test('birthDateText should format correctly', () {
        viewModel.setBirthDate(DateTime(1995, 5, 20));
        expect(viewModel.birthDateText, '20/05/1995');
      });
    });

    group('height and weight', () {
      test('setHeight should update height', () {
        viewModel.setHeight(175);
        expect(viewModel.height, 175);
      });

      test('setHeight should ignore zero or negative', () {
        viewModel.setHeight(0);
        expect(viewModel.height, 158);

        viewModel.setHeight(-10);
        expect(viewModel.height, 158);
      });

      test('setWeight should update weight', () {
        viewModel.setWeight(70);
        expect(viewModel.weight, 70);
      });

      test('setWeight should ignore zero or negative', () {
        viewModel.setWeight(0);
        expect(viewModel.weight, 50);
      });

      test('setHeight should update controller text', () {
        viewModel.setHeight(180);
        expect(viewModel.heightController.text, '180');
      });

      test('setWeight should update controller text', () {
        viewModel.setWeight(75);
        expect(viewModel.weightController.text, '75');
      });
    });

    group('diseases', () {
      test('availableDiseases should contain default diseases', () {
        expect(viewModel.availableDiseases, contains('Diyabet'));
        expect(viewModel.availableDiseases, contains('Hipertansiyon'));
        expect(viewModel.availableDiseases, contains('Astım'));
        expect(viewModel.availableDiseases, contains('Kalp Hastalığı'));
      });

      test('toggleDisease should select disease', () {
        viewModel.toggleDisease('Diyabet');
        expect(viewModel.selectedDiseases, contains('Diyabet'));
      });

      test('toggleDisease should deselect disease', () {
        viewModel.toggleDisease('Diyabet');
        viewModel.toggleDisease('Diyabet');
        expect(viewModel.selectedDiseases, isNot(contains('Diyabet')));
      });

      test('addNewDisease should add and select', () {
        viewModel.addNewDisease('Epilepsi');
        expect(viewModel.availableDiseases, contains('Epilepsi'));
        expect(viewModel.selectedDiseases, contains('Epilepsi'));
      });

      test('addNewDisease should not add empty name', () {
        final initialCount = viewModel.availableDiseases.length;
        viewModel.addNewDisease('');
        expect(viewModel.availableDiseases.length, initialCount);
      });

      test('addNewDisease should not add duplicate', () {
        final initialCount = viewModel.availableDiseases.length;
        viewModel.addNewDisease('Diyabet');
        expect(viewModel.availableDiseases.length, initialCount);
      });
    });

    group('allergies', () {
      test('availableAllergies should contain default allergies', () {
        expect(viewModel.availableAllergies, contains('Penisilin'));
        expect(viewModel.availableAllergies, contains('Polen'));
      });

      test('toggleAllergy should toggle selection', () {
        viewModel.toggleAllergy('Polen');
        expect(viewModel.selectedAllergies, contains('Polen'));

        viewModel.toggleAllergy('Polen');
        expect(viewModel.selectedAllergies, isNot(contains('Polen')));
      });

      test('addNewAllergy should add and select', () {
        viewModel.addNewAllergy('Süt');
        expect(viewModel.availableAllergies, contains('Süt'));
        expect(viewModel.selectedAllergies, contains('Süt'));
      });
    });

    group('selectedDiseases/selectedAllergies immutability', () {
      test('selectedDiseases should be unmodifiable', () {
        expect(
          () => viewModel.selectedDiseases.add('Test'),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('selectedAllergies should be unmodifiable', () {
        expect(
          () => viewModel.selectedAllergies.add('Test'),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });

    group('saveProfile', () {
      test('should return Person with selected data', () async {
        viewModel.setBirthDate(DateTime(1990, 1, 1));
        viewModel.setGender(Gender.male);
        viewModel.setHeight(180);
        viewModel.setWeight(80);
        viewModel.toggleDisease('Diyabet');
        viewModel.toggleAllergy('Polen');

        final result = await viewModel.saveProfile();
        expect(result, false);
        expect(viewModel.status, ProfileEntranceStatus.error);
        expect(viewModel.errorMessage, isNotNull);
      });

      test('should fail when birth date is missing', () async {
        final result = await viewModel.saveProfile();
        expect(result, false);
        expect(viewModel.status, ProfileEntranceStatus.error);
        expect(viewModel.errorMessage, contains('doğum tarihi'));
      });
    });
  });
}
