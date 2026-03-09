import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laundry_admin/screens/SelectUserForChatScreen.dart';
import 'package:laundry_admin/screens/chat_screen.dart';
import 'package:laundry_admin/screens/notification_detail_screen.dart';
import 'package:laundry_admin/screens/notifications_list_screen.dart';
import 'package:laundry_admin/screens/send_notification_screen.dart';

import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/order_details_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/user_details_screen.dart';
import 'screens/users_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',

  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;

    final currentLocation = state.uri
        .toString(); // <-- use this instead of state.location

    // User already logged in and trying to go to login -> redirect to dashboard
    if (user != null && currentLocation == '/login') return '/dashboard';

    // User logged out and trying to access dashboard -> redirect to login
    if (user == null && currentLocation == '/dashboard') return '/login';

    return null; // no redirect
  },

  routes: [
    // Login
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    // Dashboard
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),

    // Orders list
    GoRoute(path: '/orders', builder: (context, state) => const OrdersScreen()),

    // Order details
    GoRoute(
      path: '/orderDetails',
      builder: (context, state) {
        final orderData = state.extra as Map<String, dynamic>;
        return OrderDetailsScreen(
          orderId: orderData['id'],
          orderData: orderData,
        );
      },
    ),

    // Users list
    GoRoute(path: '/users', builder: (context, state) => const UsersScreen()),

    // User details
    GoRoute(
      path: '/userDetails',
      builder: (context, state) {
        final userData = state.extra as Map<String, dynamic>;
        return UserDetailsScreen(userData: userData);
      },
    ),

    GoRoute(
      path: '/selectUserForChat',
      builder: (context, state) => const SelectUserForChatScreen(),
    ),

    GoRoute(
      path: '/chat',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        if (data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("Chat")),
            body: const Center(
              child: Text("No user selected. Please select a user to chat."),
            ),
          );
        }
        return ChatScreen(userId: data['userId'], userName: data['userName']);
      },
    ),

    GoRoute(
      path: '/sendNotification',
      builder: (context, state) => const SendNotificationScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsListScreen(),
    ),
    GoRoute(
      path: '/notificationDetail',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final id = extra['id'] as String;
        final data = extra['data'] as Map<String, dynamic>;
        return NotificationDetailScreen(id: id, data: data);
      },
    ),
  ],
);
