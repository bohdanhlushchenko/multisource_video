import 'package:flutter/material.dart';
import 'package:pip_video/controllers/overlay_handler_controller.dart';
import 'package:provider/provider.dart';

class VideoOverlayWidget extends StatefulWidget {
  final VoidCallback onClear;
  final Widget child;

  const VideoOverlayWidget({Key? key, required this.onClear, required this.child}) : super(key: key);

  @override
  State<VideoOverlayWidget> createState() => _VideoOverlayWidgetState();
}

class _VideoOverlayWidgetState extends State<VideoOverlayWidget> {
  late double width = MediaQuery.of(context).size.width;
  late double oldWidth = MediaQuery.of(context).size.width;
  late double oldHeight = MediaQuery.of(context).size.height;
  late double height = MediaQuery.of(context).size.height;
  bool _isInPipMode = false;
  Offset _offset = const Offset(0, 0);

  double get _videoHeightPip => MediaQuery.of(context).size.width * 0.5;

  void _onExitPipMode() {
    Future.microtask(() {
      setState(() {
        _isInPipMode = false;
        width = oldWidth;
        height = oldHeight;
        _offset = const Offset(0, 0);
      });
    });
    Future.delayed(const Duration(milliseconds: 250), Provider.of<OverlayHandlerController>(context, listen: false).disablePip);
  }

  void _onPipMode() {
    final aspectRatio = Provider.of<OverlayHandlerController>(context, listen: false).aspectRatio;
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isInPipMode = true;
          width = _videoHeightPip;
          height = width / aspectRatio;
          _offset = Offset(oldWidth - width, oldHeight - height - 30);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OverlayHandlerController>(builder: (context, overlayProvider, _) {
      if (overlayProvider.inPipMode != _isInPipMode) {
        _isInPipMode = overlayProvider.inPipMode;
        if (_isInPipMode) {
          _onPipMode();
        } else {
          _onExitPipMode();
        }
      }
      return AnimatedPositioned(
        duration: const Duration(milliseconds: 150),
        left: _offset.dx,
        top: _offset.dy,
        child: Draggable(
          feedback: Container(),
          onDragUpdate: (details) {
            if (!_isInPipMode) return;
            if (details.globalPosition.dx >= 0 &&
                details.globalPosition.dx < (oldWidth - _videoHeightPip) &&
                details.globalPosition.dy >= 48.0 &&
                details.globalPosition.dy < (oldHeight - _videoHeightPip - 30)) {
              setState(() {
                _offset = details.globalPosition;
              });
            }
          },
          onDragEnd: (details) {
            if (details.velocity.pixelsPerSecond.dx < -1000) {
              widget.onClear();
            }
          },
          child: AnimatedContainer(
            height: height,
            width: width,
            duration: const Duration(milliseconds: 250),
            child: widget.child,
          ),
        ),
      );
    });
  }
}
