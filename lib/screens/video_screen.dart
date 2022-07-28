import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:pip_video/controllers/multisource_video_controller.dart';
import 'package:pip_video/screens/another_screen.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({Key? key}) : super(key: key);

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final _controller = MultiSourceVideoController(
    url: 'https://vimeo.com/51106808',
    source: VideoSource.vimeo,
    configuration: const BetterPlayerConfiguration(handleLifecycle: false),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          BetterPlayer(controller: _controller),
          const SizedBox(height: 20),
          TextButton(
            onPressed: _navigateToNextPage,
            child: const Text('Go to next screen'),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToNextPage() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AnotherScreen(),
      ),
    );
  }
}
