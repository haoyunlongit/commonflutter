import 'package:flutter/material.dart';

class Popover {
  final BuildContext context;
  final Widget Function() builder;

  OverlayEntry? _overlayEntry;

  Popover({
    required this.context,
    required this.builder,
  });

  void show({double? top,
    double? right,
    double? bottom,
    double? left, }) {
    // 创建 overlay entry
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => dismiss(),
          child: Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned(
                  top: top,
                  right: right,
                  bottom: bottom,
                  left: left,
                  child: builder(),
                ),
              ],
            ),
          ),
        );
      },
    );

    // 将 overlay entry 添加到 overlay 中并显示
    Overlay.of(context).insert(_overlayEntry!);
  }

  void dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
