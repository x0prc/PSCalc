import 'package:flutter/foundation.dart';
import '../../../core/services/storage_service.dart';

class SettingsController extends ChangeNotifier {
  final StorageService _storage;

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
  String _inputMode = 'rpn';
  bool _showStackPreview = true;
  String _themeMode = 'dark';

  SettingsController(this._storage) {
    _loadSettings();
  }

  void _loadSettings() {
    _domainOrder = _storage.loadDomainOrder(_domainOrder);
    _enabledDomains = _storage.loadEnabledDomains(_enabledDomains);
    _useLakhCrore = _storage.loadUseLakhCrore(_useLakhCrore);
    _inputMode = _storage.loadInputMode(_inputMode);
    _showStackPreview = _storage.loadShowStackPreview(_showStackPreview);
    _themeMode = _storage.loadThemeMode(_themeMode);
  }

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
    _storage.saveDomainOrder(_domainOrder);
    _storage.saveEnabledDomains(_enabledDomains);
    notifyListeners();
  }

  void reorderDomains(List<String> newOrder) {
    _domainOrder = newOrder;
    _storage.saveDomainOrder(_domainOrder);
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
      _storage.saveDomainOrder(_domainOrder);
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
      _storage.saveDomainOrder(_domainOrder);
      notifyListeners();
    }
  }

  // Formatting
  void setLakhCrore(bool value) {
    _useLakhCrore = value;
    _storage.saveUseLakhCrore(value);
    notifyListeners();
  }

  // Input mode
  void setInputMode(String mode) {
    _inputMode = mode;
    _storage.saveInputMode(mode);
    notifyListeners();
  }

  void toggleStackPreview() {
    _showStackPreview = !_showStackPreview;
    _storage.saveShowStackPreview(_showStackPreview);
    notifyListeners();
  }

  void setThemeMode(String mode) {
    _themeMode = mode;
    _storage.saveThemeMode(mode);
    notifyListeners();
  }
}
