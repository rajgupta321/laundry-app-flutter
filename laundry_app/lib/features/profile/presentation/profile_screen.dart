import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../customer_info/providers/customer_info_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadCustomerInfo();
  }

  Future<void> loadCustomerInfo() async {
    setState(() => _loading = true);
    await ref.read(customerInfoProvider.notifier).loadCustomerInfo();
    setState(() => _loading = false);
  }

  Widget infoCard(String label, String? value, {IconData? icon}) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) Icon(icon, color: const Color(0xFF3F3CFF)),
            if (icon != null) const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value ?? "-",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customerInfo = ref.watch(customerInfoProvider);
    final size = MediaQuery.of(context).size;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================= HEADER / HERO PROFILE =================
            Container(
              width: size.width,
              padding: const EdgeInsets.only(
                top: 60,
                left: 20,
                right: 20,
                bottom: 40,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF3F3CFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // Row(
                  //   children: [
                  //     IconButton(
                  //       onPressed: () => context.pop(),
                  //       icon: const Icon(Icons.arrow_back, color: Colors.white),
                  //     ),
                  //     const Spacer(),
                  //     IconButton(
                  //       onPressed: () => context.push('/customerInfo'),
                  //       icon: const Icon(Icons.edit, color: Colors.white),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 10),

                  // PROFILE AVATAR
                  const CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 45,
                      color: Color(0xFF3F3CFF),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    customerInfo?["name"] ?? "Your Name",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    customerInfo?["phone1"] ?? "+91 XXXXXXXX",
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= EMPTY STATE =================
            if (customerInfo == null)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.person_off, size: 90, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      "Profile not completed",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Complete your profile to book services faster",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => context.push('/customerInfo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F3CFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Add Profile Info",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              // ================= PROFILE DETAILS =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Personal Information"),
                    _profileTile(
                      icon: Icons.person,
                      label: "Full Name",
                      value: customerInfo["name"],
                    ),
                    _profileTile(
                      icon: Icons.phone,
                      label: "Phone Number",
                      value: customerInfo["phone1"],
                    ),
                    _profileTile(
                      icon: Icons.email,
                      label: "Email",
                      value: customerInfo["email"],
                    ),

                    const SizedBox(height: 16),

                    _sectionTitle("Address"),
                    _profileTile(
                      icon: Icons.location_on,
                      label: "Home Address",
                      value:
                          "${customerInfo["house"]}, ${customerInfo["area"]}, ${customerInfo["city"]}, ${customerInfo["state"]}, ${customerInfo["pincode"]}",
                      maxLines: 2,
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/customerInfo'),
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text(
                          "Edit Profile",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F3CFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Widget _sectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );
}

Widget _profileTile({
  required IconData icon,
  required String label,
  required String? value,
  int maxLines = 1,
}) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF6C63FF).withOpacity(0.12),
            child: Icon(icon, color: const Color(0xFF3F3CFF)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  value ?? "-",
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
