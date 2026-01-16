import '../domain/domain.dart';

/// Manages the list of available domains, filtering and ordering them.
class DomainRegistry {
  final List<Domain> _allDomains;
  final List<String> _enabledIds;
  late final List<String> _order;

  DomainRegistry({
    required List<Domain> allDomains,
    List<String>? enabledIds,
    List<String>? order,
  })  : _allDomains = allDomains,
        _enabledIds = enabledIds ?? allDomains.map((d) => d.id).toList() {
    _order = order ?? List.from(_enabledIds);
  }

  List<Domain> get activeDomains => _computeActive();

  Domain getDomainById(String id) {
    try {
      return _allDomains.firstWhere((d) => d.id == id);
    } catch (e) {
      throw Exception('Domain $id not found');
    }
  }

  Domain nextDomain(String currentId) {
    final active = activeDomains;
    final idx = active.indexWhere((d) => d.id == currentId);
    if (idx == -1) return active.first;
    return active[(idx + 1) % active.length];
  }

  Domain prevDomain(String currentId) {
    final active = activeDomains;
    final idx = active.indexWhere((d) => d.id == currentId);
    if (idx == -1) return active.first;
    return active[(idx - 1) % active.length];
  }

  List<Domain> _computeActive() {
    return _order
        .where((id) => _enabledIds.contains(id))
        .map((id) {
          try {
            return _allDomains.firstWhere((d) => d.id == id);
          } catch (e) {
            // Skip domains that don't exist in _allDomains
            return null;
          }
        })
        .whereType<Domain>()
        .toList();
  }

  void setEnabled(String domainId, bool enabled) {
    if (enabled) {
      if (!_enabledIds.contains(domainId)) {
        _enabledIds.add(domainId);
      }
    } else {
      _enabledIds.remove(domainId);
    }
  }

  /// Reorder domains (user drag/drop).
  void reorder(List<String> newOrder) => _order = newOrder;
}