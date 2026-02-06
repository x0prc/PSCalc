import '../../../core/engine/number.dart';
import '../../../core/engine/rpn_engine.dart';
import 'domain.dart';

class DateDomain implements Domain {
  @override
  String get id => 'date';

  @override
  String get name => 'Date Arithmetic';

  @override
  String get shortLabel => 'DATE';

  @override
  List<DomainOperation> get operations => [
    DaysBetweenOp(),
    BusinessDaysOp(),
    AgeCalcOp(),
    AddMonthsOp(),
    AddDaysOp(),
  ];
}

/// DAYS BETWEEN: Date2 Date1 → Days
class DaysBetweenOp implements DomainOperation {
  @override
  String get id => 'days_diff';
  @override
  String get label => 'DAYS';
  @override
  int get arity => 2;
  @override
  String? get description => 'Days between dates (Date2 Date1)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    if (newStack.length < 2) throw Exception('Need 2 dates');

    final date2Str = newStack
        .removeLast()
        .value
        .toDouble()
        .toInt()
        .toString()
        .padLeft(8, '0');
    final date1Str = newStack
        .removeLast()
        .value
        .toDouble()
        .toInt()
        .toString()
        .padLeft(8, '0');

    final date2 = DateTime.parse(date2Str);
    final date1 = DateTime.parse(date1Str);
    final days = (date2.difference(date1).inDays).toDouble();

    newStack.add(CalcNumber.fromString(days.toString()));
    return state.copyWith(stack: newStack);
  }
}

/// BUSINESS DAYS: EndDate StartDate → Business Days
class BusinessDaysOp implements DomainOperation {
  @override
  String get id => 'bus_days';
  @override
  String get label => 'BD';
  @override
  int get arity => 2;
  @override
  String? get description => 'Business days (Mon-Fri)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final endStr = newStack
        .removeLast()
        .value
        .toDouble()
        .toInt()
        .toString()
        .padLeft(8, '0');
    final startStr = newStack
        .removeLast()
        .value
        .toDouble()
        .toInt()
        .toString()
        .padLeft(8, '0');

    final endDate = DateTime.parse(endStr);
    final startDate = DateTime.parse(startStr);

    int businessDays = 0;
    var current = startDate;
    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      if (current.weekday >= DateTime.monday &&
          current.weekday <= DateTime.friday) {
        businessDays++;
      }
      current = current.add(const Duration(days: 1));
    }

    newStack.add(CalcNumber.fromString(businessDays.toString()));
    return state.copyWith(stack: newStack);
  }
}

/// AGE: Today BirthDate → Years Months Days
class AgeCalcOp implements DomainOperation {
  @override
  String get id => 'age';
  @override
  String get label => 'AGE';
  @override
  int get arity => 2;
  @override
  String? get description => 'Age YMD (Today Birth)';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final birthStr = newStack
        .removeLast()
        .value
        .toDouble()
        .toInt()
        .toString()
        .padLeft(8, '0');
    final todayStr = newStack
        .removeLast()
        .value
        .toDouble()
        .toInt()
        .toString()
        .padLeft(8, '0');

    final birthDate = DateTime.parse(birthStr);
    final today = DateTime.parse(todayStr);

    var years = today.year - birthDate.year;
    var months = today.month - birthDate.month;
    var days = today.day - birthDate.day;

    // Adjust if birthday hasn't occurred this year
    if (months < 0 || (months == 0 && days < 0)) {
      years--;
    }

    newStack.add(
      CalcNumber.fromString((years * 365 + months * 30 + days).toString()),
    );
    return state.copyWith(stack: newStack);
  }
}

/// ADD MONTHS: Months Date → New Date (YYYYMMDD)
class AddMonthsOp implements DomainOperation {
  @override
  String get id => 'add_months';
  @override
  String get label => '+M';
  @override
  int get arity => 2;
  @override
  String? get description => 'Add months to date';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final months = newStack.removeLast().value.toDouble().toInt();
    final dateInt = newStack.removeLast().value.toDouble().toInt();

    final dateStr = dateInt.toString().padLeft(8, '0');
    var date = DateTime.parse(dateStr);
    date = DateTime(date.year, date.month + months, date.day);

    final newDateInt = int.parse(
      '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}',
    );
    newStack.add(CalcNumber.fromString(newDateInt.toString()));
    return state.copyWith(stack: newStack);
  }
}

/// ADD DAYS: Days Date → New Date (YYYYMMDD)
class AddDaysOp implements DomainOperation {
  @override
  String get id => 'add_days';
  @override
  String get label => '+D';
  @override
  int get arity => 2;
  @override
  String? get description => 'Add days to date';

  @override
  RpnStackState execute(RpnStackState state) {
    final newStack = List<CalcNumber>.from(state.stack);
    final days = newStack.removeLast().value.toDouble().toInt();
    final dateInt = newStack.removeLast().value.toDouble().toInt();

    final dateStr = dateInt.toString().padLeft(8, '0');
    final date = DateTime.parse(dateStr).add(Duration(days: days));

    final newDateInt = int.parse(
      '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}',
    );
    newStack.add(CalcNumber.fromString(newDateInt.toString()));
    return state.copyWith(stack: newStack);
  }
}
