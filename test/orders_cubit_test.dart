import 'package:alkhafajdashboard/utils/order_distance_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('distance helper prefers nearby coordinates', () {
    final double nearDistance = calculateDistanceKm(
      33.301,
      44.361,
      33.300,
      44.360,
    );
    final double farDistance = calculateDistanceKm(
      33.301,
      44.361,
      33.315,
      44.400,
    );

    expect(nearDistance, lessThan(farDistance));
  });
}
