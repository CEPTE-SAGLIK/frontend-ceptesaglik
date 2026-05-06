import 'package:flutter/foundation.dart';

enum NavigationTab {
  home('Ana Sayfa'),
  calendar('Takvim'),
  aiAssistant('AI Asistanı'),
  map('Yakındakiler'),
  profile('Profil');

  final String label;
  const NavigationTab(this.label);

  static NavigationTab fromIndex(int index) {
    if (index >= 0 && index < NavigationTab.values.length) {
      return NavigationTab.values[index];
    }
    return NavigationTab.home;
  }
}

class NavigatorViewModel extends ChangeNotifier {
  NavigationTab _currentTab = NavigationTab.home;
  final List<NavigationTab> _navigationHistory = [NavigationTab.home];

  NavigationTab get currentTab => _currentTab;
  int get currentIndex => _currentTab.index;
  String get currentTabLabel => _currentTab.label;

  bool get canGoBack => _navigationHistory.length > 1;

  void navigateTo(int index) {
    final newTab = NavigationTab.fromIndex(index);
    if (newTab != _currentTab) {
      _currentTab = newTab;
      _navigationHistory.add(newTab);
      notifyListeners();
    }
  }

  void navigateToTab(NavigationTab tab) {
    if (tab != _currentTab) {
      _currentTab = tab;
      _navigationHistory.add(tab);
      notifyListeners();
    }
  }

  bool goBack() {
    if (_navigationHistory.length > 1) {
      _navigationHistory.removeLast();
      _currentTab = _navigationHistory.last;
      notifyListeners();
      return true;
    }
    return false;
  }

  void resetToHome() {
    _currentTab = NavigationTab.home;
    _navigationHistory.clear();
    _navigationHistory.add(NavigationTab.home);
    notifyListeners();
  }
}
