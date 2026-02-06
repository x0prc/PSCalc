import 'dart:math';
import 'package:decimal/decimal.dart';
import '../../../core/engine/number.dart';
import '../../../core/engine/rpn_engine.dart';
import 'domain.dart';

class ConstructionDomain implements Domain {
  @override
  String get id => 'construction';
  @override
  String get name => 'Construction';
  @override
  String get shortLabel => 'BUILD';
  @override
  List<DomainOperation> get operations => [
    ConcreteVolumeOp(),
    RebarWeightOp(),
    RoofPitchOp(),
  ];
}

// CONCRETE VOL: Length Width Depth → m³
class ConcreteVolumeOp implements DomainOperation {
  @override
  String get id => 'concrete_vol';
  @override
  String get label => 'CONC';
  @override
  int get arity => 3;
  @override
  String? get description => 'Concrete volume (L W D → m³)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final depth = newStack.removeLast().value;
    final width = newStack.removeLast().value;
    final length = newStack.removeLast().value;
    final volume = (length * width * depth);
    newStack.add(CalcNumber(volume));
    return state.copyWith(stack: newStack);
  }
}

// REBAR WEIGHT: Length Diameter → kg
class RebarWeightOp implements DomainOperation {
  @override
  String get id => 'rebar_wt';
  @override
  String get label => 'REBAR';
  @override
  int get arity => 2;
  @override
  String? get description => 'Rebar weight (L D → kg)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final diameter = newStack.removeLast().value; // mm
    final length = newStack.removeLast().value; // m
    // Weight = (π * d² / 4) * length * density (7850 kg/m³)
    final area =
        (Decimal.parse('3.14159') * diameter * diameter / Decimal.fromInt(4))
            .toDecimal();
    final volume = (area * length / Decimal.fromInt(1000000))
        .toDecimal(); // convert mm² to m²
    final weight = (volume * Decimal.fromInt(7850));
    newStack.add(CalcNumber(weight));
    return state.copyWith(stack: newStack);
  }
}

// ROOF PITCH: Rise Run → Pitch degrees
class RoofPitchOp implements DomainOperation {
  @override
  String get id => 'roof_pitch';
  @override
  String get label => 'PITCH';
  @override
  int get arity => 2;
  @override
  String? get description => 'Roof pitch in degrees (Rise Run → °)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final run = newStack.removeLast().value;
    final rise = newStack.removeLast().value;
    final pitch = Decimal.parse(
      (atan2(rise.toDouble(), run.toDouble()) * 180 / pi).toString(),
    );
    newStack.add(CalcNumber(pitch));
    return state.copyWith(stack: newStack);
  }
}
