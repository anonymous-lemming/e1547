import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/markup/markup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<bool> replyComment({
  required BuildContext context,
  required Comment comment,
}) {
  String body = comment.body;
  body = body
      .replaceFirstMapped(
        RegExp(
          r'\[quote\]"[\S\s]*?":/user(s|/show)/\d* said:[\S\s]*?\[/quote\]',
        ),
        (match) => '',
      )
      .trim();
  body =
      '[quote]"${comment.creatorName}":/users/${comment.creatorId} said:\n$body[/quote]\n';
  return writeComment(context: context, postId: comment.postId, text: body);
}

Future<bool> editComment({
  required BuildContext context,
  required Comment comment,
}) =>
    writeComment(
      postId: comment.postId,
      context: context,
      comment: comment,
    );

Future<bool> writeComment({
  required BuildContext context,
  required int postId,
  String? text,
  Comment? comment,
}) async {
  bool sent = false;
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => DTextEditor(
        title: Text('#$postId comment'),
        content: text ?? (comment?.body),
        onSubmit: (text) async {
          NavigatorState navigator = Navigator.of(context);
          if (text.isNotEmpty) {
            try {
              if (comment == null) {
                await context
                    .read<Client>()
                    .postComment(postId: postId, content: text);
              } else {
                await context.read<Client>().updateComment(
                      id: comment.id,
                      postId: postId,
                      content: text,
                    );
              }
              sent = true;
              navigator.maybePop();
            } on ClientException {
              return 'Failed to send comment!';
            }
          }
          return null;
        },
      ),
    ),
  );
  return sent;
}

extension Transitioning on Comment {
  String get hero => getCommentHero(id);
}

String getCommentHero(int id) => 'comment_$id';
