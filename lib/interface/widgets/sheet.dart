import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

class SheetActions extends InheritedNotifier {
  final SheetActionController controller;

  SheetActions({required Widget child, required this.controller})
      : super(child: child, notifier: controller);

  static SheetActionController? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SheetActions>()
        ?.controller;
  }
}

class SheetActionController extends ActionController {
  PersistentBottomSheetController? sheetController;
  bool get isShown => sheetController != null;
  void close() => sheetController?.close.call();

  @override
  void onSucess() {
    sheetController!.close();
  }

  @override
  void reset() {
    sheetController = null;
    super.reset();
  }

  @override
  void setAction(ActionControllerCallback submit) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      super.setAction(submit);
    });
  }

  void show(BuildContext context, Widget child) {
    sheetController = Scaffold.of(context).showBottomSheet(
      (context) => ActionBottomSheet(child: child, controller: this),
    );
    sheetController!.closed.then((_) => reset());
  }
}

class ActionBottomSheet extends StatelessWidget {
  final Widget child;
  final SheetActionController controller;

  const ActionBottomSheet({required this.controller, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) => Padding(
        padding: EdgeInsets.all(10).copyWith(top: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CrossFade(
                  showChild: controller.isLoading,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: SizedCircularProgressIndicator(size: 16),
                    ),
                  ),
                ),
                CrossFade(
                  showChild: controller.isError && !controller.isForgiven,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Icon(
                        Icons.clear,
                        color: Theme.of(context).errorColor,
                      ),
                    ),
                  ),
                ),
                Expanded(child: child!),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class SheetFloatingActionButton extends StatefulWidget {
  final IconData actionIcon;
  final IconData? confirmIcon;
  final SheetActionController? controller;
  final Widget Function(BuildContext context, ActionController actionController)
      builder;

  const SheetFloatingActionButton(
      {required this.builder,
      required this.actionIcon,
      this.controller,
      this.confirmIcon});

  @override
  _SheetFloatingActionButtonState createState() =>
      _SheetFloatingActionButtonState();
}

class _SheetFloatingActionButtonState extends State<SheetFloatingActionButton> {
  late SheetActionController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? SheetActionController();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => FloatingActionButton(
        child: controller.isShown
            ? Icon(widget.confirmIcon ?? Icons.check)
            : Icon(widget.actionIcon),
        onPressed: controller.isLoading
            ? null
            : controller.action ??
                () async {
                  controller.show(
                    context,
                    widget.builder(context, controller),
                  );
                },
      ),
    );
  }
}

Future<void> showDefaultSlidingBottomSheet(
    BuildContext context, SheetBuilder builder) async {
  return showSlidingBottomSheet(
    context,
    builder: (context) => defaultSlidingSheetDialog(
      context,
      builder,
    ),
  );
}

SlidingSheetDialog defaultSlidingSheetDialog(
    BuildContext context, SheetBuilder builder) {
  return SlidingSheetDialog(
    scrollSpec: ScrollSpec(physics: const ClampingScrollPhysics()),
    duration: Duration(milliseconds: 400),
    avoidStatusBar: true,
    isBackdropInteractable: true,
    cornerRadius: 16,
    cornerRadiusOnFullscreen: 0,
    minHeight: 600,
    maxWidth: 600,
    builder: builder,
    snapSpec: SnapSpec(
      snap: true,
      positioning: SnapPositioning.relativeToAvailableSpace,
      snappings: [
        0.6,
        SnapSpec.expanded,
      ],
    ),
  );
}

class DefaultSheetBody extends StatelessWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget body;

  const DefaultSheetBody({
    Key? key,
    this.title,
    this.actions,
    required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null || actions != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: DefaultTextStyle(
                        child: title!,
                        style: Theme.of(context).textTheme.headline6!,
                      ),
                    ),
                  ),
                  if (actions != null)
                    Row(
                      children: actions!,
                    ),
                ],
              ),
            Padding(
              padding: EdgeInsets.all(16),
              child: body,
            ),
          ],
        ),
      ),
    );
  }
}
