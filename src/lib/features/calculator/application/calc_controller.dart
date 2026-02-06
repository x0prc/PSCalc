import 'package:flutter/foundation.dart';
import 'package:decimal/decimal.dart';
import '../domain/domain.dart';
import '../../../core/engine/number.dart';
import '../../../core/engine/rpn_engine.dart';

class CalcController extends ChangeNotifier {
  // STATE
  final List<Domain> _allDomains;
  List<CalcNumber> _stack = [];
  String _inputBuffer = '';
  String? _pendingOp;
  int _currentDomainIndex = 0;
  bool _showHistory = false;

  // GETTERS
  List<CalcNumber> get stack => List.unmodifiable(_stack);
  String get inputBuffer => _inputBuffer;
  Domain get currentDomain => _allDomains[_currentDomainIndex];
  bool get showHistory => _showHistory;
  List<DomainOperation> get currentOperations => currentDomain.operations;

  CalcController({required List<Domain> allDomains}) : _allDomains = allDomains;

  // INPUT HANDLING
  void digit(String d) {
    if (_inputBuffer.length < 16) {
      // Prevent overflow
      _inputBuffer += d;
      notifyListeners();
    }
  }

  void decimalPoint() {
    if (_inputBuffer.isEmpty || !_inputBuffer.contains('.')) {
      _inputBuffer += '.';
      notifyListeners();
    }
  }

  void enter() {
    if (_inputBuffer.isNotEmpty) {
      try {
        final num = Decimal.parse(_inputBuffer);
        _stack.add(CalcNumber(num));
        _inputBuffer = '';
        _executePending();
      } catch (e) {
        // Invalid input - ignore
      }
    }
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
      notifyListeners();
    }
  }

  void clearAll() {
    _stack.clear();
    _inputBuffer = '';
    _pendingOp = null;
    notifyListeners();
  }

  // DOMAIN CYCLING
  void cycleDomain() {
    _currentDomainIndex = (_currentDomainIndex + 1) % _allDomains.length;
    notifyListeners();
  }

  void nextDomain() => cycleDomain();

  void previousDomain() {
    _currentDomainIndex = (_currentDomainIndex - 1) % _allDomains.length;
    if (_currentDomainIndex < 0) _currentDomainIndex = _allDomains.length - 1;
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
        // Error - restore stack
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
      notifyListeners();
    }
  }

  void dup() {
    if (_stack.isNotEmpty) {
      final x = _stack.last;
      _stack.add(x);
      notifyListeners();
    }
  }

  void swap() {
    if (_stack.length >= 2) {
      final y = _stack.removeLast();
      final x = _stack.removeLast();
      _stack.add(x);
      _stack.add(y);
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
      _stack = result.stack;
      notifyListeners();
    } catch (e) {
      debugPrint('Domain op error: $e');
    }
  }
}
