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
  RpnStackState _state = RpnStackState();
  final List<RpnStackState> _history = [];

  RpnStackState get state => _state;
  
  void set state(RpnStackState value) {
    _state = value;
  }

  /// Save current state before mutation.
  void _save() => _history.add(state.copyWith());

  void clear() {
    _save();
    state = RpnStackState();
  }

  void pushNumber(CalcNumber n) {
    _save();
    final newStack = List<CalcNumber>.from(state.stack)..add(n);
    state = state.copyWith(stack: newStack);
  }

  void applyOp(RpnOp op) {
    if (state.stack.length < 2) {
      throw CalcError.stackUnderflow();
    }
    _save();
    final newStack = List<CalcNumber>.from(state.stack);
    final b = newStack.removeLast();
    final a = newStack.removeLast();
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
    newStack.add(res);
    state = state.copyWith(stack: newStack);
  }

  void undo() {
    if (_history.isNotEmpty) {
      state = _history.removeLast();
    }
  }

  // Basic stack manipulation
  void swap() {
    if (state.stack.length < 2) {
      throw CalcError.stackUnderflow();
    }
    _save();
    final newStack = List<CalcNumber>.from(state.stack);
    final temp = newStack.removeLast();
    newStack.add(newStack.removeLast());
    newStack.add(temp);
    state = state.copyWith(stack: newStack);
  }

  void drop() {
    if (state.stack.isEmpty) {
      throw CalcError.stackUnderflow();
    }
    _save();
    final newStack = List<CalcNumber>.from(state.stack)..removeLast();
    state = state.copyWith(stack: newStack);
  }

  void dup() {
    if (state.stack.isEmpty) {
      throw CalcError.stackUnderflow();
    }
    _save();
    final newStack = List<CalcNumber>.from(state.stack)
      ..add(state.stack.last);
    state = state.copyWith(stack: newStack);
  }
}