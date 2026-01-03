class CalcPolicy {
  const CalcPolicy._();

  static const bool allowSymbolicMath = false;

  static const bool requireAlgAndRpnSupport = true;

  /// Maximum allowed magnitude for any result.
  /// Anything with |value| > maxMagnitude should be treated as overflow.
  static const double maxMagnitude = 1e100;

  /// Minimum non‑zero magnitude we bother to represent.
  /// Values smaller in magnitude than this can be flushed to zero.
  static const double minNonZeroMagnitude = 1e-100;
}
