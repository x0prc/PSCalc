import '../../../core/engine/number.dart';
import '../../../core/engine/rpn_engine.dart';
import 'domain.dart';

class BusinessDomain implements Domain {
    @override
    String get id => 'business';

    @override
    String get name => 'Business Math';

    @override
    String get shortLabel => 'BUS';

    @override
    List<DomainOperation> get operations => [
        DiscountAmountOp(),
        SellingPriceOp(),
        MarkupOp(),
        BreakEvenOp(),
        ProfitMarginOp(),
    ]
}

class DiscountAmountOp implements DomainOperation {
  @override String get id => 'discount_amt'; @override String get label => 'DISC%'; @override int get arity => 2;
  @override String? get description => 'Discount amount (Rate Amount → Disc)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final amount = newStack.removeLast().value;
    final rate = newStack.removeLast().value / Decimal.fromInt(100);
    newStack.add(CalcNumber(amount * rate));
    return state.copyWith(stack: newStack);
  }
}

class SellingPriceOp implements DomainOperation {
  @override String get id => 'sell_price'; @override String get label => 'SELL'; @override int get arity => 2;
  @override String? get description => 'Selling price (Margin% Cost → Price)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final cost = newStack.removeLast().value;
    final marginPct = newStack.removeLast().value / Decimal.fromInt(100);
    final price = cost / (Decimal.one - marginPct);
    newStack.add(CalcNumber(price));
    return state.copyWith(stack: newStack);
  }
}

class MarkupOp implements DomainOperation {
  @override String get id => 'markup'; @override String get label => 'MARKUP'; @override int get arity => 2;
  @override String? get description => 'Markup % (Selling Cost → Margin%)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final cost = newStack.removeLast().value;
    final selling = newStack.removeLast().value;
    final markup = ((selling - cost) / cost) * Decimal.fromInt(100);
    newStack.add(CalcNumber(markup));
    return state.copyWith(stack: newStack);
  }
}

class BreakEvenOp implements DomainOperation {
  @override String get id => 'break_even'; @override String get label => 'B/E'; @override int get arity => 2;
  @override String? get description => 'Break-even units (Fixed Cost Margin/unit)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final marginPerUnit = newStack.removeLast().value;
    final fixedCosts = newStack.removeLast().value;
    if (marginPerUnit == Decimal.zero) throw CalcError.divideByZero();
    final units = fixedCosts / marginPerUnit;
    newStack.add(CalcNumber(units));
    return state.copyWith(stack: newStack);
  }
}

class ProfitMarginOp implements DomainOperation {
  @override String get id => 'profit_margin'; @override String get label => 'PM%'; @override int get arity => 2;
  @override String? get description => 'Profit margin % (Revenue Cost → Margin%)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final cost = newStack.removeLast().value;
    final revenue = newStack.removeLast().value;
    final margin = ((revenue - cost) / revenue) * Decimal.fromInt(100);
    newStack.add(CalcNumber(margin));
    return state.copyWith(stack: newStack);
  }
}