import '../../../core/engine/number.dart';
import '../../../core/engine/rpn_engine.dart';
import 'domain.dart';

class FinanceDomain implements Domain {
  @override
  String get id => 'finance';

  @override
  String get name => 'Finance';

  @override
  String get shortLabel => 'FIN';

  @override
  List<DomainOperation> get operations => [
    EmiOp(),
    NpvOp(),
    RoiOp(),
    FutureValueOp(),
    AnnuityPmtOp(),
  ];
}

///--------------------------------------------- EMI (Equated Monthly Installment) ----------------------------------------------------------------------------------------------
class EmiOp implements DomainOperation {
  @override String get id => 'emi'; 
  @override String get label => 'EMI'; 
  @override int get arity => 3;
  @override String? get description => 'EMI (P r% N → EMI)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final years = newStack.removeLast().value.toInt() * 12; // months
    final annualRate = newStack.removeLast().value / Decimal.fromInt(100);
    final principal = newStack.removeLast().value;
    
    final monthlyRate = annualRate / Decimal.fromInt(12);
    final power = pow(1 + monthlyRate.toDouble(), years.toDouble());
    final emi = principal * monthlyRate * Decimal.parse(power.toString()) /
                (Decimal.parse(power.toString()) - Decimal.one);
    
    newStack.add(CalcNumber(emi));
    return state.copyWith(stack: newStack);
  }
}

///--------------------------------------------- NPV (Net Present Value) ----------------------------------------------------------------------------------------------
class NpvOp implements DomainOperation {
  @override String get id => 'npv'; 
  @override String get label => 'NPV'; 
  @override int get arity => -1; // variable
  @override String? get description => 'NPV (r CFs → NPV)';

  @override
  RpnStackState execute(RpnStackState state) {
    if (state.stack.length < 2) throw Exception('Need rate + cashflows');
    final newStack = List<CalcNumber>.from(state.stack);
    final rate = newStack.removeLast().value / Decimal.fromInt(100);
    
    Decimal npv = Decimal.zero;
    while (newStack.isNotEmpty) {
      final cf = newStack.removeLast().value;
      npv += cf / pow(1 + rate.toDouble(), newStack.length.toDouble() + 1);
    }
    
    newStack.add(CalcNumber(npv));
    return state.copyWith(stack: newStack);
  }
}

///--------------------------------------------- ROI (Return on Investment) ----------------------------------------------------------------------------------------------
class RoiOp implements DomainOperation {
  @override String get id => 'roi'; 
  @override String get label => 'ROI%'; 
  @override int get arity => 2;
  @override String? get description => 'ROI % (Gain Invest → %)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final investment = newStack.removeLast().value;
    final gain = newStack.removeLast().value;
    final roi = (gain / investment) * Decimal.fromInt(100);
    newStack.add(CalcNumber(roi));
    return state.copyWith(stack: newStack);
  }
}

///--------------------------------------------- FV (Future Value) ----------------------------------------------------------------------------------------------
class FutureValueOp implements DomainOperation {
  @override String get id => 'fv'; 
  @override String get label => 'FV'; 
  @override int get arity => 3;
  @override String? get description => 'Future value (Pmt r N → FV)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final periods = newStack.removeLast().value.toInt();
    final rate = newStack.removeLast().value / Decimal.fromInt(100);
    final pmt = newStack.removeLast().value;
    
    Decimal fv = Decimal.zero;
    for (int i = 0; i < periods; i++) {
      fv = fv * (Decimal.one + rate) + pmt;
    }
    newStack.add(CalcNumber(fv));
    return state.copyWith(stack: newStack);
  }
}

///--------------------------------------------- Annuity Payment ----------------------------------------------------------------------------------------------
class AnnuityPmtOp implements DomainOperation {
  @override String get id => 'pmt'; 
  @override String get label => 'PMT'; 
  @override int get arity => 3;
  @override String? get description => 'Annuity payment (PV r N → Pmt)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final periods = newStack.removeLast().value.toInt();
    final rate = newStack.removeLast().value / Decimal.fromInt(100);
    final pv = newStack.removeLast().value;
    
    final power = pow(1 + rate.toDouble(), periods.toDouble());
    final pmt = pv * rate * Decimal.parse(power.toString()) /
                (Decimal.parse(power.toString()) - Decimal.one);
    
    newStack.add(CalcNumber(pmt));
    return state.copyWith(stack: newStack);
  }
}
