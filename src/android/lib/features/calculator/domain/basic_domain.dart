import '../../../core/engine/rpn_engine.dart';
import '../../../core/engine/number.dart';
import 'domain.dart';

class BasicDomain implements Domain {
  @override
  String get id => 'basic';

  @override
  String get name => 'Basic Math';

  @override
  String get shortLabel => 'BAS';

  @override
  List<DomainOperation> get operations =>
      [
        ReciprocalOp(),
        PercentOp(),
        SquareRootOp(),
      ];
}
///---------------------------------------------- RECIPROCAL OPERATION -------------------------------------------------------------------------------------------
class ReciprocalOp implements DomainOperation {
  @override
  String get id => 'reciprocal';

  @override
  String get label => '1/x';

  @override
  String? get description => 'Reciprocal (1 ÷ X)';

  @override
  int get arity => 1;

  @override
  RpnStackState execute(RpnStackState state) {
    if (state.stack.isEmpty) throw Exception('Stack empty');
    final newStack = List<CalcNumber>.from(state.stack);
    final top = newStack.removeLast();
    newStack.add(top / CalcNumber.fromString('1'));
    return state.copyWith(stack: newStack);
  }
}

///--------------------------------------------- PERCENTAGE OPERATION ----------------------------------------------------------------------------------------------
class PercentOp implements DomainOperation {
  @override
  String get id => 'percent';

  @override
  String get label => '%';

  @override
  String? get description => 'X ÷ 100';

  @override
  int get arity => 1;

  @override
  RpnStackState execute(RpnStackState state) {
    if (state.stack.isEmpty) throw Exception('Stack empty');
    final newStack = List<CalcNumber>.from(state.stack);
    final top = newStack.removeLast();
    newStack.add(top * CalcNumber.fromString('0.01'));
    return state.copyWith(stack: newStack);
  }
}

///----------------------------------------------- SQUARE ROOT OPERATION ------------------------------------------------------------------------------------------
class SquareRootOp implements DomainOperation {
  @override
  String get id => 'sqrt';

  @override
  String get label => '√';

  @override
  String? get description => 'Square root';

  @override
  int get arity => 1;

  @override
  RpnStackState execute(RpnStackState state) {
    // TODO: implement actual sqrt using decimal.sqrt()
    throw UnimplementedError('√ not yet implemented');
  }
}