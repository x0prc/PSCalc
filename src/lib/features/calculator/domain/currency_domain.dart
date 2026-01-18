import 'dart:convert';
import 'package:decimal/decimal.dart';
import 'package:http/http.dart' as http;
import '../../../core/engine/number.dart';
import '../../../core/engine/rpn_engine.dart';
import 'domain.dart';

class CurrencyRates {
  static Map<String, Decimal> _rates = {};
  static DateTime? _lastUpdate;

  static Future<void> fetchLatest() async {
    if (DateTime.now().difference(_lastUpdate ?? DateTime(1900)).inMinutes < 30) {
      return;
    }
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
      // Fallback
      _rates = {
        'USD': Decimal.fromInt(1),
        'EUR': Decimal.parse('0.92'),
        'INR': Decimal.parse('83.5'),
        'GBP': Decimal.parse('0.79'),
        'JPY': Decimal.parse('148'),
      };
    }
  }

  static Decimal rateFor(String code) {
    fetchLatest(); // fire async
    return _rates[code.toUpperCase()] ?? Decimal.zero;
  }
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

class CurrencyConvertOp implements DomainOperation {
  @override
  String get id => 'currency_convert';
  @override
  String get label => '→USD';
  @override
  String? get description => 'Convert to USD';
  @override
  int get arity => 2;

  @override
  RpnStackState execute(RpnStackState state) {
    if (state.stack.length < 2) throw Exception('Need 2 items');
    final newStack = List<CalcNumber>.from(state.stack);
    final amount = newStack.removeLast().value;
    final fromCode = newStack.removeLast().value.toString().toUpperCase();

    final rate = CurrencyRates.rateFor(fromCode);
    if (rate == Decimal.zero) throw Exception('Unknown: $fromCode');

    newStack.add(CalcNumber((amount / rate).toDecimal()));
    return state.copyWith(stack: newStack);
  }
}

class CrossRateOp implements DomainOperation {
  @override
  String get id => 'cross_rate';
  @override
  String get label => 'X/Y';
  @override
  String? get description => 'Cross rate';
  @override
  int get arity => 2;

  @override
  RpnStackState execute(RpnStackState state) {
    if (state.stack.length < 2) throw Exception('Need 2 items');
    final newStack = List<CalcNumber>.from(state.stack);
    final denomCode = newStack.removeLast().value.toString().toUpperCase();
    final numCode = newStack.removeLast().value.toString().toUpperCase();

    final denomRate = CurrencyRates.rateFor(denomCode);
    final numRate = CurrencyRates.rateFor(numCode);

    if (denomRate == Decimal.zero || numRate == Decimal.zero) {
      throw Exception('Unknown: $numCode/$denomCode');
    }

    newStack.add(CalcNumber((numRate / denomRate).toDecimal()));
    return state.copyWith(stack: newStack);
  }
}

class PipsOp implements DomainOperation {
  @override
  String get id => 'pips';
  @override
  String get label => 'PIPS';
  @override
  String? get description => 'Pip value';
  @override
  int get arity => 3;

  @override
  RpnStackState execute(RpnStackState state) {
    if (state.stack.length < 3) throw Exception('Need 3 items');
    final newStack = List<CalcNumber>.from(state.stack);
    final rate = newStack.removeLast().value;
    final pipSize = newStack.removeLast().value;
    final posSize = newStack.removeLast().value;

    newStack.add(CalcNumber(posSize * pipSize * rate));
    return state.copyWith(stack: newStack);
  }
}
