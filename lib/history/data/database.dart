import 'dart:math';

import 'package:drift/drift.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/identity/data/database.dart';
import 'package:e1547/interface/interface.dart';

// ignore: always_use_package_imports
import 'database.drift.dart';

@UseRowClass(History, generateInsertable: true)
class HistoriesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get visitedAt => dateTime()();
  TextColumn get link => text()();
  TextColumn get thumbnails => text().map(JsonSqlConverter.list<String>())();
  TextColumn get title => text().nullable()();
  TextColumn get subtitle => text().nullable()();
}

@DataClassName('HistoryIdentity')
class HistoriesIdentitiesTable extends Table {
  IntColumn get identity => integer().references(IdentitiesTable, #id,
      onDelete: KeyAction.noAction, onUpdate: KeyAction.noAction)();
  IntColumn get history => integer().references(HistoriesTable, #id,
      onDelete: KeyAction.cascade, onUpdate: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {identity, history};
}

@DriftAccessor(tables: [
  HistoriesTable,
  HistoriesIdentitiesTable,
  IdentitiesTable,
])
class HistoriesDao extends DatabaseAccessor<GeneratedDatabase>
    with $HistoriesDaoMixin {
  HistoriesDao({
    required GeneratedDatabase database,
    required this.identity,
  }) : super(database);

  final int? identity;

  Expression<bool> _identityQuery($HistoriesTableTable tbl) {
    final subQuery = historiesIdentitiesTable.selectOnly()
      ..addColumns([historiesIdentitiesTable.history])
      ..where(Variable(identity).isNull() |
          historiesIdentitiesTable.identity.equalsNullable(identity));

    return tbl.id.isInQuery(subQuery);
  }

  Stream<int> length() {
    final Expression<int> count = historiesTable.id.count();
    final Expression<bool> identified = _identityQuery(historiesTable);

    return (selectOnly(historiesTable)
          ..where(identified)
          ..addColumns([count]))
        .map((row) => row.read(count)!)
        .watchSingle();
  }

  Stream<List<DateTime>> dates({String? host}) {
    final Expression<DateTime> time = historiesTable.visitedAt;
    final Expression<String> date = historiesTable.visitedAt.date;
    final Expression<bool> hosted = _identityQuery(historiesTable);

    return (selectOnly(historiesTable)
          ..where(hosted)
          ..orderBy([OrderingTerm(expression: time)])
          ..groupBy([date])
          ..addColumns([time]))
        .map((row) {
      DateTime source = row.read(time)!;
      return DateTime(source.year, source.month, source.day);
    }).watch();
  }

  Stream<History> get(int id) =>
      (select(historiesTable)..where((tbl) => tbl.id.equals(id))).watchSingle();

  SimpleSelectStatement<HistoriesTable, History> _querySelect({
    int? limit,
    int? offset,
    DateTime? day,
    String? linkRegex,
    String? titleRegex,
    String? subtitleRegex,
  }) {
    final selectable = select(historiesTable)
      ..orderBy([
        (t) => OrderingTerm(expression: t.visitedAt, mode: OrderingMode.desc)
      ])
      ..where(_identityQuery);
    if (linkRegex != null) {
      selectable
          .where((tbl) => tbl.link.regexp(linkRegex, caseSensitive: false));
    }
    if (titleRegex != null) {
      selectable
          .where((tbl) => tbl.title.regexp(titleRegex, caseSensitive: false));
    }
    if (subtitleRegex != null) {
      selectable.where(
          (tbl) => tbl.subtitle.regexp(subtitleRegex, caseSensitive: false));
    }
    if (day != null) {
      day = DateTime(day.year, day.month, day.day);
      selectable.where(
        (tbl) => tbl.visitedAt.isBetweenValues(
          day!,
          day.add(const Duration(days: 1, milliseconds: -1)),
        ),
      );
    }
    assert(
      offset == null || limit != null,
      'Cannot specify offset without limit!',
    );
    if (limit != null) {
      selectable.limit(limit, offset: offset);
    }
    return selectable;
  }

  Stream<List<History>> page({
    required int page,
    int? limit,
    DateTime? day,
    String? linkRegex,
    String? titleRegex,
    String? subtitleRegex,
  }) {
    limit ??= 80;
    int offset = (max(1, page) - 1) * limit;
    return _querySelect(
      day: day,
      linkRegex: linkRegex,
      titleRegex: titleRegex,
      subtitleRegex: subtitleRegex,
      limit: limit,
      offset: offset,
    ).watch();
  }

  Stream<List<History>> all({
    int? limit,
    DateTime? day,
    String? linkRegex,
    String? titleRegex,
    String? subtitleRegex,
  }) =>
      _querySelect(
        day: day,
        linkRegex: linkRegex,
        titleRegex: titleRegex,
        subtitleRegex: subtitleRegex,
        limit: limit,
      ).watch();

  SimpleSelectStatement<HistoriesTable, History> _recentSelect({
    int? limit,
    required Duration maxAge,
  }) =>
      (_querySelect(limit: limit)
        ..where((tbl) => (tbl.visitedAt
            .isBiggerThanValue(DateTime.now().subtract(maxAge)))));

  Stream<List<History>> recent({
    int limit = 15,
    Duration maxAge = const Duration(minutes: 10),
  }) =>
      _recentSelect(limit: limit, maxAge: maxAge).watch();

  Future<void> add(HistoryRequest item, {int? identity}) async {
    if (this.identity == null && identity == null) {
      throw ArgumentError('Cannot add history without identity!');
    }
    History history = await into(historiesTable).insertReturning(
      HistoryCompanion(
        visitedAt: Value(item.visitedAt),
        link: Value(item.link),
        thumbnails: Value(item.thumbnails),
        title: Value(item.title),
        subtitle: Value(item.subtitle),
      ),
    );
    await into(historiesIdentitiesTable).insert(
      HistoryIdentityCompanion(
        identity: Value(this.identity ?? identity!),
        history: Value(history.id),
      ),
    );
  }

  Future<void> remove(int id) async =>
      (delete(historiesTable)..where((tbl) => tbl.id.equals(id))).go();

  Future<void> removeAll(List<int> ids) async =>
      (delete(historiesTable)..where((tbl) => tbl.id.isIn(ids))).go();

  Future<void> trim({
    required int maxAmount,
    required Duration maxAge,
  }) async =>
      transaction(() async {
        await (delete(historiesTable)
              ..where(_identityQuery)
              ..where((tbl) => tbl.id.isNotInQuery(
                  _recentSelect(limit: maxAmount, maxAge: maxAge))))
            .go();
      });
}
