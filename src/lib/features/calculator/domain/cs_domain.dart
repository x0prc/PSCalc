import 'dart:math';
import 'package:decimal/decimal.dart';
import '../../../core/engine/number.dart';
import '../../../core/engine/rpn_engine.dart';
import 'domain.dart';

class CsDomain implements Domain {
  @override
  String get id => 'cs';
  @override
  String get name => 'CS Utils';
  @override
  String get shortLabel => 'CS';
  @override
  List<DomainOperation> get operations => [BitCountOp(), Log2Op(), BitsOp()];
}

// POPCNT: Count 1 bits in integer
class BitCountOp implements DomainOperation {
  @override
  String get id => 'popcnt';
  @override
  String get label => 'BITS';
  @override
  int get arity => 1;
  @override
  String? get description => 'Count set bits';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final n = newStack.removeLast().value.toDouble().toInt();
    var count = 0;
    var temp = n;
    while (temp > 0) {
      count += temp & 1;
      temp >>= 1;
    }
    newStack.add(CalcNumber.fromString(count.toString()));
    return state.copyWith(stack: newStack);
  }
}

// LOG2: X → log2(X)
class Log2Op implements DomainOperation {
  @override
  String get id => 'log2';
  @override
  String get label => 'LOG2';
  @override
  int get arity => 1;
  @override
  String? get description => 'Log base 2';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final x = newStack.removeLast().value.toDouble();
    final result = log(x) / log(2);
    newStack.add(CalcNumber.fromString(result.toString()));
    return state.copyWith(stack: newStack);
  }
}

// BITS: Bits Value → Value shifted/scaled
class BitsOp implements DomainOperation {
  @override
  String get id => 'bits';
  @override
  String get label => '>>';
  @override
  int get arity => 2;
  @override
  String? get description => 'Right shift (Value Bits → Value>>Bits)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final bits = newStack.removeLast().value.toDouble().toInt();
    final value = newStack.removeLast().value.toDouble().toInt();
    newStack.add(CalcNumber.fromString((value >> bits).toString()));
    return state.copyWith(stack: newStack);
  }
}
