import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

Future<void> postDownloadingSnackbar(
  BuildContext context,
  Set<Post> items,
) async =>
    loadingSnackbar<Post>(
      context: context,
      timeout: Duration(milliseconds: 100),
      process: (Post item) => item.download(),
      items: items,
      onDone: (items) => items.length == 1
          ? 'Downloaded post #${items.first.id}'
          : 'Downloaded ${items.length} posts',
      onProgress: (items, index) => items.length == 1
          ? 'Downloading Post #${items.first.id}'
          : 'Downloading Post #${items.elementAt(index).id} ($index/${items.length})',
      onFailure: (items, index) =>
          'Failed to download post #${items.elementAt(index).id}',
      onCancel: (items, index) => 'Cancelled download',
    );

Future<void> postFavoritingSnackbar(
  BuildContext context,
  Set<Post> items,
  bool isLiked,
) =>
    loadingSnackbar<Post>(
      context: context,
      items: items,
      timeout: Duration(milliseconds: 300),
      process: isLiked
          ? (post) async {
              if (post.isFavorited) {
                return post.tryRemoveFav(context);
              } else {
                return true;
              }
            }
          : (post) async {
              if (!post.isFavorited) {
                return post.tryAddFav(context);
              } else {
                return true;
              }
            },
      onDone: (items) => items.length == 1
          ? 'Favorited post #${items.first.id}'
          : 'Favorited ${items.length} posts',
      onProgress: (items, index) => items.length == 1
          ? 'Favoriting Post #${items.first.id}'
          : 'Favoriting Post #${items.elementAt(index).id} ($index/${items.length})',
      onFailure: (items, index) =>
          'Failed to favorite post #${items.elementAt(index).id}',
      onCancel: (items, index) => 'Cancelled favoriting',
    );
