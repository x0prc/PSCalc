import 'package:shared_preferences/shared_preferences.dart';
import '../engine/number.dart';
import 'package:decimal/decimal.dart';

class StorageService {
  static const String _keyDomainOrder = 'domain_order';
  static const String _keyEnabledDomains = 'enabled_domains';
  static const String _keyUseLakhCrore = 'use_lakh_crore';
  static const String _keyInputMode = 'input_mode';
  static const String _keyShowStackPreview = 'show_stack_preview';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyCurrentDomainIndex = 'current_domain_index';
  static const String _keyStack = 'stack';

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // Domain Order
  Future<void> saveDomainOrder(List<String> order) async {
    await _prefs.setStringList(_keyDomainOrder, order);
  }

  List<String> loadDomainOrder(List<String> defaultValue) {
    final list = _prefs.getStringList(_keyDomainOrder);
    return list ?? defaultValue;
  }

  // Enabled Domains
  Future<void> saveEnabledDomains(Set<String> domains) async {
    await _prefs.setStringList(_keyEnabledDomains, domains.toList());
  }

  Set<String> loadEnabledDomains(Set<String> defaultValue) {
    final list = _prefs.getStringList(_keyEnabledDomains);
    return list != null ? list.toSet() : defaultValue;
  }

  // Use Lakh Crore
  Future<void> saveUseLakhCrore(bool value) async {
    await _prefs.setBool(_keyUseLakhCrore, value);
  }

  bool loadUseLakhCrore(bool defaultValue) {
    return _prefs.getBool(_keyUseLakhCrore) ?? defaultValue;
  }

  // Input Mode
  Future<void> saveInputMode(String mode) async {
    await _prefs.setString(_keyInputMode, mode);
  }

  String loadInputMode(String defaultValue) {
    return _prefs.getString(_keyInputMode) ?? defaultValue;
  }

  // Show Stack Preview
  Future<void> saveShowStackPreview(bool value) async {
    await _prefs.setBool(_keyShowStackPreview, value);
  }

  bool loadShowStackPreview(bool defaultValue) {
    return _prefs.getBool(_keyShowStackPreview) ?? defaultValue;
  }

  // Theme Mode
  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(_keyThemeMode, mode);
  }

  String loadThemeMode(String defaultValue) {
    return _prefs.getString(_keyThemeMode) ?? defaultValue;
  }

  // Current Domain Index
  Future<void> saveCurrentDomainIndex(int index) async {
    await _prefs.setInt(_keyCurrentDomainIndex, index);
  }

  int loadCurrentDomainIndex(int defaultValue) {
    return _prefs.getInt(_keyCurrentDomainIndex) ?? defaultValue;
  }

  // Stack
  Future<void> saveStack(List<CalcNumber> stack) async {
    final stackStrings = stack.map((n) => n.value.toString()).toList();
    await _prefs.setStringList(_keyStack, stackStrings);
  }

  List<CalcNumber> loadStack(List<CalcNumber> defaultValue) {
    final list = _prefs.getStringList(_keyStack);
    if (list == null) return defaultValue;
    try {
      return list.map((s) => CalcNumber(Decimal.parse(s))).toList();
    } catch (e) {
      return defaultValue;
    }
  }
}
