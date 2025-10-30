import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
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
    final email = prefs.getString('email');
    if (email != null && mounted) {
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
            Container(height: 40, width: 200),
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
              child: const Text("Connexion",
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
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _car = TextEditingController();
  final _plate = TextEditingController();

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', _email.text.trim());
    await prefs.setString('password', _password.text.trim());
    await prefs.setString('carModel', _car.text.trim());
    await prefs.setString('licensePlate', _plate.text.trim());
    if (mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const ZoremApp()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Connexion"),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(children: [
          const SizedBox(height: 20),
          TextField(
            controller: _email,
            decoration: const InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Mot de passe",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _car,
            decoration: const InputDecoration(
              labelText: "Modèle du véhicule",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _plate,
            decoration: const InputDecoration(
              labelText: "Plaque d’immatriculation",
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
            child: const Text("Valider",
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

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.lightBlue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Carte'),
          BottomNavigationBarItem(
              icon: Icon(Icons.credit_card), label: 'Crédits'),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// PAGE PROFIL UTILISATEUR AVEC DÉCONNEXION
// -------------------------------------------------------------
class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});
  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _email = TextEditingController();
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
      _email.text = prefs.getString('email') ?? '';
      _password.text = prefs.getString('password') ?? '';
      _car.text = prefs.getString('carModel') ?? '';
      _plate.text = prefs.getString('licensePlate') ?? '';
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', _email.text);
    await prefs.setString('password', _password.text);
    await prefs.setString('carModel', _car.text);
    await prefs.setString('licensePlate', _plate.text);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Profil sauvegardé.")));
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
        title: const Text("Profil"),
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: "Déconnexion"),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(children: [
          TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: "Email")),
          TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Mot de passe")),
          TextField(
              controller: _car,
              decoration:
                  const InputDecoration(labelText: "Marque du véhicule")),
          TextField(
              controller: _plate,
              decoration:
                  const InputDecoration(labelText: "Plaque d’immatriculation")),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
            child: const Text("Enregistrer"),
          ),
        ]),
      ),
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
  ParkingSpot({
    required this.position,
    required this.code,
    this.isReserved = false,
  });

  Map<String, dynamic> toJson() => {
        'lat': position.latitude,
        'lng': position.longitude,
        'code': code,
        'isReserved': isReserved,
      };

  static ParkingSpot fromJson(Map<String, dynamic> json) => ParkingSpot(
        position: LatLng(json['lat'], json['lng']),
        code: json['code'],
        isReserved: json['isReserved'],
      );
}

class _ParkingHomePageState extends State<ParkingHomePage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  LatLng? _currentLocation;
  List<ParkingSpot> _spots = [];
  int _credits = 5;
  LatLng? _tempSpotPosition;
  String? _generatedCode;
  bool _showSidebar = false;
  bool _movingMarkerMode = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _loadCredits();
    _loadSpots();
  }

  Future<void> _initLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition();
    final latLng = LatLng(pos.latitude, pos.longitude);
    setState(() => _currentLocation = latLng);
    _mapController.move(latLng, 16);
  }

  Future<void> _loadCredits() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _credits = prefs.getInt('credits') ?? 5);
  }

  Future<void> _saveCredits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('credits', _credits);
  }

  Future<void> _loadSpots() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('spots') ?? [];
    setState(() {
      _spots = data.map((e) => ParkingSpot.fromJson(jsonDecode(e))).toList();
    });
  }

  Future<void> _saveSpots() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _spots.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('spots', data);
  }

  // ----------- RECHERCHE LIEU + DEBOUNCE ------------
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce =
        Timer(const Duration(milliseconds: 600), () => _searchLocation());
  }

  void _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    try {
      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final pos = LatLng(locations.first.latitude, locations.first.longitude);
        _mapController.move(pos, 16);
      }
    } catch (e) {}
  }

  // ----------- LIBÉRER PLACE ------------
  void _startAddSpot() {
    if (_currentLocation == null) return;
    final randomCode = (1000 + Random().nextInt(9000)).toString();
    setState(() {
      _tempSpotPosition = _currentLocation;
      _generatedCode = randomCode;
      _movingMarkerMode = true;
    });
  }

  void _confirmAddSpot() {
    if (_tempSpotPosition == null || _generatedCode == null) return;
    final spot =
        ParkingSpot(position: _tempSpotPosition!, code: _generatedCode!);
    setState(() {
      _spots.add(spot);
      _tempSpotPosition = null;
      _movingMarkerMode = false;
    });
    _saveSpots();
  }

  void _centerOnUser() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 16);
    }
  }

  // ----------- RÉSERVER PLACE ------------
  void _onSelectSpot(ParkingSpot spot) {
    if (spot.isReserved) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Réserver cette place ?"),
        content: Text("Code associé : ${spot.code}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmReservation(spot);
            },
            child: const Text("Confirmer"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
        ],
      ),
    );
  }

  void _confirmReservation(ParkingSpot spot) {
    setState(() {
      spot.isReserved = true;
    });
    _saveSpots();
  }

  // ----------- VALIDER CODE ------------
  void _validateDriver() {
    final codeInput = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Valider un conducteur"),
        content: TextField(
          controller: codeInput,
          decoration: const InputDecoration(hintText: "Entrer le code"),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () {
              final enteredCode = codeInput.text.trim();
              final match = _spots.where((s) => s.code == enteredCode).toList();
              if (match.isNotEmpty) {
                setState(() {
                  _spots.remove(match.first);
                  _credits++;
                });
                _saveCredits();
                _saveSpots();
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text("Valider"),
          ),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final available = _spots;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Row(
          children: [
            ClipOval(
                child: Image.asset('assets/logo_zorem.png',
                    height: 36, width: 36, fit: BoxFit.cover)),
            const SizedBox(width: 10),
            const Text('Zorem',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
            const Spacer(),
            Row(children: [
              const Text('💰 ', style: TextStyle(fontSize: 18)),
              Text('Crédits : $_credits',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ]),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.verified, color: Colors.white),
              onPressed: _validateDriver),
        ],
      ),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(children: [
              Row(children: [
                // ---------- SIDEBAR À GAUCHE ----------
                if (_showSidebar)
                  Container(
                    width: 260,
                    color: Colors.white,
                    child: ListView(
                      padding: const EdgeInsets.only(top: 70),
                      children: available.map((s) {
                        final distance = Distance()
                            .as(LengthUnit.Meter, _currentLocation!, s.position)
                            .toStringAsFixed(0);
                        return Card(
                          child: ListTile(
                            title: const Text("🚗 Place"),
                            subtitle: Text("📍 $distance m"),
                            onTap: () => _onSelectSpot(s),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                // ---------- CARTE ----------
                Expanded(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentLocation!,
                      initialZoom: 15,
                      onPositionChanged: (pos, _) {
                        if (_movingMarkerMode && pos.center != null) {
                          setState(() => _tempSpotPosition = pos.center);
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                          urlTemplate:
                              'https://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                          subdomains: const ['mt0', 'mt1', 'mt2', 'mt3']),
                      MarkerLayer(markers: [
                        Marker(
                            point: _currentLocation!,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.my_location,
                                size: 38, color: Colors.blueAccent)),
                        if (_tempSpotPosition != null)
                          Marker(
                              point: _tempSpotPosition!,
                              width: 50,
                              height: 50,
                              child: const Icon(Icons.location_on,
                                  color: Colors.red, size: 40)),
                        ..._spots.map((s) => Marker(
                              point: s.position,
                              width: 40,
                              height: 40,
                              child: GestureDetector(
                                  onTap: () => _onSelectSpot(s),
                                  child: Icon(Icons.local_parking,
                                      size: 30,
                                      color: s.isReserved
                                          ? Colors.pink
                                          : Colors.blue)),
                            )),
                      ]),
                    ],
                  ),
                ),
              ]),
              // ---------- BARRE DE RECHERCHE + GPS ----------
              if (!_showSidebar)
                Positioned(
                  top: 20,
                  left: 20,
                  right: 120,
                  child: Row(
                    children: [
                      Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(30),
                        child: IconButton(
                          icon: const Icon(Icons.gps_fixed, color: Colors.blue),
                          onPressed: _centerOnUser,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Material(
                          elevation: 6,
                          borderRadius: BorderRadius.circular(30),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'Rechercher un lieu...',
                              prefixIcon:
                                  const Icon(Icons.search, color: Colors.blue),
                              suffixIcon: IconButton(
                                  icon: const Icon(Icons.arrow_forward,
                                      color: Colors.blue),
                                  onPressed: _searchLocation),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
            ]),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_movingMarkerMode)
            RoundLabelButton(
                icon: Icons.check, label: 'Valider', onPressed: _confirmAddSpot)
          else
            RoundLabelButton(
                icon: Icons.add_location_alt,
                label: 'Libérer',
                onPressed: _startAddSpot),
          const SizedBox(height: 12),
          RoundLabelButton(
            icon: _showSidebar ? Icons.close : Icons.search,
            label: _showSidebar ? 'Fermer' : 'Places',
            onPressed: () => setState(() => _showSidebar = !_showSidebar),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// PAGE CRÉDITS
// -------------------------------------------------------------
class CreditShopPage extends StatefulWidget {
  const CreditShopPage({super.key});
  @override
  State<CreditShopPage> createState() => _CreditShopPageState();
}

class _CreditShopPageState extends State<CreditShopPage> {
  int _credits = 5;

  @override
  void initState() {
    super.initState();
    _loadCredits();
  }

  Future<void> _loadCredits() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _credits = prefs.getInt('credits') ?? 5);
  }

  Future<void> _addCredits(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _credits += amount);
    await prefs.setInt('credits', _credits);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "+$amount crédit${amount > 1 ? 's' : ''} ajouté${amount > 1 ? 's' : ''}")));
  }

  @override
  Widget build(BuildContext context) {
    final offers = [
      {"credits": 10, "price": 2.5},
      {"credits": 20, "price": 4.5},
      {"credits": 30, "price": 6.5},
      {"credits": 30, "price": 5.0, "abonnement": true},
    ];

    return Scaffold(
      appBar: AppBar(
          title: const Text("Acheter des crédits"),
          backgroundColor: Colors.lightBlue),
      body: Container(
        width: double.infinity,
        color: const Color(0xFFF8F6FF),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text("Crédits actuels : $_credits",
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 40),
            for (final offer in offers)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SizedBox(
                  width: offer["abonnement"] == true ? 300 : 260,
                  height: offer["abonnement"] == true ? 70 : 60,
                  child: ElevatedButton(
                    onPressed: () => _addCredits(offer["credits"] as int),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: offer["abonnement"] == true
                            ? Colors.green
                            : Colors.lightBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25))),
                    child: Text(
                      offer["abonnement"] == true
                          ? "Abonnement mensuel : 30 crédits — 5€ (minimum 3 mois)"
                          : "Acheter ${offer["credits"]} crédits — ${offer["price"]}€",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
          ]),
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
              shape: BoxShape.circle, color: Colors.lightBlue),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, color: Colors.white, size: 26),
              Text(label,
                  style: const TextStyle(fontSize: 10, color: Colors.white)),
            ]),
          ),
        ),
      ),
    ]);
  }
}
