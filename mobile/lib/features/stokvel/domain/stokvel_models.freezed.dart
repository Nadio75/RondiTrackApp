// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stokvel_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Membership {

 String get stokvelId; StokvelRole get role;
/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MembershipCopyWith<Membership> get copyWith => _$MembershipCopyWithImpl<Membership>(this as Membership, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Membership;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Membership&&(identical(other.stokvelId, _this.stokvelId) || other.stokvelId == _this.stokvelId)&&(identical(other.role, _this.role) || other.role == _this.role));
}


@override
int get hashCode {
  final _this = this as Membership;
  return Object.hash(runtimeType,_this.stokvelId,_this.role);
}

@override
String toString() {
  final _this = this as Membership;
  return 'Membership(stokvelId: ${_this.stokvelId}, role: ${_this.role})';
}


}

/// @nodoc
abstract mixin class $MembershipCopyWith<$Res>  {
  factory $MembershipCopyWith(Membership value, $Res Function(Membership) _then) = _$MembershipCopyWithImpl;
@useResult
$Res call({
 String stokvelId, StokvelRole role
});




}
/// @nodoc
class _$MembershipCopyWithImpl<$Res>
    implements $MembershipCopyWith<$Res> {
  _$MembershipCopyWithImpl(this._self, this._then);

  final Membership _self;
  final $Res Function(Membership) _then;

/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stokvelId = null,Object? role = null,}) {
  return _then(Membership(
stokvelId: null == stokvelId ? _self.stokvelId : stokvelId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as StokvelRole,
  ));
}

}


/// Adds pattern-matching-related methods to [Membership].
extension MembershipPatterns on Membership {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Membership value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Membership() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Membership value)  $default,){
final _that = this;
switch (_that) {
case _Membership():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Membership value)?  $default,){
final _that = this;
switch (_that) {
case _Membership() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String stokvelId,  StokvelRole role)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Membership() when $default != null:
return $default(_that.stokvelId,_that.role);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String stokvelId,  StokvelRole role)  $default,) {final _that = this;
switch (_that) {
case _Membership():
return $default(_that.stokvelId,_that.role);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String stokvelId,  StokvelRole role)?  $default,) {final _that = this;
switch (_that) {
case _Membership() when $default != null:
return $default(_that.stokvelId,_that.role);case _:
  return null;

}
}

}

/// @nodoc


class _Membership implements Membership {
  const _Membership({required this.stokvelId, required this.role});
  

@override final  String stokvelId;
@override final  StokvelRole role;

/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MembershipCopyWith<_Membership> get copyWith => __$MembershipCopyWithImpl<_Membership>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Membership&&(identical(other.stokvelId, stokvelId) || other.stokvelId == stokvelId)&&(identical(other.role, role) || other.role == role));
}


@override
int get hashCode {
    return Object.hash(runtimeType,stokvelId,role);
}

@override
String toString() {
    return 'Membership(stokvelId: $stokvelId, role: $role)';
}


}

/// @nodoc
abstract mixin class _$MembershipCopyWith<$Res> implements $MembershipCopyWith<$Res> {
  factory _$MembershipCopyWith(_Membership value, $Res Function(_Membership) _then) = __$MembershipCopyWithImpl;
@override @useResult
$Res call({
 String stokvelId, StokvelRole role
});




}
/// @nodoc
class __$MembershipCopyWithImpl<$Res>
    implements _$MembershipCopyWith<$Res> {
  __$MembershipCopyWithImpl(this._self, this._then);

  final _Membership _self;
  final $Res Function(_Membership) _then;

/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stokvelId = null,Object? role = null,}) {
  return _then(_Membership(
stokvelId: null == stokvelId ? _self.stokvelId : stokvelId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as StokvelRole,
  ));
}


}

/// @nodoc
mixin _$Stokvel {

 String get id; String get name; String get description; int get monthlyContributionCents;
/// Create a copy of Stokvel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StokvelCopyWith<Stokvel> get copyWith => _$StokvelCopyWithImpl<Stokvel>(this as Stokvel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Stokvel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Stokvel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.monthlyContributionCents, _this.monthlyContributionCents) || other.monthlyContributionCents == _this.monthlyContributionCents));
}


@override
int get hashCode {
  final _this = this as Stokvel;
  return Object.hash(runtimeType,_this.id,_this.name,_this.description,_this.monthlyContributionCents);
}

@override
String toString() {
  final _this = this as Stokvel;
  return 'Stokvel(id: ${_this.id}, name: ${_this.name}, description: ${_this.description}, monthlyContributionCents: ${_this.monthlyContributionCents})';
}


}

/// @nodoc
abstract mixin class $StokvelCopyWith<$Res>  {
  factory $StokvelCopyWith(Stokvel value, $Res Function(Stokvel) _then) = _$StokvelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, int monthlyContributionCents
});




}
/// @nodoc
class _$StokvelCopyWithImpl<$Res>
    implements $StokvelCopyWith<$Res> {
  _$StokvelCopyWithImpl(this._self, this._then);

  final Stokvel _self;
  final $Res Function(Stokvel) _then;

/// Create a copy of Stokvel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? monthlyContributionCents = null,}) {
  return _then(Stokvel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,monthlyContributionCents: null == monthlyContributionCents ? _self.monthlyContributionCents : monthlyContributionCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Stokvel].
extension StokvelPatterns on Stokvel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Stokvel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Stokvel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Stokvel value)  $default,){
final _that = this;
switch (_that) {
case _Stokvel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Stokvel value)?  $default,){
final _that = this;
switch (_that) {
case _Stokvel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  int monthlyContributionCents)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Stokvel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.monthlyContributionCents);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  int monthlyContributionCents)  $default,) {final _that = this;
switch (_that) {
case _Stokvel():
return $default(_that.id,_that.name,_that.description,_that.monthlyContributionCents);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  int monthlyContributionCents)?  $default,) {final _that = this;
switch (_that) {
case _Stokvel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.monthlyContributionCents);case _:
  return null;

}
}

}

/// @nodoc


class _Stokvel implements Stokvel {
  const _Stokvel({required this.id, required this.name, required this.description, required this.monthlyContributionCents});
  

@override final  String id;
@override final  String name;
@override final  String description;
@override final  int monthlyContributionCents;

/// Create a copy of Stokvel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StokvelCopyWith<_Stokvel> get copyWith => __$StokvelCopyWithImpl<_Stokvel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Stokvel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.monthlyContributionCents, monthlyContributionCents) || other.monthlyContributionCents == monthlyContributionCents));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,description,monthlyContributionCents);
}

@override
String toString() {
    return 'Stokvel(id: $id, name: $name, description: $description, monthlyContributionCents: $monthlyContributionCents)';
}


}

/// @nodoc
abstract mixin class _$StokvelCopyWith<$Res> implements $StokvelCopyWith<$Res> {
  factory _$StokvelCopyWith(_Stokvel value, $Res Function(_Stokvel) _then) = __$StokvelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, int monthlyContributionCents
});




}
/// @nodoc
class __$StokvelCopyWithImpl<$Res>
    implements _$StokvelCopyWith<$Res> {
  __$StokvelCopyWithImpl(this._self, this._then);

  final _Stokvel _self;
  final $Res Function(_Stokvel) _then;

/// Create a copy of Stokvel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? monthlyContributionCents = null,}) {
  return _then(_Stokvel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,monthlyContributionCents: null == monthlyContributionCents ? _self.monthlyContributionCents : monthlyContributionCents // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$Contribution {

 String get id; String get stokvelId; String get memberId; int get amountCents; ContributionStatus get status;
/// Create a copy of Contribution
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContributionCopyWith<Contribution> get copyWith => _$ContributionCopyWithImpl<Contribution>(this as Contribution, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Contribution;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Contribution&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.stokvelId, _this.stokvelId) || other.stokvelId == _this.stokvelId)&&(identical(other.memberId, _this.memberId) || other.memberId == _this.memberId)&&(identical(other.amountCents, _this.amountCents) || other.amountCents == _this.amountCents)&&(identical(other.status, _this.status) || other.status == _this.status));
}


@override
int get hashCode {
  final _this = this as Contribution;
  return Object.hash(runtimeType,_this.id,_this.stokvelId,_this.memberId,_this.amountCents,_this.status);
}

@override
String toString() {
  final _this = this as Contribution;
  return 'Contribution(id: ${_this.id}, stokvelId: ${_this.stokvelId}, memberId: ${_this.memberId}, amountCents: ${_this.amountCents}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $ContributionCopyWith<$Res>  {
  factory $ContributionCopyWith(Contribution value, $Res Function(Contribution) _then) = _$ContributionCopyWithImpl;
@useResult
$Res call({
 String id, String stokvelId, String memberId, int amountCents, ContributionStatus status
});




}
/// @nodoc
class _$ContributionCopyWithImpl<$Res>
    implements $ContributionCopyWith<$Res> {
  _$ContributionCopyWithImpl(this._self, this._then);

  final Contribution _self;
  final $Res Function(Contribution) _then;

/// Create a copy of Contribution
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? stokvelId = null,Object? memberId = null,Object? amountCents = null,Object? status = null,}) {
  return _then(Contribution(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,stokvelId: null == stokvelId ? _self.stokvelId : stokvelId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,amountCents: null == amountCents ? _self.amountCents : amountCents // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContributionStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [Contribution].
extension ContributionPatterns on Contribution {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Contribution value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Contribution() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Contribution value)  $default,){
final _that = this;
switch (_that) {
case _Contribution():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Contribution value)?  $default,){
final _that = this;
switch (_that) {
case _Contribution() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String stokvelId,  String memberId,  int amountCents,  ContributionStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Contribution() when $default != null:
return $default(_that.id,_that.stokvelId,_that.memberId,_that.amountCents,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String stokvelId,  String memberId,  int amountCents,  ContributionStatus status)  $default,) {final _that = this;
switch (_that) {
case _Contribution():
return $default(_that.id,_that.stokvelId,_that.memberId,_that.amountCents,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String stokvelId,  String memberId,  int amountCents,  ContributionStatus status)?  $default,) {final _that = this;
switch (_that) {
case _Contribution() when $default != null:
return $default(_that.id,_that.stokvelId,_that.memberId,_that.amountCents,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _Contribution implements Contribution {
  const _Contribution({required this.id, required this.stokvelId, required this.memberId, required this.amountCents, required this.status});
  

@override final  String id;
@override final  String stokvelId;
@override final  String memberId;
@override final  int amountCents;
@override final  ContributionStatus status;

/// Create a copy of Contribution
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContributionCopyWith<_Contribution> get copyWith => __$ContributionCopyWithImpl<_Contribution>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Contribution&&(identical(other.id, id) || other.id == id)&&(identical(other.stokvelId, stokvelId) || other.stokvelId == stokvelId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.amountCents, amountCents) || other.amountCents == amountCents)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,stokvelId,memberId,amountCents,status);
}

@override
String toString() {
    return 'Contribution(id: $id, stokvelId: $stokvelId, memberId: $memberId, amountCents: $amountCents, status: $status)';
}


}

/// @nodoc
abstract mixin class _$ContributionCopyWith<$Res> implements $ContributionCopyWith<$Res> {
  factory _$ContributionCopyWith(_Contribution value, $Res Function(_Contribution) _then) = __$ContributionCopyWithImpl;
@override @useResult
$Res call({
 String id, String stokvelId, String memberId, int amountCents, ContributionStatus status
});




}
/// @nodoc
class __$ContributionCopyWithImpl<$Res>
    implements _$ContributionCopyWith<$Res> {
  __$ContributionCopyWithImpl(this._self, this._then);

  final _Contribution _self;
  final $Res Function(_Contribution) _then;

/// Create a copy of Contribution
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? stokvelId = null,Object? memberId = null,Object? amountCents = null,Object? status = null,}) {
  return _then(_Contribution(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,stokvelId: null == stokvelId ? _self.stokvelId : stokvelId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,amountCents: null == amountCents ? _self.amountCents : amountCents // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContributionStatus,
  ));
}


}

/// @nodoc
mixin _$Cycle {

 String get id; String get stokvelId; CycleStatus get status; DateTime get startDate; DateTime get endDate;
/// Create a copy of Cycle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CycleCopyWith<Cycle> get copyWith => _$CycleCopyWithImpl<Cycle>(this as Cycle, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Cycle;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Cycle&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.stokvelId, _this.stokvelId) || other.stokvelId == _this.stokvelId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.startDate, _this.startDate) || other.startDate == _this.startDate)&&(identical(other.endDate, _this.endDate) || other.endDate == _this.endDate));
}


@override
int get hashCode {
  final _this = this as Cycle;
  return Object.hash(runtimeType,_this.id,_this.stokvelId,_this.status,_this.startDate,_this.endDate);
}

@override
String toString() {
  final _this = this as Cycle;
  return 'Cycle(id: ${_this.id}, stokvelId: ${_this.stokvelId}, status: ${_this.status}, startDate: ${_this.startDate}, endDate: ${_this.endDate})';
}


}

/// @nodoc
abstract mixin class $CycleCopyWith<$Res>  {
  factory $CycleCopyWith(Cycle value, $Res Function(Cycle) _then) = _$CycleCopyWithImpl;
@useResult
$Res call({
 String id, String stokvelId, CycleStatus status, DateTime startDate, DateTime endDate
});




}
/// @nodoc
class _$CycleCopyWithImpl<$Res>
    implements $CycleCopyWith<$Res> {
  _$CycleCopyWithImpl(this._self, this._then);

  final Cycle _self;
  final $Res Function(Cycle) _then;

/// Create a copy of Cycle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? stokvelId = null,Object? status = null,Object? startDate = null,Object? endDate = null,}) {
  return _then(Cycle(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,stokvelId: null == stokvelId ? _self.stokvelId : stokvelId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CycleStatus,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Cycle].
extension CyclePatterns on Cycle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Cycle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Cycle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Cycle value)  $default,){
final _that = this;
switch (_that) {
case _Cycle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Cycle value)?  $default,){
final _that = this;
switch (_that) {
case _Cycle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String stokvelId,  CycleStatus status,  DateTime startDate,  DateTime endDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Cycle() when $default != null:
return $default(_that.id,_that.stokvelId,_that.status,_that.startDate,_that.endDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String stokvelId,  CycleStatus status,  DateTime startDate,  DateTime endDate)  $default,) {final _that = this;
switch (_that) {
case _Cycle():
return $default(_that.id,_that.stokvelId,_that.status,_that.startDate,_that.endDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String stokvelId,  CycleStatus status,  DateTime startDate,  DateTime endDate)?  $default,) {final _that = this;
switch (_that) {
case _Cycle() when $default != null:
return $default(_that.id,_that.stokvelId,_that.status,_that.startDate,_that.endDate);case _:
  return null;

}
}

}

/// @nodoc


class _Cycle implements Cycle {
  const _Cycle({required this.id, required this.stokvelId, required this.status, required this.startDate, required this.endDate});
  

@override final  String id;
@override final  String stokvelId;
@override final  CycleStatus status;
@override final  DateTime startDate;
@override final  DateTime endDate;

/// Create a copy of Cycle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CycleCopyWith<_Cycle> get copyWith => __$CycleCopyWithImpl<_Cycle>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Cycle&&(identical(other.id, id) || other.id == id)&&(identical(other.stokvelId, stokvelId) || other.stokvelId == stokvelId)&&(identical(other.status, status) || other.status == status)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,stokvelId,status,startDate,endDate);
}

@override
String toString() {
    return 'Cycle(id: $id, stokvelId: $stokvelId, status: $status, startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class _$CycleCopyWith<$Res> implements $CycleCopyWith<$Res> {
  factory _$CycleCopyWith(_Cycle value, $Res Function(_Cycle) _then) = __$CycleCopyWithImpl;
@override @useResult
$Res call({
 String id, String stokvelId, CycleStatus status, DateTime startDate, DateTime endDate
});




}
/// @nodoc
class __$CycleCopyWithImpl<$Res>
    implements _$CycleCopyWith<$Res> {
  __$CycleCopyWithImpl(this._self, this._then);

  final _Cycle _self;
  final $Res Function(_Cycle) _then;

/// Create a copy of Cycle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? stokvelId = null,Object? status = null,Object? startDate = null,Object? endDate = null,}) {
  return _then(_Cycle(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,stokvelId: null == stokvelId ? _self.stokvelId : stokvelId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CycleStatus,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
