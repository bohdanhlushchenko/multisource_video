import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class VideoModel {
  final String title;
  final String author;
  final String imageUrl;
  final double aspectRatio;
  final Map<String, String> urls;

  const VideoModel(this.title, this.author, this.imageUrl, this.aspectRatio, this.urls);

  bool get isPortrait => aspectRatio < 1;

  factory VideoModel.fromYoutube(Video video, UnmodifiableListView<MuxedStreamInfo> muxed) {
    final urls = _sortQualityVideoUrls(
      muxed.map((e) => e.qualityLabel),
      muxed.map((e) => e.url.toString()),
    );
    final aspectRatio = muxed.fold<double>(1, (p, e) => e.videoResolution.width / e.videoResolution.height);
    return VideoModel(video.title, video.author, video.thumbnails.standardResUrl, aspectRatio, urls);
  }

  factory VideoModel.fromVimeo(Map<String, dynamic> json) {
    final videoInfo = json['request']['files']['progressive'] as List;
    final filteredVideoInfo = videoInfo.where((e) => e['quality'] is String && e['url'] is String);
    final urls = _sortQualityVideoUrls(
      filteredVideoInfo.map((e) => e['quality'] as String),
      filteredVideoInfo.map((e) => e['url'] as String),
    );
    final width = (json['video']['width'] as num? ?? 0).toDouble();
    final height = (json['video']['height'] as num? ?? 0).toDouble();
    final aspectRatio = width / height;
    return VideoModel(
      json['video']['title'] as String? ?? '',
      json['video']['owner']['name'] as String? ?? '',
      json['video']['thumbs']['base'] as String? ?? '',
      aspectRatio,
      urls,
    );
  }

  static Map<String, String> _sortQualityVideoUrls(
    Iterable<String> qualities,
    Iterable<String> url,
  ) {
    final urls = SplayTreeMap<String, String>.fromIterables(
      qualities,
      url,
      (a, b) => a.qualityInteger.compareTo(b.qualityInteger),
    );
    urls.removeWhere((key, value) => key.qualityInteger == 240);
    if (kIsWeb) {
      urls.removeWhere((key, value) => key.qualityInteger == 144);
    }
    return urls;
  }
}

extension Quality on String {
  int get qualityInteger => int.parse(split('p').firstOrNull ?? '0');
}
