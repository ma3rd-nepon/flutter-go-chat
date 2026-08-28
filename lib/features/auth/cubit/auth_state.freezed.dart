// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState()';
}


}

/// @nodoc
class $AuthStateCopyWith<$Res>  {
$AuthStateCopyWith(AuthState _, $Res Function(AuthState) __);
}


/// Adds pattern-matching-related methods to [AuthState].
extension AuthStatePatterns on AuthState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AuthInitialState value)?  initial,TResult Function( AuthLoadingState value)?  loading,TResult Function( AuthAuthorizingState value)?  authorize,TResult Function( AuthOtpSentState value)?  otpSent,TResult Function( AuthPasswordSetup value)?  passwordSetup,TResult Function( AuthProfileSetupState value)?  profileSetup,TResult Function( AuthAuthenticatedState value)?  authenticated,TResult Function( AuthErrorState value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AuthInitialState() when initial != null:
return initial(_that);case AuthLoadingState() when loading != null:
return loading(_that);case AuthAuthorizingState() when authorize != null:
return authorize(_that);case AuthOtpSentState() when otpSent != null:
return otpSent(_that);case AuthPasswordSetup() when passwordSetup != null:
return passwordSetup(_that);case AuthProfileSetupState() when profileSetup != null:
return profileSetup(_that);case AuthAuthenticatedState() when authenticated != null:
return authenticated(_that);case AuthErrorState() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AuthInitialState value)  initial,required TResult Function( AuthLoadingState value)  loading,required TResult Function( AuthAuthorizingState value)  authorize,required TResult Function( AuthOtpSentState value)  otpSent,required TResult Function( AuthPasswordSetup value)  passwordSetup,required TResult Function( AuthProfileSetupState value)  profileSetup,required TResult Function( AuthAuthenticatedState value)  authenticated,required TResult Function( AuthErrorState value)  error,}){
final _that = this;
switch (_that) {
case AuthInitialState():
return initial(_that);case AuthLoadingState():
return loading(_that);case AuthAuthorizingState():
return authorize(_that);case AuthOtpSentState():
return otpSent(_that);case AuthPasswordSetup():
return passwordSetup(_that);case AuthProfileSetupState():
return profileSetup(_that);case AuthAuthenticatedState():
return authenticated(_that);case AuthErrorState():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AuthInitialState value)?  initial,TResult? Function( AuthLoadingState value)?  loading,TResult? Function( AuthAuthorizingState value)?  authorize,TResult? Function( AuthOtpSentState value)?  otpSent,TResult? Function( AuthPasswordSetup value)?  passwordSetup,TResult? Function( AuthProfileSetupState value)?  profileSetup,TResult? Function( AuthAuthenticatedState value)?  authenticated,TResult? Function( AuthErrorState value)?  error,}){
final _that = this;
switch (_that) {
case AuthInitialState() when initial != null:
return initial(_that);case AuthLoadingState() when loading != null:
return loading(_that);case AuthAuthorizingState() when authorize != null:
return authorize(_that);case AuthOtpSentState() when otpSent != null:
return otpSent(_that);case AuthPasswordSetup() when passwordSetup != null:
return passwordSetup(_that);case AuthProfileSetupState() when profileSetup != null:
return profileSetup(_that);case AuthAuthenticatedState() when authenticated != null:
return authenticated(_that);case AuthErrorState() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function()?  authorize,TResult Function( (String, String) data)?  otpSent,TResult Function( (String, String) data)?  passwordSetup,TResult Function( (String, String) data)?  profileSetup,TResult Function( (User, String) fullUser)?  authenticated,TResult Function( String message,  AuthState previousState)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AuthInitialState() when initial != null:
return initial();case AuthLoadingState() when loading != null:
return loading();case AuthAuthorizingState() when authorize != null:
return authorize();case AuthOtpSentState() when otpSent != null:
return otpSent(_that.data);case AuthPasswordSetup() when passwordSetup != null:
return passwordSetup(_that.data);case AuthProfileSetupState() when profileSetup != null:
return profileSetup(_that.data);case AuthAuthenticatedState() when authenticated != null:
return authenticated(_that.fullUser);case AuthErrorState() when error != null:
return error(_that.message,_that.previousState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function()  authorize,required TResult Function( (String, String) data)  otpSent,required TResult Function( (String, String) data)  passwordSetup,required TResult Function( (String, String) data)  profileSetup,required TResult Function( (User, String) fullUser)  authenticated,required TResult Function( String message,  AuthState previousState)  error,}) {final _that = this;
switch (_that) {
case AuthInitialState():
return initial();case AuthLoadingState():
return loading();case AuthAuthorizingState():
return authorize();case AuthOtpSentState():
return otpSent(_that.data);case AuthPasswordSetup():
return passwordSetup(_that.data);case AuthProfileSetupState():
return profileSetup(_that.data);case AuthAuthenticatedState():
return authenticated(_that.fullUser);case AuthErrorState():
return error(_that.message,_that.previousState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function()?  authorize,TResult? Function( (String, String) data)?  otpSent,TResult? Function( (String, String) data)?  passwordSetup,TResult? Function( (String, String) data)?  profileSetup,TResult? Function( (User, String) fullUser)?  authenticated,TResult? Function( String message,  AuthState previousState)?  error,}) {final _that = this;
switch (_that) {
case AuthInitialState() when initial != null:
return initial();case AuthLoadingState() when loading != null:
return loading();case AuthAuthorizingState() when authorize != null:
return authorize();case AuthOtpSentState() when otpSent != null:
return otpSent(_that.data);case AuthPasswordSetup() when passwordSetup != null:
return passwordSetup(_that.data);case AuthProfileSetupState() when profileSetup != null:
return profileSetup(_that.data);case AuthAuthenticatedState() when authenticated != null:
return authenticated(_that.fullUser);case AuthErrorState() when error != null:
return error(_that.message,_that.previousState);case _:
  return null;

}
}

}

/// @nodoc


class AuthInitialState implements AuthState {
  const AuthInitialState();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthInitialState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.initial()';
}


}




/// @nodoc


class AuthLoadingState implements AuthState {
  const AuthLoadingState();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthLoadingState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.loading()';
}


}




/// @nodoc


class AuthAuthorizingState implements AuthState {
  const AuthAuthorizingState();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthAuthorizingState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthState.authorize()';
}


}




/// @nodoc


class AuthOtpSentState implements AuthState {
  const AuthOtpSentState({required this.data});
  

 final  (String, String) data;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthOtpSentStateCopyWith<AuthOtpSentState> get copyWith => _$AuthOtpSentStateCopyWithImpl<AuthOtpSentState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthOtpSentState&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'AuthState.otpSent(data: $data)';
}


}

/// @nodoc
abstract mixin class $AuthOtpSentStateCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory $AuthOtpSentStateCopyWith(AuthOtpSentState value, $Res Function(AuthOtpSentState) _then) = _$AuthOtpSentStateCopyWithImpl;
@useResult
$Res call({
 (String, String) data
});




}
/// @nodoc
class _$AuthOtpSentStateCopyWithImpl<$Res>
    implements $AuthOtpSentStateCopyWith<$Res> {
  _$AuthOtpSentStateCopyWithImpl(this._self, this._then);

  final AuthOtpSentState _self;
  final $Res Function(AuthOtpSentState) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(AuthOtpSentState(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as (String, String),
  ));
}


}

/// @nodoc


class AuthPasswordSetup implements AuthState {
  const AuthPasswordSetup({required this.data});
  

 final  (String, String) data;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthPasswordSetupCopyWith<AuthPasswordSetup> get copyWith => _$AuthPasswordSetupCopyWithImpl<AuthPasswordSetup>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthPasswordSetup&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'AuthState.passwordSetup(data: $data)';
}


}

/// @nodoc
abstract mixin class $AuthPasswordSetupCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory $AuthPasswordSetupCopyWith(AuthPasswordSetup value, $Res Function(AuthPasswordSetup) _then) = _$AuthPasswordSetupCopyWithImpl;
@useResult
$Res call({
 (String, String) data
});




}
/// @nodoc
class _$AuthPasswordSetupCopyWithImpl<$Res>
    implements $AuthPasswordSetupCopyWith<$Res> {
  _$AuthPasswordSetupCopyWithImpl(this._self, this._then);

  final AuthPasswordSetup _self;
  final $Res Function(AuthPasswordSetup) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(AuthPasswordSetup(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as (String, String),
  ));
}


}

/// @nodoc


class AuthProfileSetupState implements AuthState {
  const AuthProfileSetupState({required this.data});
  

 final  (String, String) data;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthProfileSetupStateCopyWith<AuthProfileSetupState> get copyWith => _$AuthProfileSetupStateCopyWithImpl<AuthProfileSetupState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthProfileSetupState&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'AuthState.profileSetup(data: $data)';
}


}

/// @nodoc
abstract mixin class $AuthProfileSetupStateCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory $AuthProfileSetupStateCopyWith(AuthProfileSetupState value, $Res Function(AuthProfileSetupState) _then) = _$AuthProfileSetupStateCopyWithImpl;
@useResult
$Res call({
 (String, String) data
});




}
/// @nodoc
class _$AuthProfileSetupStateCopyWithImpl<$Res>
    implements $AuthProfileSetupStateCopyWith<$Res> {
  _$AuthProfileSetupStateCopyWithImpl(this._self, this._then);

  final AuthProfileSetupState _self;
  final $Res Function(AuthProfileSetupState) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(AuthProfileSetupState(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as (String, String),
  ));
}


}

/// @nodoc


class AuthAuthenticatedState implements AuthState {
  const AuthAuthenticatedState({required this.fullUser});
  

 final  (User, String) fullUser;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthAuthenticatedStateCopyWith<AuthAuthenticatedState> get copyWith => _$AuthAuthenticatedStateCopyWithImpl<AuthAuthenticatedState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthAuthenticatedState&&(identical(other.fullUser, fullUser) || other.fullUser == fullUser));
}


@override
int get hashCode => Object.hash(runtimeType,fullUser);

@override
String toString() {
  return 'AuthState.authenticated(fullUser: $fullUser)';
}


}

/// @nodoc
abstract mixin class $AuthAuthenticatedStateCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory $AuthAuthenticatedStateCopyWith(AuthAuthenticatedState value, $Res Function(AuthAuthenticatedState) _then) = _$AuthAuthenticatedStateCopyWithImpl;
@useResult
$Res call({
 (User, String) fullUser
});




}
/// @nodoc
class _$AuthAuthenticatedStateCopyWithImpl<$Res>
    implements $AuthAuthenticatedStateCopyWith<$Res> {
  _$AuthAuthenticatedStateCopyWithImpl(this._self, this._then);

  final AuthAuthenticatedState _self;
  final $Res Function(AuthAuthenticatedState) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? fullUser = null,}) {
  return _then(AuthAuthenticatedState(
fullUser: null == fullUser ? _self.fullUser : fullUser // ignore: cast_nullable_to_non_nullable
as (User, String),
  ));
}


}

/// @nodoc


class AuthErrorState implements AuthState {
  const AuthErrorState({required this.message, required this.previousState});
  

 final  String message;
 final  AuthState previousState;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthErrorStateCopyWith<AuthErrorState> get copyWith => _$AuthErrorStateCopyWithImpl<AuthErrorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthErrorState&&(identical(other.message, message) || other.message == message)&&(identical(other.previousState, previousState) || other.previousState == previousState));
}


@override
int get hashCode => Object.hash(runtimeType,message,previousState);

@override
String toString() {
  return 'AuthState.error(message: $message, previousState: $previousState)';
}


}

/// @nodoc
abstract mixin class $AuthErrorStateCopyWith<$Res> implements $AuthStateCopyWith<$Res> {
  factory $AuthErrorStateCopyWith(AuthErrorState value, $Res Function(AuthErrorState) _then) = _$AuthErrorStateCopyWithImpl;
@useResult
$Res call({
 String message, AuthState previousState
});


$AuthStateCopyWith<$Res> get previousState;

}
/// @nodoc
class _$AuthErrorStateCopyWithImpl<$Res>
    implements $AuthErrorStateCopyWith<$Res> {
  _$AuthErrorStateCopyWithImpl(this._self, this._then);

  final AuthErrorState _self;
  final $Res Function(AuthErrorState) _then;

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? previousState = null,}) {
  return _then(AuthErrorState(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,previousState: null == previousState ? _self.previousState : previousState // ignore: cast_nullable_to_non_nullable
as AuthState,
  ));
}

/// Create a copy of AuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthStateCopyWith<$Res> get previousState {
  
  return $AuthStateCopyWith<$Res>(_self.previousState, (value) {
    return _then(_self.copyWith(previousState: value));
  });
}
}

// dart format on
