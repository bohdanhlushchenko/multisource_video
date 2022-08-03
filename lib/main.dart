import 'package:flutter/material.dart';
import 'package:pip_video/controllers/overlay_handler_controller.dart';
import 'package:pip_video/screens/video_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider<OverlayHandlerController>(
      create: (_) => OverlayHandlerController(),
      child: const MaterialApp(
        home: VideoScreen(),
      ),
    ),
  );
}
