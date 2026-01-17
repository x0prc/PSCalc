import 'package:decimal/decimal.dart';
import '../config/calc_policy.dart';


class CalcNumber {
  final Decimal value;

  CalcNumber(this.value);

  factory CalcNumber.fromString(String s) {
    return CalcNumber(Decimal.parse(s));
  }

  /// Internal helper to enforce overflow/underflow limits.
  static Decimal _checked(Decimal v) {
    final abs = v < Decimal.zero ? -v : v;

    final max = Decimal.parse(CalcPolicy.maxMagnitude.toString());
    final min = Decimal.parse(CalcPolicy.minNonZeroMagnitude.toString());

    if (abs > max) {
      throw CalcError.overflow();
    }
    // Optional: treat very small non‑zero values as underflow → zero.
    if (abs > Decimal.zero && abs < min) {
      return Decimal.zero;
    }
    return v;
  }

  CalcNumber operator +(CalcNumber other) =>
      CalcNumber(_checked(value + other.value));

  CalcNumber operator -(CalcNumber other) =>
      CalcNumber(_checked(value - other.value));

  CalcNumber operator *(CalcNumber other) =>
      CalcNumber(_checked(value * other.value));

  CalcNumber operator /(CalcNumber other) {
    if (other.value == Decimal.zero) {
      throw CalcError.divideByZero();
    }
    // Convert Rational to Decimal
    return CalcNumber(_checked((value / other.value).toDecimal()));
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
