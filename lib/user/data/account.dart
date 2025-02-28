import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';
part 'account.g.dart';

@freezed
class Account with _$Account {
  const factory Account({
    required int id,
    required String name,
    required int? avatarId,
    required String? blacklistedTags,
    required int? perPage,
  }) = _Account;

  factory Account.fromJson(dynamic json) => _$AccountFromJson(json);
}

extension E621Account on Account {
  static Account fromJson(dynamic json) => Account.fromJson(json);
}
