import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class AuthService extends GetxController {
  RxBool isInitialized = false.obs;
  RxBool isPlaying = false.obs;
  late VideoPlayerController videoPlayerController;

  var isLoading = false.obs;
  RxBool isPasswordVisible = false.obs;

  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxString profileImageUrl = ''.obs;
  RxString name = ''.obs;
  RxString phoneNumber = ''.obs;

  RxList<Map<String, dynamic>> users = <Map<String, dynamic>>[].obs;

  Future<File?> pickProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    update();
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<void> registerWithEmailPassword({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required File? profileImage,
  }) async {
    try {
      isLoading.value = true;

      final authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? profileImageUrl;
      if (profileImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${authResult.user!.uid}.jpg');
        final uploadTask = storageRef.putFile(profileImage);
        final snapshot = await uploadTask.whenComplete(() {});
        profileImageUrl = await snapshot.ref.getDownloadURL();
      }

      await _firestore.collection('users').doc(authResult.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phoneNumber,
        'profileImageUrl': profileImageUrl,
      });

      Get.snackbar(
        'Registration Success',
        'You have successfully registered.',
        snackPosition: SnackPosition.TOP,
      );
    } catch (error) {
      Get.snackbar(
        'Registration Failed',
        error.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Get.snackbar(
        'Login Success',
        'You have successfully logged in.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Login Failed',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      Get.snackbar(
        'Logout Success',
        'You have successfully logged out.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Logout Failed',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> loadUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userProfile = userDoc.data();
      if (userProfile != null) {
        profileImageUrl.value = userProfile['profileImageUrl'] ?? '';
        name.value = userProfile['name'] ?? '';
        phoneNumber.value = userProfile['phoneNumber'] ?? '';
      }
    }
  }

  Future<void> updateUserProfile(
      {required String name, required String profileImageUrl}) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'name': name,
        'profileImageUrl': profileImageUrl,
      });
      Get.snackbar('Success', 'Profile updated successfully');
    }
  }

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      users.clear();
      return;
    }
    try {
      isLoading.value = true;

      final querySnapshot = await _firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .get();

      users.value = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'name': data['name'] ?? 'No name provided',
          'profileImageUrl':
              data['profileImageUrl'] ?? 'assets/default_profile.png',
        };
      }).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch users: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> uploadProfileImage(XFile image) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg');
      final uploadTask = storageRef.putFile(File(image.path));
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (error) {
      print('Error uploading profile image: $error');
      throw Exception('Error uploading profile image: $error');

    }
  }

  var Loading = false.obs;
}
