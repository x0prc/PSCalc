import 'dart:math';
import 'package:decimal/decimal.dart';
import '../../../core/engine/number.dart';
import '../../../core/engine/rpn_engine.dart';
import 'domain.dart';

class RealEstateDomain implements Domain {
  @override
  String get id => 'real_estate';

  @override
  String get name => 'Real Estate & TVM';

  @override
  String get shortLabel => 'RE';

  @override
  List<DomainOperation> get operations => [
    CapRateOp(),
    RentalYieldOp(),
    GrmOp(),
    CashOnCashOp(),
    MortgageEmiOp(),
  ];
}

///---------------------------------------------- CAP Rate Operation -------------------------------------------------------------------------------------------
class CapRateOp implements DomainOperation {
  @override String get id => 'cap_rate'; 
  @override String get label => 'CAP%'; 
  @override int get arity => 2;
  @override String? get description => 'Cap Rate (NOI Value → %)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    if (newStack.length < 2) throw Exception('Need NOI + Value');
    final value = newStack.removeLast().value;
    final noi = newStack.removeLast().value;
    final ratio = (noi / value).toDecimal();
    final capRate = ratio * Decimal.fromInt(100);
    newStack.add(CalcNumber(capRate));
    return state.copyWith(stack: newStack);
  }
}

///---------------------------------------------- Rental Yield Operation -------------------------------------------------------------------------------------------
class RentalYieldOp implements DomainOperation {
  @override String get id => 'rent_yield'; 
  @override String get label => 'YLD%'; 
  @override int get arity => 2;
  @override String? get description => 'Gross Rental Yield %';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final value = newStack.removeLast().value;
    final annualRent = newStack.removeLast().value;
    final ratio = (annualRent / value).toDecimal();
    final yieldPct = ratio * Decimal.fromInt(100);
    newStack.add(CalcNumber(yieldPct));
    return state.copyWith(stack: newStack);
  }
}

///---------------------------------------------- Gross Rent Multiplier Operation -------------------------------------------------------------------------------------------
class GrmOp implements DomainOperation {
  @override String get id => 'grm'; 
  @override String get label => 'GRM'; 
  @override int get arity => 2;
  @override String? get description => 'Gross Rent Multiplier';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final price = newStack.removeLast().value;
    final annualRent = newStack.removeLast().value;
    final grm = (price / annualRent).toDecimal();
    newStack.add(CalcNumber(grm));
    return state.copyWith(stack: newStack);
  }
}

///---------------------------------------------- Cash On Cash Operation -------------------------------------------------------------------------------------------
class CashOnCashOp implements DomainOperation {
  @override String get id => 'cash_cash'; 
  @override String get label => 'CoC%'; 
  @override int get arity => 2;
  @override String? get description => 'Cash on Cash Return %';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final investment = newStack.removeLast().value;
    final annualCashFlow = newStack.removeLast().value;
    final ratio = (annualCashFlow / investment).toDecimal();
    final coc = ratio * Decimal.fromInt(100);
    newStack.add(CalcNumber(coc));
    return state.copyWith(stack: newStack);
  }
}

///---------------------------------------------- Mortgage EMI Operation -------------------------------------------------------------------------------------------
class MortgageEmiOp implements DomainOperation {
  @override String get id => 'mortgage_emi'; 
  @override String get label => 'MTG'; 
  @override int get arity => 3;
  @override String? get description => 'Mortgage EMI (Loan r% Years)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final years = newStack.removeLast().value.toDouble().toInt() * 12;
    final annualRate = (newStack.removeLast().value / Decimal.fromInt(100)).toDecimal();
    final loan = newStack.removeLast().value;
    
    final monthlyRate = (annualRate / Decimal.fromInt(12)).toDecimal();
    final power = pow(1 + monthlyRate.toDouble(), years.toDouble());
    final emi = (loan * monthlyRate * Decimal.parse(power.toString()) /
                (Decimal.parse(power.toString()) - Decimal.one)).toDecimal();
    
    newStack.add(CalcNumber(emi));
    return state.copyWith(stack: newStack);
  }
}
