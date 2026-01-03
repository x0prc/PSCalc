import 'number.dart';

enum RpnOp { add, sub, mul, div }

class RpnStackState {
  final List<CalcNumber> stack;

  RpnStackState({List<CalcNumber>? stack}) : stack = stack ?? [];

  RpnStackState copyWith({List<CalcNumber>? stack}) {
    return RpnStackState(stack: stack ?? List.of(this.stack));
  }
}

