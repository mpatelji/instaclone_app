import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../controller/login_and_registesion_service/registesion_and_login_controller.dart';

class SearchScreenShowId extends StatelessWidget {
  final AuthService _authService = Get.put(AuthService());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Users'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              
              onChanged: (value) {
                _authService.searchUsers(value);

              },
              decoration: InputDecoration(
                
                hintText: 'Search by name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_authService.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }
              if (_authService.users.isEmpty) {
                return Center(child: Text('No users found'));
              }
              return ListView.builder(
                itemCount: _authService.users.length,
                itemBuilder: (context, index) {
                  final user = _authService.users[index];
                  final profileImageUrl = user['profileImageUrl'] as String?;
                  final userName = user['name'] as String?;

                  return ListTile(
                    contentPadding: EdgeInsets.all(8.0),
                    leading: CircleAvatar(
                      backgroundImage: profileImageUrl != null &&
                          profileImageUrl.isNotEmpty
                          ? CachedNetworkImageProvider(profileImageUrl)
                          : AssetImage(
                          'assets/default_profile.png') as ImageProvider,
                      backgroundColor: Colors.grey[200],
                      child: profileImageUrl == null || profileImageUrl.isEmpty
                          ? Icon(Icons.person, color: Colors.grey[700])
                          : null,
                    ),
                    title: Text(userName ?? 'No name provided'),
                    // Align the text and image in a vertical layout
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8.0),
                        Text(userName ?? 'No name provided',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4.0),
                        // Optionally add more widgets here if needed
                      ],
                    ),
                    isThreeLine: true, // Allows for more space if needed
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}