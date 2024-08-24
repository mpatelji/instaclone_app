import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:instaclone_app/views/screen/reels_screen.dart';
import 'package:instaclone_app/views/screen/registesion_and_login/upload_rellls.dart';
import 'package:instaclone_app/views/screen/search_id_screen_show_video.dart';
import 'package:video_player/video_player.dart';
import 'edit_screen.dart';
import 'logout_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<String> videoUrls = [];
  List<Widget> _pages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVideoUrls();
  }

  Future<void> _loadVideoUrls() async {
    try {
      List<String> fetchedVideoUrls = await fetchVideoUrls();
      setState(() {
        videoUrls = fetchedVideoUrls;
        _pages = _buildPages();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading video URLs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<String>> fetchVideoUrls() async {
    List<String> videoUrls = [];
    final storageRef = FirebaseStorage.instance.ref();
    final videoRef = storageRef.child('videos');
    final videoList = await videoRef.listAll();
    for (var item in videoList.items) {
      final videoUrl = await item.getDownloadURL();
      videoUrls.add(videoUrl);
    }
    return videoUrls;
  }

  List<Widget> _buildPages() {
    return [

      ProfileScreen(),
      SearchScreen(),
      ReelsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_collection),
            label: 'Reels',
          ),
        ],
      ),
    );
  }
}





class ProfileScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final VideoController _videoController = Get.put(VideoController());

  Future<Map<String, dynamic>?> _fetchUserProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      Get.snackbar('Error', 'User is not signed in');
      return null;
    }

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final videoCount = await _getUserVideoCount(user.uid);
        final userData = userDoc.data()!;
        userData['videoCount'] = videoCount;
        userData['followersCount'] = userData['followers_count'] ?? 0;
        userData['followingCount'] = userData['following_count'] ?? 0;
        return userData;
      } else {
        Get.snackbar('Error', 'User profile not found');
        return null;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch user profile: $e');
      return null;
    }
  }

  Future<int> _getUserVideoCount(String userId) async {
    try {
      final videosSnapshot = await _firestore.collection('videos').where('userId', isEqualTo: userId).get();
      return videosSnapshot.size;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch video count: $e');
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUserVideos(String userId) async {
    try {
      final videosSnapshot = await _firestore.collection('videos').where('userId', isEqualTo: userId).get();
      return videosSnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch videos: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Profile", style: TextStyle(color: Colors.grey)),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.video_library, color: Colors.grey),
            onPressed: () {
              final user = _auth.currentUser;
              if (user != null) {
                Get.to(() => VideoUploadScreen(userId: user.uid));
              } else {
                Get.snackbar('Error', 'User is not signed in');
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('User profile not found'));
          }

          final userProfile = snapshot.data!;
          final profileImageUrl = userProfile['profileImageUrl'] as String?;
          final userName = userProfile['name'] as String?;
          final videoCount = userProfile['videoCount'] as int?;
          final followersCount = userProfile['followersCount'] as int?;
          final followingCount = userProfile['followingCount'] as int?;
          final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: profileImageUrl != null
                              ? NetworkImage(profileImageUrl)
                              : const AssetImage('assets/default_profile.png') as ImageProvider,
                        ),
                        Column(
                          children: [
                            Text(videoCount?.toString() ?? "0", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            Text("Posts", style: TextStyle(fontSize: 15)),
                          ],
                        ),
                        Column(
                          children: [
                            Text(followersCount?.toString() ?? "0", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            Text("Followers", style: TextStyle(fontSize: 15)),
                          ],
                        ),
                        Column(
                          children: [
                            Text(followingCount?.toString() ?? "0", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            Text("Following", style: TextStyle(fontSize: 15)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        userName ?? 'No name provided',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      OutlinedButton(
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
                        onPressed: () {
                          Get.to(() => LogoutScreen());
                        },
                        child: Text('Account Settings', style: TextStyle(color: Colors.grey)),
                      ),
                      OutlinedButton(
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
                        onPressed: () {
                          Get.to(() => EditProfileScreen());
                        },
                        child: Text('Edit Profile', style: TextStyle(color: Colors.grey)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 20),

                  // Video Grid with Inline Player
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchUserVideos(userId),
                    builder: (context, videoSnapshot) {
                      if (videoSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (videoSnapshot.hasError) {
                        return Center(child: Text('Error: ${videoSnapshot.error}'));
                      }
                      if (!videoSnapshot.hasData || videoSnapshot.data == null || videoSnapshot.data!.isEmpty) {
                        return const Center(child: Text('No videos found'));
                      }

                      final videos = videoSnapshot.data!;
                      final maxVideosToShow = videoCount ?? 0;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 9.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemCount: videos.length > maxVideosToShow ? maxVideosToShow : videos.length,
                        itemBuilder: (context, index) {
                          final video = videos[index];
                          final videoUrl = video['url'];

                          if (videoUrl == null) {
                            return Center(child: Text("No URL"));
                          }

                          return Obx(() {
                            final isPlaying = _videoController.playingVideoUrl.value == videoUrl;
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: VideoPlayerWidget(videoUrl: videoUrl, isPlaying: isPlaying),
                            );
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


class VideoController extends GetxController {
  var playingVideoUrl = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    ever(playingVideoUrl, (String? url) {
      if (url != null) {
      }
    });
  }
  void toggleVideo(String videoUrl) {
    if (playingVideoUrl.value == videoUrl) {
      playingVideoUrl.value = null;
    } else {
      playingVideoUrl.value = videoUrl;
    }
  }
}
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool isPlaying;

  const VideoPlayerWidget({Key? key, required this.videoUrl, required this.isPlaying}) : super(key: key);

  @override
  _VideosPlayerWidgetState createState() => _VideosPlayerWidgetState();
}

class _VideosPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  final VideoController _videoController = Get.find(); // Get instance of VideoController

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          if (widget.isPlaying) {
            _controller.play();
          } else {
            _controller.pause();
          }
        });
      }).catchError((error) {
        print('Error initializing video: $error');
      });
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller.dispose();
      _initializePlayer();
    } else if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _controller.play();
      } else {
        _controller.pause();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _videoController.toggleVideo(widget.videoUrl);
      },
      child: _controller.value.isInitialized
          ? Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller),
          if (!widget.isPlaying)
            const Icon(
              Icons.play_circle,
              color: Colors.white,
              size: 50.0,
            ),
        ],
      )
          : const Center(child: SpinKitCircle(color: Colors.white)),
    );
  }
}


