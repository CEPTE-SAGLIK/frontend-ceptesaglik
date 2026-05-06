import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/presentation/onboarding/viewmodel/onboarding_viewmodel.dart';

void main() {
  group('OnboardingViewModel', () {
    late OnboardingViewModel viewModel;

    setUp(() {
      viewModel = OnboardingViewModel();
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('should start at first page', () {
      expect(viewModel.currentIndex, 0);
    });

    group('contents', () {
      test('should have 4 onboarding pages', () {
        expect(viewModel.contents.length, 4);
        expect(viewModel.totalPages, 4);
      });

      test('should have titles', () {
        for (final content in viewModel.contents) {
          expect(content.title, isNotEmpty);
        }
      });

      test('should have descriptions', () {
        for (final content in viewModel.contents) {
          expect(content.description, isNotEmpty);
        }
      });

      test('should have image paths', () {
        for (final content in viewModel.contents) {
          expect(content.imagePath, isNotEmpty);
        }
      });
    });

    group('isLastPage', () {
      test('should be false at first page', () {
        expect(viewModel.isLastPage, false);
      });

      test('should be true at last page', () {
        viewModel.onPageChanged(3);
        expect(viewModel.isLastPage, true);
      });
    });

    group('currentContent', () {
      test('should return content for current index', () {
        expect(viewModel.currentContent, viewModel.contents[0]);
      });

      test('should update with page change', () {
        viewModel.onPageChanged(2);
        expect(viewModel.currentContent, viewModel.contents[2]);
      });
    });

    group('onPageChanged', () {
      test('should update currentIndex', () {
        viewModel.onPageChanged(2);
        expect(viewModel.currentIndex, 2);
      });

      test('should notify listeners', () {
        int count = 0;
        viewModel.addListener(() => count++);

        viewModel.onPageChanged(1);

        expect(count, 1);
      });

      test('should not notify when same page', () {
        int count = 0;
        viewModel.addListener(() => count++);

        viewModel.onPageChanged(0);

        expect(count, 0);
      });
    });

    group('reset', () {
      test('should reset currentIndex via onPageChanged', () {
        viewModel.onPageChanged(3);
        expect(viewModel.currentIndex, 3);

        // reset() internally calls pageController.jumpToPage which needs
        // an attached PageView, so we test the index logic directly
        viewModel.onPageChanged(0);
        expect(viewModel.currentIndex, 0);
      });
    });
  });
}
