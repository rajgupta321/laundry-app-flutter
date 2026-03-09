import 'package:go_router/go_router.dart';
import 'package:laundry_app/features/chat/presentation/chat_screen.dart';
import 'package:laundry_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:laundry_app/features/notifications/presentation/notifications_screen.dart';
import 'package:laundry_app/features/profile/presentation/profile_screen.dart';
import 'package:laundry_app/features/services/presentation/services_screen.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/otp_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/providers/orders_provider_dashboard.dart';
import '../features/customer_info/presentation/customer_info_screen.dart';
import '../features/orders/presentation/order_details_screen.dart';
import '../features/orders/presentation/orders_list_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    // GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/notification',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/services',
      builder: (context, state) => const ServicesScreen(),
    ),
    GoRoute(
      path: '/ordersList',
      builder: (context, state) => const OrdersListScreen(),
    ),
    GoRoute(
      path: '/customerInfo',
      builder: (context, state) => const CustomerInfoScreen(),
    ),
    GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),

    // OTP screen
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final phone = state.extra as String;
        return OtpScreen(phone: phone);
      },
    ),

    /// ✅ Order Details screen with typed extra (FullOrder)
    GoRoute(
      path: '/orderDetails',
      builder: (context, state) {
        final order = state.extra as FullOrder;
        return OrderDetailsScreen(order: order);
      },
    ),
  ],
);
