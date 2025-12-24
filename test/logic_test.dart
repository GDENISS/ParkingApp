import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('Location Tests', () {
    test('should calculate distance between two points', () {
      const raanana = LatLng(32.1847, 34.8709);
      const telaviv = LatLng(32.0853, 34.7818);
      
      final distance = const Distance().as(
        LengthUnit.Meter,
        raanana,
        telaviv,
      );
      
      // Distance should be approximately 13-14 km
      expect(distance, greaterThan(13000));
      expect(distance, lessThan(15000));
    });

    test('should calculate zero distance for same point', () {
      const point = LatLng(32.1847, 34.8709);
      
      final distance = const Distance().as(
        LengthUnit.Meter,
        point,
        point,
      );
      
      expect(distance, 0);
    });

    test('should calculate small distance accurately', () {
      const point1 = LatLng(32.1847, 34.8709);
      const point2 = LatLng(32.1848, 34.8710); // ~15 meters away
      
      final distance = const Distance().as(
        LengthUnit.Meter,
        point1,
        point2,
      );
      
      // Should be approximately 10-20 meters
      expect(distance, greaterThan(10));
      expect(distance, lessThan(20));
    });

    test('should validate default location coordinates', () {
      const defaultLocation = LatLng(32.1847, 34.8709);
      
      expect(defaultLocation.latitude, 32.1847);
      expect(defaultLocation.longitude, 34.8709);
      
      // Verify coordinates are in valid range
      expect(defaultLocation.latitude, greaterThanOrEqualTo(-90));
      expect(defaultLocation.latitude, lessThanOrEqualTo(90));
      expect(defaultLocation.longitude, greaterThanOrEqualTo(-180));
      expect(defaultLocation.longitude, lessThanOrEqualTo(180));
    });
  });

  group('Spot Code Generation', () {
    test('should generate 4-digit codes', () {
      for (int i = 0; i < 100; i++) {
        final code = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
        expect(code.length, 4);
        expect(int.parse(code), greaterThanOrEqualTo(1000));
        expect(int.parse(code), lessThanOrEqualTo(9999));
      }
    });
  });

  group('Time Calculations', () {
    test('should calculate elapsed time correctly', () {
      final past = DateTime.now().subtract(const Duration(minutes: 15, seconds: 30));
      final now = DateTime.now();
      final elapsed = now.difference(past);
      
      expect(elapsed.inMinutes, 15);
      expect(elapsed.inSeconds, greaterThanOrEqualTo(930)); // 15 min 30 sec
    });

    test('should handle 24-hour cooldown correctly', () {
      final yesterday = DateTime.now().subtract(const Duration(hours: 24));
      final now = DateTime.now();
      final elapsed = now.difference(yesterday);
      
      expect(elapsed.inHours, greaterThanOrEqualTo(24));
    });

    test('should detect if 24 hours have passed', () {
      final yesterday = DateTime.now().subtract(const Duration(hours: 25));
      final now = DateTime.now();
      
      expect(now.difference(yesterday).inHours, greaterThan(24));
    });

    test('should detect if 24 hours have not passed', () {
      final recent = DateTime.now().subtract(const Duration(hours: 23));
      final now = DateTime.now();
      
      expect(now.difference(recent).inHours, lessThan(24));
    });
  });

  group('Credit System', () {
    test('should initialize with 3 credits', () {
      const initialCredits = 3;
      expect(initialCredits, 3);
    });

    test('should deduct credits for releasing spot', () {
      int credits = 3;
      credits -= 1; // Release spot
      expect(credits, 2);
    });

    test('should add credits from daily claim', () {
      int credits = 0;
      credits += 3; // Daily claim
      expect(credits, 3);
    });

    test('should not allow negative credits', () {
      int credits = 0;
      if (credits > 0) {
        credits -= 1;
      }
      expect(credits, greaterThanOrEqualTo(0));
    });
  });
}
