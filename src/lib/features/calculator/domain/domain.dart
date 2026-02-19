import '../../../core/engine/rpn_engine.dart';

import 'basic_domain.dart';
import 'business_domain.dart';
import 'finance_domain.dart';
import 'fx_domain.dart';
import 'realestate_domain.dart';
import 'investments.dart';
import 'date_domain.dart';
import 'cs_domain.dart';
import 'nav_domain.dart';
import 'jewellery_domain.dart';
import 'construction_domain.dart';

/// Collection of specialised operations
abstract class Domain {
  String get id;
  String get name;
  String get shortLabel;
  List<DomainOperation> get operations;
}

/// Operation within a domain
abstract class DomainOperation {
  String get id;
  String get label;
  String? get description;

  /// Stack items consumed
  int get arity;

  /// Throws updated state OR error
  RpnStackState execute(RpnStackState state);
}

final List<Domain> allDomains = [
  BasicDomain(),
  BusinessDomain(),
  FinanceDomain(),
  FxDomain(),
  RealEstateDomain(),
  InvestmentDomain(),
  DateDomain(),
  CsDomain(),
  NavDomain(),
  JewelleryDomain(),
  ConstructionDomain(),
];
