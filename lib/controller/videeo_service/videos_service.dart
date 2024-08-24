// import 'dart:io';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:video_player/video_player.dart';
//
// class VideoUploadController extends GetxController {
//   var videoComments = <List<String>>[].obs;
//
//
//   var followersCount = 0.obs;
//   var isFollowing = false.obs;
//   var userPosts = <String>[].obs;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   var Following = false.obs;
//   var isProcessing = false.obs;
//
//   Future<void> toggleFollow(String userId) async {
//     if (isProcessing.value) return;
//
//     isProcessing.value = true;
//
//     final currentUserId = _auth.currentUser?.uid;
//     if (currentUserId == null) {
//       isProcessing.value = false;
//       return;
//     }
//
//     try {
//       if (isFollowing.value) {
//         // Unfollow
//         await _firestore.collection('users').doc(currentUserId).update({
//           'following': FieldValue.arrayRemove([userId]),
//         });
//         await _firestore.collection('users').doc(userId).update({
//           'followers': FieldValue.arrayRemove([currentUserId]),
//         });
//         isFollowing.value = false;
//       } else {
//         // Follow
//         await _firestore.collection('users').doc(currentUserId).update({
//           'following': FieldValue.arrayUnion([userId]),
//         });
//         await _firestore.collection('users').doc(userId).update({
//           'followers': FieldValue.arrayUnion([currentUserId]),
//         });
//         isFollowing.value = true;
//       }
//     } catch (error) {
//       Get.snackbar(
//         'Follow/Unfollow Failed',
//         'Failed to follow/unfollow user: $error',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     } finally {
//       isProcessing.value = false;
//     }
//   }
//
//   var isLoading = false.obs;
//   var videoFilePath = ''.obs;
//   var videoUrl = ''.obs;
//   var videoUrls = <String>[].obs;
//   var videoUsernames = <String>[].obs;
//   var videoProfileImages = <String>[].obs;
//   final ImagePicker _picker = ImagePicker();
//   late VideoPlayerController _videoPlayerController;
//
//   Future<Map<String, String>> getUserData(String userId) async {
//     try {
//       final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
//       if (userDoc.exists) {
//         final userData = userDoc.data()!;
//         return {
//           'name': userData['name'] ?? 'Unknown',
//           'profileImageUrl': userData['profileImageUrl'] ?? '',
//         };
//       }
//       return {'name': 'Unknown', 'profileImageUrl': ''};
//     } catch (error) {
//       Get.snackbar(
//         'User Data Fetch Failed',
//         'Failed to fetch user data: $error',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return {'name': 'Unknown', 'profileImageUrl': ''};
//     }
//   }
//
//   Future<File?> pickVideo() async {
//     try {
//       final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
//       if (pickedFile != null) {
//         videoFilePath.value = pickedFile.path;
//         return File(pickedFile.path);
//       }
//       return null;
//     } catch (error) {
//       Get.snackbar(
//         'Video Selection Failed',
//         'Failed to pick video: $error',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return null;
//     }
//   }
//
//   Future<void> uploadVideo(File videoFile, String userId) async {
//     try {
//       isLoading.value = true;
//       final fileName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
//       final storageRef = FirebaseStorage.instance.ref().child('videos').child(fileName);
//
//       final uploadTask = storageRef.putFile(videoFile);
//       await uploadTask;
//
//       final downloadUrl = await storageRef.getDownloadURL();
//       videoUrl.value = downloadUrl;
//
//       final userData = await getUserData(userId);
//       final username = userData['name'];
//       final profileImageUrl = userData['profileImageUrl'];
//
//       await FirebaseFirestore.instance.collection('videos').doc(fileName).set({
//         'url': downloadUrl,
//         'name': username,
//         'profileImageUrl': profileImageUrl,
//         'userId': userId,
//         'timestamp': FieldValue.serverTimestamp(), // Timestamp for sorting or other purposes
//       });
//
//       // Update user's post count
//       await _incrementPostCount(userId);
//
//       videoUrls.add(downloadUrl);
//       videoUsernames.add(username ?? "");
//       videoProfileImages.add(profileImageUrl ?? "");
//
//       Get.snackbar(
//         'Upload Success',
//         'Video uploaded successfully!',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     } catch (error) {
//       Get.snackbar(
//         'Upload Failed',
//         'Failed to upload video: $error',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   // Method to increment post count in user's profile
//   Future<void> _incrementPostCount(String userId) async {
//     try {
//       final userDoc = _firestore.collection('users').doc(userId);
//       final snapshot = await userDoc.get();
//       if (snapshot.exists) {
//         final currentCount = snapshot.data()?['postCount'] ?? 0;
//         await userDoc.update({'postCount': currentCount + 1});
//       } else {
//         await userDoc.set({'postCount': 1}, SetOptions(merge: true));
//       }
//     } catch (error) {
//       Get.snackbar(
//         'Post Count Update Failed',
//         'Failed to update post count: $error',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     }
//   }
//
//   Future<void> fetchVideoUrls() async {
//     try {
//       isLoading.value = true;
//       final storageRef = FirebaseStorage.instance.ref().child('videos');
//       final result = await storageRef.listAll();
//       videoUrls.clear();
//       videoUsernames.clear();
//       videoProfileImages.clear();
//
//       for (var item in result.items) {
//         final url = await item.getDownloadURL();
//         videoUrls.add(url);
//         final videoDoc = await FirebaseFirestore.instance.collection('videos').doc(item.name).get();
//         if (videoDoc.exists) {
//           final videoData = videoDoc.data()!;
//           final username = videoData['name'] ?? 'Unknown';
//           final profileImageUrl = videoData['profileImageUrl'] ?? '';
//           videoUsernames.add(username);
//           videoProfileImages.add(profileImageUrl);
//         } else {
//           videoUsernames.add('Unknown');
//           videoProfileImages.add('');
//         }
//       }
//     } catch (error) {
//       Get.snackbar(
//         'Fetch Failed',
//         'Failed to fetch video URLs: $error',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> initializeVideoPlayer(String filePath) async {
//     try {
//       _videoPlayerController = VideoPlayerController.file(File(filePath));
//       await _videoPlayerController.initialize();
//       _videoPlayerController.play();
//     } catch (error) {
//       Get.snackbar(
//         'Player Initialization Failed',
//         'Failed to initialize video player: $error',
//         snackPosition: SnackPosition.BOTTOM,
//
//
//
//       );
//
//
//
//     }
//   }
//
//   @override
//   void onClose() {
//     _videoPlayerController.dispose();
//     super.onClose();
//   }
// }


import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';

class VideoUploadController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  late VideoPlayerController _videoPlayerController;

  // Observables
  var isLoading = false.obs;
  var videoFilePath = ''.obs;
  var videoUrl = ''.obs;
  var videoUrls = <String>[].obs;
  var videoUsernames = <String>[].obs;
  var videoProfileImages = <String>[].obs;
  var videoComments = <List<String>>[].obs;
  var followersCount = 0.obs;
  var isFollowing = false.obs;
  var userPosts = <String>[].obs;
  var isProcessing = false.obs;


  var Following = false.obs;

  void updateFollowStatus(bool newStatus) {
    isFollowing.value = newStatus;
  }

  var users = <Map<String, dynamic>>[].obs; // Observable list to store search results
  var Loading = false.obs;
  var reels = <Map<String, dynamic>>[].obs;
  Future<void> searchByUserId(String userId) async {
    try {
      isLoading.value = true;

      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('userId', isEqualTo: userId)
          .get();

      // Map the documents to a list of maps containing user data
      final List<Map<String, dynamic>> fetchedUsers = snapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      // Update observable list with search results
      users.value = fetchedUsers;

    } catch (e) {
      print("Error searching users: $e");
      Get.snackbar(
        'Search Failed',
        'Failed to search for users: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserReels(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('reels')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error fetching user reels: $e");
      throw e; // rethrow the error for handling in the UI
    }
  }

  // Fetch user videos
  Future<List<String>> fetchUserVideos(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('videos')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) => doc['url'] as String).toList();
    } catch (e) {
      print('Error fetching videos: $e');
      return [];
    }
  }

  // Get user data
  Future<Map<String, String>> getUserData(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        return {
          'name': userData['name'] ?? 'Unknown',
          'profileImageUrl': userData['profileImageUrl'] ?? '',
        };
      }
      return {'name': 'Unknown', 'profileImageUrl': ''};
    } catch (error) {
      Get.snackbar(
        'User Data Fetch Failed',
        'Failed to fetch user data: $error',
        snackPosition: SnackPosition.BOTTOM,
      );
      return {'name': 'Unknown', 'profileImageUrl': ''};
    }
  }

  // Pick a video
  Future<File?> pickVideo() async {
    try {
      final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
      if (pickedFile != null) {
        videoFilePath.value = pickedFile.path;
        return File(pickedFile.path);
      }
      return null;
    } catch (error) {
      Get.snackbar(
        'Video Selection Failed',
        'Failed to pick video: $error',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  // Upload video
  Future<void> uploadVideo(File videoFile, String userId) async {
    try {
      isLoading.value = true;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
      final storageRef = FirebaseStorage.instance.ref().child('videos').child(fileName);

      final uploadTask = storageRef.putFile(videoFile);
      await uploadTask;

      final downloadUrl = await storageRef.getDownloadURL();
      videoUrl.value = downloadUrl;

      final userData = await getUserData(userId);
      final username = userData['name'];
      final profileImageUrl = userData['profileImageUrl'];

      // Save video information to Firestore
      await _firestore.collection('videos').doc(fileName).set({
        'url': downloadUrl,
        'name': username,
        'profileImageUrl': profileImageUrl,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Increment user's post count after video upload
      await _incrementPostCount(userId);

      // Update local data for the UI
      videoUrls.add(downloadUrl);
      videoUsernames.add(username!);
      videoProfileImages.add(profileImageUrl!);

      Get.snackbar(
        'Upload Success',
        'Video uploaded successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Upload Failed',
        'Failed to upload video: $error',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Increment post count for the user
  Future<void> _incrementPostCount(String userId) async {
    try {
      final userDocRef = _firestore.collection('users').doc(userId);
      final userDoc = await userDocRef.get();

      if (userDoc.exists) {
        final currentPostCount = userDoc.data()?['postCount'] ?? 0;
        await userDocRef.update({
          'postCount': currentPostCount + 1,
        });
      } else {
        // If the user document doesn't exist, create it with postCount = 1
        await userDocRef.set({
          'postCount': 1,
        }, SetOptions(merge: true));
      }
    } catch (error) {
      Get.snackbar(
        'Post Count Update Failed',
        'Failed to update post count: $error',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Fetch all video URLs from Firebase Storage
  Future<void> fetchVideoUrls() async {
    try {
      isLoading.value = true;
      final storageRef = FirebaseStorage.instance.ref().child('videos');
      final result = await storageRef.listAll();

      videoUrls.clear();
      videoUsernames.clear();
      videoProfileImages.clear();

      for (var item in result.items) {
        final url = await item.getDownloadURL();
        videoUrls.add(url);

        final videoDoc = await _firestore.collection('videos').doc(item.name).get();
        if (videoDoc.exists) {
          final videoData = videoDoc.data()!;
          final username = videoData['name'] ?? 'Unknown';
          final profileImageUrl = videoData['profileImageUrl'] ?? '';
          videoUsernames.add(username);
          videoProfileImages.add(profileImageUrl);
        } else {
          videoUsernames.add('Unknown');
          videoProfileImages.add('');
        }
      }
    } catch (error) {
      Get.snackbar(
        'Fetch Failed',
        'Failed to fetch video URLs: $error',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Initialize video player
  Future<void> initializeVideoPlayer(String filePath) async {
    try {
      _videoPlayerController = VideoPlayerController.file(File(filePath));
      await _videoPlayerController.initialize();
      _videoPlayerController.play();
    } catch (error) {
      Get.snackbar(
        'Player Initialization Failed',
        'Failed to initialize video player: $error',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    _videoPlayerController.dispose();
    super.onClose();
  }
}
