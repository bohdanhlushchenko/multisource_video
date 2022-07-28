import 'dart:convert';

import 'package:better_player/better_player.dart';
import 'package:http/http.dart' as http;
import 'package:pip_video/models/video_model.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

enum VideoSource { youtube, vimeo }

class MultiSourceVideoController extends BetterPlayerController {
  MultiSourceVideoController({
    required this.url,
    required this.source,
    this.initialQuality,
    this.configuration,
  }) : super(configuration ?? const BetterPlayerConfiguration()) {
    initDataSource();
  }

  final String url;
  final VideoSource source;
  final int? initialQuality;
  final BetterPlayerConfiguration? configuration;

  Future<void> initDataSource() async {
    final videoModel = await _getVideoUrls(url, source);
    final urls = videoModel.urls;
    final initialUrl = initialQuality != null ? (urls['p$initialQuality'] ?? urls.values.last) : urls.values.last;
    super.setupDataSource(
      BetterPlayerDataSource.network(
        initialUrl,
        qualities: urls,
        notificationConfiguration: BetterPlayerNotificationConfiguration(
          showNotification: true,
          title: videoModel.title,
          author: videoModel.author,
          imageUrl: videoModel.imageUrl,
          activityName: 'MainActivity',
        ),
      ),
    );
  }

  Future<VideoModel> _getVideoUrls(String url, VideoSource source) async {
    if (source == VideoSource.youtube) {
      final yt = YoutubeExplode();
      final video = await yt.videos.get(url);
      final muxed = (await yt.videos.streamsClient.getManifest(url)).muxed;
      return VideoModel.fromYoutube(video, muxed);
    } else {
      final id = url.split('vimeo.com/').last;
      final response = await http.get(
        Uri.parse('https://player.vimeo.com/video/$id/config'),
      );
      final json = jsonDecode(response.body);
      return VideoModel.fromVimeo(json);
    }
  }
}
