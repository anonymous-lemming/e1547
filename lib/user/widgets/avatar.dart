import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_sub/flutter_sub.dart';

class AccountAvatar extends StatelessWidget {
  const AccountAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountAvatarController>(
      builder: (context, controller, child) {
        if (controller.error != null) {
          return CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: const Icon(Icons.warning_amber),
          );
        }

        return UserAvatar(
          id: controller.items?.firstOrNull?.id,
          controller: controller,
        );
      },
    );
  }
}

class AccountAvatarController extends PostsController {
  AccountAvatarController({
    required super.client,
  }) : super(filterMode: PostFilterMode.unavailable);

  @override
  Future<List<Post>> fetch(int page, bool force) async {
    if (page != firstPageKey) return [];
    int? id = (await client.account())?.avatarId;
    if (id == null) return [];
    return [
      await client.post(
        id,
        force: force,
        cancelToken: cancelToken,
      ),
    ];
  }
}

class AccountAvatarProvider
    extends SubChangeNotifierProvider<Client, AccountAvatarController> {
  AccountAvatarProvider({super.child, TransitionBuilder? builder})
      : super(
          create: (context, client) =>
              AccountAvatarController(client: client)..getNextPage(),
          builder: (context, child) => SubEffect(
            effect: () {
              Future(() async {
                PostsController? controller =
                    context.read<AccountAvatarController>();
                await controller.waitForNextPage();
                Post? avatar = controller.items?.firstOrNull;
                if (avatar?.sample != null && context.mounted) {
                  await preloadPostImage(
                    context: context,
                    post: avatar!,
                    size: PostImageSize.sample,
                  );
                }
              });
              return null;
            },
            keys: [context.watch<AccountAvatarController>()],
            child: builder?.call(context, child) ?? child!,
          ),
        );
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.controller, required this.id});

  final PostsController? controller;
  final int? id;

  @override
  Widget build(BuildContext context) {
    int? id = this.id;
    PostsController? controller = this.controller;
    if (id == null || controller == null) {
      return const EmptyAvatar();
    }
    return SubFuture<PostsController>(
      create: () => Future<PostsController>(() async {
        await controller.getNextPage();
        return controller;
      }),
      keys: [controller],
      builder: (context, _) => PostsControllerConnector(
        id: id,
        controller: controller,
        builder: (context, post) => Avatar(
          post,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PostsControllerConnector(
                  id: id,
                  controller: controller,
                  builder: (context, post) => PostsRouteConnector(
                    controller: controller,
                    child: PostDetail(post: post!),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PostAvatar extends StatelessWidget {
  const PostAvatar({super.key, required this.id});

  final int? id;

  @override
  Widget build(BuildContext context) {
    if (id == null) {
      return const EmptyAvatar();
    } else {
      return SinglePostProvider(
        id: id!,
        child: Consumer<PostsController>(
          builder: (context, controller, child) =>
              UserAvatar(id: id, controller: controller),
        ),
      );
    }
  }
}

class Avatar extends StatelessWidget {
  const Avatar(
    this.post, {
    super.key,
    this.onTap,
    this.radius = 20,
  });

  final Post? post;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (post?.sample != null) {
      return MouseCursorRegion(
        onTap: onTap,
        child: PostTileOverlay(
          post: post!,
          child: Container(
            decoration: const BoxDecoration(shape: BoxShape.circle),
            clipBehavior: Clip.antiAlias,
            width: radius * 2,
            height: radius * 2,
            child: CachedNetworkImage(
              fadeInDuration: Duration.zero,
              fadeOutDuration: Duration.zero,
              imageUrl: post!.sample!,
              fit: BoxFit.cover,
              cacheManager: context.read<BaseCacheManager>(),
              placeholder: (context, url) => const EmptyAvatar(),
              errorWidget: (context, url, error) => const Center(
                child: Icon(Icons.warning_amber),
              ),
            ),
          ),
        ),
      );
    } else {
      return const EmptyAvatar();
    }
  }
}

class EmptyAvatar extends StatelessWidget {
  const EmptyAvatar({
    super.key,
    this.radius = 20,
  });

  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(shape: BoxShape.circle),
        clipBehavior: Clip.antiAlias,
        width: radius * 2,
        height: radius * 2,
        child: Image.asset('assets/icon/app/user.png'),
      );
}
