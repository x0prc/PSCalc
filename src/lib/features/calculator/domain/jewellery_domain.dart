import 'package:decimal/decimal.dart';
import '../../../core/engine/number.dart';
import '../../../core/engine/rpn_engine.dart';
import 'domain.dart';

class JewelleryDomain implements Domain {
  @override
  String get id => 'jewellery';
  @override
  String get name => 'Jewellery';
  @override
  String get shortLabel => 'GOLD';
  @override
  List<DomainOperation> get operations => [
    JewelleryPriceOp(),
    MakingChargeOp(),
  ];
}

// JEWEL PRICE: Weight Purity Rate → Total Price
class JewelleryPriceOp implements DomainOperation {
  @override
  String get id => 'jew_price';
  @override
  String get label => 'GOLD\$';
  @override
  int get arity => 3;
  @override
  String? get description => 'Gold price (Weight Purity Rate → Total)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final rate = newStack.removeLast().value; // per gram
    final purity = (newStack.removeLast().value / Decimal.fromInt(1000))
        .toDecimal(); // 24k=240
    final weight = newStack.removeLast().value; // grams

    final pureWeight = (weight * purity);
    final price = (pureWeight * rate);
    newStack.add(CalcNumber(price));
    return state.copyWith(stack: newStack);
  }
}

// MAKING CHARGE: BasePrice % → Total w/ Making
class MakingChargeOp implements DomainOperation {
  @override
  String get id => 'making';
  @override
  String get label => '+MC%';
  @override
  int get arity => 2;
  @override
  String? get description => 'Add making charge %';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final pct = (newStack.removeLast().value / Decimal.fromInt(100))
        .toDecimal();
    final base = newStack.removeLast().value;
    final total = (base * (Decimal.one + pct));
    newStack.add(CalcNumber(total));
    return state.copyWith(stack: newStack);
  }
}
