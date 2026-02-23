import 'dart:math';
import 'package:decimal/decimal.dart';
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

class EmiOp implements DomainOperation {
  @override
  String get id => 'emi';
  @override
  String get label => 'EMI';
  @override
  int get arity => 3;
  @override
  String? get description => 'EMI (P r% N → EMI)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final years = newStack.removeLast().value.toDouble().toInt() * 12;
    final annualRate =
        (newStack.removeLast().value / Decimal.fromInt(100)).toDecimal();
    final principal = newStack.removeLast().value;

    final monthlyRate = (annualRate / Decimal.fromInt(12)).toDecimal();
    final rateDouble = monthlyRate.toDouble();
    final power = pow(1 + rateDouble, years.toDouble());
    final powerDec = Decimal.parse(power.toString());
    final emi = (principal * monthlyRate * powerDec / (powerDec - Decimal.one))
        .toDecimal();

    newStack.add(CalcNumber(emi));
    return state.copyWith(stack: newStack);
  }
}

class NpvOp implements DomainOperation {
  @override
  String get id => 'npv';
  @override
  String get label => 'NPV';
  @override
  int get arity => -1;
  @override
  String? get description => 'NPV (r CFs → NPV)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    if (newStack.length < 2) throw Exception('Need rate + cashflows');
    final rate =
        (newStack.removeLast().value / Decimal.fromInt(100)).toDecimal();
    final rateDouble = rate.toDouble();

    Decimal npv = Decimal.zero;
    int period = 1;
    while (newStack.isNotEmpty) {
      final cf = newStack.removeLast().value;
      final discountFactor =
          Decimal.parse(pow(1 + rateDouble, period).toString());
      npv = npv + (cf / discountFactor).toDecimal();
      period++;
    }

    newStack.add(CalcNumber(npv));
    return state.copyWith(stack: newStack);
  }
}

class RoiOp implements DomainOperation {
  @override
  String get id => 'roi';
  @override
  String get label => 'ROI%';
  @override
  int get arity => 2;
  @override
  String? get description => 'ROI % (Gain Invest → %)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final investment = newStack.removeLast().value;
    final gain = newStack.removeLast().value;
    final ratio = (gain / investment).toDecimal();
    final roi = ratio * Decimal.fromInt(100);
    newStack.add(CalcNumber(roi));
    return state.copyWith(stack: newStack);
  }
}

class FutureValueOp implements DomainOperation {
  @override
  String get id => 'fv';
  @override
  String get label => 'FV';
  @override
  int get arity => 3;
  @override
  String? get description => 'Future value (Pmt r N → FV)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final periods = newStack.removeLast().value.toDouble().toInt();
    final rate =
        (newStack.removeLast().value / Decimal.fromInt(100)).toDecimal();
    final pmt = newStack.removeLast().value;

    if (periods <= 0) {
      newStack.add(CalcNumber(pmt));
      return state.copyWith(stack: newStack);
    }

    final rateDouble = rate.toDouble();
    final power = pow(1 + rateDouble, periods.toDouble());
    final powerDec = Decimal.parse(power.toString());
    final fv = (pmt * (powerDec - Decimal.one) / rate).toDecimal();

    newStack.add(CalcNumber(fv));
    return state.copyWith(stack: newStack);
  }
}

class AnnuityPmtOp implements DomainOperation {
  @override
  String get id => 'pmt';
  @override
  String get label => 'PMT';
  @override
  int get arity => 3;
  @override
  String? get description => 'Annuity payment (PV r N → Pmt)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final periods = newStack.removeLast().value.toDouble().toInt();
    final rate =
        (newStack.removeLast().value / Decimal.fromInt(100)).toDecimal();
    final pv = newStack.removeLast().value;

    final rateDouble = rate.toDouble();
    final power = pow(1 + rateDouble, periods.toDouble());
    final powerDec = Decimal.parse(power.toString());
    final pmt = (pv * rate * powerDec / (powerDec - Decimal.one)).toDecimal();

    newStack.add(CalcNumber(pmt));
    return state.copyWith(stack: newStack);
  }
}
