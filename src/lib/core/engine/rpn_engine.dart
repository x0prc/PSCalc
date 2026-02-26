import 'number.dart';

enum RpnOp { add, sub, mul, div }

class RpnStackState {
  final List<CalcNumber> stack;

  RpnStackState({List<CalcNumber>? stack}) : stack = stack ?? [];

  RpnStackState copyWith({List<CalcNumber>? stack}) {
    return RpnStackState(stack: stack ?? List.of(this.stack));
  }
}

class RpnEngine {
  static const int _maxHistorySize = 50;

  RpnStackState _state = RpnStackState();
  final List<RpnStackState> _history = [];

  RpnStackState get state => _state;

  void updateState(RpnStackState value) {
    _state = value;
  }

  void _save() {
    _history.add(_state.copyWith());
    while (_history.length > _maxHistorySize) {
      _history.removeAt(0);
    }
  }

  void clear() {
    _save();
    _state = RpnStackState();
  }

  void pushNumber(CalcNumber n) {
    _save();
    _state.stack.add(n);
  }

  void applyOp(RpnOp op) {
    if (_state.stack.length < 2) {
      throw CalcError.stackUnderflow();
    }
    _save();
    final b = _state.stack.removeLast();
    final a = _state.stack.removeLast();
    CalcNumber res;
    switch (op) {
      case RpnOp.add:
        res = a + b;
        break;
      case RpnOp.sub:
        res = a - b;
        break;
      case RpnOp.mul:
        res = a * b;
        break;
      case RpnOp.div:
        res = a / b;
        break;
    }
    _state.stack.add(res);
  }

  void undo() {
    if (_history.isNotEmpty) {
      _state = _history.removeLast();
    }
  }

  void swap() {
    if (_state.stack.length < 2) {
      throw CalcError.stackUnderflow();
    }
    _save();
    final last = _state.stack.length - 1;
    final temp = _state.stack[last];
    _state.stack[last] = _state.stack[last - 1];
    _state.stack[last - 1] = temp;
  }

  void drop() {
    if (_state.stack.isEmpty) {
      throw CalcError.stackUnderflow();
    }
    _save();
    _state.stack.removeLast();
  }

  void dup() {
    if (_state.stack.isEmpty) {
      throw CalcError.stackUnderflow();
    }
    _save();
    _state.stack.add(_state.stack.last);
  }
}
