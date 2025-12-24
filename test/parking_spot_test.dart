import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:zorem/main.dart';

void main() {
  group('ParkingSpot', () {
    test('should create a parking spot with default values', () {
      final spot = ParkingSpot(
        position: const LatLng(32.1847, 34.8709),
        code: '1234',
      );

      expect(spot.position.latitude, 32.1847);
      expect(spot.position.longitude, 34.8709);
      expect(spot.code, '1234');
      expect(spot.isReserved, false);
      expect(spot.status, 'available');
      expect(spot.carModel, '');
      expect(spot.licensePlate, '');
    });

    test('should create a parking spot with custom values', () {
      final now = DateTime.now();
      final spot = ParkingSpot(
        position: const LatLng(32.1847, 34.8709),
        code: '5678',
        isReserved: true,
        carModel: 'Tesla Model 3',
        licensePlate: 'ABC123',
        status: 'reserved',
        ownerUsername: 'testuser',
        createdAt: now,
        driverLat: 32.1850,
        driverLng: 34.8710,
      );

      expect(spot.isReserved, true);
      expect(spot.carModel, 'Tesla Model 3');
      expect(spot.licensePlate, 'ABC123');
      expect(spot.status, 'reserved');
      expect(spot.ownerUsername, 'testuser');
      expect(spot.createdAt, now);
      expect(spot.driverLat, 32.1850);
      expect(spot.driverLng, 34.8710);
    });

    test('should convert to JSON correctly', () {
      final now = DateTime.now();
      final spot = ParkingSpot(
        position: const LatLng(32.1847, 34.8709),
        code: '1234',
        isReserved: true,
        carModel: 'Toyota',
        licensePlate: 'XYZ789',
        status: 'pending',
        ownerUsername: 'john',
        createdAt: now,
        driverLat: 32.1850,
        driverLng: 34.8710,
      );

      final json = spot.toJson();

      expect(json['lat'], 32.1847);
      expect(json['lng'], 34.8709);
      expect(json['code'], '1234');
      expect(json['isReserved'], true);
      expect(json['carModel'], 'Toyota');
      expect(json['licensePlate'], 'XYZ789');
      expect(json['status'], 'pending');
      expect(json['ownerUsername'], 'john');
      expect(json['createdAt'], now.toIso8601String());
      expect(json['driverLat'], 32.1850);
      expect(json['driverLng'], 34.8710);
    });

    test('should create from JSON correctly', () {
      final now = DateTime.now();
      final json = {
        'lat': 32.1847,
        'lng': 34.8709,
        'code': '1234',
        'isReserved': true,
        'carModel': 'Honda',
        'licensePlate': 'DEF456',
        'status': 'reserved',
        'ownerUsername': 'alice',
        'createdAt': now.toIso8601String(),
        'driverLat': 32.1850,
        'driverLng': 34.8710,
      };

      final spot = ParkingSpot.fromJson(json);

      expect(spot.position.latitude, 32.1847);
      expect(spot.position.longitude, 34.8709);
      expect(spot.code, '1234');
      expect(spot.isReserved, true);
      expect(spot.carModel, 'Honda');
      expect(spot.licensePlate, 'DEF456');
      expect(spot.status, 'reserved');
      expect(spot.ownerUsername, 'alice');
      expect(spot.createdAt?.toIso8601String(), now.toIso8601String());
      expect(spot.driverLat, 32.1850);
      expect(spot.driverLng, 34.8710);
    });

    test('should handle null values in JSON', () {
      final json = {
        'lat': 32.1847,
        'lng': 34.8709,
        'code': '1234',
        'isReserved': false,
      };

      final spot = ParkingSpot.fromJson(json);

      expect(spot.carModel, '');
      expect(spot.licensePlate, '');
      expect(spot.status, 'available');
      expect(spot.ownerUsername, '');
      expect(spot.createdAt, null);
      expect(spot.driverLat, null);
      expect(spot.driverLng, null);
    });
  });
}
