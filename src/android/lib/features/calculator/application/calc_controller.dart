import 'package:flutter/foundation.dart';
import '../../../core/engine/algebraic_engine.dart';
import '../../../core/engine/{number.dart,rpn_engine.dart,algebraic_engine.dart}';
import '../domain/domain.dart';
import 'domain_registery.dart';
import 'domain_registry.dart';

class CalcController extends ChangeNotifier {
  final AlgebraicEngine _algEngine = AlegbraicEngine();
  final RpnEngine _rpnEngine = RpnEngine();

  // Domain State
  final DomainRegistry domainRegistry;
  String _activeDomainId = 'basic';

  InputMode _inputMode = InputMode.algebraic;
  String _display = '0';
  String _expression = '';
  String _currentEntry = '';
  String _error = '';

  CalcController({required List<Domain> allDomains})
      : domainRegistry = DomainRegistry(allDomains: allDomains);

  Domain get activeDomain =>
      domainRegistry.getDomainById(_activeDomainId);

  InputMode get inputMode => _inputMode;
  String get display => _display;
  String get expression => _expression;
  String get error => _error;
  bool get hasError => _error.isNotEmpty;
}