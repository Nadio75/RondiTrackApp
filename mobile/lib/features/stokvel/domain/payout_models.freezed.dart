// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payout_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PayoutRotationEntry {

 String get memberId; String get memberName; int get position; Cents get amountCents; DateTime? get scheduledDate; PayoutStatus get status; bool get isNext;
/// Create a copy of PayoutRotationEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayoutRotationEntryCopyWith<PayoutRotationEntry> get copyWith => _$PayoutRotationEntryCopyWithImpl<PayoutRotationEntry>(this as PayoutRotationEntry, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PayoutRotationEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PayoutRotationEntry&&(identical(other.memberId, _this.memberId) || other.memberId == _this.memberId)&&(identical(other.memberName, _this.memberName) || other.memberName == _this.memberName)&&(identical(other.position, _this.position) || other.position == _this.position)&&(identical(other.amountCents, _this.amountCents) || other.amountCents == _this.amountCents)&&(identical(other.scheduledDate, _this.scheduledDate) || other.scheduledDate == _this.scheduledDate)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.isNext, _this.isNext) || other.isNext == _this.isNext));
}


@override
int get hashCode {
  final _this = this as PayoutRotationEntry;
  return Object.hash(runtimeType,_this.memberId,_this.memberName,_this.position,_this.amountCents,_this.scheduledDate,_this.status,_this.isNext);
}

@override
String toString() {
  final _this = this as PayoutRotationEntry;
  return 'PayoutRotationEntry(memberId: ${_this.memberId}, memberName: ${_this.memberName}, position: ${_this.position}, amountCents: ${_this.amountCents}, scheduledDate: ${_this.scheduledDate}, status: ${_this.status}, isNext: ${_this.isNext})';
}


}

/// @nodoc
abstract mixin class $PayoutRotationEntryCopyWith<$Res>  {
  factory $PayoutRotationEntryCopyWith(PayoutRotationEntry value, $Res Function(PayoutRotationEntry) _then) = _$PayoutRotationEntryCopyWithImpl;
@useResult
$Res call({
 String memberId, String memberName, int position, Cents amountCents, DateTime? scheduledDate, PayoutStatus status, bool isNext
});




}
/// @nodoc
class _$PayoutRotationEntryCopyWithImpl<$Res>
    implements $PayoutRotationEntryCopyWith<$Res> {
  _$PayoutRotationEntryCopyWithImpl(this._self, this._then);

  final PayoutRotationEntry _self;
  final $Res Function(PayoutRotationEntry) _then;

/// Create a copy of PayoutRotationEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? memberId = null,Object? memberName = null,Object? position = null,Object? amountCents = null,Object? scheduledDate = freezed,Object? status = null,Object? isNext = null,}) {
  return _then(PayoutRotationEntry(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,amountCents: null == amountCents ? _self.amountCents : amountCents // ignore: cast_nullable_to_non_nullable
as Cents,scheduledDate: freezed == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PayoutStatus,isNext: null == isNext ? _self.isNext : isNext // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PayoutRotationEntry].
extension PayoutRotationEntryPatterns on PayoutRotationEntry {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PayoutRotationEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PayoutRotationEntry() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PayoutRotationEntry value)  $default,){
final _that = this;
switch (_that) {
case _PayoutRotationEntry():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PayoutRotationEntry value)?  $default,){
final _that = this;
switch (_that) {
case _PayoutRotationEntry() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String memberId,  String memberName,  int position,  Cents amountCents,  DateTime? scheduledDate,  PayoutStatus status,  bool isNext)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PayoutRotationEntry() when $default != null:
return $default(_that.memberId,_that.memberName,_that.position,_that.amountCents,_that.scheduledDate,_that.status,_that.isNext);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String memberId,  String memberName,  int position,  Cents amountCents,  DateTime? scheduledDate,  PayoutStatus status,  bool isNext)  $default,) {final _that = this;
switch (_that) {
case _PayoutRotationEntry():
return $default(_that.memberId,_that.memberName,_that.position,_that.amountCents,_that.scheduledDate,_that.status,_that.isNext);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String memberId,  String memberName,  int position,  Cents amountCents,  DateTime? scheduledDate,  PayoutStatus status,  bool isNext)?  $default,) {final _that = this;
switch (_that) {
case _PayoutRotationEntry() when $default != null:
return $default(_that.memberId,_that.memberName,_that.position,_that.amountCents,_that.scheduledDate,_that.status,_that.isNext);case _:
  return null;

}
}

}

/// @nodoc


class _PayoutRotationEntry implements PayoutRotationEntry {
  const _PayoutRotationEntry({required this.memberId, required this.memberName, required this.position, required this.amountCents, required this.scheduledDate, required this.status, required this.isNext});


@override final  String memberId;
@override final  String memberName;
@override final  int position;
@override final  Cents amountCents;
@override final  DateTime? scheduledDate;
@override final  PayoutStatus status;
@override final  bool isNext;

/// Create a copy of PayoutRotationEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayoutRotationEntryCopyWith<_PayoutRotationEntry> get copyWith => __$PayoutRotationEntryCopyWithImpl<_PayoutRotationEntry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PayoutRotationEntry&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.position, position) || other.position == position)&&(identical(other.amountCents, amountCents) || other.amountCents == amountCents)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.isNext, isNext) || other.isNext == isNext));
}


@override
int get hashCode {
    return Object.hash(runtimeType,memberId,memberName,position,amountCents,scheduledDate,status,isNext);
}

@override
String toString() {
    return 'PayoutRotationEntry(memberId: $memberId, memberName: $memberName, position: $position, amountCents: $amountCents, scheduledDate: $scheduledDate, status: $status, isNext: $isNext)';
}


}

/// @nodoc
abstract mixin class _$PayoutRotationEntryCopyWith<$Res> implements $PayoutRotationEntryCopyWith<$Res> {
  factory _$PayoutRotationEntryCopyWith(_PayoutRotationEntry value, $Res Function(_PayoutRotationEntry) _then) = __$PayoutRotationEntryCopyWithImpl;
@override @useResult
$Res call({
 String memberId, String memberName, int position, Cents amountCents, DateTime? scheduledDate, PayoutStatus status, bool isNext
});




}
/// @nodoc
class __$PayoutRotationEntryCopyWithImpl<$Res>
    implements _$PayoutRotationEntryCopyWith<$Res> {
  __$PayoutRotationEntryCopyWithImpl(this._self, this._then);

  final _PayoutRotationEntry _self;
  final $Res Function(_PayoutRotationEntry) _then;

/// Create a copy of PayoutRotationEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? memberId = null,Object? memberName = null,Object? position = null,Object? amountCents = null,Object? scheduledDate = freezed,Object? status = null,Object? isNext = null,}) {
  return _then(_PayoutRotationEntry(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,amountCents: null == amountCents ? _self.amountCents : amountCents // ignore: cast_nullable_to_non_nullable
as Cents,scheduledDate: freezed == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PayoutStatus,isNext: null == isNext ? _self.isNext : isNext // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$PayoutRotation {

 String get stokvelId; String get cycleId; List<PayoutRotationEntry> get entries;
/// Create a copy of PayoutRotation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PayoutRotationCopyWith<PayoutRotation> get copyWith => _$PayoutRotationCopyWithImpl<PayoutRotation>(this as PayoutRotation, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PayoutRotation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PayoutRotation&&(identical(other.stokvelId, _this.stokvelId) || other.stokvelId == _this.stokvelId)&&(identical(other.cycleId, _this.cycleId) || other.cycleId == _this.cycleId)&&const DeepCollectionEquality().equals(other.entries, _this.entries));
}


@override
int get hashCode {
  final _this = this as PayoutRotation;
  return Object.hash(runtimeType,_this.stokvelId,_this.cycleId,const DeepCollectionEquality().hash(_this.entries));
}

@override
String toString() {
  final _this = this as PayoutRotation;
  return 'PayoutRotation(stokvelId: ${_this.stokvelId}, cycleId: ${_this.cycleId}, entries: ${_this.entries})';
}


}

/// @nodoc
abstract mixin class $PayoutRotationCopyWith<$Res>  {
  factory $PayoutRotationCopyWith(PayoutRotation value, $Res Function(PayoutRotation) _then) = _$PayoutRotationCopyWithImpl;
@useResult
$Res call({
 String stokvelId, String cycleId, List<PayoutRotationEntry> entries
});




}
/// @nodoc
class _$PayoutRotationCopyWithImpl<$Res>
    implements $PayoutRotationCopyWith<$Res> {
  _$PayoutRotationCopyWithImpl(this._self, this._then);

  final PayoutRotation _self;
  final $Res Function(PayoutRotation) _then;

/// Create a copy of PayoutRotation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stokvelId = null,Object? cycleId = null,Object? entries = null,}) {
  return _then(PayoutRotation(
stokvelId: null == stokvelId ? _self.stokvelId : stokvelId // ignore: cast_nullable_to_non_nullable
as String,cycleId: null == cycleId ? _self.cycleId : cycleId // ignore: cast_nullable_to_non_nullable
as String,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<PayoutRotationEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [PayoutRotation].
extension PayoutRotationPatterns on PayoutRotation {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PayoutRotation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PayoutRotation() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PayoutRotation value)  $default,){
final _that = this;
switch (_that) {
case _PayoutRotation():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PayoutRotation value)?  $default,){
final _that = this;
switch (_that) {
case _PayoutRotation() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String stokvelId,  String cycleId,  List<PayoutRotationEntry> entries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PayoutRotation() when $default != null:
return $default(_that.stokvelId,_that.cycleId,_that.entries);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String stokvelId,  String cycleId,  List<PayoutRotationEntry> entries)  $default,) {final _that = this;
switch (_that) {
case _PayoutRotation():
return $default(_that.stokvelId,_that.cycleId,_that.entries);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String stokvelId,  String cycleId,  List<PayoutRotationEntry> entries)?  $default,) {final _that = this;
switch (_that) {
case _PayoutRotation() when $default != null:
return $default(_that.stokvelId,_that.cycleId,_that.entries);case _:
  return null;

}
}

}

/// @nodoc


class _PayoutRotation implements PayoutRotation {
  const _PayoutRotation({required this.stokvelId, required this.cycleId, required  List<PayoutRotationEntry> entries}): _entries = entries;


@override final  String stokvelId;
@override final  String cycleId;
 final  List<PayoutRotationEntry> _entries;
@override List<PayoutRotationEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}


/// Create a copy of PayoutRotation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PayoutRotationCopyWith<_PayoutRotation> get copyWith => __$PayoutRotationCopyWithImpl<_PayoutRotation>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PayoutRotation&&(identical(other.stokvelId, stokvelId) || other.stokvelId == stokvelId)&&(identical(other.cycleId, cycleId) || other.cycleId == cycleId)&&const DeepCollectionEquality().equals(other.entries, _entries));
}


@override
int get hashCode {
    return Object.hash(runtimeType,stokvelId,cycleId,const DeepCollectionEquality().hash(_entries));
}

@override
String toString() {
    return 'PayoutRotation(stokvelId: $stokvelId, cycleId: $cycleId, entries: $entries)';
}


}

/// @nodoc
abstract mixin class _$PayoutRotationCopyWith<$Res> implements $PayoutRotationCopyWith<$Res> {
  factory _$PayoutRotationCopyWith(_PayoutRotation value, $Res Function(_PayoutRotation) _then) = __$PayoutRotationCopyWithImpl;
@override @useResult
$Res call({
 String stokvelId, String cycleId, List<PayoutRotationEntry> entries
});




}
/// @nodoc
class __$PayoutRotationCopyWithImpl<$Res>
    implements _$PayoutRotationCopyWith<$Res> {
  __$PayoutRotationCopyWithImpl(this._self, this._then);

  final _PayoutRotation _self;
  final $Res Function(_PayoutRotation) _then;

/// Create a copy of PayoutRotation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stokvelId = null,Object? cycleId = null,Object? entries = null,}) {
  return _then(_PayoutRotation(
stokvelId: null == stokvelId ? _self.stokvelId : stokvelId // ignore: cast_nullable_to_non_nullable
as String,cycleId: null == cycleId ? _self.cycleId : cycleId // ignore: cast_nullable_to_non_nullable
as String,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<PayoutRotationEntry>,
  ));
}


}

// dart format on
