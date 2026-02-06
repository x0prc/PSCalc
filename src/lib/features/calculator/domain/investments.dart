import 'dart:math';
import 'package:decimal/decimal.dart';
import '../../../core/engine/number.dart';
import '../../../core/engine/rpn_engine.dart';
import 'domain.dart';

class InvestmentDomain implements Domain {
  @override
  String get id => 'investment';

  @override
  String get name => 'Investment Basics';

  @override
  String get shortLabel => 'INV';

  @override
  List<DomainOperation> get operations => [
    CagrOp(),
    XirrApproxOp(),
    SharpeRatioOp(),
    MaxDrawdownOp(),
    PortfolioWeightOp(),
  ];
}

///-------------------------------- CAGR: EndValue StartValue Years → CAGR % -----------------------------------------------------------------
class CagrOp implements DomainOperation {
  @override
  String get id => 'cagr';
  @override
  String get label => 'CAGR%';
  @override
  int get arity => 3;
  @override
  String? get description => 'Compound Annual Growth Rate %';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final years = newStack.removeLast().value;
    final startValue = newStack.removeLast().value;
    final endValue = newStack.removeLast().value;

    // Use double math for CAGR, then convert back to Decimal for display
    final cagr =
        pow(
          (endValue.toDouble() / startValue.toDouble()),
          1 / years.toDouble(),
        ) -
        1;
    final cagrPct = Decimal.parse(cagr.toString()) * Decimal.fromInt(100);

    newStack.add(CalcNumber(cagrPct));
    return state.copyWith(stack: newStack);
  }
}

///-------------------------------- XIRR APPROX: Final Initial Periods → XIRR % -----------------------------------------------------------------
class XirrApproxOp implements DomainOperation {
  @override
  String get id => 'xirr';
  @override
  String get label => 'XIRR%';
  @override
  int get arity => 3;
  @override
  String? get description => 'XIRR approximation (irregular CFs)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final periods = newStack.removeLast().value;
    final initial = newStack.removeLast().value;
    final finalValue = newStack.removeLast().value;

    // Simplified XIRR: modified CAGR for uneven periods, using doubles for pow
    final totalReturn = finalValue.toDouble() / initial.toDouble() - 1;
    final xirr = pow(1 + totalReturn, 1 / periods.toDouble()) - 1;
    final xirrPct = Decimal.parse(xirr.toString()) * Decimal.fromInt(100);

    newStack.add(CalcNumber(xirrPct));
    return state.copyWith(stack: newStack);
  }
}

///-------------------------------- SHARPE: Return RiskFree Volatility → Sharpe Ratio -----------------------------------------------------------------
class SharpeRatioOp implements DomainOperation {
  @override
  String get id => 'sharpe';
  @override
  String get label => 'SHARPE';
  @override
  int get arity => 3;
  @override
  String? get description => 'Sharpe Ratio (Return Rf Vol → Sharpe)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final volatility = newStack.removeLast().value / Decimal.fromInt(100);
    final riskFree = newStack.removeLast().value / Decimal.fromInt(100);
    final portReturn = newStack.removeLast().value / Decimal.fromInt(100);

    final sharpe = ((portReturn - riskFree) / volatility).toDecimal();
    newStack.add(CalcNumber(sharpe));
    return state.copyWith(stack: newStack);
  }
}

///-------------------------------- MAX DRAWDOWN: PeakValues → Max Drawdown % -----------------------------------------------------------------
class MaxDrawdownOp implements DomainOperation {
  @override
  String get id => 'max_dd';
  @override
  String get label => 'MDD%';
  @override
  int get arity => -1; // variable
  @override
  String? get description => 'Max Drawdown % (prices → MDD%)';

  @override
  RpnStackState execute(RpnStackState state) {
    if (state.stack.length < 2) throw Exception('Need price series');
    final newStack = List<CalcNumber>.from(state.stack);
    Decimal peak = Decimal.zero;
    Decimal maxDd = Decimal.zero;

    while (newStack.isNotEmpty) {
      final price = newStack.removeLast().value;
      if (price > peak) peak = price;
      final dd = ((peak - price) / peak).toDecimal();
      if (dd > maxDd) maxDd = dd;
    }

    newStack.add(CalcNumber(maxDd * Decimal.fromInt(100)));
    return state.copyWith(stack: newStack);
  }
}

///-------------------------------- PORTFOLIO WEIGHT: Value Total → Weight % -----------------------------------------------------------------
class PortfolioWeightOp implements DomainOperation {
  @override
  String get id => 'port_weight';
  @override
  String get label => 'WT%';
  @override
  int get arity => 2;
  @override
  String? get description => 'Portfolio weight %';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final total = newStack.removeLast().value;
    final value = newStack.removeLast().value;
    final weight = ((value / total).toDecimal() * Decimal.fromInt(100));
    newStack.add(CalcNumber(weight));
    return state.copyWith(stack: newStack);
  }
}
