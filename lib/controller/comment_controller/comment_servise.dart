import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../model/fllow_and_unfllow_model.dart';

class FllowingController extends GetxController {
  var user = UserModel().obs;
  Future<void> followUser(String userId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
    final targetUserRef = FirebaseFirestore.instance.collection('users').doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      final targetUserDoc = await transaction.get(targetUserRef);

      if (!userDoc.exists || !targetUserDoc.exists) return;

      final currentUserData = userDoc.data()!;
      final targetUserData = targetUserDoc.data()!;

      final currentUserFollowing = List<String>.from(currentUserData['following'] ?? []);
      final targetUserFollowers = List<String>.from(targetUserData['followers'] ?? []);

      if (!currentUserFollowing.contains(userId)) {
        currentUserFollowing.add(userId);
        targetUserFollowers.add(currentUser.uid);

        transaction.update(userRef, {'following': currentUserFollowing});
        transaction.update(targetUserRef, {'followers': targetUserFollowers});
      }
    });
  }

  Future<void> unfollowUser(String userId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
    final targetUserRef = FirebaseFirestore.instance.collection('users').doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      final targetUserDoc = await transaction.get(targetUserRef);

      if (!userDoc.exists || !targetUserDoc.exists) return;

      final currentUserData = userDoc.data()!;
      final targetUserData = targetUserDoc.data()!;

      final currentUserFollowing = List<String>.from(currentUserData['following'] ?? []);
      final targetUserFollowers = List<String>.from(targetUserData['followers'] ?? []);

      if (currentUserFollowing.contains(userId)) {
        currentUserFollowing.remove(userId);
        targetUserFollowers.remove(currentUser.uid);

        transaction.update(userRef, {'following': currentUserFollowing});
        transaction.update(targetUserRef, {'followers': targetUserFollowers});
      }
    });
  }
}
