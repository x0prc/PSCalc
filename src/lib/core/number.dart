import 'package:decimal/decimal.dart';

class CalcNumber {
  final Decimal value;

  CalcNumber(this.value);

  factory CalcNumber.fromString(String s) {
    return CalcNumber(Decimal.parse(s));
  }

  CalcNumber operator +(CalcNumber other) => CalcNumber(value + other.value);
  CalcNumber operator -(CalcNumber other) => CalcNumber(value - other.value);
  CalcNumber operator *(CalcNumber other) => CalcNumber(value * other.value);

  CalcNumber operator /(CalcNumber other) {
    if(other.value == Decimal.zero) {
      throw CalcError.divideByZero();
    }
    // decimal package division returns Rational, convert back to Decimal
    return CalcNumber((value / other.value).toDecimal());
  }

  @override
  String toString() => value.toString();
}

class CalcError implements Exception {
  final String message;

  CalcError(this.message);

  factory CalcError.divideByZero() => CalcError('Divide by zero');
  factory CalcError.stackUnderflow() => CalcError('Stack underflow');
  factory CalcError.parseError() => CalcError('Parse error');
  factory CalcError.overflow() => CalcError('Overflow');

  @override
  String toString() => message;
}
