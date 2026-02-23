import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:decimal/decimal.dart';
import '../domain/domain.dart';
import '../../../core/engine/number.dart';
import '../../../core/engine/rpn_engine.dart';
import '../../../core/services/storage_service.dart';

class CalcController extends ChangeNotifier {
  static const int _maxStackSize = 50;
  static const int _maxInputLength = 20;
  static const Duration _saveDebounce = Duration(milliseconds: 500);
  static const Duration _notifyThrottle = Duration(milliseconds: 16);

  final StorageService _storage;
  final List<Domain> _allDomains;
  List<CalcNumber> _stack = [];
  String _inputBuffer = '';
  String? _pendingOp;
  int _currentDomainIndex = 0;
  bool _showHistory = false;

  Timer? _saveTimer;
  Timer? _notifyTimer;
  bool _pendingNotify = false;
  bool _pendingSave = false;

  CalcController({
    required StorageService storage,
    required List<Domain> allDomains,
  })  : _storage = storage,
        _allDomains = allDomains {
    _loadState();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _notifyTimer?.cancel();
    _flushSave();
    super.dispose();
  }

  void _loadState() {
    _stack = _storage.loadStack(_stack);
    if (_stack.length > _maxStackSize) {
      _stack = _stack.sublist(_stack.length - _maxStackSize);
    }
    _currentDomainIndex = _storage.loadCurrentDomainIndex(_currentDomainIndex);
    if (_currentDomainIndex >= _allDomains.length) {
      _currentDomainIndex = 0;
    }
  }

  void _scheduleSave() {
    _pendingSave = true;
    _saveTimer?.cancel();
    _saveTimer = Timer(_saveDebounce, () {
      _flushSave();
    });
  }

  void _flushSave() {
    if (_pendingSave) {
      _storage.saveStack(_stack);
      _storage.saveCurrentDomainIndex(_currentDomainIndex);
      _pendingSave = false;
    }
  }

  void _throttledNotify() {
    if (_pendingNotify) return;
    _pendingNotify = true;
    _notifyTimer?.cancel();
    _notifyTimer = Timer(_notifyThrottle, () {
      notifyListeners();
      _pendingNotify = false;
    });
  }

  // GETTERS
  List<CalcNumber> get stack => List.unmodifiable(_stack);
  String get inputBuffer => _inputBuffer;
  Domain get currentDomain => _allDomains[_currentDomainIndex];
  bool get showHistory => _showHistory;
  List<DomainOperation> get currentOperations => currentDomain.operations;
  CalcNumber get xRegister =>
      stack.isNotEmpty ? stack.last : CalcNumber(Decimal.zero);

  // INPUT HANDLING
  void digit(String d) {
    if (_inputBuffer.length < _maxInputLength) {
      _inputBuffer += d;
      _throttledNotify();
    }
  }

  void decimalPoint() {
    if (_inputBuffer.isEmpty || !_inputBuffer.contains('.')) {
      _inputBuffer += '.';
      _throttledNotify();
    }
  }

  void enter() {
    if (_inputBuffer.isNotEmpty) {
      try {
        final num = Decimal.parse(_inputBuffer);
        final cn = CalcNumber(num);
        if (_stack.length >= _maxStackSize) {
          _stack.removeAt(0);
        }
        _stack.add(cn);
        _inputBuffer = '';
        _executePending();
      } catch (e) {
        // Invalid input - ignore
      }
    }
    _scheduleSave();
    notifyListeners();
  }

  void operation(String op) {
    enter(); // Push current input first
    _pendingOp = op;
    notifyListeners();
  }

  void backspace() {
    if (_inputBuffer.isNotEmpty) {
      _inputBuffer = _inputBuffer.substring(0, _inputBuffer.length - 1);
      _throttledNotify();
    }
  }

  void clearAll() {
    _stack.clear();
    _inputBuffer = '';
    _pendingOp = null;
    _scheduleSave();
    notifyListeners();
  }

  // DOMAIN CYCLING
  void cycleDomain() {
    _currentDomainIndex = (_currentDomainIndex + 1) % _allDomains.length;
    _scheduleSave();
    notifyListeners();
  }

  void nextDomain() => cycleDomain();

  void previousDomain() {
    _currentDomainIndex = (_currentDomainIndex - 1) % _allDomains.length;
    if (_currentDomainIndex < 0) _currentDomainIndex = _allDomains.length - 1;
    _scheduleSave();
    notifyListeners();
  }

  void toggleHistory() {
    _showHistory = !_showHistory;
    notifyListeners();
  }

  // CORE EXECUTION
  void _executePending() {
    if (_pendingOp != null && _stack.length >= 2) {
      final b = _stack.removeLast();
      final a = _stack.removeLast();
      try {
        Decimal result;

        switch (_pendingOp!) {
          case '+':
            result = a.value + b.value;
            break;
          case '−':
            result = a.value - b.value;
            break;
          case '×':
            result = a.value * b.value;
            break;
          case '÷':
            if (b.value == Decimal.zero) throw CalcError.divideByZero();
            result = (a.value / b.value).toDecimal();
            break;
          default:
            _stack.add(a);
            _stack.add(b);
            return;
        }

        _stack.add(CalcNumber(result));
        _pendingOp = null;
      } catch (e) {
        _stack.add(a);
        _stack.add(b);
      }
    }
  }

  // STACK OPERATIONS
  void rollDown() {
    if (_stack.length >= 2) {
      final x = _stack.removeLast();
      _stack.insert(_stack.length - 1, x);
      _scheduleSave();
      notifyListeners();
    }
  }

  void dup() {
    if (_stack.isNotEmpty) {
      final x = _stack.last;
      if (_stack.length < _maxStackSize) {
        _stack.add(x);
      }
      _scheduleSave();
      notifyListeners();
    }
  }

  void swap() {
    if (_stack.length >= 2) {
      final y = _stack.removeLast();
      final x = _stack.removeLast();
      _stack.add(x);
      _stack.add(y);
      _scheduleSave();
      notifyListeners();
    }
  }

  // CONSTANTS
  void constant(String constName) {
    switch (constName) {
      case 'pi':
        _stack.add(CalcNumber(Decimal.parse('3.14159265358979323846')));
        break;
      case 'e':
        _stack.add(CalcNumber(Decimal.parse('2.71828182845904523536')));
        break;
    }
    _scheduleSave();
    notifyListeners();
  }

  void constantsMenu() {
    constant('pi');
  }

  void executeDomainOp(DomainOperation op) {
    enter(); // Finalize input
    try {
      final currentState = RpnStackState(stack: _stack);
      final result = op.execute(currentState);
      if (result.stack.length > _maxStackSize) {
        _stack = result.stack.sublist(result.stack.length - _maxStackSize);
      } else {
        _stack = result.stack;
      }
      _scheduleSave();
      notifyListeners();
    } catch (e) {
      debugPrint('Domain op error: $e');
    }
  }
}
