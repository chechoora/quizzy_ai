// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DeckTableTable extends DeckTable
    with TableInfo<$DeckTableTable, DeckTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeckTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<int> uid = GeneratedColumn<int>(
      'uid', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title =
      GeneratedColumn<String>('title', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 3,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _isArchiveMeta =
      const VerificationMeta('isArchive');
  @override
  late final GeneratedColumn<bool> isArchive = GeneratedColumn<bool>(
      'is_archive', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archive" IN (0, 1))'));
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _statsAccuracyWeekMeta =
      const VerificationMeta('statsAccuracyWeek');
  @override
  late final GeneratedColumn<double> statsAccuracyWeek =
      GeneratedColumn<double>('stats_accuracy_week', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _statsAccuracyMonthMeta =
      const VerificationMeta('statsAccuracyMonth');
  @override
  late final GeneratedColumn<double> statsAccuracyMonth =
      GeneratedColumn<double>('stats_accuracy_month', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _statsAccuracyYearMeta =
      const VerificationMeta('statsAccuracyYear');
  @override
  late final GeneratedColumn<double> statsAccuracyYear =
      GeneratedColumn<double>('stats_accuracy_year', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _statsAttemptsWeekMeta =
      const VerificationMeta('statsAttemptsWeek');
  @override
  late final GeneratedColumn<int> statsAttemptsWeek = GeneratedColumn<int>(
      'stats_attempts_week', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _statsAttemptsMonthMeta =
      const VerificationMeta('statsAttemptsMonth');
  @override
  late final GeneratedColumn<int> statsAttemptsMonth = GeneratedColumn<int>(
      'stats_attempts_month', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _statsAttemptsYearMeta =
      const VerificationMeta('statsAttemptsYear');
  @override
  late final GeneratedColumn<int> statsAttemptsYear = GeneratedColumn<int>(
      'stats_attempts_year', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _statsBestStreakWeekMeta =
      const VerificationMeta('statsBestStreakWeek');
  @override
  late final GeneratedColumn<int> statsBestStreakWeek = GeneratedColumn<int>(
      'stats_best_streak_week', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _statsBestStreakMonthMeta =
      const VerificationMeta('statsBestStreakMonth');
  @override
  late final GeneratedColumn<int> statsBestStreakMonth = GeneratedColumn<int>(
      'stats_best_streak_month', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _statsBestStreakYearMeta =
      const VerificationMeta('statsBestStreakYear');
  @override
  late final GeneratedColumn<int> statsBestStreakYear = GeneratedColumn<int>(
      'stats_best_streak_year', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _statsLastPlayedAtMeta =
      const VerificationMeta('statsLastPlayedAt');
  @override
  late final GeneratedColumn<DateTime> statsLastPlayedAt =
      GeneratedColumn<DateTime>('stats_last_played_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uid,
        title,
        isArchive,
        remoteId,
        isDirty,
        statsAccuracyWeek,
        statsAccuracyMonth,
        statsAccuracyYear,
        statsAttemptsWeek,
        statsAttemptsMonth,
        statsAttemptsYear,
        statsBestStreakWeek,
        statsBestStreakMonth,
        statsBestStreakYear,
        statsLastPlayedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deck_table';
  @override
  VerificationContext validateIntegrity(Insertable<DeckTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid']!, _uidMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('is_archive')) {
      context.handle(_isArchiveMeta,
          isArchive.isAcceptableOrUnknown(data['is_archive']!, _isArchiveMeta));
    } else if (isInserting) {
      context.missing(_isArchiveMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    if (data.containsKey('stats_accuracy_week')) {
      context.handle(
          _statsAccuracyWeekMeta,
          statsAccuracyWeek.isAcceptableOrUnknown(
              data['stats_accuracy_week']!, _statsAccuracyWeekMeta));
    }
    if (data.containsKey('stats_accuracy_month')) {
      context.handle(
          _statsAccuracyMonthMeta,
          statsAccuracyMonth.isAcceptableOrUnknown(
              data['stats_accuracy_month']!, _statsAccuracyMonthMeta));
    }
    if (data.containsKey('stats_accuracy_year')) {
      context.handle(
          _statsAccuracyYearMeta,
          statsAccuracyYear.isAcceptableOrUnknown(
              data['stats_accuracy_year']!, _statsAccuracyYearMeta));
    }
    if (data.containsKey('stats_attempts_week')) {
      context.handle(
          _statsAttemptsWeekMeta,
          statsAttemptsWeek.isAcceptableOrUnknown(
              data['stats_attempts_week']!, _statsAttemptsWeekMeta));
    }
    if (data.containsKey('stats_attempts_month')) {
      context.handle(
          _statsAttemptsMonthMeta,
          statsAttemptsMonth.isAcceptableOrUnknown(
              data['stats_attempts_month']!, _statsAttemptsMonthMeta));
    }
    if (data.containsKey('stats_attempts_year')) {
      context.handle(
          _statsAttemptsYearMeta,
          statsAttemptsYear.isAcceptableOrUnknown(
              data['stats_attempts_year']!, _statsAttemptsYearMeta));
    }
    if (data.containsKey('stats_best_streak_week')) {
      context.handle(
          _statsBestStreakWeekMeta,
          statsBestStreakWeek.isAcceptableOrUnknown(
              data['stats_best_streak_week']!, _statsBestStreakWeekMeta));
    }
    if (data.containsKey('stats_best_streak_month')) {
      context.handle(
          _statsBestStreakMonthMeta,
          statsBestStreakMonth.isAcceptableOrUnknown(
              data['stats_best_streak_month']!, _statsBestStreakMonthMeta));
    }
    if (data.containsKey('stats_best_streak_year')) {
      context.handle(
          _statsBestStreakYearMeta,
          statsBestStreakYear.isAcceptableOrUnknown(
              data['stats_best_streak_year']!, _statsBestStreakYearMeta));
    }
    if (data.containsKey('stats_last_played_at')) {
      context.handle(
          _statsLastPlayedAtMeta,
          statsLastPlayedAt.isAcceptableOrUnknown(
              data['stats_last_played_at']!, _statsLastPlayedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeckTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeckTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}uid']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      isArchive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archive'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
      statsAccuracyWeek: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}stats_accuracy_week']),
      statsAccuracyMonth: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}stats_accuracy_month']),
      statsAccuracyYear: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}stats_accuracy_year']),
      statsAttemptsWeek: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}stats_attempts_week']),
      statsAttemptsMonth: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}stats_attempts_month']),
      statsAttemptsYear: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}stats_attempts_year']),
      statsBestStreakWeek: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}stats_best_streak_week']),
      statsBestStreakMonth: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}stats_best_streak_month']),
      statsBestStreakYear: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}stats_best_streak_year']),
      statsLastPlayedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}stats_last_played_at']),
    );
  }

  @override
  $DeckTableTable createAlias(String alias) {
    return $DeckTableTable(attachedDatabase, alias);
  }
}

class DeckTableData extends DataClass implements Insertable<DeckTableData> {
  final int id;

  /// Stable, timestamp-based unique id used for idempotent iCloud
  /// backup/restore (dedupe across devices). Nullable for additive migration.
  final int? uid;
  final String title;
  final bool isArchive;

  /// quizzy-ai-pro backend id once this deck has been created remotely.
  /// Null means it has never been pushed. Unique index allows multiple
  /// NULLs (SQLite), which is required since most local rows start unsynced.
  final String? remoteId;

  /// True when this row has local changes not yet pushed to the backend.
  /// Defaults to true so every new insert (and every pre-existing row,
  /// backfilled by the v10 migration) is picked up by the next push cycle.
  final bool isDirty;

  /// quizzy-ai-pro backend play stats (quizzyPro flavor only). Null for
  /// local-only rows and for rows never synced. All ten columns are always
  /// written together as one unit by the sync pull path, so [statsAttemptsWeek]
  /// doubles as the "has stats" sentinel in [DeckDatBaseMapper].
  final double? statsAccuracyWeek;
  final double? statsAccuracyMonth;
  final double? statsAccuracyYear;
  final int? statsAttemptsWeek;
  final int? statsAttemptsMonth;
  final int? statsAttemptsYear;
  final int? statsBestStreakWeek;
  final int? statsBestStreakMonth;
  final int? statsBestStreakYear;
  final DateTime? statsLastPlayedAt;
  const DeckTableData(
      {required this.id,
      this.uid,
      required this.title,
      required this.isArchive,
      this.remoteId,
      required this.isDirty,
      this.statsAccuracyWeek,
      this.statsAccuracyMonth,
      this.statsAccuracyYear,
      this.statsAttemptsWeek,
      this.statsAttemptsMonth,
      this.statsAttemptsYear,
      this.statsBestStreakWeek,
      this.statsBestStreakMonth,
      this.statsBestStreakYear,
      this.statsLastPlayedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || uid != null) {
      map['uid'] = Variable<int>(uid);
    }
    map['title'] = Variable<String>(title);
    map['is_archive'] = Variable<bool>(isArchive);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    if (!nullToAbsent || statsAccuracyWeek != null) {
      map['stats_accuracy_week'] = Variable<double>(statsAccuracyWeek);
    }
    if (!nullToAbsent || statsAccuracyMonth != null) {
      map['stats_accuracy_month'] = Variable<double>(statsAccuracyMonth);
    }
    if (!nullToAbsent || statsAccuracyYear != null) {
      map['stats_accuracy_year'] = Variable<double>(statsAccuracyYear);
    }
    if (!nullToAbsent || statsAttemptsWeek != null) {
      map['stats_attempts_week'] = Variable<int>(statsAttemptsWeek);
    }
    if (!nullToAbsent || statsAttemptsMonth != null) {
      map['stats_attempts_month'] = Variable<int>(statsAttemptsMonth);
    }
    if (!nullToAbsent || statsAttemptsYear != null) {
      map['stats_attempts_year'] = Variable<int>(statsAttemptsYear);
    }
    if (!nullToAbsent || statsBestStreakWeek != null) {
      map['stats_best_streak_week'] = Variable<int>(statsBestStreakWeek);
    }
    if (!nullToAbsent || statsBestStreakMonth != null) {
      map['stats_best_streak_month'] = Variable<int>(statsBestStreakMonth);
    }
    if (!nullToAbsent || statsBestStreakYear != null) {
      map['stats_best_streak_year'] = Variable<int>(statsBestStreakYear);
    }
    if (!nullToAbsent || statsLastPlayedAt != null) {
      map['stats_last_played_at'] = Variable<DateTime>(statsLastPlayedAt);
    }
    return map;
  }

  DeckTableCompanion toCompanion(bool nullToAbsent) {
    return DeckTableCompanion(
      id: Value(id),
      uid: uid == null && nullToAbsent ? const Value.absent() : Value(uid),
      title: Value(title),
      isArchive: Value(isArchive),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      isDirty: Value(isDirty),
      statsAccuracyWeek: statsAccuracyWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(statsAccuracyWeek),
      statsAccuracyMonth: statsAccuracyMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(statsAccuracyMonth),
      statsAccuracyYear: statsAccuracyYear == null && nullToAbsent
          ? const Value.absent()
          : Value(statsAccuracyYear),
      statsAttemptsWeek: statsAttemptsWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(statsAttemptsWeek),
      statsAttemptsMonth: statsAttemptsMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(statsAttemptsMonth),
      statsAttemptsYear: statsAttemptsYear == null && nullToAbsent
          ? const Value.absent()
          : Value(statsAttemptsYear),
      statsBestStreakWeek: statsBestStreakWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(statsBestStreakWeek),
      statsBestStreakMonth: statsBestStreakMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(statsBestStreakMonth),
      statsBestStreakYear: statsBestStreakYear == null && nullToAbsent
          ? const Value.absent()
          : Value(statsBestStreakYear),
      statsLastPlayedAt: statsLastPlayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(statsLastPlayedAt),
    );
  }

  factory DeckTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeckTableData(
      id: serializer.fromJson<int>(json['id']),
      uid: serializer.fromJson<int?>(json['uid']),
      title: serializer.fromJson<String>(json['title']),
      isArchive: serializer.fromJson<bool>(json['isArchive']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      statsAccuracyWeek:
          serializer.fromJson<double?>(json['statsAccuracyWeek']),
      statsAccuracyMonth:
          serializer.fromJson<double?>(json['statsAccuracyMonth']),
      statsAccuracyYear:
          serializer.fromJson<double?>(json['statsAccuracyYear']),
      statsAttemptsWeek: serializer.fromJson<int?>(json['statsAttemptsWeek']),
      statsAttemptsMonth: serializer.fromJson<int?>(json['statsAttemptsMonth']),
      statsAttemptsYear: serializer.fromJson<int?>(json['statsAttemptsYear']),
      statsBestStreakWeek:
          serializer.fromJson<int?>(json['statsBestStreakWeek']),
      statsBestStreakMonth:
          serializer.fromJson<int?>(json['statsBestStreakMonth']),
      statsBestStreakYear:
          serializer.fromJson<int?>(json['statsBestStreakYear']),
      statsLastPlayedAt:
          serializer.fromJson<DateTime?>(json['statsLastPlayedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uid': serializer.toJson<int?>(uid),
      'title': serializer.toJson<String>(title),
      'isArchive': serializer.toJson<bool>(isArchive),
      'remoteId': serializer.toJson<String?>(remoteId),
      'isDirty': serializer.toJson<bool>(isDirty),
      'statsAccuracyWeek': serializer.toJson<double?>(statsAccuracyWeek),
      'statsAccuracyMonth': serializer.toJson<double?>(statsAccuracyMonth),
      'statsAccuracyYear': serializer.toJson<double?>(statsAccuracyYear),
      'statsAttemptsWeek': serializer.toJson<int?>(statsAttemptsWeek),
      'statsAttemptsMonth': serializer.toJson<int?>(statsAttemptsMonth),
      'statsAttemptsYear': serializer.toJson<int?>(statsAttemptsYear),
      'statsBestStreakWeek': serializer.toJson<int?>(statsBestStreakWeek),
      'statsBestStreakMonth': serializer.toJson<int?>(statsBestStreakMonth),
      'statsBestStreakYear': serializer.toJson<int?>(statsBestStreakYear),
      'statsLastPlayedAt': serializer.toJson<DateTime?>(statsLastPlayedAt),
    };
  }

  DeckTableData copyWith(
          {int? id,
          Value<int?> uid = const Value.absent(),
          String? title,
          bool? isArchive,
          Value<String?> remoteId = const Value.absent(),
          bool? isDirty,
          Value<double?> statsAccuracyWeek = const Value.absent(),
          Value<double?> statsAccuracyMonth = const Value.absent(),
          Value<double?> statsAccuracyYear = const Value.absent(),
          Value<int?> statsAttemptsWeek = const Value.absent(),
          Value<int?> statsAttemptsMonth = const Value.absent(),
          Value<int?> statsAttemptsYear = const Value.absent(),
          Value<int?> statsBestStreakWeek = const Value.absent(),
          Value<int?> statsBestStreakMonth = const Value.absent(),
          Value<int?> statsBestStreakYear = const Value.absent(),
          Value<DateTime?> statsLastPlayedAt = const Value.absent()}) =>
      DeckTableData(
        id: id ?? this.id,
        uid: uid.present ? uid.value : this.uid,
        title: title ?? this.title,
        isArchive: isArchive ?? this.isArchive,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        isDirty: isDirty ?? this.isDirty,
        statsAccuracyWeek: statsAccuracyWeek.present
            ? statsAccuracyWeek.value
            : this.statsAccuracyWeek,
        statsAccuracyMonth: statsAccuracyMonth.present
            ? statsAccuracyMonth.value
            : this.statsAccuracyMonth,
        statsAccuracyYear: statsAccuracyYear.present
            ? statsAccuracyYear.value
            : this.statsAccuracyYear,
        statsAttemptsWeek: statsAttemptsWeek.present
            ? statsAttemptsWeek.value
            : this.statsAttemptsWeek,
        statsAttemptsMonth: statsAttemptsMonth.present
            ? statsAttemptsMonth.value
            : this.statsAttemptsMonth,
        statsAttemptsYear: statsAttemptsYear.present
            ? statsAttemptsYear.value
            : this.statsAttemptsYear,
        statsBestStreakWeek: statsBestStreakWeek.present
            ? statsBestStreakWeek.value
            : this.statsBestStreakWeek,
        statsBestStreakMonth: statsBestStreakMonth.present
            ? statsBestStreakMonth.value
            : this.statsBestStreakMonth,
        statsBestStreakYear: statsBestStreakYear.present
            ? statsBestStreakYear.value
            : this.statsBestStreakYear,
        statsLastPlayedAt: statsLastPlayedAt.present
            ? statsLastPlayedAt.value
            : this.statsLastPlayedAt,
      );
  DeckTableData copyWithCompanion(DeckTableCompanion data) {
    return DeckTableData(
      id: data.id.present ? data.id.value : this.id,
      uid: data.uid.present ? data.uid.value : this.uid,
      title: data.title.present ? data.title.value : this.title,
      isArchive: data.isArchive.present ? data.isArchive.value : this.isArchive,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      statsAccuracyWeek: data.statsAccuracyWeek.present
          ? data.statsAccuracyWeek.value
          : this.statsAccuracyWeek,
      statsAccuracyMonth: data.statsAccuracyMonth.present
          ? data.statsAccuracyMonth.value
          : this.statsAccuracyMonth,
      statsAccuracyYear: data.statsAccuracyYear.present
          ? data.statsAccuracyYear.value
          : this.statsAccuracyYear,
      statsAttemptsWeek: data.statsAttemptsWeek.present
          ? data.statsAttemptsWeek.value
          : this.statsAttemptsWeek,
      statsAttemptsMonth: data.statsAttemptsMonth.present
          ? data.statsAttemptsMonth.value
          : this.statsAttemptsMonth,
      statsAttemptsYear: data.statsAttemptsYear.present
          ? data.statsAttemptsYear.value
          : this.statsAttemptsYear,
      statsBestStreakWeek: data.statsBestStreakWeek.present
          ? data.statsBestStreakWeek.value
          : this.statsBestStreakWeek,
      statsBestStreakMonth: data.statsBestStreakMonth.present
          ? data.statsBestStreakMonth.value
          : this.statsBestStreakMonth,
      statsBestStreakYear: data.statsBestStreakYear.present
          ? data.statsBestStreakYear.value
          : this.statsBestStreakYear,
      statsLastPlayedAt: data.statsLastPlayedAt.present
          ? data.statsLastPlayedAt.value
          : this.statsLastPlayedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeckTableData(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('title: $title, ')
          ..write('isArchive: $isArchive, ')
          ..write('remoteId: $remoteId, ')
          ..write('isDirty: $isDirty, ')
          ..write('statsAccuracyWeek: $statsAccuracyWeek, ')
          ..write('statsAccuracyMonth: $statsAccuracyMonth, ')
          ..write('statsAccuracyYear: $statsAccuracyYear, ')
          ..write('statsAttemptsWeek: $statsAttemptsWeek, ')
          ..write('statsAttemptsMonth: $statsAttemptsMonth, ')
          ..write('statsAttemptsYear: $statsAttemptsYear, ')
          ..write('statsBestStreakWeek: $statsBestStreakWeek, ')
          ..write('statsBestStreakMonth: $statsBestStreakMonth, ')
          ..write('statsBestStreakYear: $statsBestStreakYear, ')
          ..write('statsLastPlayedAt: $statsLastPlayedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      uid,
      title,
      isArchive,
      remoteId,
      isDirty,
      statsAccuracyWeek,
      statsAccuracyMonth,
      statsAccuracyYear,
      statsAttemptsWeek,
      statsAttemptsMonth,
      statsAttemptsYear,
      statsBestStreakWeek,
      statsBestStreakMonth,
      statsBestStreakYear,
      statsLastPlayedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeckTableData &&
          other.id == this.id &&
          other.uid == this.uid &&
          other.title == this.title &&
          other.isArchive == this.isArchive &&
          other.remoteId == this.remoteId &&
          other.isDirty == this.isDirty &&
          other.statsAccuracyWeek == this.statsAccuracyWeek &&
          other.statsAccuracyMonth == this.statsAccuracyMonth &&
          other.statsAccuracyYear == this.statsAccuracyYear &&
          other.statsAttemptsWeek == this.statsAttemptsWeek &&
          other.statsAttemptsMonth == this.statsAttemptsMonth &&
          other.statsAttemptsYear == this.statsAttemptsYear &&
          other.statsBestStreakWeek == this.statsBestStreakWeek &&
          other.statsBestStreakMonth == this.statsBestStreakMonth &&
          other.statsBestStreakYear == this.statsBestStreakYear &&
          other.statsLastPlayedAt == this.statsLastPlayedAt);
}

class DeckTableCompanion extends UpdateCompanion<DeckTableData> {
  final Value<int> id;
  final Value<int?> uid;
  final Value<String> title;
  final Value<bool> isArchive;
  final Value<String?> remoteId;
  final Value<bool> isDirty;
  final Value<double?> statsAccuracyWeek;
  final Value<double?> statsAccuracyMonth;
  final Value<double?> statsAccuracyYear;
  final Value<int?> statsAttemptsWeek;
  final Value<int?> statsAttemptsMonth;
  final Value<int?> statsAttemptsYear;
  final Value<int?> statsBestStreakWeek;
  final Value<int?> statsBestStreakMonth;
  final Value<int?> statsBestStreakYear;
  final Value<DateTime?> statsLastPlayedAt;
  const DeckTableCompanion({
    this.id = const Value.absent(),
    this.uid = const Value.absent(),
    this.title = const Value.absent(),
    this.isArchive = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.statsAccuracyWeek = const Value.absent(),
    this.statsAccuracyMonth = const Value.absent(),
    this.statsAccuracyYear = const Value.absent(),
    this.statsAttemptsWeek = const Value.absent(),
    this.statsAttemptsMonth = const Value.absent(),
    this.statsAttemptsYear = const Value.absent(),
    this.statsBestStreakWeek = const Value.absent(),
    this.statsBestStreakMonth = const Value.absent(),
    this.statsBestStreakYear = const Value.absent(),
    this.statsLastPlayedAt = const Value.absent(),
  });
  DeckTableCompanion.insert({
    this.id = const Value.absent(),
    this.uid = const Value.absent(),
    required String title,
    required bool isArchive,
    this.remoteId = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.statsAccuracyWeek = const Value.absent(),
    this.statsAccuracyMonth = const Value.absent(),
    this.statsAccuracyYear = const Value.absent(),
    this.statsAttemptsWeek = const Value.absent(),
    this.statsAttemptsMonth = const Value.absent(),
    this.statsAttemptsYear = const Value.absent(),
    this.statsBestStreakWeek = const Value.absent(),
    this.statsBestStreakMonth = const Value.absent(),
    this.statsBestStreakYear = const Value.absent(),
    this.statsLastPlayedAt = const Value.absent(),
  })  : title = Value(title),
        isArchive = Value(isArchive);
  static Insertable<DeckTableData> custom({
    Expression<int>? id,
    Expression<int>? uid,
    Expression<String>? title,
    Expression<bool>? isArchive,
    Expression<String>? remoteId,
    Expression<bool>? isDirty,
    Expression<double>? statsAccuracyWeek,
    Expression<double>? statsAccuracyMonth,
    Expression<double>? statsAccuracyYear,
    Expression<int>? statsAttemptsWeek,
    Expression<int>? statsAttemptsMonth,
    Expression<int>? statsAttemptsYear,
    Expression<int>? statsBestStreakWeek,
    Expression<int>? statsBestStreakMonth,
    Expression<int>? statsBestStreakYear,
    Expression<DateTime>? statsLastPlayedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uid != null) 'uid': uid,
      if (title != null) 'title': title,
      if (isArchive != null) 'is_archive': isArchive,
      if (remoteId != null) 'remote_id': remoteId,
      if (isDirty != null) 'is_dirty': isDirty,
      if (statsAccuracyWeek != null) 'stats_accuracy_week': statsAccuracyWeek,
      if (statsAccuracyMonth != null)
        'stats_accuracy_month': statsAccuracyMonth,
      if (statsAccuracyYear != null) 'stats_accuracy_year': statsAccuracyYear,
      if (statsAttemptsWeek != null) 'stats_attempts_week': statsAttemptsWeek,
      if (statsAttemptsMonth != null)
        'stats_attempts_month': statsAttemptsMonth,
      if (statsAttemptsYear != null) 'stats_attempts_year': statsAttemptsYear,
      if (statsBestStreakWeek != null)
        'stats_best_streak_week': statsBestStreakWeek,
      if (statsBestStreakMonth != null)
        'stats_best_streak_month': statsBestStreakMonth,
      if (statsBestStreakYear != null)
        'stats_best_streak_year': statsBestStreakYear,
      if (statsLastPlayedAt != null) 'stats_last_played_at': statsLastPlayedAt,
    });
  }

  DeckTableCompanion copyWith(
      {Value<int>? id,
      Value<int?>? uid,
      Value<String>? title,
      Value<bool>? isArchive,
      Value<String?>? remoteId,
      Value<bool>? isDirty,
      Value<double?>? statsAccuracyWeek,
      Value<double?>? statsAccuracyMonth,
      Value<double?>? statsAccuracyYear,
      Value<int?>? statsAttemptsWeek,
      Value<int?>? statsAttemptsMonth,
      Value<int?>? statsAttemptsYear,
      Value<int?>? statsBestStreakWeek,
      Value<int?>? statsBestStreakMonth,
      Value<int?>? statsBestStreakYear,
      Value<DateTime?>? statsLastPlayedAt}) {
    return DeckTableCompanion(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      isArchive: isArchive ?? this.isArchive,
      remoteId: remoteId ?? this.remoteId,
      isDirty: isDirty ?? this.isDirty,
      statsAccuracyWeek: statsAccuracyWeek ?? this.statsAccuracyWeek,
      statsAccuracyMonth: statsAccuracyMonth ?? this.statsAccuracyMonth,
      statsAccuracyYear: statsAccuracyYear ?? this.statsAccuracyYear,
      statsAttemptsWeek: statsAttemptsWeek ?? this.statsAttemptsWeek,
      statsAttemptsMonth: statsAttemptsMonth ?? this.statsAttemptsMonth,
      statsAttemptsYear: statsAttemptsYear ?? this.statsAttemptsYear,
      statsBestStreakWeek: statsBestStreakWeek ?? this.statsBestStreakWeek,
      statsBestStreakMonth: statsBestStreakMonth ?? this.statsBestStreakMonth,
      statsBestStreakYear: statsBestStreakYear ?? this.statsBestStreakYear,
      statsLastPlayedAt: statsLastPlayedAt ?? this.statsLastPlayedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uid.present) {
      map['uid'] = Variable<int>(uid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (isArchive.present) {
      map['is_archive'] = Variable<bool>(isArchive.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (statsAccuracyWeek.present) {
      map['stats_accuracy_week'] = Variable<double>(statsAccuracyWeek.value);
    }
    if (statsAccuracyMonth.present) {
      map['stats_accuracy_month'] = Variable<double>(statsAccuracyMonth.value);
    }
    if (statsAccuracyYear.present) {
      map['stats_accuracy_year'] = Variable<double>(statsAccuracyYear.value);
    }
    if (statsAttemptsWeek.present) {
      map['stats_attempts_week'] = Variable<int>(statsAttemptsWeek.value);
    }
    if (statsAttemptsMonth.present) {
      map['stats_attempts_month'] = Variable<int>(statsAttemptsMonth.value);
    }
    if (statsAttemptsYear.present) {
      map['stats_attempts_year'] = Variable<int>(statsAttemptsYear.value);
    }
    if (statsBestStreakWeek.present) {
      map['stats_best_streak_week'] = Variable<int>(statsBestStreakWeek.value);
    }
    if (statsBestStreakMonth.present) {
      map['stats_best_streak_month'] =
          Variable<int>(statsBestStreakMonth.value);
    }
    if (statsBestStreakYear.present) {
      map['stats_best_streak_year'] = Variable<int>(statsBestStreakYear.value);
    }
    if (statsLastPlayedAt.present) {
      map['stats_last_played_at'] = Variable<DateTime>(statsLastPlayedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeckTableCompanion(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('title: $title, ')
          ..write('isArchive: $isArchive, ')
          ..write('remoteId: $remoteId, ')
          ..write('isDirty: $isDirty, ')
          ..write('statsAccuracyWeek: $statsAccuracyWeek, ')
          ..write('statsAccuracyMonth: $statsAccuracyMonth, ')
          ..write('statsAccuracyYear: $statsAccuracyYear, ')
          ..write('statsAttemptsWeek: $statsAttemptsWeek, ')
          ..write('statsAttemptsMonth: $statsAttemptsMonth, ')
          ..write('statsAttemptsYear: $statsAttemptsYear, ')
          ..write('statsBestStreakWeek: $statsBestStreakWeek, ')
          ..write('statsBestStreakMonth: $statsBestStreakMonth, ')
          ..write('statsBestStreakYear: $statsBestStreakYear, ')
          ..write('statsLastPlayedAt: $statsLastPlayedAt')
          ..write(')'))
        .toString();
  }
}

class $QuizCardTableTable extends QuizCardTable
    with TableInfo<$QuizCardTableTable, QuizCardTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuizCardTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<int> uid = GeneratedColumn<int>(
      'uid', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<int> deckId = GeneratedColumn<int>(
      'deck_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES deck_table (id)'));
  static const VerificationMeta _questionTextMeta =
      const VerificationMeta('questionText');
  @override
  late final GeneratedColumn<String> questionText =
      GeneratedColumn<String>('question_text', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _answerTextMeta =
      const VerificationMeta('answerText');
  @override
  late final GeneratedColumn<String> answerText =
      GeneratedColumn<String>('answer_text', aliasedName, false,
          additionalChecks: GeneratedColumn.checkTextLength(
            minTextLength: 1,
          ),
          type: DriftSqlType.string,
          requiredDuringInsert: true);
  static const VerificationMeta _isArchiveMeta =
      const VerificationMeta('isArchive');
  @override
  late final GeneratedColumn<bool> isArchive = GeneratedColumn<bool>(
      'is_archive', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archive" IN (0, 1))'));
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isDirtyMeta =
      const VerificationMeta('isDirty');
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
      'is_dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_dirty" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _statsAccuracyWeekMeta =
      const VerificationMeta('statsAccuracyWeek');
  @override
  late final GeneratedColumn<double> statsAccuracyWeek =
      GeneratedColumn<double>('stats_accuracy_week', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _statsAccuracyMonthMeta =
      const VerificationMeta('statsAccuracyMonth');
  @override
  late final GeneratedColumn<double> statsAccuracyMonth =
      GeneratedColumn<double>('stats_accuracy_month', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _statsAccuracyYearMeta =
      const VerificationMeta('statsAccuracyYear');
  @override
  late final GeneratedColumn<double> statsAccuracyYear =
      GeneratedColumn<double>('stats_accuracy_year', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _statsAttemptsWeekMeta =
      const VerificationMeta('statsAttemptsWeek');
  @override
  late final GeneratedColumn<int> statsAttemptsWeek = GeneratedColumn<int>(
      'stats_attempts_week', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _statsAttemptsMonthMeta =
      const VerificationMeta('statsAttemptsMonth');
  @override
  late final GeneratedColumn<int> statsAttemptsMonth = GeneratedColumn<int>(
      'stats_attempts_month', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _statsAttemptsYearMeta =
      const VerificationMeta('statsAttemptsYear');
  @override
  late final GeneratedColumn<int> statsAttemptsYear = GeneratedColumn<int>(
      'stats_attempts_year', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _statsBestStreakWeekMeta =
      const VerificationMeta('statsBestStreakWeek');
  @override
  late final GeneratedColumn<int> statsBestStreakWeek = GeneratedColumn<int>(
      'stats_best_streak_week', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _statsBestStreakMonthMeta =
      const VerificationMeta('statsBestStreakMonth');
  @override
  late final GeneratedColumn<int> statsBestStreakMonth = GeneratedColumn<int>(
      'stats_best_streak_month', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _statsBestStreakYearMeta =
      const VerificationMeta('statsBestStreakYear');
  @override
  late final GeneratedColumn<int> statsBestStreakYear = GeneratedColumn<int>(
      'stats_best_streak_year', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _statsLastPlayedAtMeta =
      const VerificationMeta('statsLastPlayedAt');
  @override
  late final GeneratedColumn<DateTime> statsLastPlayedAt =
      GeneratedColumn<DateTime>('stats_last_played_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        uid,
        deckId,
        questionText,
        answerText,
        isArchive,
        remoteId,
        isDirty,
        statsAccuracyWeek,
        statsAccuracyMonth,
        statsAccuracyYear,
        statsAttemptsWeek,
        statsAttemptsMonth,
        statsAttemptsYear,
        statsBestStreakWeek,
        statsBestStreakMonth,
        statsBestStreakYear,
        statsLastPlayedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quiz_card_table';
  @override
  VerificationContext validateIntegrity(Insertable<QuizCardTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid']!, _uidMeta));
    }
    if (data.containsKey('deck_id')) {
      context.handle(_deckIdMeta,
          deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta));
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('question_text')) {
      context.handle(
          _questionTextMeta,
          questionText.isAcceptableOrUnknown(
              data['question_text']!, _questionTextMeta));
    } else if (isInserting) {
      context.missing(_questionTextMeta);
    }
    if (data.containsKey('answer_text')) {
      context.handle(
          _answerTextMeta,
          answerText.isAcceptableOrUnknown(
              data['answer_text']!, _answerTextMeta));
    } else if (isInserting) {
      context.missing(_answerTextMeta);
    }
    if (data.containsKey('is_archive')) {
      context.handle(_isArchiveMeta,
          isArchive.isAcceptableOrUnknown(data['is_archive']!, _isArchiveMeta));
    } else if (isInserting) {
      context.missing(_isArchiveMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('is_dirty')) {
      context.handle(_isDirtyMeta,
          isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta));
    }
    if (data.containsKey('stats_accuracy_week')) {
      context.handle(
          _statsAccuracyWeekMeta,
          statsAccuracyWeek.isAcceptableOrUnknown(
              data['stats_accuracy_week']!, _statsAccuracyWeekMeta));
    }
    if (data.containsKey('stats_accuracy_month')) {
      context.handle(
          _statsAccuracyMonthMeta,
          statsAccuracyMonth.isAcceptableOrUnknown(
              data['stats_accuracy_month']!, _statsAccuracyMonthMeta));
    }
    if (data.containsKey('stats_accuracy_year')) {
      context.handle(
          _statsAccuracyYearMeta,
          statsAccuracyYear.isAcceptableOrUnknown(
              data['stats_accuracy_year']!, _statsAccuracyYearMeta));
    }
    if (data.containsKey('stats_attempts_week')) {
      context.handle(
          _statsAttemptsWeekMeta,
          statsAttemptsWeek.isAcceptableOrUnknown(
              data['stats_attempts_week']!, _statsAttemptsWeekMeta));
    }
    if (data.containsKey('stats_attempts_month')) {
      context.handle(
          _statsAttemptsMonthMeta,
          statsAttemptsMonth.isAcceptableOrUnknown(
              data['stats_attempts_month']!, _statsAttemptsMonthMeta));
    }
    if (data.containsKey('stats_attempts_year')) {
      context.handle(
          _statsAttemptsYearMeta,
          statsAttemptsYear.isAcceptableOrUnknown(
              data['stats_attempts_year']!, _statsAttemptsYearMeta));
    }
    if (data.containsKey('stats_best_streak_week')) {
      context.handle(
          _statsBestStreakWeekMeta,
          statsBestStreakWeek.isAcceptableOrUnknown(
              data['stats_best_streak_week']!, _statsBestStreakWeekMeta));
    }
    if (data.containsKey('stats_best_streak_month')) {
      context.handle(
          _statsBestStreakMonthMeta,
          statsBestStreakMonth.isAcceptableOrUnknown(
              data['stats_best_streak_month']!, _statsBestStreakMonthMeta));
    }
    if (data.containsKey('stats_best_streak_year')) {
      context.handle(
          _statsBestStreakYearMeta,
          statsBestStreakYear.isAcceptableOrUnknown(
              data['stats_best_streak_year']!, _statsBestStreakYearMeta));
    }
    if (data.containsKey('stats_last_played_at')) {
      context.handle(
          _statsLastPlayedAtMeta,
          statsLastPlayedAt.isAcceptableOrUnknown(
              data['stats_last_played_at']!, _statsLastPlayedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuizCardTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuizCardTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}uid']),
      deckId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deck_id'])!,
      questionText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}question_text'])!,
      answerText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}answer_text'])!,
      isArchive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archive'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      isDirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_dirty'])!,
      statsAccuracyWeek: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}stats_accuracy_week']),
      statsAccuracyMonth: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}stats_accuracy_month']),
      statsAccuracyYear: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}stats_accuracy_year']),
      statsAttemptsWeek: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}stats_attempts_week']),
      statsAttemptsMonth: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}stats_attempts_month']),
      statsAttemptsYear: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}stats_attempts_year']),
      statsBestStreakWeek: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}stats_best_streak_week']),
      statsBestStreakMonth: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}stats_best_streak_month']),
      statsBestStreakYear: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}stats_best_streak_year']),
      statsLastPlayedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}stats_last_played_at']),
    );
  }

  @override
  $QuizCardTableTable createAlias(String alias) {
    return $QuizCardTableTable(attachedDatabase, alias);
  }
}

class QuizCardTableData extends DataClass
    implements Insertable<QuizCardTableData> {
  final int id;

  /// Stable, timestamp-based unique id used for idempotent iCloud
  /// backup/restore (dedupe across devices). Nullable for additive migration.
  final int? uid;
  final int deckId;
  final String questionText;
  final String answerText;
  final bool isArchive;

  /// quizzy-ai-pro backend id once this card has been created remotely.
  final String? remoteId;

  /// True when this row has local changes not yet pushed to the backend.
  final bool isDirty;

  /// quizzy-ai-pro backend play stats (quizzyPro flavor only). See
  /// [DeckTable.statsAccuracyWeek] for the write/sentinel convention.
  final double? statsAccuracyWeek;
  final double? statsAccuracyMonth;
  final double? statsAccuracyYear;
  final int? statsAttemptsWeek;
  final int? statsAttemptsMonth;
  final int? statsAttemptsYear;
  final int? statsBestStreakWeek;
  final int? statsBestStreakMonth;
  final int? statsBestStreakYear;
  final DateTime? statsLastPlayedAt;
  const QuizCardTableData(
      {required this.id,
      this.uid,
      required this.deckId,
      required this.questionText,
      required this.answerText,
      required this.isArchive,
      this.remoteId,
      required this.isDirty,
      this.statsAccuracyWeek,
      this.statsAccuracyMonth,
      this.statsAccuracyYear,
      this.statsAttemptsWeek,
      this.statsAttemptsMonth,
      this.statsAttemptsYear,
      this.statsBestStreakWeek,
      this.statsBestStreakMonth,
      this.statsBestStreakYear,
      this.statsLastPlayedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || uid != null) {
      map['uid'] = Variable<int>(uid);
    }
    map['deck_id'] = Variable<int>(deckId);
    map['question_text'] = Variable<String>(questionText);
    map['answer_text'] = Variable<String>(answerText);
    map['is_archive'] = Variable<bool>(isArchive);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['is_dirty'] = Variable<bool>(isDirty);
    if (!nullToAbsent || statsAccuracyWeek != null) {
      map['stats_accuracy_week'] = Variable<double>(statsAccuracyWeek);
    }
    if (!nullToAbsent || statsAccuracyMonth != null) {
      map['stats_accuracy_month'] = Variable<double>(statsAccuracyMonth);
    }
    if (!nullToAbsent || statsAccuracyYear != null) {
      map['stats_accuracy_year'] = Variable<double>(statsAccuracyYear);
    }
    if (!nullToAbsent || statsAttemptsWeek != null) {
      map['stats_attempts_week'] = Variable<int>(statsAttemptsWeek);
    }
    if (!nullToAbsent || statsAttemptsMonth != null) {
      map['stats_attempts_month'] = Variable<int>(statsAttemptsMonth);
    }
    if (!nullToAbsent || statsAttemptsYear != null) {
      map['stats_attempts_year'] = Variable<int>(statsAttemptsYear);
    }
    if (!nullToAbsent || statsBestStreakWeek != null) {
      map['stats_best_streak_week'] = Variable<int>(statsBestStreakWeek);
    }
    if (!nullToAbsent || statsBestStreakMonth != null) {
      map['stats_best_streak_month'] = Variable<int>(statsBestStreakMonth);
    }
    if (!nullToAbsent || statsBestStreakYear != null) {
      map['stats_best_streak_year'] = Variable<int>(statsBestStreakYear);
    }
    if (!nullToAbsent || statsLastPlayedAt != null) {
      map['stats_last_played_at'] = Variable<DateTime>(statsLastPlayedAt);
    }
    return map;
  }

  QuizCardTableCompanion toCompanion(bool nullToAbsent) {
    return QuizCardTableCompanion(
      id: Value(id),
      uid: uid == null && nullToAbsent ? const Value.absent() : Value(uid),
      deckId: Value(deckId),
      questionText: Value(questionText),
      answerText: Value(answerText),
      isArchive: Value(isArchive),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      isDirty: Value(isDirty),
      statsAccuracyWeek: statsAccuracyWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(statsAccuracyWeek),
      statsAccuracyMonth: statsAccuracyMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(statsAccuracyMonth),
      statsAccuracyYear: statsAccuracyYear == null && nullToAbsent
          ? const Value.absent()
          : Value(statsAccuracyYear),
      statsAttemptsWeek: statsAttemptsWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(statsAttemptsWeek),
      statsAttemptsMonth: statsAttemptsMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(statsAttemptsMonth),
      statsAttemptsYear: statsAttemptsYear == null && nullToAbsent
          ? const Value.absent()
          : Value(statsAttemptsYear),
      statsBestStreakWeek: statsBestStreakWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(statsBestStreakWeek),
      statsBestStreakMonth: statsBestStreakMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(statsBestStreakMonth),
      statsBestStreakYear: statsBestStreakYear == null && nullToAbsent
          ? const Value.absent()
          : Value(statsBestStreakYear),
      statsLastPlayedAt: statsLastPlayedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(statsLastPlayedAt),
    );
  }

  factory QuizCardTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuizCardTableData(
      id: serializer.fromJson<int>(json['id']),
      uid: serializer.fromJson<int?>(json['uid']),
      deckId: serializer.fromJson<int>(json['deckId']),
      questionText: serializer.fromJson<String>(json['questionText']),
      answerText: serializer.fromJson<String>(json['answerText']),
      isArchive: serializer.fromJson<bool>(json['isArchive']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      statsAccuracyWeek:
          serializer.fromJson<double?>(json['statsAccuracyWeek']),
      statsAccuracyMonth:
          serializer.fromJson<double?>(json['statsAccuracyMonth']),
      statsAccuracyYear:
          serializer.fromJson<double?>(json['statsAccuracyYear']),
      statsAttemptsWeek: serializer.fromJson<int?>(json['statsAttemptsWeek']),
      statsAttemptsMonth: serializer.fromJson<int?>(json['statsAttemptsMonth']),
      statsAttemptsYear: serializer.fromJson<int?>(json['statsAttemptsYear']),
      statsBestStreakWeek:
          serializer.fromJson<int?>(json['statsBestStreakWeek']),
      statsBestStreakMonth:
          serializer.fromJson<int?>(json['statsBestStreakMonth']),
      statsBestStreakYear:
          serializer.fromJson<int?>(json['statsBestStreakYear']),
      statsLastPlayedAt:
          serializer.fromJson<DateTime?>(json['statsLastPlayedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uid': serializer.toJson<int?>(uid),
      'deckId': serializer.toJson<int>(deckId),
      'questionText': serializer.toJson<String>(questionText),
      'answerText': serializer.toJson<String>(answerText),
      'isArchive': serializer.toJson<bool>(isArchive),
      'remoteId': serializer.toJson<String?>(remoteId),
      'isDirty': serializer.toJson<bool>(isDirty),
      'statsAccuracyWeek': serializer.toJson<double?>(statsAccuracyWeek),
      'statsAccuracyMonth': serializer.toJson<double?>(statsAccuracyMonth),
      'statsAccuracyYear': serializer.toJson<double?>(statsAccuracyYear),
      'statsAttemptsWeek': serializer.toJson<int?>(statsAttemptsWeek),
      'statsAttemptsMonth': serializer.toJson<int?>(statsAttemptsMonth),
      'statsAttemptsYear': serializer.toJson<int?>(statsAttemptsYear),
      'statsBestStreakWeek': serializer.toJson<int?>(statsBestStreakWeek),
      'statsBestStreakMonth': serializer.toJson<int?>(statsBestStreakMonth),
      'statsBestStreakYear': serializer.toJson<int?>(statsBestStreakYear),
      'statsLastPlayedAt': serializer.toJson<DateTime?>(statsLastPlayedAt),
    };
  }

  QuizCardTableData copyWith(
          {int? id,
          Value<int?> uid = const Value.absent(),
          int? deckId,
          String? questionText,
          String? answerText,
          bool? isArchive,
          Value<String?> remoteId = const Value.absent(),
          bool? isDirty,
          Value<double?> statsAccuracyWeek = const Value.absent(),
          Value<double?> statsAccuracyMonth = const Value.absent(),
          Value<double?> statsAccuracyYear = const Value.absent(),
          Value<int?> statsAttemptsWeek = const Value.absent(),
          Value<int?> statsAttemptsMonth = const Value.absent(),
          Value<int?> statsAttemptsYear = const Value.absent(),
          Value<int?> statsBestStreakWeek = const Value.absent(),
          Value<int?> statsBestStreakMonth = const Value.absent(),
          Value<int?> statsBestStreakYear = const Value.absent(),
          Value<DateTime?> statsLastPlayedAt = const Value.absent()}) =>
      QuizCardTableData(
        id: id ?? this.id,
        uid: uid.present ? uid.value : this.uid,
        deckId: deckId ?? this.deckId,
        questionText: questionText ?? this.questionText,
        answerText: answerText ?? this.answerText,
        isArchive: isArchive ?? this.isArchive,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        isDirty: isDirty ?? this.isDirty,
        statsAccuracyWeek: statsAccuracyWeek.present
            ? statsAccuracyWeek.value
            : this.statsAccuracyWeek,
        statsAccuracyMonth: statsAccuracyMonth.present
            ? statsAccuracyMonth.value
            : this.statsAccuracyMonth,
        statsAccuracyYear: statsAccuracyYear.present
            ? statsAccuracyYear.value
            : this.statsAccuracyYear,
        statsAttemptsWeek: statsAttemptsWeek.present
            ? statsAttemptsWeek.value
            : this.statsAttemptsWeek,
        statsAttemptsMonth: statsAttemptsMonth.present
            ? statsAttemptsMonth.value
            : this.statsAttemptsMonth,
        statsAttemptsYear: statsAttemptsYear.present
            ? statsAttemptsYear.value
            : this.statsAttemptsYear,
        statsBestStreakWeek: statsBestStreakWeek.present
            ? statsBestStreakWeek.value
            : this.statsBestStreakWeek,
        statsBestStreakMonth: statsBestStreakMonth.present
            ? statsBestStreakMonth.value
            : this.statsBestStreakMonth,
        statsBestStreakYear: statsBestStreakYear.present
            ? statsBestStreakYear.value
            : this.statsBestStreakYear,
        statsLastPlayedAt: statsLastPlayedAt.present
            ? statsLastPlayedAt.value
            : this.statsLastPlayedAt,
      );
  QuizCardTableData copyWithCompanion(QuizCardTableCompanion data) {
    return QuizCardTableData(
      id: data.id.present ? data.id.value : this.id,
      uid: data.uid.present ? data.uid.value : this.uid,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      questionText: data.questionText.present
          ? data.questionText.value
          : this.questionText,
      answerText:
          data.answerText.present ? data.answerText.value : this.answerText,
      isArchive: data.isArchive.present ? data.isArchive.value : this.isArchive,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      statsAccuracyWeek: data.statsAccuracyWeek.present
          ? data.statsAccuracyWeek.value
          : this.statsAccuracyWeek,
      statsAccuracyMonth: data.statsAccuracyMonth.present
          ? data.statsAccuracyMonth.value
          : this.statsAccuracyMonth,
      statsAccuracyYear: data.statsAccuracyYear.present
          ? data.statsAccuracyYear.value
          : this.statsAccuracyYear,
      statsAttemptsWeek: data.statsAttemptsWeek.present
          ? data.statsAttemptsWeek.value
          : this.statsAttemptsWeek,
      statsAttemptsMonth: data.statsAttemptsMonth.present
          ? data.statsAttemptsMonth.value
          : this.statsAttemptsMonth,
      statsAttemptsYear: data.statsAttemptsYear.present
          ? data.statsAttemptsYear.value
          : this.statsAttemptsYear,
      statsBestStreakWeek: data.statsBestStreakWeek.present
          ? data.statsBestStreakWeek.value
          : this.statsBestStreakWeek,
      statsBestStreakMonth: data.statsBestStreakMonth.present
          ? data.statsBestStreakMonth.value
          : this.statsBestStreakMonth,
      statsBestStreakYear: data.statsBestStreakYear.present
          ? data.statsBestStreakYear.value
          : this.statsBestStreakYear,
      statsLastPlayedAt: data.statsLastPlayedAt.present
          ? data.statsLastPlayedAt.value
          : this.statsLastPlayedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuizCardTableData(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('deckId: $deckId, ')
          ..write('questionText: $questionText, ')
          ..write('answerText: $answerText, ')
          ..write('isArchive: $isArchive, ')
          ..write('remoteId: $remoteId, ')
          ..write('isDirty: $isDirty, ')
          ..write('statsAccuracyWeek: $statsAccuracyWeek, ')
          ..write('statsAccuracyMonth: $statsAccuracyMonth, ')
          ..write('statsAccuracyYear: $statsAccuracyYear, ')
          ..write('statsAttemptsWeek: $statsAttemptsWeek, ')
          ..write('statsAttemptsMonth: $statsAttemptsMonth, ')
          ..write('statsAttemptsYear: $statsAttemptsYear, ')
          ..write('statsBestStreakWeek: $statsBestStreakWeek, ')
          ..write('statsBestStreakMonth: $statsBestStreakMonth, ')
          ..write('statsBestStreakYear: $statsBestStreakYear, ')
          ..write('statsLastPlayedAt: $statsLastPlayedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      uid,
      deckId,
      questionText,
      answerText,
      isArchive,
      remoteId,
      isDirty,
      statsAccuracyWeek,
      statsAccuracyMonth,
      statsAccuracyYear,
      statsAttemptsWeek,
      statsAttemptsMonth,
      statsAttemptsYear,
      statsBestStreakWeek,
      statsBestStreakMonth,
      statsBestStreakYear,
      statsLastPlayedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuizCardTableData &&
          other.id == this.id &&
          other.uid == this.uid &&
          other.deckId == this.deckId &&
          other.questionText == this.questionText &&
          other.answerText == this.answerText &&
          other.isArchive == this.isArchive &&
          other.remoteId == this.remoteId &&
          other.isDirty == this.isDirty &&
          other.statsAccuracyWeek == this.statsAccuracyWeek &&
          other.statsAccuracyMonth == this.statsAccuracyMonth &&
          other.statsAccuracyYear == this.statsAccuracyYear &&
          other.statsAttemptsWeek == this.statsAttemptsWeek &&
          other.statsAttemptsMonth == this.statsAttemptsMonth &&
          other.statsAttemptsYear == this.statsAttemptsYear &&
          other.statsBestStreakWeek == this.statsBestStreakWeek &&
          other.statsBestStreakMonth == this.statsBestStreakMonth &&
          other.statsBestStreakYear == this.statsBestStreakYear &&
          other.statsLastPlayedAt == this.statsLastPlayedAt);
}

class QuizCardTableCompanion extends UpdateCompanion<QuizCardTableData> {
  final Value<int> id;
  final Value<int?> uid;
  final Value<int> deckId;
  final Value<String> questionText;
  final Value<String> answerText;
  final Value<bool> isArchive;
  final Value<String?> remoteId;
  final Value<bool> isDirty;
  final Value<double?> statsAccuracyWeek;
  final Value<double?> statsAccuracyMonth;
  final Value<double?> statsAccuracyYear;
  final Value<int?> statsAttemptsWeek;
  final Value<int?> statsAttemptsMonth;
  final Value<int?> statsAttemptsYear;
  final Value<int?> statsBestStreakWeek;
  final Value<int?> statsBestStreakMonth;
  final Value<int?> statsBestStreakYear;
  final Value<DateTime?> statsLastPlayedAt;
  const QuizCardTableCompanion({
    this.id = const Value.absent(),
    this.uid = const Value.absent(),
    this.deckId = const Value.absent(),
    this.questionText = const Value.absent(),
    this.answerText = const Value.absent(),
    this.isArchive = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.statsAccuracyWeek = const Value.absent(),
    this.statsAccuracyMonth = const Value.absent(),
    this.statsAccuracyYear = const Value.absent(),
    this.statsAttemptsWeek = const Value.absent(),
    this.statsAttemptsMonth = const Value.absent(),
    this.statsAttemptsYear = const Value.absent(),
    this.statsBestStreakWeek = const Value.absent(),
    this.statsBestStreakMonth = const Value.absent(),
    this.statsBestStreakYear = const Value.absent(),
    this.statsLastPlayedAt = const Value.absent(),
  });
  QuizCardTableCompanion.insert({
    this.id = const Value.absent(),
    this.uid = const Value.absent(),
    required int deckId,
    required String questionText,
    required String answerText,
    required bool isArchive,
    this.remoteId = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.statsAccuracyWeek = const Value.absent(),
    this.statsAccuracyMonth = const Value.absent(),
    this.statsAccuracyYear = const Value.absent(),
    this.statsAttemptsWeek = const Value.absent(),
    this.statsAttemptsMonth = const Value.absent(),
    this.statsAttemptsYear = const Value.absent(),
    this.statsBestStreakWeek = const Value.absent(),
    this.statsBestStreakMonth = const Value.absent(),
    this.statsBestStreakYear = const Value.absent(),
    this.statsLastPlayedAt = const Value.absent(),
  })  : deckId = Value(deckId),
        questionText = Value(questionText),
        answerText = Value(answerText),
        isArchive = Value(isArchive);
  static Insertable<QuizCardTableData> custom({
    Expression<int>? id,
    Expression<int>? uid,
    Expression<int>? deckId,
    Expression<String>? questionText,
    Expression<String>? answerText,
    Expression<bool>? isArchive,
    Expression<String>? remoteId,
    Expression<bool>? isDirty,
    Expression<double>? statsAccuracyWeek,
    Expression<double>? statsAccuracyMonth,
    Expression<double>? statsAccuracyYear,
    Expression<int>? statsAttemptsWeek,
    Expression<int>? statsAttemptsMonth,
    Expression<int>? statsAttemptsYear,
    Expression<int>? statsBestStreakWeek,
    Expression<int>? statsBestStreakMonth,
    Expression<int>? statsBestStreakYear,
    Expression<DateTime>? statsLastPlayedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uid != null) 'uid': uid,
      if (deckId != null) 'deck_id': deckId,
      if (questionText != null) 'question_text': questionText,
      if (answerText != null) 'answer_text': answerText,
      if (isArchive != null) 'is_archive': isArchive,
      if (remoteId != null) 'remote_id': remoteId,
      if (isDirty != null) 'is_dirty': isDirty,
      if (statsAccuracyWeek != null) 'stats_accuracy_week': statsAccuracyWeek,
      if (statsAccuracyMonth != null)
        'stats_accuracy_month': statsAccuracyMonth,
      if (statsAccuracyYear != null) 'stats_accuracy_year': statsAccuracyYear,
      if (statsAttemptsWeek != null) 'stats_attempts_week': statsAttemptsWeek,
      if (statsAttemptsMonth != null)
        'stats_attempts_month': statsAttemptsMonth,
      if (statsAttemptsYear != null) 'stats_attempts_year': statsAttemptsYear,
      if (statsBestStreakWeek != null)
        'stats_best_streak_week': statsBestStreakWeek,
      if (statsBestStreakMonth != null)
        'stats_best_streak_month': statsBestStreakMonth,
      if (statsBestStreakYear != null)
        'stats_best_streak_year': statsBestStreakYear,
      if (statsLastPlayedAt != null) 'stats_last_played_at': statsLastPlayedAt,
    });
  }

  QuizCardTableCompanion copyWith(
      {Value<int>? id,
      Value<int?>? uid,
      Value<int>? deckId,
      Value<String>? questionText,
      Value<String>? answerText,
      Value<bool>? isArchive,
      Value<String?>? remoteId,
      Value<bool>? isDirty,
      Value<double?>? statsAccuracyWeek,
      Value<double?>? statsAccuracyMonth,
      Value<double?>? statsAccuracyYear,
      Value<int?>? statsAttemptsWeek,
      Value<int?>? statsAttemptsMonth,
      Value<int?>? statsAttemptsYear,
      Value<int?>? statsBestStreakWeek,
      Value<int?>? statsBestStreakMonth,
      Value<int?>? statsBestStreakYear,
      Value<DateTime?>? statsLastPlayedAt}) {
    return QuizCardTableCompanion(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      deckId: deckId ?? this.deckId,
      questionText: questionText ?? this.questionText,
      answerText: answerText ?? this.answerText,
      isArchive: isArchive ?? this.isArchive,
      remoteId: remoteId ?? this.remoteId,
      isDirty: isDirty ?? this.isDirty,
      statsAccuracyWeek: statsAccuracyWeek ?? this.statsAccuracyWeek,
      statsAccuracyMonth: statsAccuracyMonth ?? this.statsAccuracyMonth,
      statsAccuracyYear: statsAccuracyYear ?? this.statsAccuracyYear,
      statsAttemptsWeek: statsAttemptsWeek ?? this.statsAttemptsWeek,
      statsAttemptsMonth: statsAttemptsMonth ?? this.statsAttemptsMonth,
      statsAttemptsYear: statsAttemptsYear ?? this.statsAttemptsYear,
      statsBestStreakWeek: statsBestStreakWeek ?? this.statsBestStreakWeek,
      statsBestStreakMonth: statsBestStreakMonth ?? this.statsBestStreakMonth,
      statsBestStreakYear: statsBestStreakYear ?? this.statsBestStreakYear,
      statsLastPlayedAt: statsLastPlayedAt ?? this.statsLastPlayedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uid.present) {
      map['uid'] = Variable<int>(uid.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<int>(deckId.value);
    }
    if (questionText.present) {
      map['question_text'] = Variable<String>(questionText.value);
    }
    if (answerText.present) {
      map['answer_text'] = Variable<String>(answerText.value);
    }
    if (isArchive.present) {
      map['is_archive'] = Variable<bool>(isArchive.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (statsAccuracyWeek.present) {
      map['stats_accuracy_week'] = Variable<double>(statsAccuracyWeek.value);
    }
    if (statsAccuracyMonth.present) {
      map['stats_accuracy_month'] = Variable<double>(statsAccuracyMonth.value);
    }
    if (statsAccuracyYear.present) {
      map['stats_accuracy_year'] = Variable<double>(statsAccuracyYear.value);
    }
    if (statsAttemptsWeek.present) {
      map['stats_attempts_week'] = Variable<int>(statsAttemptsWeek.value);
    }
    if (statsAttemptsMonth.present) {
      map['stats_attempts_month'] = Variable<int>(statsAttemptsMonth.value);
    }
    if (statsAttemptsYear.present) {
      map['stats_attempts_year'] = Variable<int>(statsAttemptsYear.value);
    }
    if (statsBestStreakWeek.present) {
      map['stats_best_streak_week'] = Variable<int>(statsBestStreakWeek.value);
    }
    if (statsBestStreakMonth.present) {
      map['stats_best_streak_month'] =
          Variable<int>(statsBestStreakMonth.value);
    }
    if (statsBestStreakYear.present) {
      map['stats_best_streak_year'] = Variable<int>(statsBestStreakYear.value);
    }
    if (statsLastPlayedAt.present) {
      map['stats_last_played_at'] = Variable<DateTime>(statsLastPlayedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuizCardTableCompanion(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('deckId: $deckId, ')
          ..write('questionText: $questionText, ')
          ..write('answerText: $answerText, ')
          ..write('isArchive: $isArchive, ')
          ..write('remoteId: $remoteId, ')
          ..write('isDirty: $isDirty, ')
          ..write('statsAccuracyWeek: $statsAccuracyWeek, ')
          ..write('statsAccuracyMonth: $statsAccuracyMonth, ')
          ..write('statsAccuracyYear: $statsAccuracyYear, ')
          ..write('statsAttemptsWeek: $statsAttemptsWeek, ')
          ..write('statsAttemptsMonth: $statsAttemptsMonth, ')
          ..write('statsAttemptsYear: $statsAttemptsYear, ')
          ..write('statsBestStreakWeek: $statsBestStreakWeek, ')
          ..write('statsBestStreakMonth: $statsBestStreakMonth, ')
          ..write('statsBestStreakYear: $statsBestStreakYear, ')
          ..write('statsLastPlayedAt: $statsLastPlayedAt')
          ..write(')'))
        .toString();
  }
}

class $UserTableTable extends UserTable
    with TableInfo<$UserTableTable, UserTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  @override
  List<GeneratedColumn> get $columns => [id];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_table';
  @override
  VerificationContext validateIntegrity(Insertable<UserTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
    );
  }

  @override
  $UserTableTable createAlias(String alias) {
    return $UserTableTable(attachedDatabase, alias);
  }
}

class UserTableData extends DataClass implements Insertable<UserTableData> {
  final int id;
  const UserTableData({required this.id});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    return map;
  }

  UserTableCompanion toCompanion(bool nullToAbsent) {
    return UserTableCompanion(
      id: Value(id),
    );
  }

  factory UserTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserTableData(
      id: serializer.fromJson<int>(json['id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
    };
  }

  UserTableData copyWith({int? id}) => UserTableData(
        id: id ?? this.id,
      );
  UserTableData copyWithCompanion(UserTableCompanion data) {
    return UserTableData(
      id: data.id.present ? data.id.value : this.id,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserTableData(')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => id.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is UserTableData && other.id == this.id);
}

class UserTableCompanion extends UpdateCompanion<UserTableData> {
  final Value<int> id;
  const UserTableCompanion({
    this.id = const Value.absent(),
  });
  UserTableCompanion.insert({
    this.id = const Value.absent(),
  });
  static Insertable<UserTableData> custom({
    Expression<int>? id,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
    });
  }

  UserTableCompanion copyWith({Value<int>? id}) {
    return UserTableCompanion(
      id: id ?? this.id,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserTableCompanion(')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTableTable extends UserSettingsTable
    with TableInfo<$UserSettingsTableTable, UserSettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES user_table (id)'));
  static const VerificationMeta _answerValidatorTypeMeta =
      const VerificationMeta('answerValidatorType');
  @override
  late final GeneratedColumn<String> answerValidatorType =
      GeneratedColumn<String>('answer_validator_type', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('ml'));
  static const VerificationMeta _deckGenerationAiTypeMeta =
      const VerificationMeta('deckGenerationAiType');
  @override
  late final GeneratedColumn<String> deckGenerationAiType =
      GeneratedColumn<String>('deck_generation_ai_type', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('claude'));
  static const VerificationMeta _geminiApiKeyMeta =
      const VerificationMeta('geminiApiKey');
  @override
  late final GeneratedColumn<String> geminiApiKey = GeneratedColumn<String>(
      'gemini_api_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _geminiModelNameMeta =
      const VerificationMeta('geminiModelName');
  @override
  late final GeneratedColumn<String> geminiModelName = GeneratedColumn<String>(
      'gemini_model_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _claudeApiKeyMeta =
      const VerificationMeta('claudeApiKey');
  @override
  late final GeneratedColumn<String> claudeApiKey = GeneratedColumn<String>(
      'claude_api_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _claudeModelNameMeta =
      const VerificationMeta('claudeModelName');
  @override
  late final GeneratedColumn<String> claudeModelName = GeneratedColumn<String>(
      'claude_model_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _openAiApiKeyMeta =
      const VerificationMeta('openAiApiKey');
  @override
  late final GeneratedColumn<String> openAiApiKey = GeneratedColumn<String>(
      'open_ai_api_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _openAiModelNameMeta =
      const VerificationMeta('openAiModelName');
  @override
  late final GeneratedColumn<String> openAiModelName = GeneratedColumn<String>(
      'open_ai_model_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ollamaModelUrlMeta =
      const VerificationMeta('ollamaModelUrl');
  @override
  late final GeneratedColumn<String> ollamaModelUrl = GeneratedColumn<String>(
      'ollama_model_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ollamaModelNameMeta =
      const VerificationMeta('ollamaModelName');
  @override
  late final GeneratedColumn<String> ollamaModelName = GeneratedColumn<String>(
      'ollama_model_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _onboardingCompletedMeta =
      const VerificationMeta('onboardingCompleted');
  @override
  late final GeneratedColumn<bool> onboardingCompleted = GeneratedColumn<bool>(
      'onboarding_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("onboarding_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        answerValidatorType,
        deckGenerationAiType,
        geminiApiKey,
        geminiModelName,
        claudeApiKey,
        claudeModelName,
        openAiApiKey,
        openAiModelName,
        ollamaModelUrl,
        ollamaModelName,
        onboardingCompleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<UserSettingsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('answer_validator_type')) {
      context.handle(
          _answerValidatorTypeMeta,
          answerValidatorType.isAcceptableOrUnknown(
              data['answer_validator_type']!, _answerValidatorTypeMeta));
    }
    if (data.containsKey('deck_generation_ai_type')) {
      context.handle(
          _deckGenerationAiTypeMeta,
          deckGenerationAiType.isAcceptableOrUnknown(
              data['deck_generation_ai_type']!, _deckGenerationAiTypeMeta));
    }
    if (data.containsKey('gemini_api_key')) {
      context.handle(
          _geminiApiKeyMeta,
          geminiApiKey.isAcceptableOrUnknown(
              data['gemini_api_key']!, _geminiApiKeyMeta));
    }
    if (data.containsKey('gemini_model_name')) {
      context.handle(
          _geminiModelNameMeta,
          geminiModelName.isAcceptableOrUnknown(
              data['gemini_model_name']!, _geminiModelNameMeta));
    }
    if (data.containsKey('claude_api_key')) {
      context.handle(
          _claudeApiKeyMeta,
          claudeApiKey.isAcceptableOrUnknown(
              data['claude_api_key']!, _claudeApiKeyMeta));
    }
    if (data.containsKey('claude_model_name')) {
      context.handle(
          _claudeModelNameMeta,
          claudeModelName.isAcceptableOrUnknown(
              data['claude_model_name']!, _claudeModelNameMeta));
    }
    if (data.containsKey('open_ai_api_key')) {
      context.handle(
          _openAiApiKeyMeta,
          openAiApiKey.isAcceptableOrUnknown(
              data['open_ai_api_key']!, _openAiApiKeyMeta));
    }
    if (data.containsKey('open_ai_model_name')) {
      context.handle(
          _openAiModelNameMeta,
          openAiModelName.isAcceptableOrUnknown(
              data['open_ai_model_name']!, _openAiModelNameMeta));
    }
    if (data.containsKey('ollama_model_url')) {
      context.handle(
          _ollamaModelUrlMeta,
          ollamaModelUrl.isAcceptableOrUnknown(
              data['ollama_model_url']!, _ollamaModelUrlMeta));
    }
    if (data.containsKey('ollama_model_name')) {
      context.handle(
          _ollamaModelNameMeta,
          ollamaModelName.isAcceptableOrUnknown(
              data['ollama_model_name']!, _ollamaModelNameMeta));
    }
    if (data.containsKey('onboarding_completed')) {
      context.handle(
          _onboardingCompletedMeta,
          onboardingCompleted.isAcceptableOrUnknown(
              data['onboarding_completed']!, _onboardingCompletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserSettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSettingsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      answerValidatorType: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}answer_validator_type'])!,
      deckGenerationAiType: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deck_generation_ai_type'])!,
      geminiApiKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gemini_api_key']),
      geminiModelName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}gemini_model_name']),
      claudeApiKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}claude_api_key']),
      claudeModelName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}claude_model_name']),
      openAiApiKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}open_ai_api_key']),
      openAiModelName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}open_ai_model_name']),
      ollamaModelUrl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}ollama_model_url']),
      ollamaModelName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}ollama_model_name']),
      onboardingCompleted: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}onboarding_completed'])!,
    );
  }

  @override
  $UserSettingsTableTable createAlias(String alias) {
    return $UserSettingsTableTable(attachedDatabase, alias);
  }
}

class UserSettingsTableData extends DataClass
    implements Insertable<UserSettingsTableData> {
  final int id;
  final int userId;
  final String answerValidatorType;
  final String deckGenerationAiType;
  final String? geminiApiKey;
  final String? geminiModelName;
  final String? claudeApiKey;
  final String? claudeModelName;
  final String? openAiApiKey;
  final String? openAiModelName;
  final String? ollamaModelUrl;
  final String? ollamaModelName;
  final bool onboardingCompleted;
  const UserSettingsTableData(
      {required this.id,
      required this.userId,
      required this.answerValidatorType,
      required this.deckGenerationAiType,
      this.geminiApiKey,
      this.geminiModelName,
      this.claudeApiKey,
      this.claudeModelName,
      this.openAiApiKey,
      this.openAiModelName,
      this.ollamaModelUrl,
      this.ollamaModelName,
      required this.onboardingCompleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['answer_validator_type'] = Variable<String>(answerValidatorType);
    map['deck_generation_ai_type'] = Variable<String>(deckGenerationAiType);
    if (!nullToAbsent || geminiApiKey != null) {
      map['gemini_api_key'] = Variable<String>(geminiApiKey);
    }
    if (!nullToAbsent || geminiModelName != null) {
      map['gemini_model_name'] = Variable<String>(geminiModelName);
    }
    if (!nullToAbsent || claudeApiKey != null) {
      map['claude_api_key'] = Variable<String>(claudeApiKey);
    }
    if (!nullToAbsent || claudeModelName != null) {
      map['claude_model_name'] = Variable<String>(claudeModelName);
    }
    if (!nullToAbsent || openAiApiKey != null) {
      map['open_ai_api_key'] = Variable<String>(openAiApiKey);
    }
    if (!nullToAbsent || openAiModelName != null) {
      map['open_ai_model_name'] = Variable<String>(openAiModelName);
    }
    if (!nullToAbsent || ollamaModelUrl != null) {
      map['ollama_model_url'] = Variable<String>(ollamaModelUrl);
    }
    if (!nullToAbsent || ollamaModelName != null) {
      map['ollama_model_name'] = Variable<String>(ollamaModelName);
    }
    map['onboarding_completed'] = Variable<bool>(onboardingCompleted);
    return map;
  }

  UserSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsTableCompanion(
      id: Value(id),
      userId: Value(userId),
      answerValidatorType: Value(answerValidatorType),
      deckGenerationAiType: Value(deckGenerationAiType),
      geminiApiKey: geminiApiKey == null && nullToAbsent
          ? const Value.absent()
          : Value(geminiApiKey),
      geminiModelName: geminiModelName == null && nullToAbsent
          ? const Value.absent()
          : Value(geminiModelName),
      claudeApiKey: claudeApiKey == null && nullToAbsent
          ? const Value.absent()
          : Value(claudeApiKey),
      claudeModelName: claudeModelName == null && nullToAbsent
          ? const Value.absent()
          : Value(claudeModelName),
      openAiApiKey: openAiApiKey == null && nullToAbsent
          ? const Value.absent()
          : Value(openAiApiKey),
      openAiModelName: openAiModelName == null && nullToAbsent
          ? const Value.absent()
          : Value(openAiModelName),
      ollamaModelUrl: ollamaModelUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(ollamaModelUrl),
      ollamaModelName: ollamaModelName == null && nullToAbsent
          ? const Value.absent()
          : Value(ollamaModelName),
      onboardingCompleted: Value(onboardingCompleted),
    );
  }

  factory UserSettingsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSettingsTableData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      answerValidatorType:
          serializer.fromJson<String>(json['answerValidatorType']),
      deckGenerationAiType:
          serializer.fromJson<String>(json['deckGenerationAiType']),
      geminiApiKey: serializer.fromJson<String?>(json['geminiApiKey']),
      geminiModelName: serializer.fromJson<String?>(json['geminiModelName']),
      claudeApiKey: serializer.fromJson<String?>(json['claudeApiKey']),
      claudeModelName: serializer.fromJson<String?>(json['claudeModelName']),
      openAiApiKey: serializer.fromJson<String?>(json['openAiApiKey']),
      openAiModelName: serializer.fromJson<String?>(json['openAiModelName']),
      ollamaModelUrl: serializer.fromJson<String?>(json['ollamaModelUrl']),
      ollamaModelName: serializer.fromJson<String?>(json['ollamaModelName']),
      onboardingCompleted:
          serializer.fromJson<bool>(json['onboardingCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'answerValidatorType': serializer.toJson<String>(answerValidatorType),
      'deckGenerationAiType': serializer.toJson<String>(deckGenerationAiType),
      'geminiApiKey': serializer.toJson<String?>(geminiApiKey),
      'geminiModelName': serializer.toJson<String?>(geminiModelName),
      'claudeApiKey': serializer.toJson<String?>(claudeApiKey),
      'claudeModelName': serializer.toJson<String?>(claudeModelName),
      'openAiApiKey': serializer.toJson<String?>(openAiApiKey),
      'openAiModelName': serializer.toJson<String?>(openAiModelName),
      'ollamaModelUrl': serializer.toJson<String?>(ollamaModelUrl),
      'ollamaModelName': serializer.toJson<String?>(ollamaModelName),
      'onboardingCompleted': serializer.toJson<bool>(onboardingCompleted),
    };
  }

  UserSettingsTableData copyWith(
          {int? id,
          int? userId,
          String? answerValidatorType,
          String? deckGenerationAiType,
          Value<String?> geminiApiKey = const Value.absent(),
          Value<String?> geminiModelName = const Value.absent(),
          Value<String?> claudeApiKey = const Value.absent(),
          Value<String?> claudeModelName = const Value.absent(),
          Value<String?> openAiApiKey = const Value.absent(),
          Value<String?> openAiModelName = const Value.absent(),
          Value<String?> ollamaModelUrl = const Value.absent(),
          Value<String?> ollamaModelName = const Value.absent(),
          bool? onboardingCompleted}) =>
      UserSettingsTableData(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        answerValidatorType: answerValidatorType ?? this.answerValidatorType,
        deckGenerationAiType: deckGenerationAiType ?? this.deckGenerationAiType,
        geminiApiKey:
            geminiApiKey.present ? geminiApiKey.value : this.geminiApiKey,
        geminiModelName: geminiModelName.present
            ? geminiModelName.value
            : this.geminiModelName,
        claudeApiKey:
            claudeApiKey.present ? claudeApiKey.value : this.claudeApiKey,
        claudeModelName: claudeModelName.present
            ? claudeModelName.value
            : this.claudeModelName,
        openAiApiKey:
            openAiApiKey.present ? openAiApiKey.value : this.openAiApiKey,
        openAiModelName: openAiModelName.present
            ? openAiModelName.value
            : this.openAiModelName,
        ollamaModelUrl:
            ollamaModelUrl.present ? ollamaModelUrl.value : this.ollamaModelUrl,
        ollamaModelName: ollamaModelName.present
            ? ollamaModelName.value
            : this.ollamaModelName,
        onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      );
  UserSettingsTableData copyWithCompanion(UserSettingsTableCompanion data) {
    return UserSettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      answerValidatorType: data.answerValidatorType.present
          ? data.answerValidatorType.value
          : this.answerValidatorType,
      deckGenerationAiType: data.deckGenerationAiType.present
          ? data.deckGenerationAiType.value
          : this.deckGenerationAiType,
      geminiApiKey: data.geminiApiKey.present
          ? data.geminiApiKey.value
          : this.geminiApiKey,
      geminiModelName: data.geminiModelName.present
          ? data.geminiModelName.value
          : this.geminiModelName,
      claudeApiKey: data.claudeApiKey.present
          ? data.claudeApiKey.value
          : this.claudeApiKey,
      claudeModelName: data.claudeModelName.present
          ? data.claudeModelName.value
          : this.claudeModelName,
      openAiApiKey: data.openAiApiKey.present
          ? data.openAiApiKey.value
          : this.openAiApiKey,
      openAiModelName: data.openAiModelName.present
          ? data.openAiModelName.value
          : this.openAiModelName,
      ollamaModelUrl: data.ollamaModelUrl.present
          ? data.ollamaModelUrl.value
          : this.ollamaModelUrl,
      ollamaModelName: data.ollamaModelName.present
          ? data.ollamaModelName.value
          : this.ollamaModelName,
      onboardingCompleted: data.onboardingCompleted.present
          ? data.onboardingCompleted.value
          : this.onboardingCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsTableData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('answerValidatorType: $answerValidatorType, ')
          ..write('deckGenerationAiType: $deckGenerationAiType, ')
          ..write('geminiApiKey: $geminiApiKey, ')
          ..write('geminiModelName: $geminiModelName, ')
          ..write('claudeApiKey: $claudeApiKey, ')
          ..write('claudeModelName: $claudeModelName, ')
          ..write('openAiApiKey: $openAiApiKey, ')
          ..write('openAiModelName: $openAiModelName, ')
          ..write('ollamaModelUrl: $ollamaModelUrl, ')
          ..write('ollamaModelName: $ollamaModelName, ')
          ..write('onboardingCompleted: $onboardingCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userId,
      answerValidatorType,
      deckGenerationAiType,
      geminiApiKey,
      geminiModelName,
      claudeApiKey,
      claudeModelName,
      openAiApiKey,
      openAiModelName,
      ollamaModelUrl,
      ollamaModelName,
      onboardingCompleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSettingsTableData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.answerValidatorType == this.answerValidatorType &&
          other.deckGenerationAiType == this.deckGenerationAiType &&
          other.geminiApiKey == this.geminiApiKey &&
          other.geminiModelName == this.geminiModelName &&
          other.claudeApiKey == this.claudeApiKey &&
          other.claudeModelName == this.claudeModelName &&
          other.openAiApiKey == this.openAiApiKey &&
          other.openAiModelName == this.openAiModelName &&
          other.ollamaModelUrl == this.ollamaModelUrl &&
          other.ollamaModelName == this.ollamaModelName &&
          other.onboardingCompleted == this.onboardingCompleted);
}

class UserSettingsTableCompanion
    extends UpdateCompanion<UserSettingsTableData> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> answerValidatorType;
  final Value<String> deckGenerationAiType;
  final Value<String?> geminiApiKey;
  final Value<String?> geminiModelName;
  final Value<String?> claudeApiKey;
  final Value<String?> claudeModelName;
  final Value<String?> openAiApiKey;
  final Value<String?> openAiModelName;
  final Value<String?> ollamaModelUrl;
  final Value<String?> ollamaModelName;
  final Value<bool> onboardingCompleted;
  const UserSettingsTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.answerValidatorType = const Value.absent(),
    this.deckGenerationAiType = const Value.absent(),
    this.geminiApiKey = const Value.absent(),
    this.geminiModelName = const Value.absent(),
    this.claudeApiKey = const Value.absent(),
    this.claudeModelName = const Value.absent(),
    this.openAiApiKey = const Value.absent(),
    this.openAiModelName = const Value.absent(),
    this.ollamaModelUrl = const Value.absent(),
    this.ollamaModelName = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
  });
  UserSettingsTableCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    this.answerValidatorType = const Value.absent(),
    this.deckGenerationAiType = const Value.absent(),
    this.geminiApiKey = const Value.absent(),
    this.geminiModelName = const Value.absent(),
    this.claudeApiKey = const Value.absent(),
    this.claudeModelName = const Value.absent(),
    this.openAiApiKey = const Value.absent(),
    this.openAiModelName = const Value.absent(),
    this.ollamaModelUrl = const Value.absent(),
    this.ollamaModelName = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<UserSettingsTableData> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? answerValidatorType,
    Expression<String>? deckGenerationAiType,
    Expression<String>? geminiApiKey,
    Expression<String>? geminiModelName,
    Expression<String>? claudeApiKey,
    Expression<String>? claudeModelName,
    Expression<String>? openAiApiKey,
    Expression<String>? openAiModelName,
    Expression<String>? ollamaModelUrl,
    Expression<String>? ollamaModelName,
    Expression<bool>? onboardingCompleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (answerValidatorType != null)
        'answer_validator_type': answerValidatorType,
      if (deckGenerationAiType != null)
        'deck_generation_ai_type': deckGenerationAiType,
      if (geminiApiKey != null) 'gemini_api_key': geminiApiKey,
      if (geminiModelName != null) 'gemini_model_name': geminiModelName,
      if (claudeApiKey != null) 'claude_api_key': claudeApiKey,
      if (claudeModelName != null) 'claude_model_name': claudeModelName,
      if (openAiApiKey != null) 'open_ai_api_key': openAiApiKey,
      if (openAiModelName != null) 'open_ai_model_name': openAiModelName,
      if (ollamaModelUrl != null) 'ollama_model_url': ollamaModelUrl,
      if (ollamaModelName != null) 'ollama_model_name': ollamaModelName,
      if (onboardingCompleted != null)
        'onboarding_completed': onboardingCompleted,
    });
  }

  UserSettingsTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? userId,
      Value<String>? answerValidatorType,
      Value<String>? deckGenerationAiType,
      Value<String?>? geminiApiKey,
      Value<String?>? geminiModelName,
      Value<String?>? claudeApiKey,
      Value<String?>? claudeModelName,
      Value<String?>? openAiApiKey,
      Value<String?>? openAiModelName,
      Value<String?>? ollamaModelUrl,
      Value<String?>? ollamaModelName,
      Value<bool>? onboardingCompleted}) {
    return UserSettingsTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      answerValidatorType: answerValidatorType ?? this.answerValidatorType,
      deckGenerationAiType: deckGenerationAiType ?? this.deckGenerationAiType,
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      geminiModelName: geminiModelName ?? this.geminiModelName,
      claudeApiKey: claudeApiKey ?? this.claudeApiKey,
      claudeModelName: claudeModelName ?? this.claudeModelName,
      openAiApiKey: openAiApiKey ?? this.openAiApiKey,
      openAiModelName: openAiModelName ?? this.openAiModelName,
      ollamaModelUrl: ollamaModelUrl ?? this.ollamaModelUrl,
      ollamaModelName: ollamaModelName ?? this.ollamaModelName,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (answerValidatorType.present) {
      map['answer_validator_type'] =
          Variable<String>(answerValidatorType.value);
    }
    if (deckGenerationAiType.present) {
      map['deck_generation_ai_type'] =
          Variable<String>(deckGenerationAiType.value);
    }
    if (geminiApiKey.present) {
      map['gemini_api_key'] = Variable<String>(geminiApiKey.value);
    }
    if (geminiModelName.present) {
      map['gemini_model_name'] = Variable<String>(geminiModelName.value);
    }
    if (claudeApiKey.present) {
      map['claude_api_key'] = Variable<String>(claudeApiKey.value);
    }
    if (claudeModelName.present) {
      map['claude_model_name'] = Variable<String>(claudeModelName.value);
    }
    if (openAiApiKey.present) {
      map['open_ai_api_key'] = Variable<String>(openAiApiKey.value);
    }
    if (openAiModelName.present) {
      map['open_ai_model_name'] = Variable<String>(openAiModelName.value);
    }
    if (ollamaModelUrl.present) {
      map['ollama_model_url'] = Variable<String>(ollamaModelUrl.value);
    }
    if (ollamaModelName.present) {
      map['ollama_model_name'] = Variable<String>(ollamaModelName.value);
    }
    if (onboardingCompleted.present) {
      map['onboarding_completed'] = Variable<bool>(onboardingCompleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('answerValidatorType: $answerValidatorType, ')
          ..write('deckGenerationAiType: $deckGenerationAiType, ')
          ..write('geminiApiKey: $geminiApiKey, ')
          ..write('geminiModelName: $geminiModelName, ')
          ..write('claudeApiKey: $claudeApiKey, ')
          ..write('claudeModelName: $claudeModelName, ')
          ..write('openAiApiKey: $openAiApiKey, ')
          ..write('openAiModelName: $openAiModelName, ')
          ..write('ollamaModelUrl: $ollamaModelUrl, ')
          ..write('ollamaModelName: $ollamaModelName, ')
          ..write('onboardingCompleted: $onboardingCompleted')
          ..write(')'))
        .toString();
  }
}

class $SyncTombstoneTableTable extends SyncTombstoneTable
    with TableInfo<$SyncTombstoneTableTable, SyncTombstoneTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncTombstoneTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, entityType, remoteId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_tombstone_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<SyncTombstoneTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    } else if (isInserting) {
      context.missing(_remoteIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncTombstoneTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncTombstoneTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SyncTombstoneTableTable createAlias(String alias) {
    return $SyncTombstoneTableTable(attachedDatabase, alias);
  }
}

class SyncTombstoneTableData extends DataClass
    implements Insertable<SyncTombstoneTableData> {
  final int id;

  /// 'deck' | 'card'.
  final String entityType;

  /// The backend id to DELETE remotely.
  final String remoteId;
  final DateTime createdAt;
  const SyncTombstoneTableData(
      {required this.id,
      required this.entityType,
      required this.remoteId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['remote_id'] = Variable<String>(remoteId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncTombstoneTableCompanion toCompanion(bool nullToAbsent) {
    return SyncTombstoneTableCompanion(
      id: Value(id),
      entityType: Value(entityType),
      remoteId: Value(remoteId),
      createdAt: Value(createdAt),
    );
  }

  factory SyncTombstoneTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncTombstoneTableData(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      remoteId: serializer.fromJson<String>(json['remoteId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'remoteId': serializer.toJson<String>(remoteId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncTombstoneTableData copyWith(
          {int? id,
          String? entityType,
          String? remoteId,
          DateTime? createdAt}) =>
      SyncTombstoneTableData(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        remoteId: remoteId ?? this.remoteId,
        createdAt: createdAt ?? this.createdAt,
      );
  SyncTombstoneTableData copyWithCompanion(SyncTombstoneTableCompanion data) {
    return SyncTombstoneTableData(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncTombstoneTableData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('remoteId: $remoteId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entityType, remoteId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncTombstoneTableData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.remoteId == this.remoteId &&
          other.createdAt == this.createdAt);
}

class SyncTombstoneTableCompanion
    extends UpdateCompanion<SyncTombstoneTableData> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> remoteId;
  final Value<DateTime> createdAt;
  const SyncTombstoneTableCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncTombstoneTableCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String remoteId,
    this.createdAt = const Value.absent(),
  })  : entityType = Value(entityType),
        remoteId = Value(remoteId);
  static Insertable<SyncTombstoneTableData> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? remoteId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (remoteId != null) 'remote_id': remoteId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncTombstoneTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? entityType,
      Value<String>? remoteId,
      Value<DateTime>? createdAt}) {
    return SyncTombstoneTableCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      remoteId: remoteId ?? this.remoteId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncTombstoneTableCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('remoteId: $remoteId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DeckTableTable deckTable = $DeckTableTable(this);
  late final $QuizCardTableTable quizCardTable = $QuizCardTableTable(this);
  late final $UserTableTable userTable = $UserTableTable(this);
  late final $UserSettingsTableTable userSettingsTable =
      $UserSettingsTableTable(this);
  late final $SyncTombstoneTableTable syncTombstoneTable =
      $SyncTombstoneTableTable(this);
  late final Index deckTableUid = Index('deck_table_uid',
      'CREATE UNIQUE INDEX deck_table_uid ON deck_table (uid)');
  late final Index deckTableRemoteId = Index('deck_table_remote_id',
      'CREATE UNIQUE INDEX deck_table_remote_id ON deck_table (remote_id)');
  late final Index quizCardTableUid = Index('quiz_card_table_uid',
      'CREATE UNIQUE INDEX quiz_card_table_uid ON quiz_card_table (uid)');
  late final Index quizCardTableRemoteId = Index('quiz_card_table_remote_id',
      'CREATE UNIQUE INDEX quiz_card_table_remote_id ON quiz_card_table (remote_id)');
  late final Index syncTombstoneEntityRemoteId = Index(
      'sync_tombstone_entity_remote_id',
      'CREATE UNIQUE INDEX sync_tombstone_entity_remote_id ON sync_tombstone_table (entity_type, remote_id)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        deckTable,
        quizCardTable,
        userTable,
        userSettingsTable,
        syncTombstoneTable,
        deckTableUid,
        deckTableRemoteId,
        quizCardTableUid,
        quizCardTableRemoteId,
        syncTombstoneEntityRemoteId
      ];
}

typedef $$DeckTableTableCreateCompanionBuilder = DeckTableCompanion Function({
  Value<int> id,
  Value<int?> uid,
  required String title,
  required bool isArchive,
  Value<String?> remoteId,
  Value<bool> isDirty,
  Value<double?> statsAccuracyWeek,
  Value<double?> statsAccuracyMonth,
  Value<double?> statsAccuracyYear,
  Value<int?> statsAttemptsWeek,
  Value<int?> statsAttemptsMonth,
  Value<int?> statsAttemptsYear,
  Value<int?> statsBestStreakWeek,
  Value<int?> statsBestStreakMonth,
  Value<int?> statsBestStreakYear,
  Value<DateTime?> statsLastPlayedAt,
});
typedef $$DeckTableTableUpdateCompanionBuilder = DeckTableCompanion Function({
  Value<int> id,
  Value<int?> uid,
  Value<String> title,
  Value<bool> isArchive,
  Value<String?> remoteId,
  Value<bool> isDirty,
  Value<double?> statsAccuracyWeek,
  Value<double?> statsAccuracyMonth,
  Value<double?> statsAccuracyYear,
  Value<int?> statsAttemptsWeek,
  Value<int?> statsAttemptsMonth,
  Value<int?> statsAttemptsYear,
  Value<int?> statsBestStreakWeek,
  Value<int?> statsBestStreakMonth,
  Value<int?> statsBestStreakYear,
  Value<DateTime?> statsLastPlayedAt,
});

final class $$DeckTableTableReferences
    extends BaseReferences<_$AppDatabase, $DeckTableTable, DeckTableData> {
  $$DeckTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$QuizCardTableTable, List<QuizCardTableData>>
      _quizCardTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.quizCardTable,
              aliasName: $_aliasNameGenerator(
                  db.deckTable.id, db.quizCardTable.deckId));

  $$QuizCardTableTableProcessedTableManager get quizCardTableRefs {
    final manager = $$QuizCardTableTableTableManager($_db, $_db.quizCardTable)
        .filter((f) => f.deckId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_quizCardTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DeckTableTableFilterComposer
    extends Composer<_$AppDatabase, $DeckTableTable> {
  $$DeckTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchive => $composableBuilder(
      column: $table.isArchive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get statsAccuracyWeek => $composableBuilder(
      column: $table.statsAccuracyWeek,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get statsAccuracyMonth => $composableBuilder(
      column: $table.statsAccuracyMonth,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get statsAccuracyYear => $composableBuilder(
      column: $table.statsAccuracyYear,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get statsAttemptsWeek => $composableBuilder(
      column: $table.statsAttemptsWeek,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get statsAttemptsMonth => $composableBuilder(
      column: $table.statsAttemptsMonth,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get statsAttemptsYear => $composableBuilder(
      column: $table.statsAttemptsYear,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get statsBestStreakWeek => $composableBuilder(
      column: $table.statsBestStreakWeek,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get statsBestStreakMonth => $composableBuilder(
      column: $table.statsBestStreakMonth,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get statsBestStreakYear => $composableBuilder(
      column: $table.statsBestStreakYear,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get statsLastPlayedAt => $composableBuilder(
      column: $table.statsLastPlayedAt,
      builder: (column) => ColumnFilters(column));

  Expression<bool> quizCardTableRefs(
      Expression<bool> Function($$QuizCardTableTableFilterComposer f) f) {
    final $$QuizCardTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.quizCardTable,
        getReferencedColumn: (t) => t.deckId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuizCardTableTableFilterComposer(
              $db: $db,
              $table: $db.quizCardTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DeckTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DeckTableTable> {
  $$DeckTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchive => $composableBuilder(
      column: $table.isArchive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get statsAccuracyWeek => $composableBuilder(
      column: $table.statsAccuracyWeek,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get statsAccuracyMonth => $composableBuilder(
      column: $table.statsAccuracyMonth,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get statsAccuracyYear => $composableBuilder(
      column: $table.statsAccuracyYear,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get statsAttemptsWeek => $composableBuilder(
      column: $table.statsAttemptsWeek,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get statsAttemptsMonth => $composableBuilder(
      column: $table.statsAttemptsMonth,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get statsAttemptsYear => $composableBuilder(
      column: $table.statsAttemptsYear,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get statsBestStreakWeek => $composableBuilder(
      column: $table.statsBestStreakWeek,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get statsBestStreakMonth => $composableBuilder(
      column: $table.statsBestStreakMonth,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get statsBestStreakYear => $composableBuilder(
      column: $table.statsBestStreakYear,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get statsLastPlayedAt => $composableBuilder(
      column: $table.statsLastPlayedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$DeckTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeckTableTable> {
  $$DeckTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get isArchive =>
      $composableBuilder(column: $table.isArchive, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<double> get statsAccuracyWeek => $composableBuilder(
      column: $table.statsAccuracyWeek, builder: (column) => column);

  GeneratedColumn<double> get statsAccuracyMonth => $composableBuilder(
      column: $table.statsAccuracyMonth, builder: (column) => column);

  GeneratedColumn<double> get statsAccuracyYear => $composableBuilder(
      column: $table.statsAccuracyYear, builder: (column) => column);

  GeneratedColumn<int> get statsAttemptsWeek => $composableBuilder(
      column: $table.statsAttemptsWeek, builder: (column) => column);

  GeneratedColumn<int> get statsAttemptsMonth => $composableBuilder(
      column: $table.statsAttemptsMonth, builder: (column) => column);

  GeneratedColumn<int> get statsAttemptsYear => $composableBuilder(
      column: $table.statsAttemptsYear, builder: (column) => column);

  GeneratedColumn<int> get statsBestStreakWeek => $composableBuilder(
      column: $table.statsBestStreakWeek, builder: (column) => column);

  GeneratedColumn<int> get statsBestStreakMonth => $composableBuilder(
      column: $table.statsBestStreakMonth, builder: (column) => column);

  GeneratedColumn<int> get statsBestStreakYear => $composableBuilder(
      column: $table.statsBestStreakYear, builder: (column) => column);

  GeneratedColumn<DateTime> get statsLastPlayedAt => $composableBuilder(
      column: $table.statsLastPlayedAt, builder: (column) => column);

  Expression<T> quizCardTableRefs<T extends Object>(
      Expression<T> Function($$QuizCardTableTableAnnotationComposer a) f) {
    final $$QuizCardTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.quizCardTable,
        getReferencedColumn: (t) => t.deckId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuizCardTableTableAnnotationComposer(
              $db: $db,
              $table: $db.quizCardTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DeckTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DeckTableTable,
    DeckTableData,
    $$DeckTableTableFilterComposer,
    $$DeckTableTableOrderingComposer,
    $$DeckTableTableAnnotationComposer,
    $$DeckTableTableCreateCompanionBuilder,
    $$DeckTableTableUpdateCompanionBuilder,
    (DeckTableData, $$DeckTableTableReferences),
    DeckTableData,
    PrefetchHooks Function({bool quizCardTableRefs})> {
  $$DeckTableTableTableManager(_$AppDatabase db, $DeckTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeckTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeckTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeckTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> uid = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<bool> isArchive = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<double?> statsAccuracyWeek = const Value.absent(),
            Value<double?> statsAccuracyMonth = const Value.absent(),
            Value<double?> statsAccuracyYear = const Value.absent(),
            Value<int?> statsAttemptsWeek = const Value.absent(),
            Value<int?> statsAttemptsMonth = const Value.absent(),
            Value<int?> statsAttemptsYear = const Value.absent(),
            Value<int?> statsBestStreakWeek = const Value.absent(),
            Value<int?> statsBestStreakMonth = const Value.absent(),
            Value<int?> statsBestStreakYear = const Value.absent(),
            Value<DateTime?> statsLastPlayedAt = const Value.absent(),
          }) =>
              DeckTableCompanion(
            id: id,
            uid: uid,
            title: title,
            isArchive: isArchive,
            remoteId: remoteId,
            isDirty: isDirty,
            statsAccuracyWeek: statsAccuracyWeek,
            statsAccuracyMonth: statsAccuracyMonth,
            statsAccuracyYear: statsAccuracyYear,
            statsAttemptsWeek: statsAttemptsWeek,
            statsAttemptsMonth: statsAttemptsMonth,
            statsAttemptsYear: statsAttemptsYear,
            statsBestStreakWeek: statsBestStreakWeek,
            statsBestStreakMonth: statsBestStreakMonth,
            statsBestStreakYear: statsBestStreakYear,
            statsLastPlayedAt: statsLastPlayedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> uid = const Value.absent(),
            required String title,
            required bool isArchive,
            Value<String?> remoteId = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<double?> statsAccuracyWeek = const Value.absent(),
            Value<double?> statsAccuracyMonth = const Value.absent(),
            Value<double?> statsAccuracyYear = const Value.absent(),
            Value<int?> statsAttemptsWeek = const Value.absent(),
            Value<int?> statsAttemptsMonth = const Value.absent(),
            Value<int?> statsAttemptsYear = const Value.absent(),
            Value<int?> statsBestStreakWeek = const Value.absent(),
            Value<int?> statsBestStreakMonth = const Value.absent(),
            Value<int?> statsBestStreakYear = const Value.absent(),
            Value<DateTime?> statsLastPlayedAt = const Value.absent(),
          }) =>
              DeckTableCompanion.insert(
            id: id,
            uid: uid,
            title: title,
            isArchive: isArchive,
            remoteId: remoteId,
            isDirty: isDirty,
            statsAccuracyWeek: statsAccuracyWeek,
            statsAccuracyMonth: statsAccuracyMonth,
            statsAccuracyYear: statsAccuracyYear,
            statsAttemptsWeek: statsAttemptsWeek,
            statsAttemptsMonth: statsAttemptsMonth,
            statsAttemptsYear: statsAttemptsYear,
            statsBestStreakWeek: statsBestStreakWeek,
            statsBestStreakMonth: statsBestStreakMonth,
            statsBestStreakYear: statsBestStreakYear,
            statsLastPlayedAt: statsLastPlayedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DeckTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({quizCardTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (quizCardTableRefs) db.quizCardTable
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (quizCardTableRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$DeckTableTableReferences
                            ._quizCardTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DeckTableTableReferences(db, table, p0)
                                .quizCardTableRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.deckId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DeckTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DeckTableTable,
    DeckTableData,
    $$DeckTableTableFilterComposer,
    $$DeckTableTableOrderingComposer,
    $$DeckTableTableAnnotationComposer,
    $$DeckTableTableCreateCompanionBuilder,
    $$DeckTableTableUpdateCompanionBuilder,
    (DeckTableData, $$DeckTableTableReferences),
    DeckTableData,
    PrefetchHooks Function({bool quizCardTableRefs})>;
typedef $$QuizCardTableTableCreateCompanionBuilder = QuizCardTableCompanion
    Function({
  Value<int> id,
  Value<int?> uid,
  required int deckId,
  required String questionText,
  required String answerText,
  required bool isArchive,
  Value<String?> remoteId,
  Value<bool> isDirty,
  Value<double?> statsAccuracyWeek,
  Value<double?> statsAccuracyMonth,
  Value<double?> statsAccuracyYear,
  Value<int?> statsAttemptsWeek,
  Value<int?> statsAttemptsMonth,
  Value<int?> statsAttemptsYear,
  Value<int?> statsBestStreakWeek,
  Value<int?> statsBestStreakMonth,
  Value<int?> statsBestStreakYear,
  Value<DateTime?> statsLastPlayedAt,
});
typedef $$QuizCardTableTableUpdateCompanionBuilder = QuizCardTableCompanion
    Function({
  Value<int> id,
  Value<int?> uid,
  Value<int> deckId,
  Value<String> questionText,
  Value<String> answerText,
  Value<bool> isArchive,
  Value<String?> remoteId,
  Value<bool> isDirty,
  Value<double?> statsAccuracyWeek,
  Value<double?> statsAccuracyMonth,
  Value<double?> statsAccuracyYear,
  Value<int?> statsAttemptsWeek,
  Value<int?> statsAttemptsMonth,
  Value<int?> statsAttemptsYear,
  Value<int?> statsBestStreakWeek,
  Value<int?> statsBestStreakMonth,
  Value<int?> statsBestStreakYear,
  Value<DateTime?> statsLastPlayedAt,
});

final class $$QuizCardTableTableReferences extends BaseReferences<_$AppDatabase,
    $QuizCardTableTable, QuizCardTableData> {
  $$QuizCardTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $DeckTableTable _deckIdTable(_$AppDatabase db) =>
      db.deckTable.createAlias(
          $_aliasNameGenerator(db.quizCardTable.deckId, db.deckTable.id));

  $$DeckTableTableProcessedTableManager? get deckId {
    if ($_item.deckId == null) return null;
    final manager = $$DeckTableTableTableManager($_db, $_db.deckTable)
        .filter((f) => f.id($_item.deckId!));
    final item = $_typedResult.readTableOrNull(_deckIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$QuizCardTableTableFilterComposer
    extends Composer<_$AppDatabase, $QuizCardTableTable> {
  $$QuizCardTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get questionText => $composableBuilder(
      column: $table.questionText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get answerText => $composableBuilder(
      column: $table.answerText, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchive => $composableBuilder(
      column: $table.isArchive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get statsAccuracyWeek => $composableBuilder(
      column: $table.statsAccuracyWeek,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get statsAccuracyMonth => $composableBuilder(
      column: $table.statsAccuracyMonth,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get statsAccuracyYear => $composableBuilder(
      column: $table.statsAccuracyYear,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get statsAttemptsWeek => $composableBuilder(
      column: $table.statsAttemptsWeek,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get statsAttemptsMonth => $composableBuilder(
      column: $table.statsAttemptsMonth,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get statsAttemptsYear => $composableBuilder(
      column: $table.statsAttemptsYear,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get statsBestStreakWeek => $composableBuilder(
      column: $table.statsBestStreakWeek,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get statsBestStreakMonth => $composableBuilder(
      column: $table.statsBestStreakMonth,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get statsBestStreakYear => $composableBuilder(
      column: $table.statsBestStreakYear,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get statsLastPlayedAt => $composableBuilder(
      column: $table.statsLastPlayedAt,
      builder: (column) => ColumnFilters(column));

  $$DeckTableTableFilterComposer get deckId {
    final $$DeckTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deckId,
        referencedTable: $db.deckTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeckTableTableFilterComposer(
              $db: $db,
              $table: $db.deckTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$QuizCardTableTableOrderingComposer
    extends Composer<_$AppDatabase, $QuizCardTableTable> {
  $$QuizCardTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get questionText => $composableBuilder(
      column: $table.questionText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get answerText => $composableBuilder(
      column: $table.answerText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchive => $composableBuilder(
      column: $table.isArchive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDirty => $composableBuilder(
      column: $table.isDirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get statsAccuracyWeek => $composableBuilder(
      column: $table.statsAccuracyWeek,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get statsAccuracyMonth => $composableBuilder(
      column: $table.statsAccuracyMonth,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get statsAccuracyYear => $composableBuilder(
      column: $table.statsAccuracyYear,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get statsAttemptsWeek => $composableBuilder(
      column: $table.statsAttemptsWeek,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get statsAttemptsMonth => $composableBuilder(
      column: $table.statsAttemptsMonth,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get statsAttemptsYear => $composableBuilder(
      column: $table.statsAttemptsYear,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get statsBestStreakWeek => $composableBuilder(
      column: $table.statsBestStreakWeek,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get statsBestStreakMonth => $composableBuilder(
      column: $table.statsBestStreakMonth,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get statsBestStreakYear => $composableBuilder(
      column: $table.statsBestStreakYear,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get statsLastPlayedAt => $composableBuilder(
      column: $table.statsLastPlayedAt,
      builder: (column) => ColumnOrderings(column));

  $$DeckTableTableOrderingComposer get deckId {
    final $$DeckTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deckId,
        referencedTable: $db.deckTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeckTableTableOrderingComposer(
              $db: $db,
              $table: $db.deckTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$QuizCardTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuizCardTableTable> {
  $$QuizCardTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get questionText => $composableBuilder(
      column: $table.questionText, builder: (column) => column);

  GeneratedColumn<String> get answerText => $composableBuilder(
      column: $table.answerText, builder: (column) => column);

  GeneratedColumn<bool> get isArchive =>
      $composableBuilder(column: $table.isArchive, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<double> get statsAccuracyWeek => $composableBuilder(
      column: $table.statsAccuracyWeek, builder: (column) => column);

  GeneratedColumn<double> get statsAccuracyMonth => $composableBuilder(
      column: $table.statsAccuracyMonth, builder: (column) => column);

  GeneratedColumn<double> get statsAccuracyYear => $composableBuilder(
      column: $table.statsAccuracyYear, builder: (column) => column);

  GeneratedColumn<int> get statsAttemptsWeek => $composableBuilder(
      column: $table.statsAttemptsWeek, builder: (column) => column);

  GeneratedColumn<int> get statsAttemptsMonth => $composableBuilder(
      column: $table.statsAttemptsMonth, builder: (column) => column);

  GeneratedColumn<int> get statsAttemptsYear => $composableBuilder(
      column: $table.statsAttemptsYear, builder: (column) => column);

  GeneratedColumn<int> get statsBestStreakWeek => $composableBuilder(
      column: $table.statsBestStreakWeek, builder: (column) => column);

  GeneratedColumn<int> get statsBestStreakMonth => $composableBuilder(
      column: $table.statsBestStreakMonth, builder: (column) => column);

  GeneratedColumn<int> get statsBestStreakYear => $composableBuilder(
      column: $table.statsBestStreakYear, builder: (column) => column);

  GeneratedColumn<DateTime> get statsLastPlayedAt => $composableBuilder(
      column: $table.statsLastPlayedAt, builder: (column) => column);

  $$DeckTableTableAnnotationComposer get deckId {
    final $$DeckTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deckId,
        referencedTable: $db.deckTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeckTableTableAnnotationComposer(
              $db: $db,
              $table: $db.deckTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$QuizCardTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QuizCardTableTable,
    QuizCardTableData,
    $$QuizCardTableTableFilterComposer,
    $$QuizCardTableTableOrderingComposer,
    $$QuizCardTableTableAnnotationComposer,
    $$QuizCardTableTableCreateCompanionBuilder,
    $$QuizCardTableTableUpdateCompanionBuilder,
    (QuizCardTableData, $$QuizCardTableTableReferences),
    QuizCardTableData,
    PrefetchHooks Function({bool deckId})> {
  $$QuizCardTableTableTableManager(_$AppDatabase db, $QuizCardTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuizCardTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuizCardTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuizCardTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> uid = const Value.absent(),
            Value<int> deckId = const Value.absent(),
            Value<String> questionText = const Value.absent(),
            Value<String> answerText = const Value.absent(),
            Value<bool> isArchive = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<double?> statsAccuracyWeek = const Value.absent(),
            Value<double?> statsAccuracyMonth = const Value.absent(),
            Value<double?> statsAccuracyYear = const Value.absent(),
            Value<int?> statsAttemptsWeek = const Value.absent(),
            Value<int?> statsAttemptsMonth = const Value.absent(),
            Value<int?> statsAttemptsYear = const Value.absent(),
            Value<int?> statsBestStreakWeek = const Value.absent(),
            Value<int?> statsBestStreakMonth = const Value.absent(),
            Value<int?> statsBestStreakYear = const Value.absent(),
            Value<DateTime?> statsLastPlayedAt = const Value.absent(),
          }) =>
              QuizCardTableCompanion(
            id: id,
            uid: uid,
            deckId: deckId,
            questionText: questionText,
            answerText: answerText,
            isArchive: isArchive,
            remoteId: remoteId,
            isDirty: isDirty,
            statsAccuracyWeek: statsAccuracyWeek,
            statsAccuracyMonth: statsAccuracyMonth,
            statsAccuracyYear: statsAccuracyYear,
            statsAttemptsWeek: statsAttemptsWeek,
            statsAttemptsMonth: statsAttemptsMonth,
            statsAttemptsYear: statsAttemptsYear,
            statsBestStreakWeek: statsBestStreakWeek,
            statsBestStreakMonth: statsBestStreakMonth,
            statsBestStreakYear: statsBestStreakYear,
            statsLastPlayedAt: statsLastPlayedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> uid = const Value.absent(),
            required int deckId,
            required String questionText,
            required String answerText,
            required bool isArchive,
            Value<String?> remoteId = const Value.absent(),
            Value<bool> isDirty = const Value.absent(),
            Value<double?> statsAccuracyWeek = const Value.absent(),
            Value<double?> statsAccuracyMonth = const Value.absent(),
            Value<double?> statsAccuracyYear = const Value.absent(),
            Value<int?> statsAttemptsWeek = const Value.absent(),
            Value<int?> statsAttemptsMonth = const Value.absent(),
            Value<int?> statsAttemptsYear = const Value.absent(),
            Value<int?> statsBestStreakWeek = const Value.absent(),
            Value<int?> statsBestStreakMonth = const Value.absent(),
            Value<int?> statsBestStreakYear = const Value.absent(),
            Value<DateTime?> statsLastPlayedAt = const Value.absent(),
          }) =>
              QuizCardTableCompanion.insert(
            id: id,
            uid: uid,
            deckId: deckId,
            questionText: questionText,
            answerText: answerText,
            isArchive: isArchive,
            remoteId: remoteId,
            isDirty: isDirty,
            statsAccuracyWeek: statsAccuracyWeek,
            statsAccuracyMonth: statsAccuracyMonth,
            statsAccuracyYear: statsAccuracyYear,
            statsAttemptsWeek: statsAttemptsWeek,
            statsAttemptsMonth: statsAttemptsMonth,
            statsAttemptsYear: statsAttemptsYear,
            statsBestStreakWeek: statsBestStreakWeek,
            statsBestStreakMonth: statsBestStreakMonth,
            statsBestStreakYear: statsBestStreakYear,
            statsLastPlayedAt: statsLastPlayedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$QuizCardTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({deckId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (deckId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.deckId,
                    referencedTable:
                        $$QuizCardTableTableReferences._deckIdTable(db),
                    referencedColumn:
                        $$QuizCardTableTableReferences._deckIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$QuizCardTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QuizCardTableTable,
    QuizCardTableData,
    $$QuizCardTableTableFilterComposer,
    $$QuizCardTableTableOrderingComposer,
    $$QuizCardTableTableAnnotationComposer,
    $$QuizCardTableTableCreateCompanionBuilder,
    $$QuizCardTableTableUpdateCompanionBuilder,
    (QuizCardTableData, $$QuizCardTableTableReferences),
    QuizCardTableData,
    PrefetchHooks Function({bool deckId})>;
typedef $$UserTableTableCreateCompanionBuilder = UserTableCompanion Function({
  Value<int> id,
});
typedef $$UserTableTableUpdateCompanionBuilder = UserTableCompanion Function({
  Value<int> id,
});

final class $$UserTableTableReferences
    extends BaseReferences<_$AppDatabase, $UserTableTable, UserTableData> {
  $$UserTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserSettingsTableTable,
      List<UserSettingsTableData>> _userSettingsTableRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.userSettingsTable,
          aliasName: $_aliasNameGenerator(
              db.userTable.id, db.userSettingsTable.userId));

  $$UserSettingsTableTableProcessedTableManager get userSettingsTableRefs {
    final manager =
        $$UserSettingsTableTableTableManager($_db, $_db.userSettingsTable)
            .filter((f) => f.userId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_userSettingsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$UserTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserTableTable> {
  $$UserTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  Expression<bool> userSettingsTableRefs(
      Expression<bool> Function($$UserSettingsTableTableFilterComposer f) f) {
    final $$UserSettingsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userSettingsTable,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserSettingsTableTableFilterComposer(
              $db: $db,
              $table: $db.userSettingsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UserTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserTableTable> {
  $$UserTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));
}

class $$UserTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserTableTable> {
  $$UserTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  Expression<T> userSettingsTableRefs<T extends Object>(
      Expression<T> Function($$UserSettingsTableTableAnnotationComposer a) f) {
    final $$UserSettingsTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.userSettingsTable,
            getReferencedColumn: (t) => t.userId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$UserSettingsTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.userSettingsTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$UserTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserTableTable,
    UserTableData,
    $$UserTableTableFilterComposer,
    $$UserTableTableOrderingComposer,
    $$UserTableTableAnnotationComposer,
    $$UserTableTableCreateCompanionBuilder,
    $$UserTableTableUpdateCompanionBuilder,
    (UserTableData, $$UserTableTableReferences),
    UserTableData,
    PrefetchHooks Function({bool userSettingsTableRefs})> {
  $$UserTableTableTableManager(_$AppDatabase db, $UserTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
          }) =>
              UserTableCompanion(
            id: id,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
          }) =>
              UserTableCompanion.insert(
            id: id,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$UserTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userSettingsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (userSettingsTableRefs) db.userSettingsTable
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userSettingsTableRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$UserTableTableReferences
                            ._userSettingsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UserTableTableReferences(db, table, p0)
                                .userSettingsTableRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$UserTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserTableTable,
    UserTableData,
    $$UserTableTableFilterComposer,
    $$UserTableTableOrderingComposer,
    $$UserTableTableAnnotationComposer,
    $$UserTableTableCreateCompanionBuilder,
    $$UserTableTableUpdateCompanionBuilder,
    (UserTableData, $$UserTableTableReferences),
    UserTableData,
    PrefetchHooks Function({bool userSettingsTableRefs})>;
typedef $$UserSettingsTableTableCreateCompanionBuilder
    = UserSettingsTableCompanion Function({
  Value<int> id,
  required int userId,
  Value<String> answerValidatorType,
  Value<String> deckGenerationAiType,
  Value<String?> geminiApiKey,
  Value<String?> geminiModelName,
  Value<String?> claudeApiKey,
  Value<String?> claudeModelName,
  Value<String?> openAiApiKey,
  Value<String?> openAiModelName,
  Value<String?> ollamaModelUrl,
  Value<String?> ollamaModelName,
  Value<bool> onboardingCompleted,
});
typedef $$UserSettingsTableTableUpdateCompanionBuilder
    = UserSettingsTableCompanion Function({
  Value<int> id,
  Value<int> userId,
  Value<String> answerValidatorType,
  Value<String> deckGenerationAiType,
  Value<String?> geminiApiKey,
  Value<String?> geminiModelName,
  Value<String?> claudeApiKey,
  Value<String?> claudeModelName,
  Value<String?> openAiApiKey,
  Value<String?> openAiModelName,
  Value<String?> ollamaModelUrl,
  Value<String?> ollamaModelName,
  Value<bool> onboardingCompleted,
});

final class $$UserSettingsTableTableReferences extends BaseReferences<
    _$AppDatabase, $UserSettingsTableTable, UserSettingsTableData> {
  $$UserSettingsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $UserTableTable _userIdTable(_$AppDatabase db) =>
      db.userTable.createAlias(
          $_aliasNameGenerator(db.userSettingsTable.userId, db.userTable.id));

  $$UserTableTableProcessedTableManager? get userId {
    if ($_item.userId == null) return null;
    final manager = $$UserTableTableTableManager($_db, $_db.userTable)
        .filter((f) => f.id($_item.userId!));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$UserSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTableTable> {
  $$UserSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get answerValidatorType => $composableBuilder(
      column: $table.answerValidatorType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deckGenerationAiType => $composableBuilder(
      column: $table.deckGenerationAiType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get geminiApiKey => $composableBuilder(
      column: $table.geminiApiKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get geminiModelName => $composableBuilder(
      column: $table.geminiModelName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get claudeApiKey => $composableBuilder(
      column: $table.claudeApiKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get claudeModelName => $composableBuilder(
      column: $table.claudeModelName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get openAiApiKey => $composableBuilder(
      column: $table.openAiApiKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get openAiModelName => $composableBuilder(
      column: $table.openAiModelName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ollamaModelUrl => $composableBuilder(
      column: $table.ollamaModelUrl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ollamaModelName => $composableBuilder(
      column: $table.ollamaModelName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get onboardingCompleted => $composableBuilder(
      column: $table.onboardingCompleted,
      builder: (column) => ColumnFilters(column));

  $$UserTableTableFilterComposer get userId {
    final $$UserTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.userTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserTableTableFilterComposer(
              $db: $db,
              $table: $db.userTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTableTable> {
  $$UserSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get answerValidatorType => $composableBuilder(
      column: $table.answerValidatorType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deckGenerationAiType => $composableBuilder(
      column: $table.deckGenerationAiType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get geminiApiKey => $composableBuilder(
      column: $table.geminiApiKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get geminiModelName => $composableBuilder(
      column: $table.geminiModelName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get claudeApiKey => $composableBuilder(
      column: $table.claudeApiKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get claudeModelName => $composableBuilder(
      column: $table.claudeModelName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get openAiApiKey => $composableBuilder(
      column: $table.openAiApiKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get openAiModelName => $composableBuilder(
      column: $table.openAiModelName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ollamaModelUrl => $composableBuilder(
      column: $table.ollamaModelUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ollamaModelName => $composableBuilder(
      column: $table.ollamaModelName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get onboardingCompleted => $composableBuilder(
      column: $table.onboardingCompleted,
      builder: (column) => ColumnOrderings(column));

  $$UserTableTableOrderingComposer get userId {
    final $$UserTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.userTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserTableTableOrderingComposer(
              $db: $db,
              $table: $db.userTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTableTable> {
  $$UserSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get answerValidatorType => $composableBuilder(
      column: $table.answerValidatorType, builder: (column) => column);

  GeneratedColumn<String> get deckGenerationAiType => $composableBuilder(
      column: $table.deckGenerationAiType, builder: (column) => column);

  GeneratedColumn<String> get geminiApiKey => $composableBuilder(
      column: $table.geminiApiKey, builder: (column) => column);

  GeneratedColumn<String> get geminiModelName => $composableBuilder(
      column: $table.geminiModelName, builder: (column) => column);

  GeneratedColumn<String> get claudeApiKey => $composableBuilder(
      column: $table.claudeApiKey, builder: (column) => column);

  GeneratedColumn<String> get claudeModelName => $composableBuilder(
      column: $table.claudeModelName, builder: (column) => column);

  GeneratedColumn<String> get openAiApiKey => $composableBuilder(
      column: $table.openAiApiKey, builder: (column) => column);

  GeneratedColumn<String> get openAiModelName => $composableBuilder(
      column: $table.openAiModelName, builder: (column) => column);

  GeneratedColumn<String> get ollamaModelUrl => $composableBuilder(
      column: $table.ollamaModelUrl, builder: (column) => column);

  GeneratedColumn<String> get ollamaModelName => $composableBuilder(
      column: $table.ollamaModelName, builder: (column) => column);

  GeneratedColumn<bool> get onboardingCompleted => $composableBuilder(
      column: $table.onboardingCompleted, builder: (column) => column);

  $$UserTableTableAnnotationComposer get userId {
    final $$UserTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.userTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserTableTableAnnotationComposer(
              $db: $db,
              $table: $db.userTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserSettingsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserSettingsTableTable,
    UserSettingsTableData,
    $$UserSettingsTableTableFilterComposer,
    $$UserSettingsTableTableOrderingComposer,
    $$UserSettingsTableTableAnnotationComposer,
    $$UserSettingsTableTableCreateCompanionBuilder,
    $$UserSettingsTableTableUpdateCompanionBuilder,
    (UserSettingsTableData, $$UserSettingsTableTableReferences),
    UserSettingsTableData,
    PrefetchHooks Function({bool userId})> {
  $$UserSettingsTableTableTableManager(
      _$AppDatabase db, $UserSettingsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<String> answerValidatorType = const Value.absent(),
            Value<String> deckGenerationAiType = const Value.absent(),
            Value<String?> geminiApiKey = const Value.absent(),
            Value<String?> geminiModelName = const Value.absent(),
            Value<String?> claudeApiKey = const Value.absent(),
            Value<String?> claudeModelName = const Value.absent(),
            Value<String?> openAiApiKey = const Value.absent(),
            Value<String?> openAiModelName = const Value.absent(),
            Value<String?> ollamaModelUrl = const Value.absent(),
            Value<String?> ollamaModelName = const Value.absent(),
            Value<bool> onboardingCompleted = const Value.absent(),
          }) =>
              UserSettingsTableCompanion(
            id: id,
            userId: userId,
            answerValidatorType: answerValidatorType,
            deckGenerationAiType: deckGenerationAiType,
            geminiApiKey: geminiApiKey,
            geminiModelName: geminiModelName,
            claudeApiKey: claudeApiKey,
            claudeModelName: claudeModelName,
            openAiApiKey: openAiApiKey,
            openAiModelName: openAiModelName,
            ollamaModelUrl: ollamaModelUrl,
            ollamaModelName: ollamaModelName,
            onboardingCompleted: onboardingCompleted,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int userId,
            Value<String> answerValidatorType = const Value.absent(),
            Value<String> deckGenerationAiType = const Value.absent(),
            Value<String?> geminiApiKey = const Value.absent(),
            Value<String?> geminiModelName = const Value.absent(),
            Value<String?> claudeApiKey = const Value.absent(),
            Value<String?> claudeModelName = const Value.absent(),
            Value<String?> openAiApiKey = const Value.absent(),
            Value<String?> openAiModelName = const Value.absent(),
            Value<String?> ollamaModelUrl = const Value.absent(),
            Value<String?> ollamaModelName = const Value.absent(),
            Value<bool> onboardingCompleted = const Value.absent(),
          }) =>
              UserSettingsTableCompanion.insert(
            id: id,
            userId: userId,
            answerValidatorType: answerValidatorType,
            deckGenerationAiType: deckGenerationAiType,
            geminiApiKey: geminiApiKey,
            geminiModelName: geminiModelName,
            claudeApiKey: claudeApiKey,
            claudeModelName: claudeModelName,
            openAiApiKey: openAiApiKey,
            openAiModelName: openAiModelName,
            ollamaModelUrl: ollamaModelUrl,
            ollamaModelName: ollamaModelName,
            onboardingCompleted: onboardingCompleted,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$UserSettingsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$UserSettingsTableTableReferences._userIdTable(db),
                    referencedColumn:
                        $$UserSettingsTableTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$UserSettingsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserSettingsTableTable,
    UserSettingsTableData,
    $$UserSettingsTableTableFilterComposer,
    $$UserSettingsTableTableOrderingComposer,
    $$UserSettingsTableTableAnnotationComposer,
    $$UserSettingsTableTableCreateCompanionBuilder,
    $$UserSettingsTableTableUpdateCompanionBuilder,
    (UserSettingsTableData, $$UserSettingsTableTableReferences),
    UserSettingsTableData,
    PrefetchHooks Function({bool userId})>;
typedef $$SyncTombstoneTableTableCreateCompanionBuilder
    = SyncTombstoneTableCompanion Function({
  Value<int> id,
  required String entityType,
  required String remoteId,
  Value<DateTime> createdAt,
});
typedef $$SyncTombstoneTableTableUpdateCompanionBuilder
    = SyncTombstoneTableCompanion Function({
  Value<int> id,
  Value<String> entityType,
  Value<String> remoteId,
  Value<DateTime> createdAt,
});

class $$SyncTombstoneTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncTombstoneTableTable> {
  $$SyncTombstoneTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SyncTombstoneTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncTombstoneTableTable> {
  $$SyncTombstoneTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncTombstoneTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncTombstoneTableTable> {
  $$SyncTombstoneTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncTombstoneTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncTombstoneTableTable,
    SyncTombstoneTableData,
    $$SyncTombstoneTableTableFilterComposer,
    $$SyncTombstoneTableTableOrderingComposer,
    $$SyncTombstoneTableTableAnnotationComposer,
    $$SyncTombstoneTableTableCreateCompanionBuilder,
    $$SyncTombstoneTableTableUpdateCompanionBuilder,
    (
      SyncTombstoneTableData,
      BaseReferences<_$AppDatabase, $SyncTombstoneTableTable,
          SyncTombstoneTableData>
    ),
    SyncTombstoneTableData,
    PrefetchHooks Function()> {
  $$SyncTombstoneTableTableTableManager(
      _$AppDatabase db, $SyncTombstoneTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncTombstoneTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncTombstoneTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncTombstoneTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> remoteId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SyncTombstoneTableCompanion(
            id: id,
            entityType: entityType,
            remoteId: remoteId,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String entityType,
            required String remoteId,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              SyncTombstoneTableCompanion.insert(
            id: id,
            entityType: entityType,
            remoteId: remoteId,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncTombstoneTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncTombstoneTableTable,
    SyncTombstoneTableData,
    $$SyncTombstoneTableTableFilterComposer,
    $$SyncTombstoneTableTableOrderingComposer,
    $$SyncTombstoneTableTableAnnotationComposer,
    $$SyncTombstoneTableTableCreateCompanionBuilder,
    $$SyncTombstoneTableTableUpdateCompanionBuilder,
    (
      SyncTombstoneTableData,
      BaseReferences<_$AppDatabase, $SyncTombstoneTableTable,
          SyncTombstoneTableData>
    ),
    SyncTombstoneTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DeckTableTableTableManager get deckTable =>
      $$DeckTableTableTableManager(_db, _db.deckTable);
  $$QuizCardTableTableTableManager get quizCardTable =>
      $$QuizCardTableTableTableManager(_db, _db.quizCardTable);
  $$UserTableTableTableManager get userTable =>
      $$UserTableTableTableManager(_db, _db.userTable);
  $$UserSettingsTableTableTableManager get userSettingsTable =>
      $$UserSettingsTableTableTableManager(_db, _db.userSettingsTable);
  $$SyncTombstoneTableTableTableManager get syncTombstoneTable =>
      $$SyncTombstoneTableTableTableManager(_db, _db.syncTombstoneTable);
}
