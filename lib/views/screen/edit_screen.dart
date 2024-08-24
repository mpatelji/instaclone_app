import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controller/login_and_registesion_service/registesion_and_login_controller.dart';
import 'home_screen.dart';

class EditProfileScreen extends StatelessWidget {
  final AuthService profileController = Get.find<AuthService>();
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          Obx(() => IconButton(
            icon: Icon(Icons.save),
            onPressed: profileController.isLoading.value
                ? null
                : () async {
              // Update user profile and navigate back
              try {
                await profileController.updateUserProfile(
                  name: nameController.text.isEmpty
                      ? profileController.name.value
                      : nameController.text,
                  profileImageUrl: profileController.profileImageUrl.value,
                );
                Get.back();
              } catch (e) {
                Get.snackbar('Error', 'Failed to update profile');
              }
            },
          )),
        ],
      ),
      body: FutureBuilder<void>(
        future: profileController.loadUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading profile data'));
          } else {
            nameController.text = profileController.name.value;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          try {
                            String newImageUrl = await profileController.uploadProfileImage(image);

                            await profileController.updateUserProfile(
                              name: nameController.text.isEmpty
                                  ? profileController.name.value
                                  : nameController.text,
                              profileImageUrl: newImageUrl,
                            );
                            profileController.profileImageUrl.value = newImageUrl;
                          } catch (e) {
                            Get.snackbar('Error', 'Failed to update profile image');
                          }
                        }
                      },
                      child: Obx(() {
                        return Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: profileController.profileImageUrl.value.isNotEmpty
                                  ? NetworkImage(profileController.profileImageUrl.value)
                                  : AssetImage('assets/default_profile.png') as ImageProvider,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.black54,
                                child: Icon(Icons.edit, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    onChanged: (value) => profileController.name.value = value,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Obx(() => ElevatedButton(
                    onPressed: profileController.isLoading.value ? null : () async {
                      try {
                        await profileController.updateUserProfile(
                          name: nameController.text.isEmpty
                              ? profileController.name.value
                              : nameController.text,
                          profileImageUrl: profileController.profileImageUrl.value,
                        );
                        Get.back(result: ProfileScreen()); // Navigate back to the previous screen (ProfileScreen)
                      } catch (e) {
                        Get.snackbar('Error', 'Failed to update profile');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                    child: profileController.isLoading.value
                        ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                        : Text('Save Changes'),
                  )),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
