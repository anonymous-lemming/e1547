import 'dart:async';

import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

import 'appbar.dart';

class FrameController extends ChangeNotifier {
  final void Function(bool shown)? onToggle;
  Timer? frameToggler;
  bool visible;

  FrameController({this.onToggle, this.visible = false});

  static FrameController? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FrameData>()?.notifier;

  void showFrame({Duration? duration}) =>
      toggleFrame(shown: true, duration: duration);

  void hideFrame({Duration? duration}) =>
      toggleFrame(shown: false, duration: duration);

  void toggleFrame({bool? shown, Duration? duration}) {
    bool result = shown ?? !visible;
    if (result == visible) {
      return;
    }
    frameToggler?.cancel();
    void toggle() {
      visible = result;
      notifyListeners();
      onToggle?.call(visible);
    }

    if (duration == null) {
      toggle();
    } else {
      frameToggler = Timer(duration, toggle);
    }
  }

  void cancel() => frameToggler?.cancel();

  @override
  void dispose() {
    cancel();
    super.dispose();
  }
}

class FrameData extends InheritedNotifier<FrameController> {
  FrameData({required Widget child, required FrameController controller})
      : super(child: child, notifier: controller);
}

class PostFullscreenFrame extends StatefulWidget {
  final Post post;
  final Widget child;
  final FrameController? controller;

  const PostFullscreenFrame({
    required this.child,
    required this.post,
    this.controller,
  });

  @override
  _PostFullscreenFrameState createState() => _PostFullscreenFrameState();
}

class _PostFullscreenFrameState extends State<PostFullscreenFrame> {
  late FrameController controller = widget.controller ?? FrameController();

  @override
  void didUpdateWidget(PostFullscreenFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      controller.cancel();
    } else {
      if (oldWidget.controller == null) {
        controller.dispose();
      }
      controller = widget.controller ?? FrameController();
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FrameData(
      controller: controller,
      child: Scaffold(
        body: AnimatedBuilder(
          animation: controller,
          child: widget.child,
          builder: (contex, child) => Scaffold(
            extendBodyBehindAppBar: true,
            appBar: FrameAppBar(
              child: PostFullscreenAppBar(post: widget.post),
            ),
            body: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                controller.toggleFrame();
                if ((widget.post.controller?.value.isPlaying ?? false) &&
                    controller.visible) {
                  controller.hideFrame(duration: Duration(seconds: 2));
                }
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  child!,
                  if (widget.post.controller != null) ...[
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: VideoBar(videoController: widget.post.controller!),
                    ),
                    VideoButton(videoController: widget.post.controller!),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FrameChild extends StatelessWidget {
  final bool? shown;
  final Widget child;

  final Duration fadeOutDuration = Duration(milliseconds: 50);

  FrameChild({required this.child, this.shown});

  @override
  Widget build(BuildContext context) {
    FrameController? controller = FrameController.of(context);
    bool shown = this.shown ?? controller?.visible ?? true;

    Widget body() {
      return AnimatedOpacity(
        opacity: shown ? 1 : 0,
        duration: fadeOutDuration,
        child: IgnorePointer(
          ignoring: !shown,
          child: child,
        ),
      );
    }

    if (controller != null) {
      return AnimatedBuilder(
        child: child,
        animation: controller,
        builder: (context, child) => body(),
      );
    } else {
      return body();
    }
  }
}

class FrameAppBar extends StatelessWidget with AppBarBuilderWidget {
  final PreferredSizeWidget child;

  const FrameAppBar({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FrameChild(
      child: child,
    );
  }
}
