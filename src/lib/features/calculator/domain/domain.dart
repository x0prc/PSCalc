import '../../../core/engine/rpn_engine.dart';

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