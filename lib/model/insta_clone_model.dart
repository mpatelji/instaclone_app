// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';
//
// class Comment {
//   final String username;
//   final String profileImage;
//   final String commentText;
//   final DateTime timestamp;
//
//   Comment({
//     required this.username,
//     required this.profileImage,
//     required this.commentText,
//     required this.timestamp,
//   });
// }
//
// class CommentService extends GetxController {
//   final RxMap<String, List<Comment>> commentsMap = <String, List<Comment>>{}.obs;
//
//   Future<void> addComment(String videoId, Comment comment) async {
//     try {
//       await FirebaseFirestore.instance.collection('comments').add({
//         'videoId': videoId,
//         'username': comment.username,
//         'profileImage': comment.profileImage,
//         'commentText': comment.commentText,
//         'timestamp': Timestamp.fromDate(comment.timestamp),
//       });
//
//       // Update comments in-memory
//       if (commentsMap.containsKey(videoId)) {
//         commentsMap[videoId]?.add(comment);
//         commentsMap.refresh(); // Notify listeners about the update
//       } else {
//         commentsMap[videoId] = [comment];
//         commentsMap.refresh(); // Notify listeners about the update
//       }
//     } catch (error) {
//       Get.snackbar('Error', 'Failed to add comment: $error');
//     }
//   }
//
//   Future<void> fetchComments(String videoId) async {
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('comments')
//           .where('videoId', isEqualTo: videoId)
//           .orderBy('timestamp', descending: true)
//           .get();
//
//       final comments = snapshot.docs.map((doc) {
//         final data = doc.data();
//         return Comment(
//           username: data['username'],
//           profileImage: data['profileImage'],
//           commentText: data['commentText'],
//           timestamp: (data['timestamp'] as Timestamp).toDate(),
//         );
//       }).toList();
//
//       commentsMap[videoId] = comments;
//       commentsMap.refresh(); // Notify listeners about the update
//     } catch (error) {
//       Get.snackbar('Error', 'Failed to fetch comments: $error');
//     }
//   }
// }
