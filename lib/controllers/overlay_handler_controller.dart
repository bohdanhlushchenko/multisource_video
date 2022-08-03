import 'package:flutter/material.dart';

class OverlayHandlerController with ChangeNotifier {
  OverlayEntry? _overlayEntry;
  double _aspectRatio = 16 / 9;
  bool _inPipMode = false;

  void disablePip() {
    _inPipMode = false;
    notifyListeners();
  }

  bool get inPipMode => _inPipMode;
  bool get overlayActive => _overlayEntry != null;
  double get aspectRatio => _aspectRatio;

  void insertOverlay(BuildContext context, OverlayEntry overlay, double aspectRatio) {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _inPipMode = true;
    _aspectRatio = aspectRatio;
    _overlayEntry = overlay;
    notifyListeners();
    Overlay.of(context)?.insert(overlay);
  }

  void removeOverlay(BuildContext context) {
    _inPipMode = false;
    _overlayEntry?.remove();
    _overlayEntry = null;
    notifyListeners();
  }
}
