import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class PostsSearchPage extends StatefulWidget {
  const PostsSearchPage({
    super.key,
    this.query,
    this.orderPoolsByOldest = true,
    this.readerMode = false,
  });

  final QueryMap? query;
  final bool orderPoolsByOldest;
  final bool readerMode;

  @override
  State<PostsSearchPage> createState() => _PostsSearchPageState();
}

class _PostsSearchPageState extends State<PostsSearchPage> {
  late bool readerMode = widget.readerMode;
  bool loadingInfo = true;
  Pool? pool;
  Follow? follow;
  QueryMap? lastQuery;

  @override
  Widget build(BuildContext context) {
    return PostsProvider(
      query: widget.query,
      orderPools: widget.orderPoolsByOldest,
      child: Consumer3<PostsController, FollowsService, Client>(
        builder: (context, controller, follows, client, child) {
          Future<void> updateFollow() async {
            follow = await follows.follow(
              controller.query['tags'] ?? '',
            );
            if (follow != null) {
              Follow updated = follow!;
              if (controller.items?.isNotEmpty ?? false) {
                updated = follow!.withLatest(
                  controller.items!.first,
                  foreground: mounted,
                );
              }
              if (pool != null) {
                updated = updated.withPool(pool!);
              }
              if (updated != follow) {
                await follows.replace(updated);
              }
              setState(() => follow = updated);
            }
          }

          Future<void> updatePool() async {
            if (!mounted) return;
            setState(() {
              loadingInfo = true;
            });
            RegExpMatch? match =
                poolRegex().firstMatch(controller.query['tags'] ?? '');
            if (match != null) {
              if (match.namedGroup('id')! != pool?.id.toString()) {
                try {
                  pool = await client.pool(
                    id: int.parse(match.namedGroup('id')!),
                  );
                } on ClientException {
                  pool = null;
                }
              }
            } else {
              pool = null;
            }
            if (!mounted) return;
            setState(() {
              loadingInfo = false;
            });
          }

          Future<void> updateSearch() async {
            if (!mounted) return;
            if (mapEquals(lastQuery, controller.query)) return;
            lastQuery = controller.query;
            HistoriesService historiesService =
                context.read<HistoriesService>();
            await updatePool();
            await controller.waitForNextPage();
            if (controller.error != null) return;
            await updateFollow();
            if (pool != null) {
              historiesService.addPool(pool!, posts: controller.items);
            } else {
              historiesService.addPostSearch(controller.query,
                  posts: controller.items);
            }
          }

          String getTitle() {
            if (follow != null) {
              return follow!.name;
            }
            if (pool != null) {
              return tagToName(pool!.name);
            }
            TagMap tags = TagMap.parse(controller.query['tags'] ?? '');
            if (tags.length == 1) {
              return tagToName(tags.toString());
            }
            return 'Search';
          }

          return SubListener(
            initialize: true,
            listenable: controller,
            listener: () => WidgetsBinding.instance
                .addPostFrameCallback((_) => updateSearch()),
            builder: (context) => PostsPage(
              controller: controller,
              displayType: readerMode ? PostDisplayType.comic : null,
              appBar: DefaultAppBar(
                title: Text(getTitle()),
                actions: [
                  CrossFade(
                    showChild: !loadingInfo &&
                        (controller.query['tags']?.trim().isNotEmpty ?? false),
                    child: IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: pool != null
                          ? () => showPoolPrompt(context: context, pool: pool!)
                          : () => showTagSearchPrompt(
                                context: context,
                                tag: controller.query['tags'] ?? '',
                              ),
                    ),
                  ),
                  const ContextDrawerButton(),
                ],
              ),
              drawerActions: [
                if (pool != null)
                  Builder(
                    builder: (context) => PoolReaderSwitch(
                      readerMode: readerMode,
                      onChange: (value) {
                        setState(() => readerMode = value);
                        Scaffold.of(context).closeEndDrawer();
                      },
                    ),
                  ),
                if (pool != null)
                  AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) => PoolOrderSwitch(
                      oldestFirst: controller.orderPools,
                      onChange: (value) {
                        controller.orderPools = value;
                        Scaffold.of(context).closeEndDrawer();
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
