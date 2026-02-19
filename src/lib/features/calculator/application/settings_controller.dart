import 'package:flutter/foundation.dart';
import '../domain/domain.dart';

class SettingsController extends ChangeNotifier {
  // Domain customization
  List<String> _domainOrder = [
    'basic',
    'business',
    'finance',
    'fx',
    'real_estate'
  ];
  Set<String> _enabledDomains = {
    'basic',
    'business',
    'finance',
    'fx',
    'real_estate'
  };
  bool _useLakhCrore = true;
  String _inputMode = 'rpn'; // rpn | algebraic
  bool _showStackPreview = true;
  String _themeMode = 'dark';

  // Getters
  List<String> get domainOrder => List.unmodifiable(_domainOrder);
  Set<String> get enabledDomains => Set.unmodifiable(_enabledDomains);
  bool get useLakhCrore => _useLakhCrore;
  String get inputMode => _inputMode;
  bool get showStackPreview => _showStackPreview;
  String get themeMode => _themeMode;

  // Domain management
  void toggleDomain(String domainId) {
    if (_enabledDomains.contains(domainId)) {
      _enabledDomains.remove(domainId);
      _domainOrder.remove(domainId);
    } else {
      _enabledDomains.add(domainId);
      _domainOrder.add(domainId);
    }
    notifyListeners();
  }

  void reorderDomains(List<String> newOrder) {
    _domainOrder = newOrder;
    notifyListeners();
  }

  void moveDomainUp(String domainId) {
    final index = _domainOrder.indexOf(domainId);
    if (index > 0) {
      final newOrder = List<String>.from(_domainOrder);
      final temp = newOrder[index - 1];
      newOrder[index - 1] = newOrder[index];
      newOrder[index] = temp;
      _domainOrder = newOrder;
      notifyListeners();
    }
  }

  void moveDomainDown(String domainId) {
    final index = _domainOrder.indexOf(domainId);
    if (index < _domainOrder.length - 1) {
      final newOrder = List<String>.from(_domainOrder);
      final temp = newOrder[index + 1];
      newOrder[index + 1] = newOrder[index];
      newOrder[index] = temp;
      _domainOrder = newOrder;
      notifyListeners();
    }
  }

  // Formatting
  void setLakhCrore(bool value) {
    _useLakhCrore = value;
    notifyListeners();
  }

  // Input mode
  void setInputMode(String mode) {
    _inputMode = mode;
    notifyListeners();
  }

  void toggleStackPreview() {
    _showStackPreview = !_showStackPreview;
    notifyListeners();
  }

  void setThemeMode(String mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
