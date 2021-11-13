import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

class DialogActionController extends ActionController {
  NavigatorState? navigator;

  @override
  void onSucess() async {
    await navigator!.maybePop();
    navigator = null;
  }

  @override
  void reset() {
    navigator = null;
    super.reset();
  }

  Future<void> show(BuildContext context, Widget child) async {
    return showDialog(context: context, builder: (context) => child);
  }

  void connect(BuildContext context) {
    navigator = Navigator.of(context);
  }
}

class LoadingDialog extends StatefulWidget {
  final Widget? title;
  final ControllerAction submit;
  final Widget Function(
    BuildContext context,
    ActionController controller,
  ) builder;

  const LoadingDialog({
    this.title,
    required this.submit,
    required this.builder,
  });

  @override
  _LoadingDialogState createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> {
  DialogActionController controller = DialogActionController();

  @override
  void initState() {
    super.initState();
    controller.setAction(widget.submit);
    controller.connect(context);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => AlertDialog(
        title: widget.title,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Row(
                children: [
                  CrossFade(
                    showChild: controller.isLoading,
                    child: Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedCircularProgressIndicator(size: 16),
                    ),
                  ),
                  Expanded(
                    child: widget.builder(context, controller),
                  ),
                ],
              ),
            ),
            SafeCrossFade(
              showChild: controller.isError,
              builder: (context) => Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: Theme.of(context).errorColor,
                        fontSize: 14,
                      ),
                  child: IconTheme(
                    data: Theme.of(context).iconTheme.copyWith(
                          color: Theme.of(context).errorColor,
                          size: 14,
                        ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(Icons.warning_amber_outlined),
                        ),
                        Text(controller.error!.message)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('CANCEL'),
            onPressed: Navigator.of(context).maybePop,
          ),
          TextButton(
            child: Text('OK'),
            onPressed: controller.isLoading ? null : controller.action,
          ),
        ],
      ),
    );
  }
}