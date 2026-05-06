import 'package:flutter_test/flutter_test.dart';
import 'package:health_asistants/presentation/navigator/viewmodel/navigator_viewmodel.dart';

void main() {
  group('NavigationTab', () {
    test('should have correct labels', () {
      expect(NavigationTab.home.label, 'Ana Sayfa');
      expect(NavigationTab.calendar.label, 'Takvim');
      expect(NavigationTab.aiAssistant.label, 'AI Asistanı');
      expect(NavigationTab.map.label, 'Yakındakiler');
      expect(NavigationTab.profile.label, 'Profil');
    });

    test('fromIndex should return correct tab', () {
      expect(NavigationTab.fromIndex(0), NavigationTab.home);
      expect(NavigationTab.fromIndex(1), NavigationTab.calendar);
      expect(NavigationTab.fromIndex(4), NavigationTab.profile);
    });

    test('fromIndex should return home for invalid index', () {
      expect(NavigationTab.fromIndex(-1), NavigationTab.home);
      expect(NavigationTab.fromIndex(99), NavigationTab.home);
    });
  });

  group('NavigatorViewModel', () {
    late NavigatorViewModel viewModel;

    setUp(() {
      viewModel = NavigatorViewModel();
    });

    test('should start at home tab', () {
      expect(viewModel.currentTab, NavigationTab.home);
      expect(viewModel.currentIndex, 0);
      expect(viewModel.currentTabLabel, 'Ana Sayfa');
    });

    test('should not be able to go back initially', () {
      expect(viewModel.canGoBack, false);
    });

    group('navigateTo', () {
      test('should navigate to tab by index', () {
        viewModel.navigateTo(1);

        expect(viewModel.currentTab, NavigationTab.calendar);
        expect(viewModel.currentIndex, 1);
      });

      test('should not notify when navigating to same tab', () {
        int notifyCount = 0;
        viewModel.addListener(() => notifyCount++);

        viewModel.navigateTo(0); // Already at home

        expect(notifyCount, 0);
      });

      test('should add to navigation history', () {
        viewModel.navigateTo(1);
        viewModel.navigateTo(2);

        expect(viewModel.canGoBack, true);
      });
    });

    group('navigateToTab', () {
      test('should navigate to specified tab', () {
        viewModel.navigateToTab(NavigationTab.profile);

        expect(viewModel.currentTab, NavigationTab.profile);
        expect(viewModel.currentTabLabel, 'Profil');
      });

      test('should not notify when navigating to same tab', () {
        int notifyCount = 0;
        viewModel.addListener(() => notifyCount++);

        viewModel.navigateToTab(NavigationTab.home);

        expect(notifyCount, 0);
      });
    });

    group('goBack', () {
      test('should go back to previous tab', () {
        viewModel.navigateTo(1);
        viewModel.navigateTo(2);

        final result = viewModel.goBack();

        expect(result, true);
        expect(viewModel.currentTab, NavigationTab.calendar);
      });

      test('should return false when at root', () {
        final result = viewModel.goBack();

        expect(result, false);
        expect(viewModel.currentTab, NavigationTab.home);
      });

      test('should be able to go back through full history', () {
        viewModel.navigateTo(1);
        viewModel.navigateTo(2);
        viewModel.navigateTo(3);

        viewModel.goBack(); // -> calendar
        viewModel.goBack(); // -> home
        expect(viewModel.currentTab, NavigationTab.calendar);

        viewModel.goBack(); // -> home
        expect(viewModel.currentTab, NavigationTab.home);

        expect(viewModel.goBack(), false);
      });
    });

    group('resetToHome', () {
      test('should reset to home and clear history', () {
        viewModel.navigateTo(1);
        viewModel.navigateTo(2);
        viewModel.navigateTo(3);

        viewModel.resetToHome();

        expect(viewModel.currentTab, NavigationTab.home);
        expect(viewModel.canGoBack, false);
      });
    });

    test('should notify listeners on navigation', () {
      int notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      viewModel.navigateTo(1);
      viewModel.navigateTo(2);
      viewModel.goBack();
      viewModel.resetToHome();

      expect(notifyCount, 4);
    });
  });
}
