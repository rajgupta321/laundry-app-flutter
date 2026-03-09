import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SelectUserForChatScreen extends StatefulWidget {
  const SelectUserForChatScreen({super.key});

  @override
  State<SelectUserForChatScreen> createState() =>
      _SelectUserForChatScreenState();
}

class _SelectUserForChatScreenState extends State<SelectUserForChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<QueryDocumentSnapshot> allUsers = [];
  List<QueryDocumentSnapshot> filteredUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
    _searchController.addListener(() {
      filterUsers(_searchController.text);
    });
  }

  Future<void> fetchUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      allUsers = snapshot.docs;
      filteredUsers = snapshot.docs;
      isLoading = false;
    });
  }

  void filterUsers(String query) {
    final q = query.toLowerCase();
    setState(() {
      filteredUsers = allUsers.where((user) {
        final data = user.data() as Map<String, dynamic>;
        final name = (data['name'] ?? '').toString().toLowerCase();
        final phone = (data['phone1'] ?? '').toString().toLowerCase();
        return name.contains(q) || phone.contains(q);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(title: const Text("Select User to Chat")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Search by name or phone",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final userData =
                          filteredUsers[index].data() as Map<String, dynamic>;
                      final userId = filteredUsers[index].id;
                      return ListTile(
                        title: Text(userData['name'] ?? "No Name"),
                        subtitle: Text(userData['phone1'] ?? ""),
                        leading: CircleAvatar(
                          child: Text(
                            (userData['name'] ?? "U")[0].toUpperCase(),
                          ),
                        ),
                        trailing: const Icon(Icons.chat, color: Colors.blue),
                        onTap: () {
                          // Navigate to ChatScreen
                          context.push(
                            '/chat',
                            extra: {
                              'userId': userId,
                              'userName': userData['name'] ?? "User",
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
