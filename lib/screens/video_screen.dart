import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:pip_video/controllers/multisource_video_controller.dart';
import 'package:pip_video/controllers/overlay_handler_controller.dart';
import 'package:pip_video/screens/another_screen.dart';
import 'package:pip_video/widgets/video_overlay_widget.dart';
import 'package:provider/provider.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({Key? key}) : super(key: key);

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final _playerKey = GlobalKey();
  final _controller = MultiSourceVideoController(
    url: 'https://vimeo.com/51106808',
    source: VideoSource.vimeo,
    configuration: const BetterPlayerConfiguration(handleLifecycle: false),
  );
  late final _player = BetterPlayer(key: _playerKey, controller: _controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Consumer<OverlayHandlerController>(
            builder: (context, controller, child) {
              if (controller.inPipMode) {
                return const SizedBox.shrink();
              } else {
                return _player;
              }
            },
          ),
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
    await _controller.pause();
    final overlayEntry = OverlayEntry(
      builder: (context) => VideoOverlayWidget(
        onClear: () {
          Provider.of<OverlayHandlerController>(context, listen: false).removeOverlay(context);
        },
        child: _player,
      ),
    );
    if (!mounted) return;
    Provider.of<OverlayHandlerController>(context, listen: false).insertOverlay(context, overlayEntry, _controller.aspectRatio);
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => const AnotherScreen(),
      ),
    )
        .then((_) {
      Provider.of<OverlayHandlerController>(context, listen: false).removeOverlay(context);
    });
    await _controller.play();
  }
}
