// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
//
// import '../model/insta_clone_model.dart';
// import '../views/screen/reels_screen.dart';
//
// class CommentUploadController extends GetxController {
//   var videoUrls = <String>[].obs;
//   var videoProfileImages = <String>[].obs;
//   var videoUsernames = <String>[].obs;
//   var isLoading = true.obs;
//
//   var commentsMap = <String, List<Comment>>{}.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchVideoUrls();
//   }
//
//   Future<void> fetchVideoUrls() async {
//     try {
//       var snapshot = await FirebaseFirestore.instance.collection('videos').get();
//       videoUrls.value = snapshot.docs.map((doc) => doc['url'] as String).toList();
//       videoProfileImages.value = snapshot.docs.map((doc) => doc['profileImage'] as String).toList();
//       videoUsernames.value = snapshot.docs.map((doc) => doc['username'] as String).toList();
//
//       await fetchCommentsAndLikes();
//     } catch (error) {
//       Get.snackbar('Error', 'Failed to fetch videos: $error');
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<void> fetchCommentsAndLikes() async {
//     try {
//       var videoIds = videoUrls;
//
//       for (var videoId in videoIds) {
//         var commentsSnapshot = await FirebaseFirestore.instance
//             .collection('comments')
//             .where('videoId', isEqualTo: videoId)
//             .get();
//       }
//     } catch (error) {
//       Get.snackbar('Error', 'Failed to fetch comments: $error');
//     }
//   }
// }
