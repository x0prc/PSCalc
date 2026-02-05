import 'package:flutter/foundation.dart';
import '../../domain/domain.dart';
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
    if (_inputBuffer.length < 16) { // Prevent overflow
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
      try {
        final b = _stack.removeLast();
        final a = _stack.removeLast();
        Decimal result;

        switch (_pendingOp!) {
          case '+': result = a.value + b.value; break;
          case '−': result = a.value - b.value; break;
          case '×': result = a.value * b.value; break;
          case '÷':
            if (b.value == Decimal.zero) throw CalcError.divideByZero();
            result = a.value / b.value;
            break;
          default: return;
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

  // DOMAIN EXECUTION
  void executeDomainOp(DomainOperation op) {
    enter(); // Final ENTER before domain op
    try {
      final newState = op.execute(RpnStackState(stack: _stack));
      _stack = newState.stack;
      notifyListeners();
    } catch (e) {
    }
  }
}
