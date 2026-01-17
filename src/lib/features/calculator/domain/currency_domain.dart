import 'dart:convert';
import 'dart:math';
import 'package:decimal/decimal.dart';
import 'package:http/http.dart' as http;
import '../../../core/engine/number.dart';
import '../../../core/engine/rpn_engine.dart';
import 'domain.dart';

class CurrencyRates {
  static Map<String, Decimal> _rates = {};
  static bool _loading = false;
  static DateTime? _lastUpdate;

  /// Fetches latest rates from Frankfurter.
  static Future<void> fetchLatest() async {
    if (_loading || DateTime.now().difference(_lastUpdate ?? DateTime(1900)).inMinutes < 30) {
      return;
    }
    _loading = true;
    try {
      final response = await http.get(Uri.parse('https://api.frankfurter.app/latest'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = <String, Decimal>{};
        (data['rates'] as Map).forEach((code, rate) {
          rates[code.toUpperCase()] = Decimal.parse(rate.toString());
        });
        _rates = rates;
        _lastUpdate = DateTime.now();
      }
    } catch (e) {
      // Fallback to hardcoded on network error
      _rates = {
        'USD': Decimal.fromInt(1),
        'EUR': Decimal.newFixed(0.92),
        'INR': Decimal.newFixed(83.5),
        'GBP': Decimal.newFixed(0.79),
        'JPY': Decimal.newFixed(148),
      };
    } finally {
      _loading = false;
    }
  }

  static Decimal rateFor(String code) {
    CurrencyRates.fetchLatest();
    return _rates[code.toUpperCase()] ?? Decimal.zero;
  }

  static List<String> get supportedCurrencies => _rates.keys.toList();
}

class CurrencyDomain implements Domain {
  @override
  String get id => 'currency';

  @override
  String get name => 'Currency & FX';

  @override
  String get shortLabel => 'FX';

  @override
  List<DomainOperation> get operations => [
    CurrencyConvertOp(),
    CrossRateOp(),
    PipsOp(),
  ];
}

class CrossRateOp implements DomainOperation {
  @override
  String get id => 'cross_rate';

  @override
  String get label => 'X/Y';

  @override
  String? get description => 'Cross rate (top/base, live)';

  @override
  int get arity => 2;

  @override
  RpnStackState execute(RpnStackState state) async {
    if (state.stack.length < 2) throw Exception('Need 2 stack items');
    final newStack = List<CalcNumber>.from(state.stack);
    final denomCode = newStack.removeLast().value.toString().toUpperCase();
    final numCode = newStack.removeLast().value.toString().toUpperCase();

    await CurrencyRates.fetchLatest();
    final denomRate = CurrencyRates.rateFor(denomCode);
    final numRate = CurrencyRates.rateFor(numCode);

    if (denomRate == Decimal.zero || numRate == Decimal.zero) {
      throw Exception('Unknown currencies: $numCode/$denomCode');
    }

    final cross = numRate / denomRate;
    newStack.add(CalcNumber(cross));
    return state.copyWith(stack: newStack);
  }
}

/// PositionSize PipSize Rate → pip value (forex).
class PipsOp implements DomainOperation {
  @override
  String get id => 'pips';

  @override
  String get label => 'PIPS';

  @override
  String? get description => 'Pip value (Z Y X → value)';

  @override
  int get arity => 3;

  @override
  RpnStackState execute(RpnStackState state) {
    if (state.stack.length < 3) throw Exception('Need 3 stack items');
    final newStack = List<CalcNumber>.from(state.stack);
    final exchangeRate = newStack.removeLast().value;
    final pipSize = newStack.removeLast().value;
    final positionSize = newStack.removeLast().value;

    final pipValue = positionSize * pipSize * exchangeRate;
    newStack.add(CalcNumber(pipValue));
    return state.copyWith(stack: newStack);
  }
}