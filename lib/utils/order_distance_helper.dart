import 'dart:math' as math;

double calculateDistanceKm(
  double startLat,
  double startLng,
  double endLat,
  double endLng,
) {
  const double earthRadiusKm = 6371;
  final double dLat = _degreesToRadians(endLat - startLat);
  final double dLng = _degreesToRadians(endLng - startLng);
  final double lat1 = _degreesToRadians(startLat);
  final double lat2 = _degreesToRadians(endLat);

  final double a =
      math.pow(math.sin(dLat / 2), 2).toDouble() +
      math.pow(math.sin(dLng / 2), 2).toDouble() *
          math.cos(lat1) *
          math.cos(lat2);
  final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusKm * c;
}

double _degreesToRadians(double degree) => degree * (math.pi / 180);
