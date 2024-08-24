import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instaclone_app/views/screen/show_id_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../controller/login_and_registesion_service/registesion_and_login_controller.dart';
import '../../controller/videeo_service/videos_service.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final AuthService _authService = Get.put(AuthService());

  final VideoUploadController _videoController =
      Get.find<VideoUploadController>();
  late List<VideoPlayerController> _controllers;
  late List<bool> _initialized;
  int _currentlyPlayingIndex = -1;

  @override
  void initState() {
    super.initState();
    _initializeVideos();
  }

  Future<void> _initializeVideos() async {
    try {
      await _videoController.fetchVideoUrls();
      setState(() {
        _controllers = _videoController.videoUrls
            .map((url) => VideoPlayerController.network(url))
            .toList();
        _initialized = List.filled(_controllers.length, false);
      });
      await _initializeVideoPlayers();
    } catch (error) {
      Get.snackbar('Initialization Error', 'Error fetching video URLs: $error');
    }
  }

  Future<void> _initializeVideoPlayers() async {
    for (int i = 0; i < _controllers.length; i++) {
      try {
        await _controllers[i].initialize();
        setState(() {
          _initialized[i] = true;
        });
      } catch (error) {
        Get.snackbar(
            'Error', 'Failed to initialize video player at index $i: $error');
      }
    }
  }

  void _playVideo(int index) {
    setState(() {
      if (_currentlyPlayingIndex != -1 && _currentlyPlayingIndex != index) {
        _controllers[_currentlyPlayingIndex].pause();
      }
      _currentlyPlayingIndex = index;
      _controllers[index].play();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Videos"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: const Color(0xff22188),
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(40))),
                  labelText: 'Search',
                  hintStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                ),
                onChanged: (value) {
                  _authService.searchUsers(value);
                  Get.to(SearchScreenShowId());
                },
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_videoController.isLoading.value) {
                return const Center(
                  child: SpinKitCircle(
                    color: Colors.black38,
                    size: 50.0,
                  ),
                );
              } else if (_videoController.videoUrls.isNotEmpty) {
                return Expanded(
                    child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio:
                        2 / 3.5,
                  ),
                  itemCount: _videoController.videoUrls.length,
                  itemBuilder: (context, index) {
                    if (index >= _controllers.length ||
                        index >= _initialized.length) {
                      return const Center(
                          child: Text('Error: Index out of bounds'));
                    }
                    return VisibilityDetector(
                      key: Key('video_$index'),
                      onVisibilityChanged: (visibilityInfo) {
                        final visiblePercentage =
                            visibilityInfo.visibleFraction * 100;
                        if (visiblePercentage > 50) {
                          if (_currentlyPlayingIndex == index &&
                              !_controllers[index].value.isPlaying) {
                            _controllers[index].play();
                          }
                        } else {
                          if (_currentlyPlayingIndex == index &&
                              _controllers[index].value.isPlaying) {
                            _controllers[index].pause();
                          }
                        }
                      },
                      child: GestureDetector(
                        onTap: () => _playVideo(index),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            alignment: Alignment.bottomLeft,
                            children: [
                              _initialized[index]
                                  ? AspectRatio(
                                      aspectRatio:
                                          _controllers[index].value.aspectRatio,
                                      child: VideoPlayer(_controllers[index]),
                                    )
                                  : Center(
                                      child: SpinKitCircle(
                                        color: Colors
                                            .blue, // Customize spinner color
                                        size: 50.0, // Customize spinner size
                                      ),
                                    ),
                              Positioned(
                                bottom: 8.0,
                                left: 8.0,
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 5.0,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        backgroundImage: _videoController
                                                    .videoProfileImages.length >
                                                index
                                            ? NetworkImage(_videoController
                                                .videoProfileImages[index])
                                            : NetworkImage(
                                                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT8NYnGDqrQm-gbf4fbXkaMBzmVLlf2rZdOLA&s"),
                                        backgroundColor: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(width: 8.0),
                                    Text(
                                      _videoController.videoUsernames.length >
                                              index
                                          ? _videoController
                                              .videoUsernames[index]
                                          : 'Unknown',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_currentlyPlayingIndex != index &&
                                  !_controllers[index].value.isPlaying)
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.play_circle,
                                      size: 60,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ));
              } else {
                return Center(child: Text('No videos available'));
              }
            }),
          ),
        ],
      ),
    );
  }
}
