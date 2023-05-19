import 'package:flutter/cupertino.dart';

import '../common_widget/popover_view.dart';

///以父视图为基准 弹出弹窗
Popover? showPopover(BuildContext context, Widget popWidget) {
  double screenWidth = MediaQuery.of(context).size.width;
  final RenderBox box = context.findRenderObject() as RenderBox;
  ///父视图相对与屏幕的坐标
  final Offset targetGlobalCenter =
  box.localToGlobal(box.size.center(Offset.zero));
  final Size size = box.size;
  ///左下角的坐标
  double dx = targetGlobalCenter.dx - size.width / 2;
  double dy = targetGlobalCenter.dy + size.height / 2 + 10;

  Popover? popover;
  popover = Popover(
      context: context,
      builder: () => popWidget
  );
  popover.show(right: screenWidth - dx, top: dy);
  return popover;
}