// import 'package:flutter_riverpod/legacy.dart';
//
// /// ----------------------
// /// MODEL
// /// ----------------------
// class ProfileImageModel {
//   final String? imageUrl;
//
//   const ProfileImageModel({this.imageUrl});
//
//   ProfileImageModel copyWith({String? imageUrl}) {
//     return ProfileImageModel(imageUrl: imageUrl ?? this.imageUrl);
//   }
// }
//
// /// ----------------------
// /// PROVIDER (NOTIFIER)
// /// ----------------------
// class ProfileImageNotifier extends StateNotifier<ProfileImageModel> {
//   ProfileImageNotifier() : super(const ProfileImageModel());
//
//   void updateImage(String url) {
//     state = state.copyWith(imageUrl: url);
//   }
//
//   void clearImage() {
//     state = const ProfileImageModel();
//   }
// }
//
// /// Global Provider
// final profileImageProvider =
//     StateNotifierProvider<ProfileImageNotifier, ProfileImageModel>((ref) {
//       return ProfileImageNotifier();
//     });
