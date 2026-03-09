// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
//
// import '../providers/auth_provider.dart';
//
// class SignupScreen extends ConsumerWidget {
//   const SignupScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final TextEditingController mobileController = TextEditingController();
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Color(0xFF6C63FF),
//                   Color(0xFF3F3CFF),
//                   Color(0xFF1A1AFF),
//                 ],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//           ),
//           Center(
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(24),
//               child: BackdropFilter(
//                 filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
//                 child: Container(
//                   width: size.width * 0.85,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 24,
//                     vertical: 32,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(24),
//                     border: Border.all(
//                       color: Colors.white.withOpacity(0.3),
//                       width: 1,
//                     ),
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: const [
//                           Icon(
//                             Icons.local_laundry_service,
//                             size: 36,
//                             color: Colors.white,
//                           ),
//                           SizedBox(width: 8),
//                           Text(
//                             'Laundry',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 28,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 32),
//                       const Text(
//                         'Create Account',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 26,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       const Text(
//                         'Sign up with your phone number',
//                         style: TextStyle(color: Colors.white70, fontSize: 16),
//                       ),
//                       const SizedBox(height: 24),
//                       const Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           'Enter your phone number',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       TextField(
//                         controller: mobileController,
//                         keyboardType: TextInputType.phone,
//                         style: const TextStyle(color: Colors.white),
//                         inputFormatters: [
//                           FilteringTextInputFormatter.digitsOnly,
//                           LengthLimitingTextInputFormatter(10),
//                         ],
//                         decoration: InputDecoration(
//                           hintText: 'Mobile Number',
//                           hintStyle: const TextStyle(color: Colors.white70),
//                           enabledBorder: OutlineInputBorder(
//                             borderSide: BorderSide(color: Colors.white54),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderSide: BorderSide(color: Colors.white),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 14,
//                           ),
//                           fillColor: Colors.white.withOpacity(0.1),
//                           filled: true,
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text(
//                             "Already have an account?",
//                             style: TextStyle(color: Colors.white70),
//                           ),
//                           TextButton(
//                             onPressed: () => context.push('/login'),
//                             child: const Text(
//                               'Login',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       SizedBox(
//                         width: double.infinity,
//                         height: 50,
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             final phone = "+91${mobileController.text}";
//                             await ref
//                                 .read(authProvider.notifier)
//                                 .sendOtp(phone);
//                             context.push('/otp', extra: phone);
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: const Text(
//                             'Sign Up',
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
