import 'package:decimal/decimal.dart';
import '../../../core/engine/number.dart';
import '../../../core/engine/rpn_engine.dart';
import 'domain.dart';

class FxDomain implements Domain {
  @override
  String get id => 'fx';

  @override
  String get name => 'FX';

  @override
  String get shortLabel => 'FX';

  @override
  List<DomainOperation> get operations => [
    PipValueOp(),
    LotSizeOp(),
    SpreadCostOp(),
    ForwardPointsOp(),
    RiskRewardOp(),
  ];
}

/// PIP VALUE: LotSize PipSize Rate → Pip Value ($)
class PipValueOp implements DomainOperation {
  @override String get id => 'pip_value'; 
  @override String get label => 'PIP\$'; 
  @override int get arity => 3;
  @override String? get description => 'Pip value USD (Lots PipSz Rate)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final rate = newStack.removeLast().value;
    final pipSize = newStack.removeLast().value;
    final lots = newStack.removeLast().value * Decimal.fromInt(100000); 
    
    Decimal pipValue;
    if (rate < Decimal.fromInt(10)) {  
      pipValue = (lots * pipSize * Decimal.fromInt(100) / rate).toDecimal();
    } else {
      pipValue = lots * pipSize;
    }
    
    newStack.add(CalcNumber(pipValue));
    return state.copyWith(stack: newStack);
  }
}

/// LOT SIZE: Risk% AccountSize StopLoss → Lot Size
class LotSizeOp implements DomainOperation {
  @override String get id => 'lot_size'; 
  @override String get label => 'LOTS'; 
  @override int get arity => 3;
  @override String? get description => 'Optimal lots (Risk% Acct SL→Lots)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final stopLossPips = newStack.removeLast().value;
    final accountSize = newStack.removeLast().value;
    final riskPct = (newStack.removeLast().value / Decimal.fromInt(100)).toDecimal();
    
    final riskAmount = accountSize * riskPct;
    final pipValueNeeded = (riskAmount / stopLossPips).toDecimal();
    final lotSize = (pipValueNeeded / Decimal.fromInt(10)).toDecimal(); 
    
    newStack.add(CalcNumber(lotSize));
    return state.copyWith(stack: newStack);
  }
}

/// SPREAD COST: Lots SpreadPips Rate → Spread Cost ($)
class SpreadCostOp implements DomainOperation {
  @override String get id => 'spread_cost'; 
  @override String get label => 'SPRD\$'; 
  @override int get arity => 3;
  @override String? get description => 'Spread cost USD';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final rate = newStack.removeLast().value;
    final spreadPips = newStack.removeLast().value;
    final lots = newStack.removeLast().value * Decimal.fromInt(100000);
    
    Decimal spreadCost;
    if (rate < Decimal.fromInt(10)) {
      spreadCost = (lots * spreadPips * Decimal.fromInt(100) / rate).toDecimal();
    } else {
      spreadCost = lots * spreadPips;
    }
    
    newStack.add(CalcNumber(spreadCost));
    return state.copyWith(stack: newStack);
  }
}

/// FORWARD POINTS: SpotRate InterestDiff Days → Fwd Points
class ForwardPointsOp implements DomainOperation {
  @override String get id => 'fwd_pts'; 
  @override String get label => 'FWD'; 
  @override int get arity => 3;
  @override String? get description => 'Forward points (Spot Diff Days)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final days = (newStack.removeLast().value / Decimal.fromInt(360)).toDecimal(); // banking year
    final interestDiff = (newStack.removeLast().value / Decimal.fromInt(100)).toDecimal();
    final spotRate = newStack.removeLast().value;
    
    final fwdPoints = spotRate * interestDiff * days * Decimal.fromInt(10000);
    newStack.add(CalcNumber(fwdPoints));
    return state.copyWith(stack: newStack);
  }
}

/// RISK/REWARD: Entry Stop Target → R/R Ratio
class RiskRewardOp implements DomainOperation {
  @override String get id => 'rr_ratio'; 
  @override String get label => 'R:R'; 
  @override int get arity => 3;
  @override String? get description => 'Risk:Reward ratio';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final target = newStack.removeLast().value;
    final stop = newStack.removeLast().value;
    final entry = newStack.removeLast().value;
    
    final risk = (entry - stop).abs();
    final reward = (target - entry).abs();
    final rr = (reward / risk).toDecimal();
    
    newStack.add(CalcNumber(rr));
    return state.copyWith(stack: newStack);
  }
}