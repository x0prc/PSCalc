import 'dart:math';
import '../../../core/engine/number.dart';
import '../../../core/engine/rpn_engine.dart';
import 'domain.dart';

class NavDomain implements Domain {
  @override
  String get id => 'nav';
  @override
  String get name => 'Navigation';
  @override
  String get shortLabel => 'NAV';
  @override
  List<DomainOperation> get operations => [BearingOp(), DistanceOp()];
}

// BEARING: Lat2 Lon2 Lat1 Lon1 → Bearing
class BearingOp implements DomainOperation {
  @override
  String get id => 'bearing';
  @override
  String get label => 'BRG';
  @override
  int get arity => 4;
  @override
  String? get description => 'Bearing between two points';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final lat2 = _toRadians(newStack.removeLast().value.toDouble());
    final lon2 = _toRadians(newStack.removeLast().value.toDouble());
    final lat1 = _toRadians(newStack.removeLast().value.toDouble());
    final lon1 = _toRadians(newStack.removeLast().value.toDouble());

    final y = sin(lon2 - lon1) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon2 - lon1);
    final bearing = atan2(y, x);

    newStack.add(CalcNumber.fromString((_toDegrees(bearing) % 360).toString()));
    return state.copyWith(stack: newStack);
  }

  double _toRadians(double degrees) => degrees * pi / 180;
  double _toDegrees(double radians) => radians * 180 / pi;
}

// DISTANCE: Lat2 Lon2 Lat1 Lon1 → Distance (km)
class DistanceOp implements DomainOperation {
  @override
  String get id => 'dist';
  @override
  String get label => 'DIST';
  @override
  int get arity => 4;
  @override
  String? get description => 'Distance in km';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final lat2 = _toRadians(newStack.removeLast().value.toDouble());
    final lon2 = _toRadians(newStack.removeLast().value.toDouble());
    final lat1 = _toRadians(newStack.removeLast().value.toDouble());
    final lon1 = _toRadians(newStack.removeLast().value.toDouble());

    final dlon = lon2 - lon1;
    final dlat = lat2 - lat1;
    final a =
        sin(dlat / 2) * sin(dlat / 2) +
        cos(lat1) * cos(lat2) * sin(dlon / 2) * sin(dlon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = 6371 * c; // Earth radius km

    newStack.add(CalcNumber.fromString(distance.toString()));
    return state.copyWith(stack: newStack);
  }

  double _toRadians(double degrees) => degrees * pi / 180;
}
