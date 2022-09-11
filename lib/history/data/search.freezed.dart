// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'search.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

HistoriesSearch _$HistoriesSearchFromJson(Map<String, dynamic> json) {
  return _HistoriesSearch.fromJson(json);
}

/// @nodoc
mixin _$HistoriesSearch {
  DateTime? get date => throw _privateConstructorUsedError;

  Set<HistorySearchFilter> get searchFilters =>
      throw _privateConstructorUsedError;

  Set<HistoryTypeFilter> get typeFilters => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $HistoriesSearchCopyWith<HistoriesSearch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HistoriesSearchCopyWith<$Res> {
  factory $HistoriesSearchCopyWith(
          HistoriesSearch value, $Res Function(HistoriesSearch) then) =
      _$HistoriesSearchCopyWithImpl<$Res>;

  $Res call(
      {DateTime? date,
      Set<HistorySearchFilter> searchFilters,
      Set<HistoryTypeFilter> typeFilters});
}

/// @nodoc
class _$HistoriesSearchCopyWithImpl<$Res>
    implements $HistoriesSearchCopyWith<$Res> {
  _$HistoriesSearchCopyWithImpl(this._value, this._then);

  final HistoriesSearch _value;

  // ignore: unused_field
  final $Res Function(HistoriesSearch) _then;

  @override
  $Res call({
    Object? date = freezed,
    Object? searchFilters = freezed,
    Object? typeFilters = freezed,
  }) {
    return _then(_value.copyWith(
      date: date == freezed
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      searchFilters: searchFilters == freezed
          ? _value.searchFilters
          : searchFilters // ignore: cast_nullable_to_non_nullable
              as Set<HistorySearchFilter>,
      typeFilters: typeFilters == freezed
          ? _value.typeFilters
          : typeFilters // ignore: cast_nullable_to_non_nullable
              as Set<HistoryTypeFilter>,
    ));
  }
}

/// @nodoc
abstract class _$$_HistoriesSearchCopyWith<$Res>
    implements $HistoriesSearchCopyWith<$Res> {
  factory _$$_HistoriesSearchCopyWith(
          _$_HistoriesSearch value, $Res Function(_$_HistoriesSearch) then) =
      __$$_HistoriesSearchCopyWithImpl<$Res>;

  @override
  $Res call(
      {DateTime? date,
      Set<HistorySearchFilter> searchFilters,
      Set<HistoryTypeFilter> typeFilters});
}

/// @nodoc
class __$$_HistoriesSearchCopyWithImpl<$Res>
    extends _$HistoriesSearchCopyWithImpl<$Res>
    implements _$$_HistoriesSearchCopyWith<$Res> {
  __$$_HistoriesSearchCopyWithImpl(
      _$_HistoriesSearch _value, $Res Function(_$_HistoriesSearch) _then)
      : super(_value, (v) => _then(v as _$_HistoriesSearch));

  @override
  _$_HistoriesSearch get _value => super._value as _$_HistoriesSearch;

  @override
  $Res call({
    Object? date = freezed,
    Object? searchFilters = freezed,
    Object? typeFilters = freezed,
  }) {
    return _then(_$_HistoriesSearch(
      date: date == freezed
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      searchFilters: searchFilters == freezed
          ? _value._searchFilters
          : searchFilters // ignore: cast_nullable_to_non_nullable
              as Set<HistorySearchFilter>,
      typeFilters: typeFilters == freezed
          ? _value._typeFilters
          : typeFilters // ignore: cast_nullable_to_non_nullable
              as Set<HistoryTypeFilter>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_HistoriesSearch extends _HistoriesSearch {
  const _$_HistoriesSearch(
      {this.date,
      required final Set<HistorySearchFilter> searchFilters,
      required final Set<HistoryTypeFilter> typeFilters})
      : _searchFilters = searchFilters,
        _typeFilters = typeFilters,
        super._();

  factory _$_HistoriesSearch.fromJson(Map<String, dynamic> json) =>
      _$$_HistoriesSearchFromJson(json);

  @override
  final DateTime? date;
  final Set<HistorySearchFilter> _searchFilters;

  @override
  Set<HistorySearchFilter> get searchFilters {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_searchFilters);
  }

  final Set<HistoryTypeFilter> _typeFilters;

  @override
  Set<HistoryTypeFilter> get typeFilters {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_typeFilters);
  }

  @override
  String toString() {
    return 'HistoriesSearch(date: $date, searchFilters: $searchFilters, typeFilters: $typeFilters)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_HistoriesSearch &&
            const DeepCollectionEquality().equals(other.date, date) &&
            const DeepCollectionEquality()
                .equals(other._searchFilters, _searchFilters) &&
            const DeepCollectionEquality()
                .equals(other._typeFilters, _typeFilters));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(date),
      const DeepCollectionEquality().hash(_searchFilters),
      const DeepCollectionEquality().hash(_typeFilters));

  @JsonKey(ignore: true)
  @override
  _$$_HistoriesSearchCopyWith<_$_HistoriesSearch> get copyWith =>
      __$$_HistoriesSearchCopyWithImpl<_$_HistoriesSearch>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_HistoriesSearchToJson(
      this,
    );
  }
}

abstract class _HistoriesSearch extends HistoriesSearch {
  const factory _HistoriesSearch(
      {final DateTime? date,
      required final Set<HistorySearchFilter> searchFilters,
      required final Set<HistoryTypeFilter> typeFilters}) = _$_HistoriesSearch;

  const _HistoriesSearch._() : super._();

  factory _HistoriesSearch.fromJson(Map<String, dynamic> json) =
      _$_HistoriesSearch.fromJson;

  @override
  DateTime? get date;

  @override
  Set<HistorySearchFilter> get searchFilters;

  @override
  Set<HistoryTypeFilter> get typeFilters;

  @override
  @JsonKey(ignore: true)
  _$$_HistoriesSearchCopyWith<_$_HistoriesSearch> get copyWith =>
      throw _privateConstructorUsedError;
}