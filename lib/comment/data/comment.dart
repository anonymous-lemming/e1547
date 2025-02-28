import 'package:deep_pick/deep_pick.dart';
import 'package:e1547/interface/interface.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment.freezed.dart';
part 'comment.g.dart';

@freezed
class Comment with _$Comment {
  const factory Comment({
    required int id,
    required int postId,
    required String body,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int creatorId,
    required String creatorName,
    required VoteInfo? vote,
    required CommentWarning? warning,
  }) = _Comment;

  factory Comment.fromJson(dynamic json) => _$CommentFromJson(json);
}

@freezed
class CommentWarning with _$CommentWarning {
  const factory CommentWarning({
    required WarningType? type,
  }) = _CommentWarning;

  factory CommentWarning.fromJson(dynamic json) =>
      _$CommentWarningFromJson(json);
}

@JsonEnum()
enum WarningType {
  warning,
  record,
  ban;

  String get message {
    switch (this) {
      case warning:
        return 'User received a warning for this message';
      case record:
        return 'User received a record for this message';
      case ban:
        return 'User was banned for this message';
    }
  }
}

extension E621Comment on Comment {
  static Comment fromJson(dynamic json) => pick(json).letOrThrow(
        (pick) => Comment(
          id: pick('id').asIntOrThrow(),
          postId: pick('post_id').asIntOrThrow(),
          body: pick('body').asStringOrThrow(),
          createdAt: pick('created_at').asDateTimeOrThrow(),
          updatedAt: pick('updated_at').asDateTimeOrThrow(),
          creatorId: pick('creator_id').asIntOrThrow(),
          creatorName: pick('creator_name').asStringOrThrow(),
          vote: VoteInfo(
            score: pick('score').asIntOrThrow(),
          ),
          warning: CommentWarning(
            type: pick('warning_type').letOrNull(
                (pick) => WarningType.values.asNameMap()[pick.asString()]!),
          ),
        ),
      );
}
