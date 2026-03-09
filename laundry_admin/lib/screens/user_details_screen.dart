import 'package:flutter/material.dart';

class UserDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserDetailsScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Details")),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 600;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  detailTile("Name", userData["name"], isTablet),
                  detailTile("Phone 1", userData["phone1"], isTablet),
                  detailTile("Phone 2", userData["phone2"], isTablet),
                  detailTile("Email", userData["email"], isTablet),
                  detailTile("State", userData["state"], isTablet),
                  detailTile("City", userData["city"], isTablet),
                  detailTile("Pincode", userData["pincode"], isTablet),
                  detailTile("Area", userData["area"], isTablet),
                  detailTile("House", userData["house"], isTablet),

                  const SizedBox(height: 20),

                  Text(
                    "Contacts Fetched (Future Feature):",
                    style: TextStyle(
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: EdgeInsets.all(isTablet ? 20 : 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Contacts list will be shown here.",
                      style: TextStyle(fontSize: isTablet ? 18 : 14),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "SMS Logs (Future Feature):",
                    style: TextStyle(
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: EdgeInsets.all(isTablet ? 20 : 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "SMS logs will appear here.",
                      style: TextStyle(fontSize: isTablet ? 18 : 14),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget detailTile(String title, dynamic value, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isTablet ? 180 : 120,
            child: Text(
              "$title:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 18 : 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? "",
              style: TextStyle(fontSize: isTablet ? 18 : 14),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
