// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedApiResponsesTable extends CachedApiResponses
    with TableInfo<$CachedApiResponsesTable, CachedApiResponse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedApiResponsesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta(
    'cacheKey',
  );
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _responseJsonMeta = const VerificationMeta(
    'responseJson',
  );
  @override
  late final GeneratedColumn<String> responseJson = GeneratedColumn<String>(
    'response_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    cacheKey,
    accountId,
    responseJson,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_api_responses';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedApiResponse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cache_key')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('response_json')) {
      context.handle(
        _responseJsonMeta,
        responseJson.isAcceptableOrUnknown(
          data['response_json']!,
          _responseJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_responseJsonMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cacheKey, accountId};
  @override
  CachedApiResponse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedApiResponse(
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_key'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      responseJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}response_json'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $CachedApiResponsesTable createAlias(String alias) {
    return $CachedApiResponsesTable(attachedDatabase, alias);
  }
}

class CachedApiResponse extends DataClass
    implements Insertable<CachedApiResponse> {
  final String cacheKey;
  final String accountId;
  final String responseJson;
  final DateTime updatedAtUtc;
  const CachedApiResponse({
    required this.cacheKey,
    required this.accountId,
    required this.responseJson,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cache_key'] = Variable<String>(cacheKey);
    map['account_id'] = Variable<String>(accountId);
    map['response_json'] = Variable<String>(responseJson);
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    return map;
  }

  CachedApiResponsesCompanion toCompanion(bool nullToAbsent) {
    return CachedApiResponsesCompanion(
      cacheKey: Value(cacheKey),
      accountId: Value(accountId),
      responseJson: Value(responseJson),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory CachedApiResponse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedApiResponse(
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      accountId: serializer.fromJson<String>(json['accountId']),
      responseJson: serializer.fromJson<String>(json['responseJson']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cacheKey': serializer.toJson<String>(cacheKey),
      'accountId': serializer.toJson<String>(accountId),
      'responseJson': serializer.toJson<String>(responseJson),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
    };
  }

  CachedApiResponse copyWith({
    String? cacheKey,
    String? accountId,
    String? responseJson,
    DateTime? updatedAtUtc,
  }) => CachedApiResponse(
    cacheKey: cacheKey ?? this.cacheKey,
    accountId: accountId ?? this.accountId,
    responseJson: responseJson ?? this.responseJson,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  CachedApiResponse copyWithCompanion(CachedApiResponsesCompanion data) {
    return CachedApiResponse(
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      responseJson: data.responseJson.present
          ? data.responseJson.value
          : this.responseJson,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedApiResponse(')
          ..write('cacheKey: $cacheKey, ')
          ..write('accountId: $accountId, ')
          ..write('responseJson: $responseJson, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(cacheKey, accountId, responseJson, updatedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedApiResponse &&
          other.cacheKey == this.cacheKey &&
          other.accountId == this.accountId &&
          other.responseJson == this.responseJson &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class CachedApiResponsesCompanion extends UpdateCompanion<CachedApiResponse> {
  final Value<String> cacheKey;
  final Value<String> accountId;
  final Value<String> responseJson;
  final Value<DateTime> updatedAtUtc;
  final Value<int> rowid;
  const CachedApiResponsesCompanion({
    this.cacheKey = const Value.absent(),
    this.accountId = const Value.absent(),
    this.responseJson = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedApiResponsesCompanion.insert({
    required String cacheKey,
    required String accountId,
    required String responseJson,
    required DateTime updatedAtUtc,
    this.rowid = const Value.absent(),
  }) : cacheKey = Value(cacheKey),
       accountId = Value(accountId),
       responseJson = Value(responseJson),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<CachedApiResponse> custom({
    Expression<String>? cacheKey,
    Expression<String>? accountId,
    Expression<String>? responseJson,
    Expression<DateTime>? updatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cacheKey != null) 'cache_key': cacheKey,
      if (accountId != null) 'account_id': accountId,
      if (responseJson != null) 'response_json': responseJson,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedApiResponsesCompanion copyWith({
    Value<String>? cacheKey,
    Value<String>? accountId,
    Value<String>? responseJson,
    Value<DateTime>? updatedAtUtc,
    Value<int>? rowid,
  }) {
    return CachedApiResponsesCompanion(
      cacheKey: cacheKey ?? this.cacheKey,
      accountId: accountId ?? this.accountId,
      responseJson: responseJson ?? this.responseJson,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (responseJson.present) {
      map['response_json'] = Variable<String>(responseJson.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedApiResponsesCompanion(')
          ..write('cacheKey: $cacheKey, ')
          ..write('accountId: $accountId, ')
          ..write('responseJson: $responseJson, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingPaymentIntentsTable extends PendingPaymentIntents
    with TableInfo<$PendingPaymentIntentsTable, PendingPaymentIntent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingPaymentIntentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _intentIdMeta = const VerificationMeta(
    'intentId',
  );
  @override
  late final GeneratedColumn<String> intentId = GeneratedColumn<String>(
    'intent_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stokvelIdMeta = const VerificationMeta(
    'stokvelId',
  );
  @override
  late final GeneratedColumn<String> stokvelId = GeneratedColumn<String>(
    'stokvel_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cycleIdMeta = const VerificationMeta(
    'cycleId',
  );
  @override
  late final GeneratedColumn<String> cycleId = GeneratedColumn<String>(
    'cycle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountInCentsMeta = const VerificationMeta(
    'amountInCents',
  );
  @override
  late final GeneratedColumn<int> amountInCents = GeneratedColumn<int>(
    'amount_in_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    intentId,
    accountId,
    stokvelId,
    cycleId,
    memberId,
    amountInCents,
    idempotencyKey,
    status,
    createdAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_payment_intents';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingPaymentIntent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('intent_id')) {
      context.handle(
        _intentIdMeta,
        intentId.isAcceptableOrUnknown(data['intent_id']!, _intentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_intentIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('stokvel_id')) {
      context.handle(
        _stokvelIdMeta,
        stokvelId.isAcceptableOrUnknown(data['stokvel_id']!, _stokvelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stokvelIdMeta);
    }
    if (data.containsKey('cycle_id')) {
      context.handle(
        _cycleIdMeta,
        cycleId.isAcceptableOrUnknown(data['cycle_id']!, _cycleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cycleIdMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('amount_in_cents')) {
      context.handle(
        _amountInCentsMeta,
        amountInCents.isAcceptableOrUnknown(
          data['amount_in_cents']!,
          _amountInCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountInCentsMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {intentId};
  @override
  PendingPaymentIntent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingPaymentIntent(
      intentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}intent_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      stokvelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stokvel_id'],
      )!,
      cycleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cycle_id'],
      )!,
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      )!,
      amountInCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_in_cents'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
    );
  }

  @override
  $PendingPaymentIntentsTable createAlias(String alias) {
    return $PendingPaymentIntentsTable(attachedDatabase, alias);
  }
}

class PendingPaymentIntent extends DataClass
    implements Insertable<PendingPaymentIntent> {
  final String intentId;
  final String accountId;
  final String stokvelId;
  final String cycleId;
  final String memberId;
  final int amountInCents;
  final String idempotencyKey;
  final String status;
  final DateTime createdAtUtc;
  const PendingPaymentIntent({
    required this.intentId,
    required this.accountId,
    required this.stokvelId,
    required this.cycleId,
    required this.memberId,
    required this.amountInCents,
    required this.idempotencyKey,
    required this.status,
    required this.createdAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['intent_id'] = Variable<String>(intentId);
    map['account_id'] = Variable<String>(accountId);
    map['stokvel_id'] = Variable<String>(stokvelId);
    map['cycle_id'] = Variable<String>(cycleId);
    map['member_id'] = Variable<String>(memberId);
    map['amount_in_cents'] = Variable<int>(amountInCents);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['status'] = Variable<String>(status);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    return map;
  }

  PendingPaymentIntentsCompanion toCompanion(bool nullToAbsent) {
    return PendingPaymentIntentsCompanion(
      intentId: Value(intentId),
      accountId: Value(accountId),
      stokvelId: Value(stokvelId),
      cycleId: Value(cycleId),
      memberId: Value(memberId),
      amountInCents: Value(amountInCents),
      idempotencyKey: Value(idempotencyKey),
      status: Value(status),
      createdAtUtc: Value(createdAtUtc),
    );
  }

  factory PendingPaymentIntent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingPaymentIntent(
      intentId: serializer.fromJson<String>(json['intentId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      stokvelId: serializer.fromJson<String>(json['stokvelId']),
      cycleId: serializer.fromJson<String>(json['cycleId']),
      memberId: serializer.fromJson<String>(json['memberId']),
      amountInCents: serializer.fromJson<int>(json['amountInCents']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      status: serializer.fromJson<String>(json['status']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'intentId': serializer.toJson<String>(intentId),
      'accountId': serializer.toJson<String>(accountId),
      'stokvelId': serializer.toJson<String>(stokvelId),
      'cycleId': serializer.toJson<String>(cycleId),
      'memberId': serializer.toJson<String>(memberId),
      'amountInCents': serializer.toJson<int>(amountInCents),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'status': serializer.toJson<String>(status),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
    };
  }

  PendingPaymentIntent copyWith({
    String? intentId,
    String? accountId,
    String? stokvelId,
    String? cycleId,
    String? memberId,
    int? amountInCents,
    String? idempotencyKey,
    String? status,
    DateTime? createdAtUtc,
  }) => PendingPaymentIntent(
    intentId: intentId ?? this.intentId,
    accountId: accountId ?? this.accountId,
    stokvelId: stokvelId ?? this.stokvelId,
    cycleId: cycleId ?? this.cycleId,
    memberId: memberId ?? this.memberId,
    amountInCents: amountInCents ?? this.amountInCents,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    status: status ?? this.status,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
  );
  PendingPaymentIntent copyWithCompanion(PendingPaymentIntentsCompanion data) {
    return PendingPaymentIntent(
      intentId: data.intentId.present ? data.intentId.value : this.intentId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      stokvelId: data.stokvelId.present ? data.stokvelId.value : this.stokvelId,
      cycleId: data.cycleId.present ? data.cycleId.value : this.cycleId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      amountInCents: data.amountInCents.present
          ? data.amountInCents.value
          : this.amountInCents,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      status: data.status.present ? data.status.value : this.status,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingPaymentIntent(')
          ..write('intentId: $intentId, ')
          ..write('accountId: $accountId, ')
          ..write('stokvelId: $stokvelId, ')
          ..write('cycleId: $cycleId, ')
          ..write('memberId: $memberId, ')
          ..write('amountInCents: $amountInCents, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('status: $status, ')
          ..write('createdAtUtc: $createdAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    intentId,
    accountId,
    stokvelId,
    cycleId,
    memberId,
    amountInCents,
    idempotencyKey,
    status,
    createdAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingPaymentIntent &&
          other.intentId == this.intentId &&
          other.accountId == this.accountId &&
          other.stokvelId == this.stokvelId &&
          other.cycleId == this.cycleId &&
          other.memberId == this.memberId &&
          other.amountInCents == this.amountInCents &&
          other.idempotencyKey == this.idempotencyKey &&
          other.status == this.status &&
          other.createdAtUtc == this.createdAtUtc);
}

class PendingPaymentIntentsCompanion
    extends UpdateCompanion<PendingPaymentIntent> {
  final Value<String> intentId;
  final Value<String> accountId;
  final Value<String> stokvelId;
  final Value<String> cycleId;
  final Value<String> memberId;
  final Value<int> amountInCents;
  final Value<String> idempotencyKey;
  final Value<String> status;
  final Value<DateTime> createdAtUtc;
  final Value<int> rowid;
  const PendingPaymentIntentsCompanion({
    this.intentId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.stokvelId = const Value.absent(),
    this.cycleId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.amountInCents = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingPaymentIntentsCompanion.insert({
    required String intentId,
    required String accountId,
    required String stokvelId,
    required String cycleId,
    required String memberId,
    required int amountInCents,
    required String idempotencyKey,
    this.status = const Value.absent(),
    required DateTime createdAtUtc,
    this.rowid = const Value.absent(),
  }) : intentId = Value(intentId),
       accountId = Value(accountId),
       stokvelId = Value(stokvelId),
       cycleId = Value(cycleId),
       memberId = Value(memberId),
       amountInCents = Value(amountInCents),
       idempotencyKey = Value(idempotencyKey),
       createdAtUtc = Value(createdAtUtc);
  static Insertable<PendingPaymentIntent> custom({
    Expression<String>? intentId,
    Expression<String>? accountId,
    Expression<String>? stokvelId,
    Expression<String>? cycleId,
    Expression<String>? memberId,
    Expression<int>? amountInCents,
    Expression<String>? idempotencyKey,
    Expression<String>? status,
    Expression<DateTime>? createdAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (intentId != null) 'intent_id': intentId,
      if (accountId != null) 'account_id': accountId,
      if (stokvelId != null) 'stokvel_id': stokvelId,
      if (cycleId != null) 'cycle_id': cycleId,
      if (memberId != null) 'member_id': memberId,
      if (amountInCents != null) 'amount_in_cents': amountInCents,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (status != null) 'status': status,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingPaymentIntentsCompanion copyWith({
    Value<String>? intentId,
    Value<String>? accountId,
    Value<String>? stokvelId,
    Value<String>? cycleId,
    Value<String>? memberId,
    Value<int>? amountInCents,
    Value<String>? idempotencyKey,
    Value<String>? status,
    Value<DateTime>? createdAtUtc,
    Value<int>? rowid,
  }) {
    return PendingPaymentIntentsCompanion(
      intentId: intentId ?? this.intentId,
      accountId: accountId ?? this.accountId,
      stokvelId: stokvelId ?? this.stokvelId,
      cycleId: cycleId ?? this.cycleId,
      memberId: memberId ?? this.memberId,
      amountInCents: amountInCents ?? this.amountInCents,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      status: status ?? this.status,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (intentId.present) {
      map['intent_id'] = Variable<String>(intentId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (stokvelId.present) {
      map['stokvel_id'] = Variable<String>(stokvelId.value);
    }
    if (cycleId.present) {
      map['cycle_id'] = Variable<String>(cycleId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (amountInCents.present) {
      map['amount_in_cents'] = Variable<int>(amountInCents.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingPaymentIntentsCompanion(')
          ..write('intentId: $intentId, ')
          ..write('accountId: $accountId, ')
          ..write('stokvelId: $stokvelId, ')
          ..write('cycleId: $cycleId, ')
          ..write('memberId: $memberId, ')
          ..write('amountInCents: $amountInCents, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('status: $status, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedApiResponsesTable cachedApiResponses =
      $CachedApiResponsesTable(this);
  late final $PendingPaymentIntentsTable pendingPaymentIntents =
      $PendingPaymentIntentsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedApiResponses,
    pendingPaymentIntents,
  ];
}

typedef $$CachedApiResponsesTableCreateCompanionBuilder =
    CachedApiResponsesCompanion Function({
      required String cacheKey,
      required String accountId,
      required String responseJson,
      required DateTime updatedAtUtc,
      Value<int> rowid,
    });
typedef $$CachedApiResponsesTableUpdateCompanionBuilder =
    CachedApiResponsesCompanion Function({
      Value<String> cacheKey,
      Value<String> accountId,
      Value<String> responseJson,
      Value<DateTime> updatedAtUtc,
      Value<int> rowid,
    });

class $$CachedApiResponsesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedApiResponsesTable> {
  $$CachedApiResponsesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responseJson => $composableBuilder(
    column: $table.responseJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedApiResponsesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedApiResponsesTable> {
  $$CachedApiResponsesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responseJson => $composableBuilder(
    column: $table.responseJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedApiResponsesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedApiResponsesTable> {
  $$CachedApiResponsesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get responseJson => $composableBuilder(
    column: $table.responseJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );
}

class $$CachedApiResponsesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedApiResponsesTable,
          CachedApiResponse,
          $$CachedApiResponsesTableFilterComposer,
          $$CachedApiResponsesTableOrderingComposer,
          $$CachedApiResponsesTableAnnotationComposer,
          $$CachedApiResponsesTableCreateCompanionBuilder,
          $$CachedApiResponsesTableUpdateCompanionBuilder,
          (
            CachedApiResponse,
            BaseReferences<
              _$AppDatabase,
              $CachedApiResponsesTable,
              CachedApiResponse
            >,
          ),
          CachedApiResponse,
          PrefetchHooks Function()
        > {
  $$CachedApiResponsesTableTableManager(
    _$AppDatabase db,
    $CachedApiResponsesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedApiResponsesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedApiResponsesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedApiResponsesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> cacheKey = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> responseJson = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedApiResponsesCompanion(
                cacheKey: cacheKey,
                accountId: accountId,
                responseJson: responseJson,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cacheKey,
                required String accountId,
                required String responseJson,
                required DateTime updatedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => CachedApiResponsesCompanion.insert(
                cacheKey: cacheKey,
                accountId: accountId,
                responseJson: responseJson,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CachedApiResponsesTable, CachedApiResponse>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $CachedApiResponsesTable,
                    CachedApiResponse
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedApiResponsesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedApiResponsesTable,
      CachedApiResponse,
      $$CachedApiResponsesTableFilterComposer,
      $$CachedApiResponsesTableOrderingComposer,
      $$CachedApiResponsesTableAnnotationComposer,
      $$CachedApiResponsesTableCreateCompanionBuilder,
      $$CachedApiResponsesTableUpdateCompanionBuilder,
      (
        CachedApiResponse,
        BaseReferences<
          _$AppDatabase,
          $CachedApiResponsesTable,
          CachedApiResponse
        >,
      ),
      CachedApiResponse,
      PrefetchHooks Function()
    >;
typedef $$PendingPaymentIntentsTableCreateCompanionBuilder =
    PendingPaymentIntentsCompanion Function({
      required String intentId,
      required String accountId,
      required String stokvelId,
      required String cycleId,
      required String memberId,
      required int amountInCents,
      required String idempotencyKey,
      Value<String> status,
      required DateTime createdAtUtc,
      Value<int> rowid,
    });
typedef $$PendingPaymentIntentsTableUpdateCompanionBuilder =
    PendingPaymentIntentsCompanion Function({
      Value<String> intentId,
      Value<String> accountId,
      Value<String> stokvelId,
      Value<String> cycleId,
      Value<String> memberId,
      Value<int> amountInCents,
      Value<String> idempotencyKey,
      Value<String> status,
      Value<DateTime> createdAtUtc,
      Value<int> rowid,
    });

class $$PendingPaymentIntentsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingPaymentIntentsTable> {
  $$PendingPaymentIntentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get intentId => $composableBuilder(
    column: $table.intentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stokvelId => $composableBuilder(
    column: $table.stokvelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cycleId => $composableBuilder(
    column: $table.cycleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountInCents => $composableBuilder(
    column: $table.amountInCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingPaymentIntentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingPaymentIntentsTable> {
  $$PendingPaymentIntentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get intentId => $composableBuilder(
    column: $table.intentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stokvelId => $composableBuilder(
    column: $table.stokvelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cycleId => $composableBuilder(
    column: $table.cycleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountInCents => $composableBuilder(
    column: $table.amountInCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingPaymentIntentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingPaymentIntentsTable> {
  $$PendingPaymentIntentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get intentId =>
      $composableBuilder(column: $table.intentId, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get stokvelId =>
      $composableBuilder(column: $table.stokvelId, builder: (column) => column);

  GeneratedColumn<String> get cycleId =>
      $composableBuilder(column: $table.cycleId, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<int> get amountInCents => $composableBuilder(
    column: $table.amountInCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );
}

class $$PendingPaymentIntentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingPaymentIntentsTable,
          PendingPaymentIntent,
          $$PendingPaymentIntentsTableFilterComposer,
          $$PendingPaymentIntentsTableOrderingComposer,
          $$PendingPaymentIntentsTableAnnotationComposer,
          $$PendingPaymentIntentsTableCreateCompanionBuilder,
          $$PendingPaymentIntentsTableUpdateCompanionBuilder,
          (
            PendingPaymentIntent,
            BaseReferences<
              _$AppDatabase,
              $PendingPaymentIntentsTable,
              PendingPaymentIntent
            >,
          ),
          PendingPaymentIntent,
          PrefetchHooks Function()
        > {
  $$PendingPaymentIntentsTableTableManager(
    _$AppDatabase db,
    $PendingPaymentIntentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingPaymentIntentsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PendingPaymentIntentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PendingPaymentIntentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> intentId = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> stokvelId = const Value.absent(),
                Value<String> cycleId = const Value.absent(),
                Value<String> memberId = const Value.absent(),
                Value<int> amountInCents = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingPaymentIntentsCompanion(
                intentId: intentId,
                accountId: accountId,
                stokvelId: stokvelId,
                cycleId: cycleId,
                memberId: memberId,
                amountInCents: amountInCents,
                idempotencyKey: idempotencyKey,
                status: status,
                createdAtUtc: createdAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String intentId,
                required String accountId,
                required String stokvelId,
                required String cycleId,
                required String memberId,
                required int amountInCents,
                required String idempotencyKey,
                Value<String> status = const Value.absent(),
                required DateTime createdAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => PendingPaymentIntentsCompanion.insert(
                intentId: intentId,
                accountId: accountId,
                stokvelId: stokvelId,
                cycleId: cycleId,
                memberId: memberId,
                amountInCents: amountInCents,
                idempotencyKey: idempotencyKey,
                status: status,
                createdAtUtc: createdAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $PendingPaymentIntentsTable,
                    PendingPaymentIntent
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PendingPaymentIntentsTable,
                    PendingPaymentIntent
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingPaymentIntentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingPaymentIntentsTable,
      PendingPaymentIntent,
      $$PendingPaymentIntentsTableFilterComposer,
      $$PendingPaymentIntentsTableOrderingComposer,
      $$PendingPaymentIntentsTableAnnotationComposer,
      $$PendingPaymentIntentsTableCreateCompanionBuilder,
      $$PendingPaymentIntentsTableUpdateCompanionBuilder,
      (
        PendingPaymentIntent,
        BaseReferences<
          _$AppDatabase,
          $PendingPaymentIntentsTable,
          PendingPaymentIntent
        >,
      ),
      PendingPaymentIntent,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedApiResponsesTableTableManager get cachedApiResponses =>
      $$CachedApiResponsesTableTableManager(_db, _db.cachedApiResponses);
  $$PendingPaymentIntentsTableTableManager get pendingPaymentIntents =>
      $$PendingPaymentIntentsTableTableManager(_db, _db.pendingPaymentIntents);
}
