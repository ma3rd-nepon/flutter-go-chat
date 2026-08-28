// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HomeState()';
}


}

/// @nodoc
class $HomeStateCopyWith<$Res>  {
$HomeStateCopyWith(HomeState _, $Res Function(HomeState) __);
}


/// Adds pattern-matching-related methods to [HomeState].
extension HomeStatePatterns on HomeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( HomeInitialState value)?  initial,TResult Function( HomeLoadingState value)?  loading,TResult Function( HomeLoadedState value)?  loaded,TResult Function( HomeErrorState value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case HomeInitialState() when initial != null:
return initial(_that);case HomeLoadingState() when loading != null:
return loading(_that);case HomeLoadedState() when loaded != null:
return loaded(_that);case HomeErrorState() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( HomeInitialState value)  initial,required TResult Function( HomeLoadingState value)  loading,required TResult Function( HomeLoadedState value)  loaded,required TResult Function( HomeErrorState value)  error,}){
final _that = this;
switch (_that) {
case HomeInitialState():
return initial(_that);case HomeLoadingState():
return loading(_that);case HomeLoadedState():
return loaded(_that);case HomeErrorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( HomeInitialState value)?  initial,TResult? Function( HomeLoadingState value)?  loading,TResult? Function( HomeLoadedState value)?  loaded,TResult? Function( HomeErrorState value)?  error,}){
final _that = this;
switch (_that) {
case HomeInitialState() when initial != null:
return initial(_that);case HomeLoadingState() when loading != null:
return loading(_that);case HomeLoadedState() when loaded != null:
return loaded(_that);case HomeErrorState() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<(Chat, Message?)> chats,  User user)?  loaded,TResult Function( String message,  HomeState previousState)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case HomeInitialState() when initial != null:
return initial();case HomeLoadingState() when loading != null:
return loading();case HomeLoadedState() when loaded != null:
return loaded(_that.chats,_that.user);case HomeErrorState() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<(Chat, Message?)> chats,  User user)  loaded,required TResult Function( String message,  HomeState previousState)  error,}) {final _that = this;
switch (_that) {
case HomeInitialState():
return initial();case HomeLoadingState():
return loading();case HomeLoadedState():
return loaded(_that.chats,_that.user);case HomeErrorState():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<(Chat, Message?)> chats,  User user)?  loaded,TResult? Function( String message,  HomeState previousState)?  error,}) {final _that = this;
switch (_that) {
case HomeInitialState() when initial != null:
return initial();case HomeLoadingState() when loading != null:
return loading();case HomeLoadedState() when loaded != null:
return loaded(_that.chats,_that.user);case HomeErrorState() when error != null:
return error(_that.message,_that.previousState);case _:
  return null;

}
}

}

/// @nodoc


class HomeInitialState implements HomeState {
  const HomeInitialState();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeInitialState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HomeState.initial()';
}


}




/// @nodoc


class HomeLoadingState implements HomeState {
  const HomeLoadingState();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeLoadingState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HomeState.loading()';
}


}




/// @nodoc


class HomeLoadedState implements HomeState {
  const HomeLoadedState({required final  List<(Chat, Message?)> chats, required this.user}): _chats = chats;
  

 final  List<(Chat, Message?)> _chats;
 List<(Chat, Message?)> get chats {
  if (_chats is EqualUnmodifiableListView) return _chats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_chats);
}

 final  User user;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeLoadedStateCopyWith<HomeLoadedState> get copyWith => _$HomeLoadedStateCopyWithImpl<HomeLoadedState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeLoadedState&&const DeepCollectionEquality().equals(other._chats, _chats)&&(identical(other.user, user) || other.user == user));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_chats),user);

@override
String toString() {
  return 'HomeState.loaded(chats: $chats, user: $user)';
}


}

/// @nodoc
abstract mixin class $HomeLoadedStateCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory $HomeLoadedStateCopyWith(HomeLoadedState value, $Res Function(HomeLoadedState) _then) = _$HomeLoadedStateCopyWithImpl;
@useResult
$Res call({
 List<(Chat, Message?)> chats, User user
});




}
/// @nodoc
class _$HomeLoadedStateCopyWithImpl<$Res>
    implements $HomeLoadedStateCopyWith<$Res> {
  _$HomeLoadedStateCopyWithImpl(this._self, this._then);

  final HomeLoadedState _self;
  final $Res Function(HomeLoadedState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? chats = null,Object? user = null,}) {
  return _then(HomeLoadedState(
chats: null == chats ? _self._chats : chats // ignore: cast_nullable_to_non_nullable
as List<(Chat, Message?)>,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,
  ));
}


}

/// @nodoc


class HomeErrorState implements HomeState {
  const HomeErrorState({required this.message, required this.previousState});
  

 final  String message;
 final  HomeState previousState;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeErrorStateCopyWith<HomeErrorState> get copyWith => _$HomeErrorStateCopyWithImpl<HomeErrorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeErrorState&&(identical(other.message, message) || other.message == message)&&(identical(other.previousState, previousState) || other.previousState == previousState));
}


@override
int get hashCode => Object.hash(runtimeType,message,previousState);

@override
String toString() {
  return 'HomeState.error(message: $message, previousState: $previousState)';
}


}

/// @nodoc
abstract mixin class $HomeErrorStateCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory $HomeErrorStateCopyWith(HomeErrorState value, $Res Function(HomeErrorState) _then) = _$HomeErrorStateCopyWithImpl;
@useResult
$Res call({
 String message, HomeState previousState
});


$HomeStateCopyWith<$Res> get previousState;

}
/// @nodoc
class _$HomeErrorStateCopyWithImpl<$Res>
    implements $HomeErrorStateCopyWith<$Res> {
  _$HomeErrorStateCopyWithImpl(this._self, this._then);

  final HomeErrorState _self;
  final $Res Function(HomeErrorState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? previousState = null,}) {
  return _then(HomeErrorState(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,previousState: null == previousState ? _self.previousState : previousState // ignore: cast_nullable_to_non_nullable
as HomeState,
  ));
}

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HomeStateCopyWith<$Res> get previousState {
  
  return $HomeStateCopyWith<$Res>(_self.previousState, (value) {
    return _then(_self.copyWith(previousState: value));
  });
}
}

// dart format on
