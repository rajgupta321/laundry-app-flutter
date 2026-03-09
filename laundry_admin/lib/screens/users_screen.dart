import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/users_provider.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  String search = "";

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("All Users")),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 600;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // SEARCH BOX
                  TextField(
                    decoration: const InputDecoration(
                      hintText: "Search by name or phone...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      setState(() {
                        search = val.toLowerCase();
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // USERS LIST – wrapped with Expanded to avoid overflow
                  Expanded(
                    child: usersAsync.when(
                      data: (snapshot) {
                        final docs = snapshot.docs.where((e) {
                          final name =
                              e['name']?.toString().toLowerCase() ?? "";
                          final phone = e['phone1']?.toString() ?? "";
                          return name.contains(search) ||
                              phone.contains(search);
                        }).toList();

                        if (docs.isEmpty) {
                          return const Center(child: Text("No users found"));
                        }

                        return ListView.builder(
                          itemCount: docs.length,
                          padding: EdgeInsets.only(bottom: isTablet ? 20 : 10),
                          itemBuilder: (context, index) {
                            final data = docs[index].data();

                            return Card(
                              elevation: isTablet ? 4 : 2,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 20 : 12,
                                  vertical: isTablet ? 12 : 6,
                                ),
                                title: Text(
                                  data["name"] ?? "No Name",
                                  style: TextStyle(
                                    fontSize: isTablet ? 20 : 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  data["phone1"] ?? "",
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: () {
                                  context.push('/userDetails', extra: data);
                                },
                              ),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text("Error: $e")),
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
}
