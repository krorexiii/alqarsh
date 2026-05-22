String normalizeDashboardEmail(String value) {
  final String trimmed = value.trim().toLowerCase();
  if (trimmed.contains('@')) {
    return trimmed;
  }
  return '$trimmed@k.com';
}

String normalizeDashboardUsername(String value) {
  return value.trim().toLowerCase();
}
