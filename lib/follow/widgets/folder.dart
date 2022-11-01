import 'dart:async';

import 'package:async_builder/async_builder.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/data/service.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FollowsFolderPage extends StatefulWidget {
  const FollowsFolderPage({super.key});

  @override
  State<FollowsFolderPage> createState() => _FollowsFolderPageState();
}

class _FollowsFolderPageState extends State<FollowsFolderPage> {
  final RefreshController refreshController = RefreshController();
  final SheetActionController sheetController = SheetActionController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => update(),
    );
  }

  Future<void> update([bool? force]) async =>
      context.read<FollowsUpdater>().update(
            client: context.read<Client>(),
            denylist: context.read<DenylistService>().items,
            force: force,
          );

  Future<void> updateRefresh() async {
    FollowsUpdater updater = context.read<FollowsUpdater>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (updater.remaining > 0 && mounted) {
        if (refreshController.headerMode?.value == RefreshStatus.idle) {
          await refreshController.requestRefresh(
            needCallback: false,
            duration: const Duration(milliseconds: 100),
          );
          await updater.finish;
          if (mounted) {
            ScrollController? scrollController =
                PrimaryScrollController.of(context);
            if (scrollController?.hasClients ?? false) {
              scrollController?.animateTo(
                0,
                duration: defaultAnimationDuration,
                curve: Curves.easeInOut,
              );
            }
            if (updater.error == null) {
              refreshController.refreshCompleted();
            } else {
              refreshController.refreshFailed();
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FollowsService, Client>(
      builder: (context, service, client, child) => ListenableListener(
        listenable: context.watch<FollowsUpdater>(),
        listener: updateRefresh,
        child: SubValueBuilder<Stream<List<Follow>>>(
          create: (context) => service.watchAll(host: client.host),
          selector: (context) => [client, service],
          builder: (context, value) =>
              SubValueBuilder<StreamSubscription<List<Follow>>>(
            create: (context) => value.listen((event) => update()),
            dispose: (context, value) => value.cancel(),
            selector: (context) => [value],
            builder: (context, _) => AsyncBuilder<List<Follow>>(
              stream: value,
              builder: (context, follows) => SheetActions(
                controller: sheetController,
                child: RefreshableLoadingPage(
                  onEmpty: const Text('No follows'),
                  onError: const Text('Failed to load follows'),
                  isError: false,
                  isBuilt: follows != null,
                  isLoading: follows == null,
                  isEmpty: follows?.isEmpty ?? false,
                  refreshController: refreshController,
                  refreshHeader: RefreshablePageDefaultHeader(
                    refreshingText:
                        'Refreshing ${context.watch<FollowsUpdater>().remaining} follows...',
                  ),
                  builder: (context, child) => TileLayout(child: child),
                  child: (context) => AlignedGridView.count(
                    primary: true,
                    padding: defaultActionListPadding,
                    addAutomaticKeepAlives: false,
                    itemCount: follows?.length ?? 0,
                    itemBuilder: (context, index) => FollowTile(
                      follow: follows![index],
                    ),
                    crossAxisCount: TileLayout.of(context).crossAxisCount,
                  ),
                  appBar: const DefaultAppBar(
                    title: Text('Follows'),
                    actions: [ContextDrawerButton()],
                  ),
                  refresh: () async {
                    try {
                      await update(true);
                      refreshController.refreshCompleted();
                    } on DioError {
                      refreshController.refreshFailed();
                    }
                  },
                  drawer: const NavigationDrawer(),
                  endDrawer: ContextDrawer(
                    title: const Text('Follows'),
                    children: [
                      if (context.findAncestorWidgetOfExactType<
                              FollowsSwitcherPage>() !=
                          null)
                        const FollowSwitcherTile(),
                      const FollowEditingTile(),
                      const Divider(),
                      const FollowMarkReadTile(),
                    ],
                  ),
                  floatingActionButton: Builder(
                    builder: (context) => AnimatedBuilder(
                      animation: SheetActions.of(context),
                      builder: (context, child) => SheetFloatingActionButton(
                        builder: (context, actionController) =>
                            ControlledTextWrapper(
                          submit: (value) {
                            value = value.trim();
                            if (value.isNotEmpty) {
                              service.addTag(client.host, value);
                            }
                          },
                          actionController: actionController,
                          builder: (context, controller, submit) => TagInput(
                            controller: controller,
                            textInputAction: TextInputAction.done,
                            labelText: 'Add to follows',
                            submit: submit,
                          ),
                        ),
                        actionIcon: Icons.add,
                        confirmIcon: Icons.check,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}