import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SharedPreferences Tests', () {
    setUp(() {
      // Initialize fake shared preferences
      SharedPreferences.setMockInitialValues({});
    });

    test('should save and retrieve username', () async {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('username', 'testuser');
      
      expect(prefs.getString('username'), 'testuser');
    });

    test('should save and retrieve credits', () async {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setInt('credits', 5);
      
      expect(prefs.getInt('credits'), 5);
    });

    test('should save and retrieve car details', () async {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('carModel', 'Tesla Model 3');
      await prefs.setString('licensePlate', 'ABC123');
      
      expect(prefs.getString('carModel'), 'Tesla Model 3');
      expect(prefs.getString('licensePlate'), 'ABC123');
    });

    test('should save and retrieve daily claim timestamp', () async {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      
      await prefs.setString('lastClaim', now.toIso8601String());
      
      final retrieved = prefs.getString('lastClaim');
      expect(retrieved, now.toIso8601String());
    });

    test('should return null for non-existent keys', () async {
      final prefs = await SharedPreferences.getInstance();
      
      expect(prefs.getString('nonexistent'), null);
      expect(prefs.getInt('nonexistent'), null);
    });

    test('should save and retrieve spot list', () async {
      final prefs = await SharedPreferences.getInstance();
      final spotList = ['spot1', 'spot2', 'spot3'];
      
      await prefs.setStringList('spots', spotList);
      
      expect(prefs.getStringList('spots'), spotList);
    });
  });
}
