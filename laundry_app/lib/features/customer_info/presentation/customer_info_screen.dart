// lib/features/customer_info/presentation/customer_info_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../providers/customer_info_provider.dart';

class CustomerInfoScreen extends ConsumerStatefulWidget {
  const CustomerInfoScreen({super.key});

  @override
  ConsumerState<CustomerInfoScreen> createState() => _CustomerInfoScreenState();
}

class _CustomerInfoScreenState extends ConsumerState<CustomerInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phone1Controller = TextEditingController();
  final phone2Controller = TextEditingController();
  final emailController = TextEditingController();

  final pincodeController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final areaController = TextEditingController();
  final houseController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    loadSavedData();
  }

  void loadSavedData() {
    final data = ref.read(customerInfoProvider);
    if (data != null) {
      nameController.text = data["name"] ?? "";
      phone1Controller.text = data["phone1"] ?? "";
      phone2Controller.text = data["phone2"] ?? "";
      emailController.text = data["email"] ?? "";
      pincodeController.text = data["pincode"] ?? "";
      stateController.text = data["state"] ?? "";
      cityController.text = data["city"] ?? "";
      areaController.text = data["area"] ?? "";
      houseController.text = data["house"] ?? "";
    } else {
      // Autofill primary number from OTP login
      phone1Controller.text = _auth.currentUser?.phoneNumber ?? '';
    }
  }

  void showLoadingSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return SizedBox(
          height: 180,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 15),
              Text(
                "Fetching your location...",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 5),
              Text(
                "Please wait while we auto detect your address.",
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        );
      },
    );
  }

  void closeSheet() {
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  Future<void> autoDetectLocation() async {
    showLoadingSheet();
    await Future.delayed(const Duration(milliseconds: 500));

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      closeSheet();
      return _showDialog("GPS is Off", "Please enable your location (GPS).");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      closeSheet();
      return _showSettingsDialog();
    }

    final pos = await Geolocator.getCurrentPosition();

    List<Placemark> place = await placemarkFromCoordinates(
      pos.latitude,
      pos.longitude,
    );

    closeSheet();

    if (place.isNotEmpty) {
      final p = place.first;

      setState(() {
        pincodeController.text = p.postalCode ?? "";
        stateController.text = p.administrativeArea ?? "";
        cityController.text = p.locality ?? "";
        areaController.text = p.subLocality ?? "";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location auto-filled successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Location Permission Needed"),
        content: const Text(
          "Location permission is permanently denied.\nPlease enable in settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Geolocator.openAppSettings();
              Navigator.pop(context);
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  void _showDialog(String title, String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    Map<String, dynamic> data = {
      "name": nameController.text.trim(),
      "phone1": phone1Controller.text.trim(),
      "phone2": phone2Controller.text.trim(),
      "email": emailController.text.trim(),
      "pincode": pincodeController.text.trim(),
      "state": stateController.text.trim(),
      "city": cityController.text.trim(),
      "area": areaController.text.trim(),
      "house": houseController.text.trim(),
    };

    await ref.read(customerInfoProvider.notifier).saveCustomerInfo(data);

    if (mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Customer Details",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F3CFF),
                ),
              ),
              const SizedBox(height: 30),
              _tf("Full Name", nameController),
              const SizedBox(height: 15),
              _tf(
                "Primary Number",
                phone1Controller,
                keyboard: TextInputType.phone,
                enabled: false,
              ),
              const SizedBox(height: 15),
              _tf(
                "Alternate Number",
                phone2Controller,
                keyboard: TextInputType.phone,
                required: false,
                type: "phone",
              ),

              const SizedBox(height: 15),
              _tf(
                "Email (optional)",
                emailController,
                keyboard: TextInputType.emailAddress,
                required: false,
                type: "email",
              ),

              const SizedBox(height: 25),
              const Text(
                "Address",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _tf("State", stateController)),
                  const SizedBox(width: 10),
                  Expanded(child: _tf("City", cityController)),
                ],
              ),
              const SizedBox(height: 10),
              _tf(
                "Pincode",
                pincodeController,
                keyboard: TextInputType.number,
                type: "pincode",
              ),
              const SizedBox(height: 15),
              _tf("Area / Locality", areaController),
              const SizedBox(height: 15),
              _tf("House No. / Street", houseController),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F3CFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _tf(
  String label,
  TextEditingController controller, {
  TextInputType keyboard = TextInputType.text,
  bool enabled = true,
  bool required = true, // required field or not
  String? type, // "phone", "email", "pincode"
}) {
  return TextFormField(
    controller: controller,
    enabled: enabled,
    keyboardType: keyboard,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
    validator: (v) {
      if (required && (v == null || v.isEmpty)) {
        return "$label is required";
      }

      // Only validate if value is not empty
      if (v != null && v.isNotEmpty) {
        if (type == "phone") {
          // Allow only 10+ digit numbers
          final phoneReg = RegExp(r'^\d{10,}$');
          if (!phoneReg.hasMatch(v)) return "Enter valid phone number";
        } else if (type == "email") {
          final emailReg = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailReg.hasMatch(v)) return "Enter valid email";
        } else if (type == "pincode") {
          final pinReg = RegExp(r'^\d+$');
          if (!pinReg.hasMatch(v)) return "Only numbers allowed";
        }
      }

      return null;
    },
  );
}
