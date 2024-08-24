import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserDetailScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  UserDetailScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    final profileImageUrl = user['profileImageUrl'] as String?;
    final userName = user['name'] as String?;
    final videos = user['videos'] as List<dynamic>?; // List of video URLs

    return Scaffold(
      appBar: AppBar(
        title: Text(userName ?? 'User Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                    ? CachedNetworkImageProvider(profileImageUrl)
                    : AssetImage('assets/default_profile.png') as ImageProvider,
                backgroundColor: Colors.grey[200],
                child: profileImageUrl == null || profileImageUrl.isEmpty
                    ? Icon(Icons.person, size: 50, color: Colors.grey[700])
                    : null,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              userName ?? 'No name provided',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              'Videos:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: videos?.length ?? 0,
                itemBuilder: (context, index) {
                  final videoUrl = videos?[index] as String?;
                  return videoUrl != null && videoUrl.isNotEmpty
                      ? VideoPlayerItem(videoUrl: videoUrl)
                      : Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: Center(child: Text('No video available')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;

  VideoPlayerItem({required this.videoUrl});

  @override
  _VideoPlayerItemState createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _controller;
  bool _isVideoReady = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isVideoReady = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isVideoReady
        ? AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    )
        : Center(child: CircularProgressIndicator());
  }
}
