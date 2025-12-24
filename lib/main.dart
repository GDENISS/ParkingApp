import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🗺️ Map imports
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// 🔥 Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // ✅ généré par flutterfire configure

// 🔔 Notifications locales
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // ✅ clé du correctif
  );

  // 🔔 Initialisation des notifications locales
  const AndroidInitializationSettings initSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
      InitializationSettings(android: initSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  runApp(
      const MaterialApp(debugShowCheckedModeBanner: false, home: SplashPage()));
}

// -------------------------------------------------------------
// PAGE D'ACCUEIL / SPLASH
// -------------------------------------------------------------
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double _carPosition = -100;
  bool _animationDone = false;

  @override
  void initState() {
    super.initState();
    _checkLogin();
    Future.delayed(const Duration(milliseconds: 400), _startAnimation);
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    if (username != null && mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const ZoremApp()));
    }
  }

  Future<void> _startAnimation() async {
    for (int i = -100; i <= 300; i += 5) {
      await Future.delayed(const Duration(milliseconds: 20));
      if (!mounted) return;
      setState(() => _carPosition = i.toDouble());
    }
    setState(() => _animationDone = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text("Zorem App",
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue)),
            const SizedBox(width: 10),
            ClipOval(
              child: Image.asset('assets/logo_zorem.png',
                  height: 50, width: 50, fit: BoxFit.cover),
            ),
          ]),
          const SizedBox(height: 60),
          Stack(children: [
            SizedBox(height: 40, width: 200),
            Positioned(
                left: _carPosition,
                child: const Icon(Icons.directions_car,
                    size: 40, color: Colors.blueAccent)),
          ]),
          const SizedBox(height: 80),
          if (_animationDone)
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginPage()));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12)),
              child: const Text("Login",
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
        ]),
      ),
    );
  }
}

// -------------------------------------------------------------
// PAGE DE CONNEXION
// -------------------------------------------------------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _car = TextEditingController();
  final _plate = TextEditingController();

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final username = _username.text.trim();

    // 🔍 Vérifier si le pseudo existe déjà sur Firestore
    final check = await FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .get();

    if (check.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This username is already taken.")),
      );
      return; // ❌ stop ici
    }

    // ✔ Le pseudo est disponible → on enregistre
    await prefs.setString('username', username);
    await prefs.setString('carModel', _car.text.trim());
    await prefs.setString('licensePlate', _plate.text.trim());

    // Update Firestore user
    await FirebaseFirestore.instance.collection('users').doc(username).set({
      'username': username,
      'credits': 3,
      'lastDailyClaim': FieldValue.serverTimestamp(),
      'carModel': _car.text.trim(),
      'licensePlate': _plate.text.trim(),
    });

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ZoremApp()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(children: [
          const SizedBox(height: 20),
          TextField(
            controller: _username,
            decoration: const InputDecoration(
              labelText: "Username",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Password",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _car,
            decoration: const InputDecoration(
              labelText: "Vehicle model",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _plate,
            decoration: const InputDecoration(
              labelText: "License plate",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _saveProfile,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text("Confirm",
                style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ]),
      ),
    );
  }
}

// -------------------------------------------------------------
// APPLICATION PRINCIPALE ZOREM
// -------------------------------------------------------------
class ZoremApp extends StatefulWidget {
  const ZoremApp({super.key});
  @override
  State<ZoremApp> createState() => _ZoremAppState();
}

class _ZoremAppState extends State<ZoremApp> {
  int _selectedIndex = 1;
  final _pages = const [
    UserProfilePage(),
    ParkingHomePage(),
    CreditShopPage(),
  ];

  void _onItemTapped(int index) {
    if (index != 1) {
      // On quitte la map → on arrête l'auto-follow
      final state = context.findAncestorStateOfType<_ParkingHomePageState>();
      state?._autoFollowUser = false;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.lightBlue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(
              icon: Icon(Icons.credit_card), label: 'Credits'),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// PAGE PROFIL UTILISATEUR
// -------------------------------------------------------------
class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});
  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _car = TextEditingController();
  final _plate = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username.text = prefs.getString('username') ?? '';
      _password.text = prefs.getString('password') ?? '';
      _car.text = prefs.getString('carModel') ?? '';
      _plate.text = prefs.getString('licensePlate') ?? '';
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _username.text);
    await prefs.setString('password', _password.text);
    await prefs.setString('carModel', _car.text);
    await prefs.setString('licensePlate', _plate.text);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Profile saved.")));
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SplashPage()),
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: "Logout"),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(children: [
          TextField(
              controller: _username,
              decoration: const InputDecoration(labelText: "Username")),
          TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password")),
          TextField(
              controller: _car,
              decoration: const InputDecoration(labelText: "Vehicle model")),
          TextField(
              controller: _plate,
              decoration: const InputDecoration(labelText: "License plate")),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
            child: const Text("Save"),
          ),
        ]),
      ),
    );
  }
}

// 🟢 AJOUT : fonction pour afficher “Released : X min ago”
String timeAgo(DateTime createdAt) {
  final diff = DateTime.now().difference(createdAt);
  if (diff.inMinutes < 1) return "just now";
  if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
  return "${diff.inHours}h ${diff.inMinutes % 60}min ago";
}

// 🟢 AJOUT : Widget LiveTimer pour afficher un vrai timer mm:ss
class LiveTimer extends StatefulWidget {
  final DateTime createdAt;

  const LiveTimer({super.key, required this.createdAt});

  @override
  State<LiveTimer> createState() => _LiveTimerState();
}

class _LiveTimerState extends State<LiveTimer> {
  late Timer _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _elapsed = DateTime.now().difference(widget.createdAt);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed = _elapsed + const Duration(seconds: 1);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String two(int n) => n.toString().padLeft(2, '0');

    final minutes = two(_elapsed.inMinutes.remainder(60));
    final seconds = two(_elapsed.inSeconds.remainder(60));

    return Text(
      "Released : $minutes:$seconds",
      style: const TextStyle(fontSize: 14, color: Colors.orange),
    );
  }
}

// -------------------------------------------------------------
// PAGE CARTE PRINCIPALE
// -------------------------------------------------------------
class ParkingHomePage extends StatefulWidget {
  const ParkingHomePage({super.key});
  @override
  State<ParkingHomePage> createState() => _ParkingHomePageState();
}

class ParkingSpot {
  final LatLng position;
  final String code;
  bool isReserved;
  String carModel;
  String licensePlate;
  DateTime? createdAt; // 🟢 NOUVEAU
  String status; // ✅ nouveau champ
  String ownerUsername; // ⭐ AJOUT

  double? driverLat; // ⭐ ajouté
  double? driverLng; // ⭐ ajouté

  ParkingSpot({
    required this.position,
    required this.code,
    this.isReserved = false,
    this.carModel = '',
    this.licensePlate = '',
    this.createdAt, // 🟢 OBLIGATOIRE
    this.status = 'available',
    this.ownerUsername = '', // ⭐ AJOUT
    this.driverLat, // ⭐ ajouté
    this.driverLng, // ⭐ ajouté
  });

  Map<String, dynamic> toJson() => {
        'lat': position.latitude,
        'lng': position.longitude,
        'code': code,
        'createdAt': createdAt?.toIso8601String(), // 🟢 NOUVEAU
        'isReserved': isReserved,
        'carModel': carModel,
        'licensePlate': licensePlate,
        'status': status,
        'ownerUsername': ownerUsername, // ⭐ CORRECTION
        'driverLat': driverLat, // ⭐ ajouté
        'driverLng': driverLng, // ⭐ ajouté
      };

  static ParkingSpot fromJson(Map<String, dynamic> json) => ParkingSpot(
        position: LatLng(json['lat'], json['lng']),
        code: json['code'],
        isReserved: json['isReserved'],
        carModel: json['carModel'] ?? '',
        licensePlate: json['licensePlate'] ?? '',
        status: json['status'] ?? 'available',
        ownerUsername: json['ownerUsername'] ?? '', // ⭐ CORRECTION
        driverLat: json['driverLat'], // ⭐ ajouté
        driverLng: json['driverLng'], // ⭐ ajouté
        createdAt: json['createdAt'] != null // 🟢 AJOUT ICI
            ? DateTime.parse(json['createdAt'])
            : null,
      );
}

class _ParkingHomePageState extends State<ParkingHomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  String? _currentReservedCode; // ✔️ maintenant au bon endroit
  bool _autoFollowUser = true; // 🔥 ajout
  
  // 🗺️ flutter_map controller
  final MapController _mapController = MapController();
  
  LatLng? _currentLocation = const LatLng(32.1847, 34.8709); // Default to Ra'anana, Israel
  List<ParkingSpot> _spots = [];
  int _credits = 3;
  LatLng? _tempSpotPosition;
  String? _generatedCode;
  bool _movingMarkerMode = false;

  Future<void> _addSpotToFirestore(ParkingSpot spot) async {
    final prefs = await SharedPreferences.getInstance();
    final carModel = prefs.getString('carModel') ?? '';
    final licensePlate = prefs.getString('licensePlate') ?? '';
    final username = prefs.getString('username') ?? '';

    await FirebaseFirestore.instance
        .collection('spots')
        .doc(spot.code) // 🔥 ID unique = code
        .set({
      'lat': spot.position.latitude,
      'lng': spot.position.longitude,
      'createdAt': FieldValue.serverTimestamp(), // 🟢 AJOUT
      'code': spot.code,
      'isReserved': spot.isReserved,
      'carModel': carModel,
      'licensePlate': licensePlate,
      'status': spot.status,
      'ownerUsername': username,
    });

    // 🔔 Notification locale quand une place est ajoutée
    if (_currentLocation != null) {
      final distance = const Distance().as(
        LengthUnit.Meter,
        _currentLocation!,
        spot.position,
      );
      if (distance <= 200) {
        await _showLocalNotification(
          "New spot available 🚗",
          "A spot has just been freed ${distance.toStringAsFixed(0)} m from you.",
        );
      }
    }
  }

  Future<void> _loadSpotsFromFirestore() async {
    FirebaseFirestore.instance
        .collection('spots')
        .snapshots()
        .listen((snapshot) {
      final List<ParkingSpot> spots = snapshot.docs.map((doc) {
        final data = doc.data();
        return ParkingSpot(
          position: LatLng(data['lat'], data['lng']),
          code: data['code'],
          isReserved: data['isReserved'] ?? false,
          carModel: data['carModel'] ?? '',
          licensePlate: data['licensePlate'] ?? '',
          status: data['status'] ?? 'available',
          ownerUsername: data['ownerUsername'] ?? '',
          driverLat: data['driverLat'],
          driverLng: data['driverLng'],
          createdAt: (data['createdAt'] as Timestamp?)?.toDate(), // 🟢 AJOUT
        );
      }).toList();

      _spots = spots;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });

      _saveSpots(); // ⭐ AJOUT INDISPENSABLE

// ⭐⭐⭐ NOTIFICATION : LE CONDUCTEUR EST ARRIVÉ (<15 m)
      for (final s in spots) {
        if (s.driverLat != null &&
            s.driverLng != null &&
            s.status == 'reserved') {
          final dist = const Distance().as(
            LengthUnit.Meter,
            LatLng(s.driverLat!, s.driverLng!),
            s.position,
          );

          if (dist < 15) {
            _showLocalNotification(
              "Driver arrived 🚗",
              "The driver has reached your released spot.",
            );
          }
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initLocation();
    _loadCredits();
    _syncCreditsWithFirestore();
    _loadSpotsFromFirestore(); // ✅ Firestore d’abord →
    _startLiveLocationUpdates(); // ✅ suivi temps réel ajouté ici
    _startAutoCleanup(); // 🧹 suppression auto après 30 min
  }

  Future<void> _initLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition();
    final latLng = LatLng(pos.latitude, pos.longitude);

    if (!mounted) return;
    setState(() => _currentLocation = latLng);
  }

  // 🔄 Suivi en temps réel de la position utilisateur
  void _startLiveLocationUpdates() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });

        // Update map camera if auto-follow is enabled
        if (_autoFollowUser) {
          try {
            _mapController.move(_currentLocation!, 16.0);
          } catch (e) {
            // Map not ready yet
          }
        }
      }
    });
  }

  Future<void> _loadCredits() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _credits = prefs.getInt('credits') ?? 3);
  }

  Future<void> _saveCredits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('credits', _credits);
  }

  Future<void> _syncCreditsWithFirestore() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    if (username == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        setState(() => _credits = data['credits'] ?? 0);
      }
    });
  }

  Future<void> _updateCreditsInFirestore() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    if (username == null) return;

    await FirebaseFirestore.instance.collection('users').doc(username).set({
      'username': username,
      'credits': _credits,
    }, SetOptions(merge: true));
  }

// 🔔 Fonction de notification locale
  Future<void> _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'zorem_channel',
      'Notifications Zorem',
      channelDescription: 'Alerts for spots and messages',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notifDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notifDetails,
    );
  }

  Future<void> _saveSpots() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _spots.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('spots', data);
  }

  void _startAddSpot() {
    if (_currentLocation == null) return;
    final randomCode = (1000 + Random().nextInt(9000)).toString();
    setState(() {
      _tempSpotPosition = _currentLocation;
      _generatedCode = randomCode;
      _movingMarkerMode = true;
    });
  }

  Future<void> _confirmAddSpot() async {
    if (_tempSpotPosition == null || _generatedCode == null) return;

    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';

    final spot = ParkingSpot(
      position: _tempSpotPosition!,
      code: _generatedCode!,
      status: 'pending',
      ownerUsername: username, // 🔥 OBLIGATOIRE
    );
    spot.status = 'pending'; // ✅ placé après la création

    setState(() {
      _spots.add(spot);
      _movingMarkerMode = false;
      _tempSpotPosition = null; // 🔥 retire le curseur rouge
    });

    _addSpotToFirestore(spot);
    _saveSpots();
  }

  // 🔥🔥🔥 NOUVELLE FONCTION AJOUTÉE ICI
  void _cancelPendingSpot() async {
    // Trouver la place "pending"
    ParkingSpot? pending;
    try {
      pending = _spots.firstWhere((s) => s.status == 'pending');
    } catch (_) {
      pending = null;
    }

    if (pending == null) return;

    // 👉 Suppression Firestore correcte (UN SEUL document)
    await FirebaseFirestore.instance
        .collection('spots')
        .doc(pending.code) // 🔥 le code = ID du document
        .delete();

    // 👉 Suppression locale + reset
    setState(() {
      _spots.removeWhere((s) => s.code == pending!.code);
      _movingMarkerMode = false;
      _tempSpotPosition = null;
    });

    _saveSpots();
  }

// -------------------------------------------------------------
// Lorsqu'on sélectionne une place sur la carte
// -------------------------------------------------------------
  void _onSelectSpot(ParkingSpot spot) async {
    if (spot.isReserved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("This spot is already reserved."),
        ),
      );
      return;
    }

    // 🔥 Empêche A de réserver sa propre place
    final prefs = await SharedPreferences.getInstance();
    final currentUsername = prefs.getString('username') ?? '';

    if (spot.ownerUsername == currentUsername) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You cannot reserve your own spot."),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reserve this spot ?"),
        content: Text("Associated code : ${spot.code}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmReservation(spot);
            },
            child: const Text("Confirm"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

// -------------------------------------------------------------
// CONFIRMER LA RÉSERVATION D'UNE PLACE
// -------------------------------------------------------------
  Future<void> _confirmReservation(ParkingSpot spot) async {
    if (_credits <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Not enough credits to reserve a spot."),
        ),
      );
      return;
    }

    // Vérifie si la place est déjà réservée sur Firestore
    final query = await FirebaseFirestore.instance
        .collection('spots')
        .where('code', isEqualTo: spot.code)
        .get();

    if (query.docs.isNotEmpty) {
      final data = query.docs.first.data();
      if (data['isReserved'] == true || data['status'] == 'reserved') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("This spot has just been reserved by another user."),
          ),
        );
        return;
      }
    }

    // Réservation locale + synchro Firestore
    setState(() {
      spot.status = 'reserved';
      spot.isReserved = true; // ⭐ OBLIGATOIRE POUR AFFICHE DRIVER + VALIDATION
      _credits--; // B paie 1 crédit
    });

// 🔥 envoyer la position immédiatement pour que A voie le driver tout de suite
    if (_currentLocation != null) {
      FirebaseFirestore.instance.collection('spots').doc(spot.code).update({
        'driverLat': _currentLocation!.latitude,
        'driverLng': _currentLocation!.longitude,
      });
    }

    // ⭐ DÉMARRER LE TRACKING DE B
    _startSendingDriverLocation(spot);

    // ⭐ Sauvegarde du code pour l’afficher dans la barre du haut
    setState(() => _currentReservedCode = spot.code);

// 🔥 Met à jour Firestore + message automatique
    for (var doc in query.docs) {
      await doc.reference.update({
        'isReserved': true,
        'status': 'reserved',
      });

      FirebaseFirestore.instance
          .collection('chats')
          .doc(spot.code)
          .collection('messages')
          .add({
        'sender': 'System',
        'text':
            '💬 Spot reserved: please confirm your arrival or report any issue.',
        'time': FieldValue.serverTimestamp(),
      });
    }

// ⭐ IMPORTANT : afficher le code uniquement au réservant (B)
    final prefs2 = await SharedPreferences.getInstance();
    final usernameUser = prefs2.getString('username') ?? '';

    final ownerUsername = query.docs.first.data()['ownerUsername'];

// ❌ A NE VOIT PAS LE CODE
    if (usernameUser == ownerUsername) {
      // On ne montre rien → A ne doit pas voir le code
    } else {
      // ✔ B voit le code
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Validation code"),
          content: Text("Your code is : ${spot.code}"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }

    await _saveCredits();
    await _updateCreditsInFirestore();
    await _saveSpots();

    // Notifications locales
    await _showLocalNotification(
      "Reservation confirmed ✅",
      "You have reserved a spot. 1 credit used.",
    );

    await _showLocalNotification(
      "Your spot has been taken 🚗",
      "A driver has reserved the spot you released.",
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Spot successfully reserved! 1 credit used.")),
    );
  }

  // ⭐⭐ NOUVELLE FONCTION — TRACKING DU CONDUCTEUR B ⭐⭐
  void _startSendingDriverLocation(ParkingSpot spot) {
    // ✔ Si on est sur Windows → on simule la position
    if (Theme.of(context).platform == TargetPlatform.windows) {
      // 🔥 première update immédiate
      void send() async {
        final target = spot.position;
        final lat = target.latitude + (Random().nextDouble() - 0.5) / 5000;
        final lng = target.longitude + (Random().nextDouble() - 0.5) / 5000;

        final snap = await FirebaseFirestore.instance
            .collection('spots')
            .where('code', isEqualTo: spot.code)
            .get();

        for (var doc in snap.docs) {
          await doc.reference.update({
            'driverLat': lat,
            'driverLng': lng,
          });
        }
      }

      // 🔥 envoi immédiat
      send();

      // 🔄 puis toutes les 2 secondes
      Timer.periodic(const Duration(seconds: 2), (_) => send());

      return;
    }

    // ✔ Version réelle (Android / iPhone)
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 7,
      ),
    ).listen((pos) {
      FirebaseFirestore.instance
          .collection('spots')
          .where('code', isEqualTo: spot.code)
          .get()
          .then((snap) {
        for (var doc in snap.docs) {
          doc.reference.update({
            'driverLat': pos.latitude,
            'driverLng': pos.longitude,
          });
        }
      });
    });
  }

  void _validateSpecificSpot(ParkingSpot spot) async {
    final codeInput = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Validate the driver"),
        content: TextField(
          controller: codeInput,
          decoration:
              const InputDecoration(hintText: "Enter the received code"),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final enteredCode = codeInput.text.trim();

              // ❌ mauvais code = on ferme juste
              if (enteredCode != spot.code) {
                Navigator.of(context).pop();
                return;
              }

              final prefs = await SharedPreferences.getInstance();
              final currentUsername = prefs.getString('username') ?? '';

              // récupération firestore
              final query = await FirebaseFirestore.instance
                  .collection('spots')
                  .where('code', isEqualTo: spot.code)
                  .get();

              if (query.docs.isEmpty) {
                Navigator.of(context).pop();
                return;
              }

              final ownerUsername = query.docs.first.data()['ownerUsername'];

// ❌ not the owner
              if (currentUsername != ownerUsername) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Only the user who released the spot can validate.",
                    ),
                  ),
                );
                Navigator.of(context).pop();
                return;
              }

              // ✔ validation
              setState(() {
                _spots.remove(spot);
                _credits++;
                _currentReservedCode =
                    null; // 🔥 suppression du code affiché pour B
              });

              // ⭐⭐⭐ suppression de la position du conducteur
              for (var d in query.docs) {
                await d.reference.update({
                  'driverLat': FieldValue.delete(),
                  'driverLng': FieldValue.delete(),
                });
              }

// ⭐⭐⭐ suppression du spot dans Firestore
              for (var d in query.docs) {
                await d.reference.delete();
              }

              await _saveCredits();
              await _updateCreditsInFirestore();
              await _saveSpots();

// ✔ fermeture UNIQUE
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
            },
            child: const Text("Confirm"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void _startAutoCleanup() {
    Timer.periodic(const Duration(minutes: 1), (timer) async {
      final now = DateTime.now();
      final snapshot =
          await FirebaseFirestore.instance.collection('spots').get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        final status = data['status'] ?? 'available';

        if (createdAt == null) continue;

        final diff = now.difference(createdAt).inMinutes;

        // 🔥 NOUVELLE LOGIQUE
        if (status == 'available' || status == 'pending') {
          // ✨ place libre ou en attente → supprimée après 5 min
          if (diff >= 5) await doc.reference.delete();
        } else if (status == 'reserved') {
          // ✨ place réservée → supprimée après 10 min
          if (diff >= 10) await doc.reference.delete();
        }
      }
    });
  }

  // 🎯 CENTER ON USER BUTTON
  void _centerOnUser() {
    if (_currentLocation == null) return;
    _autoFollowUser = true;
    _mapController.move(_currentLocation!, 16.0);
  }

  void _showSpotDetailsDialog(ParkingSpot spot) {
    // Reuse your existing dialog code for showing spot details
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) => _buildSpotDialog(spot),
    );
  }

  Widget _buildSpotDialog(ParkingSpot s) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        "P",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    s.carModel.isNotEmpty ? s.carModel : 'Unknown vehicle',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                s.licensePlate.isNotEmpty
                    ? "Plate : ${s.licensePlate}"
                    : "Plate unavailable",
                style: const TextStyle(fontSize: 14),
              ),
              if (_currentLocation != null)
                Text(
                  "Distance : ${const Distance().as(LengthUnit.Meter, _currentLocation!, s.position).toStringAsFixed(0)} m",
                  style: const TextStyle(fontSize: 14),
                ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _onSelectSpot(s);
                },
                child: const Text("Head to this spot"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/logo_zorem.png',
                height: 36,
                width: 36,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),

            // 🔵 Titre ZOREM
            const Text(
              'ZOREM',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.white,
              ),
            ),

            // 🔵🔵 AJOUT DU PETIT BOUTON (i) ICI — SANS TOUCHER LE RESTE
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("💡 Welcome to Zorem!"),
                    content: const Text(
                        "Zorem shows, in real time, the parking spots that have just been freed around you. "
                        "Blue P markers indicate available spots, while purple P markers show that another "
                        "driver is already heading toward that location.\n\n"
                        "To indicate that you are going toward a spot, you must first tap 'Head to this spot'. "
                        "This lets other users know that someone is already on the way and prevents multiple "
                        "drivers from going to the same place. Once you tap it, you receive a unique validation "
                        "code that you must give to the person who is leaving the spot.\n\n"
                        "When the correct code is entered by the person who released the spot, they receive "
                        "1 credit and your arrival is confirmed.\n\n"
                        "A 'Directions' button is also available to instantly open the fastest navigation route "
                        "to the selected parking spot.\n\n"
                        "Zorem also includes real-time tracking: you can see the approaching driver on the map "
                        "and the exact distance in meters.\n\n"
                        "A built-in chat feature allows both drivers—the one leaving the spot and the one heading "
                        "toward it—to exchange messages, for example to confirm arrival or report any situation."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 🔵🔵 FIN DE L'AJOUT

            const Spacer(),

            Row(
              children: [
                const Text('💰 ', style: TextStyle(fontSize: 18)),
                Text(
                  'Credits : $_credits',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                // 👉 NOUVEAU : bouton recentrer
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.my_location, color: Colors.white),
                  onPressed: _centerOnUser,
                ),
              ],
            ),
          ],
        ),
        actions: const [],
      ),
      body: _currentLocation == null
    ? const Center(child: CircularProgressIndicator())
    : Stack(
        children: [
          // 🗺️ MAP (works on all platforms)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
              initialZoom: 15,
              onPointerDown: (_, __) {
                _autoFollowUser = false;
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://api.mapbox.com/styles/v1/dgmasterpiece/cmjkaf5uz00al01qv5ik30fbu/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiZGdtYXN0ZXJwaWVjZSIsImEiOiJjbTQzbGVoYW4wZWJhMmtzN3h6cDl6Y2N6In0.GNWxZgSeh_Yjym_K0Rpgtg',
                subdomains: const [],
                tileSize: 512,
                zoomOffset: -1,
              ),
              MarkerLayer(
                markers: [
                  // Current location marker
                  Marker(
                    point: LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
                    width: 46,
                    height: 46,
                    child: const PulsingLocationIcon(),
                  ),
                  // Spot markers
                  ..._spots.map((s) => Marker(
                    point: LatLng(s.position.latitude, s.position.longitude),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showSpotDetailsDialog(s),
                      child: Image.asset(
                        s.status == 'reserved'
                            ? "assets/icons/p_pink.png"
                            : "assets/icons/p_blue.png",
                        width: 40,
                        height: 40,
                      ),
                    ),
                  )),
                  // Driver markers
                  ..._spots.where((p) => p.driverLat != null && p.driverLng != null).map(
                    (p) => Marker(
                      point: LatLng(p.driverLat!, p.driverLng!),
                      width: 50,
                      height: 50,
                      child: Image.asset("assets/driver_green.png", width: 40, height: 40),
                    ),
                  ),
                  // Temp spot marker if in moving mode
                  if (_tempSpotPosition != null)
                    Marker(
                      point: _tempSpotPosition!,
                      width: 60,
                      height: 60,
                      child: Image.asset("assets/marker.png", width: 60, height: 60),
                    ),
                ],
              ),
            ],
          ),
                    // ⭐⭐⭐ AJOUT : BLOC CODE + DRIVER EN BAS À GAUCHE ⭐⭐⭐
                // ⭐⭐⭐ AFFICHE LA BARRE UNIQUEMENT SI L’UTILISATEUR EST AFFECTÉ PAR UNE PLACE RÉSERVÉE
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: FutureBuilder(
                    future: SharedPreferences.getInstance(),
                    builder: (_, snap) {
                      if (!snap.hasData) return const SizedBox();

                      final currentUsername =
                          snap.data!.getString('username') ?? '';

                      // On cherche la place liée au user (A ou B)
                      final spot = _spots.firstWhere(
                        (s) {
                          final isOwner = (s.ownerUsername == currentUsername);
                          final isReservant = (_currentReservedCode != null &&
                              s.code == _currentReservedCode);

                          return
                              // ⭐ A voit la place tant qu’elle est en pending (bouton Cancel)
                              (s.status == 'pending' && isOwner) ||

                                  // ⭐ RESERVED → A et B peuvent voir :
                                  // - A : validate + distance driver
                                  // - B : code affiché
                                  (s.status == 'reserved' &&
                                      (isOwner || isReservant));
                        },
                        orElse: () => ParkingSpot(
                          position: const LatLng(0, 0),
                          code: "0",
                        ),
                      );
                      // Si aucun spot n’est trouvé → ne rien afficher
                      if (spot.code == "0") return const SizedBox();

                      final bool isOwner =
                          (spot.ownerUsername == currentUsername);
                      final bool hasDriverPos =
                          (spot.driverLat != null && spot.driverLng != null);

                      final widgets = <Widget>[];

                      // 👉 B (le réservant) voit le code
                      if (!isOwner) {
                        widgets.add(
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Code : ${spot.code}",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                          ),
                        );
                      }

                      // 👉 A (le propriétaire) voit le driver + bouton de validation
                      if (isOwner && hasDriverPos) {
                        final dist = const Distance()
                            .as(
                              LengthUnit.Meter,
                              LatLng(spot.driverLat!, spot.driverLng!),
                              spot.position,
                            )
                            .toStringAsFixed(0);

                        widgets.add(const SizedBox(height: 8));
                        widgets.add(
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Driver : $dist m",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                          ),
                        );

                        widgets.add(const SizedBox(height: 8));
                        widgets.add(
                          GestureDetector(
                            onTap: () => _validateSpecificSpot(spot),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "Validate the code",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widgets,
                      );
                    },
                  ),
                )
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 🔥 Bouton CANCEL visible UNIQUEMENT pour A (l’utilisateur qui a libéré)
          FutureBuilder(
            future: SharedPreferences.getInstance(),
            builder: (_, snap) {
              if (!snap.hasData) return const SizedBox();
              final prefsUser = snap.data!.getString('username') ?? '';

              final bool canCancel = _spots.any(
                (s) =>
                    s.status == 'pending' &&
                    s.ownerUsername == prefsUser, // ✔ seul A peut annuler
              );

              if (!canCancel) return const SizedBox();

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RoundLabelButton(
                  icon: Icons.close,
                  label: 'Cancel',
                  onPressed: _cancelPendingSpot,
                ),
              );
            },
          ),

          // 🔵 Bouton CONFIRM quand on place un marker
          if (_movingMarkerMode)
            RoundLabelButton(
              icon: Icons.check,
              label: 'Confirm',
              onPressed: _confirmAddSpot,
            )
          else
            GestureDetector(
              onTap: () => _startAddSpot(),
              child: Container(
                width:
                    85, // 🔥 Taille réduite (tu peux mettre 90 ou 100 selon ton goût)
                height: 85,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    "assets/release_button.png",
                    fit: BoxFit.cover, // 🔥 L'image prend 100% du cercle
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// PAGE DAILY CREDITS — VERSION FONCTIONNELLE AVEC TIMER LIVE
// -------------------------------------------------------------
class CreditShopPage extends StatefulWidget {
  const CreditShopPage({super.key});

  @override
  State<CreditShopPage> createState() => _CreditShopPageState();
}

class _CreditShopPageState extends State<CreditShopPage> {
  int _credits = 0;
  Timestamp? _lastClaim;
  Duration _timeLeft = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // ⭐ On attend que les données soient chargées AVANT de démarrer le timer
    Future.delayed(Duration.zero, () async {
      await _loadUserData();
      _calculateTimeLeft(); // 🔥 ajouté
      _startCountdownTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // timer des crédits
    super.dispose();
  }

  // -------------------------------------------------------------
  // 🔵 Charge Firestore puis local + initialise "lastClaim" si manquant
  // -------------------------------------------------------------
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    if (username == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .get();

    if (doc.exists) {
      _credits = doc.data()!.containsKey('credits')
          ? (doc['credits'] ?? prefs.getInt('credits') ?? 0)
          : (prefs.getInt('credits') ?? 0);

      final raw = doc['lastDailyClaim'];

      // 🔥 correction des différents formats possibles
      if (raw is Timestamp) {
        _lastClaim = raw;
      } else {
        _lastClaim = Timestamp.now();
      }

      await prefs.setInt('credits', _credits);
      await prefs.setString(
        'lastClaim',
        _lastClaim!.toDate().toIso8601String(),
      );
    } else {
      // 🔥 si pas sur Firestore → on lit la version locale
      _credits = prefs.getInt('credits') ?? 0;

      final local = prefs.getString('lastClaim');
      if (local != null) {
        _lastClaim = Timestamp.fromDate(DateTime.parse(local));
      }
    }

    // 🔥 on calcule puis on rafraîchit l'affichage
    _calculateTimeLeft();
    setState(() {});
  }

  // -------------------------------------------------------------
  // 🔵 Calcule la durée restante
  // -------------------------------------------------------------
  void _calculateTimeLeft() {
    if (_lastClaim == null) return;

    final now = Timestamp.now();
    final diff = now.toDate().difference(_lastClaim!.toDate());
    final remaining = const Duration(hours: 24) - diff;

    setState(() {
      _timeLeft = remaining.isNegative ? Duration.zero : remaining;
    });
  }

  // -------------------------------------------------------------
  // 🔵 CLAIM : récupère 3 crédits
  // -------------------------------------------------------------
  Future<void> _manualDailyClaim() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    if (username == null) return;

    final now = Timestamp.now();

    setState(() {
      _credits += 3;
      _lastClaim = now;
      _timeLeft = const Duration(hours: 24);
    });

    await FirebaseFirestore.instance.collection('users').doc(username).set({
      'credits': _credits,
      'lastDailyClaim': now,
      'username': username,
    }, SetOptions(merge: true));

    await prefs.setInt('credits', _credits);
    await prefs.setString(
      'lastClaim',
      now.toDate().toIso8601String(), // 🔥 AJOUT
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You received 3 credits 🎉")),
    );
  }

  // -------------------------------------------------------------
  // 🔵 Timer seconde par seconde
  // -------------------------------------------------------------
  void _startCountdownTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_lastClaim != null) {
        _calculateTimeLeft();
        setState(() {}); // 🔥 le timer met à jour l’UI
      }
    });
  }

  // -------------------------------------------------------------
  // 🔵 Format HH:MM:SS
  // -------------------------------------------------------------
  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final bool canClaim = _timeLeft == Duration.zero;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Credits"),
        backgroundColor: Colors.lightBlue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Your credits : $_credits",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),
            const Text("You receive 3 free credits every 24 hours.",
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 25),

            // TIMER
            Text(
              canClaim
                  ? "Credits available now 🎉"
                  : "Next credits in : ${_formatDuration(_timeLeft)}",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.blueGrey,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 35),

            // BOUTON CLAIM
            ElevatedButton(
              onPressed: canClaim ? _manualDailyClaim : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    canClaim ? Colors.lightBlue : Colors.grey.shade400,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                canClaim ? "Claim 3 credits" : "Please wait",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// BOUTON FLOTTANT
// -------------------------------------------------------------
class RoundLabelButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const RoundLabelButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 70,
          height: 70,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.lightBlue,
          ),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, color: Colors.white, size: 26),
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
            ]),
          ),
        ),
      ),
    ]);
  }
}

// -------------------------------------------------------------
// PAGE CHAT ENTRE UTILISATEURS
// -------------------------------------------------------------
class ChatPage extends StatefulWidget {
  final String spotCode;
  const ChatPage({super.key, required this.spotCode});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Stream<QuerySnapshot<Map<String, dynamic>>> _messageStream() {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.spotCode)
        .collection('messages')
        .orderBy('time', descending: false)
        .snapshots();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final sender = prefs.getString('username') ?? 'User';

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.spotCode)
        .collection('messages')
        .add({
      'sender': sender,
      'text': text,
      'time': FieldValue.serverTimestamp(),
    });

    _controller.clear();
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 80,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _messageStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].data();
                    final sender = msg['sender'] ?? 'Unknown';
                    final text = msg['text'] ?? '';

                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 10),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: sender == 'System'
                              ? Colors.orange.shade100
                              : Colors.lightBlue.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sender,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            Text(
                              text,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Write a message...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.lightBlue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ⭐⭐⭐ AJOUT : Widget pour l’icône de localisation avec pulse RAPIDE + icône plus petite
class PulsingLocationIcon extends StatefulWidget {
  const PulsingLocationIcon({super.key});

  @override
  State<PulsingLocationIcon> createState() => _PulsingLocationIconState();
}

class _PulsingLocationIconState extends State<PulsingLocationIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    // ⚡ Pulse RAPIDE (1 seconde)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    // 🌟 Amplitude réduite (moins agressif)
    _pulse = Tween<double>(begin: 0.95, end: 1.20).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulse,
      child: Image.asset(
        "assets/icons/my_location_icon.png",
        width: 34, // ⬅️ Icône plus petite (avant 46)
        height: 34,
      ),
    );
  }
}
