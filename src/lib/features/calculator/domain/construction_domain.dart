import 'dart:math';
import '../../../core/engine/number.dart';
import '../../../core/engine/rpn_engine.dart';
import 'domain.dart';

class ConstructionDomain implements Domain {
  @override String get id => 'construction'; @override String get name => 'Construction'; @override String get shortLabel => 'BUILD';
  @override List<DomainOperation> get operations => [ConcreteVolumeOp(), RebarWeightOp(), RoofPitchOp()];

  // CONCRETE VOL: Length Width Depth → m³
  class ConcreteVolumeOp implements DomainOperation
