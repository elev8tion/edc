// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_error.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AppError {
  String get message => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? details) network,
    required TResult Function(String message, String? details) database,
    required TResult Function(String message, String? field) validation,
    required TResult Function(String message, String? permission) permission,
    required TResult Function(String message, String? details) unknown,
    required TResult Function(String message, int? statusCode, String? details)
        api,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? details)? network,
    TResult? Function(String message, String? details)? database,
    TResult? Function(String message, String? field)? validation,
    TResult? Function(String message, String? permission)? permission,
    TResult? Function(String message, String? details)? unknown,
    TResult? Function(String message, int? statusCode, String? details)? api,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? details)? network,
    TResult Function(String message, String? details)? database,
    TResult Function(String message, String? field)? validation,
    TResult Function(String message, String? permission)? permission,
    TResult Function(String message, String? details)? unknown,
    TResult Function(String message, int? statusCode, String? details)? api,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkError value) network,
    required TResult Function(DatabaseError value) database,
    required TResult Function(ValidationError value) validation,
    required TResult Function(PermissionError value) permission,
    required TResult Function(UnknownError value) unknown,
    required TResult Function(ApiError value) api,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkError value)? network,
    TResult? Function(DatabaseError value)? database,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(PermissionError value)? permission,
    TResult? Function(UnknownError value)? unknown,
    TResult? Function(ApiError value)? api,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkError value)? network,
    TResult Function(DatabaseError value)? database,
    TResult Function(ValidationError value)? validation,
    TResult Function(PermissionError value)? permission,
    TResult Function(UnknownError value)? unknown,
    TResult Function(ApiError value)? api,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppErrorCopyWith<AppError> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppErrorCopyWith<$Res> {
  factory $AppErrorCopyWith(AppError value, $Res Function(AppError) then) =
      _$AppErrorCopyWithImpl<$Res, AppError>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$AppErrorCopyWithImpl<$Res, $Val extends AppError>
    implements $AppErrorCopyWith<$Res> {
  _$AppErrorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NetworkErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$NetworkErrorImplCopyWith(
          _$NetworkErrorImpl value, $Res Function(_$NetworkErrorImpl) then) =
      __$$NetworkErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? details});
}

/// @nodoc
class __$$NetworkErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$NetworkErrorImpl>
    implements _$$NetworkErrorImplCopyWith<$Res> {
  __$$NetworkErrorImplCopyWithImpl(
      _$NetworkErrorImpl _value, $Res Function(_$NetworkErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? details = freezed,
  }) {
    return _then(_$NetworkErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      details: freezed == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$NetworkErrorImpl implements NetworkError {
  const _$NetworkErrorImpl({required this.message, this.details});

  @override
  final String message;
  @override
  final String? details;

  @override
  String toString() {
    return 'AppError.network(message: $message, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.details, details) || other.details == details));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, details);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkErrorImplCopyWith<_$NetworkErrorImpl> get copyWith =>
      __$$NetworkErrorImplCopyWithImpl<_$NetworkErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? details) network,
    required TResult Function(String message, String? details) database,
    required TResult Function(String message, String? field) validation,
    required TResult Function(String message, String? permission) permission,
    required TResult Function(String message, String? details) unknown,
    required TResult Function(String message, int? statusCode, String? details)
        api,
  }) {
    return network(message, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? details)? network,
    TResult? Function(String message, String? details)? database,
    TResult? Function(String message, String? field)? validation,
    TResult? Function(String message, String? permission)? permission,
    TResult? Function(String message, String? details)? unknown,
    TResult? Function(String message, int? statusCode, String? details)? api,
  }) {
    return network?.call(message, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? details)? network,
    TResult Function(String message, String? details)? database,
    TResult Function(String message, String? field)? validation,
    TResult Function(String message, String? permission)? permission,
    TResult Function(String message, String? details)? unknown,
    TResult Function(String message, int? statusCode, String? details)? api,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(message, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkError value) network,
    required TResult Function(DatabaseError value) database,
    required TResult Function(ValidationError value) validation,
    required TResult Function(PermissionError value) permission,
    required TResult Function(UnknownError value) unknown,
    required TResult Function(ApiError value) api,
  }) {
    return network(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkError value)? network,
    TResult? Function(DatabaseError value)? database,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(PermissionError value)? permission,
    TResult? Function(UnknownError value)? unknown,
    TResult? Function(ApiError value)? api,
  }) {
    return network?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkError value)? network,
    TResult Function(DatabaseError value)? database,
    TResult Function(ValidationError value)? validation,
    TResult Function(PermissionError value)? permission,
    TResult Function(UnknownError value)? unknown,
    TResult Function(ApiError value)? api,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(this);
    }
    return orElse();
  }
}

abstract class NetworkError implements AppError {
  const factory NetworkError(
      {required final String message,
      final String? details}) = _$NetworkErrorImpl;

  @override
  String get message;
  String? get details;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NetworkErrorImplCopyWith<_$NetworkErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DatabaseErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$DatabaseErrorImplCopyWith(
          _$DatabaseErrorImpl value, $Res Function(_$DatabaseErrorImpl) then) =
      __$$DatabaseErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? details});
}

/// @nodoc
class __$$DatabaseErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$DatabaseErrorImpl>
    implements _$$DatabaseErrorImplCopyWith<$Res> {
  __$$DatabaseErrorImplCopyWithImpl(
      _$DatabaseErrorImpl _value, $Res Function(_$DatabaseErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? details = freezed,
  }) {
    return _then(_$DatabaseErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      details: freezed == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$DatabaseErrorImpl implements DatabaseError {
  const _$DatabaseErrorImpl({required this.message, this.details});

  @override
  final String message;
  @override
  final String? details;

  @override
  String toString() {
    return 'AppError.database(message: $message, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DatabaseErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.details, details) || other.details == details));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, details);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DatabaseErrorImplCopyWith<_$DatabaseErrorImpl> get copyWith =>
      __$$DatabaseErrorImplCopyWithImpl<_$DatabaseErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? details) network,
    required TResult Function(String message, String? details) database,
    required TResult Function(String message, String? field) validation,
    required TResult Function(String message, String? permission) permission,
    required TResult Function(String message, String? details) unknown,
    required TResult Function(String message, int? statusCode, String? details)
        api,
  }) {
    return database(message, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? details)? network,
    TResult? Function(String message, String? details)? database,
    TResult? Function(String message, String? field)? validation,
    TResult? Function(String message, String? permission)? permission,
    TResult? Function(String message, String? details)? unknown,
    TResult? Function(String message, int? statusCode, String? details)? api,
  }) {
    return database?.call(message, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? details)? network,
    TResult Function(String message, String? details)? database,
    TResult Function(String message, String? field)? validation,
    TResult Function(String message, String? permission)? permission,
    TResult Function(String message, String? details)? unknown,
    TResult Function(String message, int? statusCode, String? details)? api,
    required TResult orElse(),
  }) {
    if (database != null) {
      return database(message, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkError value) network,
    required TResult Function(DatabaseError value) database,
    required TResult Function(ValidationError value) validation,
    required TResult Function(PermissionError value) permission,
    required TResult Function(UnknownError value) unknown,
    required TResult Function(ApiError value) api,
  }) {
    return database(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkError value)? network,
    TResult? Function(DatabaseError value)? database,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(PermissionError value)? permission,
    TResult? Function(UnknownError value)? unknown,
    TResult? Function(ApiError value)? api,
  }) {
    return database?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkError value)? network,
    TResult Function(DatabaseError value)? database,
    TResult Function(ValidationError value)? validation,
    TResult Function(PermissionError value)? permission,
    TResult Function(UnknownError value)? unknown,
    TResult Function(ApiError value)? api,
    required TResult orElse(),
  }) {
    if (database != null) {
      return database(this);
    }
    return orElse();
  }
}

abstract class DatabaseError implements AppError {
  const factory DatabaseError(
      {required final String message,
      final String? details}) = _$DatabaseErrorImpl;

  @override
  String get message;
  String? get details;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DatabaseErrorImplCopyWith<_$DatabaseErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ValidationErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$ValidationErrorImplCopyWith(_$ValidationErrorImpl value,
          $Res Function(_$ValidationErrorImpl) then) =
      __$$ValidationErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? field});
}

/// @nodoc
class __$$ValidationErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$ValidationErrorImpl>
    implements _$$ValidationErrorImplCopyWith<$Res> {
  __$$ValidationErrorImplCopyWithImpl(
      _$ValidationErrorImpl _value, $Res Function(_$ValidationErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? field = freezed,
  }) {
    return _then(_$ValidationErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      field: freezed == field
          ? _value.field
          : field // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ValidationErrorImpl implements ValidationError {
  const _$ValidationErrorImpl({required this.message, this.field});

  @override
  final String message;
  @override
  final String? field;

  @override
  String toString() {
    return 'AppError.validation(message: $message, field: $field)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidationErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.field, field) || other.field == field));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, field);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidationErrorImplCopyWith<_$ValidationErrorImpl> get copyWith =>
      __$$ValidationErrorImplCopyWithImpl<_$ValidationErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? details) network,
    required TResult Function(String message, String? details) database,
    required TResult Function(String message, String? field) validation,
    required TResult Function(String message, String? permission) permission,
    required TResult Function(String message, String? details) unknown,
    required TResult Function(String message, int? statusCode, String? details)
        api,
  }) {
    return validation(message, field);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? details)? network,
    TResult? Function(String message, String? details)? database,
    TResult? Function(String message, String? field)? validation,
    TResult? Function(String message, String? permission)? permission,
    TResult? Function(String message, String? details)? unknown,
    TResult? Function(String message, int? statusCode, String? details)? api,
  }) {
    return validation?.call(message, field);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? details)? network,
    TResult Function(String message, String? details)? database,
    TResult Function(String message, String? field)? validation,
    TResult Function(String message, String? permission)? permission,
    TResult Function(String message, String? details)? unknown,
    TResult Function(String message, int? statusCode, String? details)? api,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(message, field);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkError value) network,
    required TResult Function(DatabaseError value) database,
    required TResult Function(ValidationError value) validation,
    required TResult Function(PermissionError value) permission,
    required TResult Function(UnknownError value) unknown,
    required TResult Function(ApiError value) api,
  }) {
    return validation(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkError value)? network,
    TResult? Function(DatabaseError value)? database,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(PermissionError value)? permission,
    TResult? Function(UnknownError value)? unknown,
    TResult? Function(ApiError value)? api,
  }) {
    return validation?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkError value)? network,
    TResult Function(DatabaseError value)? database,
    TResult Function(ValidationError value)? validation,
    TResult Function(PermissionError value)? permission,
    TResult Function(UnknownError value)? unknown,
    TResult Function(ApiError value)? api,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(this);
    }
    return orElse();
  }
}

abstract class ValidationError implements AppError {
  const factory ValidationError(
      {required final String message,
      final String? field}) = _$ValidationErrorImpl;

  @override
  String get message;
  String? get field;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValidationErrorImplCopyWith<_$ValidationErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PermissionErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$PermissionErrorImplCopyWith(_$PermissionErrorImpl value,
          $Res Function(_$PermissionErrorImpl) then) =
      __$$PermissionErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? permission});
}

/// @nodoc
class __$$PermissionErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$PermissionErrorImpl>
    implements _$$PermissionErrorImplCopyWith<$Res> {
  __$$PermissionErrorImplCopyWithImpl(
      _$PermissionErrorImpl _value, $Res Function(_$PermissionErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? permission = freezed,
  }) {
    return _then(_$PermissionErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      permission: freezed == permission
          ? _value.permission
          : permission // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$PermissionErrorImpl implements PermissionError {
  const _$PermissionErrorImpl({required this.message, this.permission});

  @override
  final String message;
  @override
  final String? permission;

  @override
  String toString() {
    return 'AppError.permission(message: $message, permission: $permission)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PermissionErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.permission, permission) ||
                other.permission == permission));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, permission);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PermissionErrorImplCopyWith<_$PermissionErrorImpl> get copyWith =>
      __$$PermissionErrorImplCopyWithImpl<_$PermissionErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? details) network,
    required TResult Function(String message, String? details) database,
    required TResult Function(String message, String? field) validation,
    required TResult Function(String message, String? permission) permission,
    required TResult Function(String message, String? details) unknown,
    required TResult Function(String message, int? statusCode, String? details)
        api,
  }) {
    return permission(message, this.permission);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? details)? network,
    TResult? Function(String message, String? details)? database,
    TResult? Function(String message, String? field)? validation,
    TResult? Function(String message, String? permission)? permission,
    TResult? Function(String message, String? details)? unknown,
    TResult? Function(String message, int? statusCode, String? details)? api,
  }) {
    return permission?.call(message, this.permission);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? details)? network,
    TResult Function(String message, String? details)? database,
    TResult Function(String message, String? field)? validation,
    TResult Function(String message, String? permission)? permission,
    TResult Function(String message, String? details)? unknown,
    TResult Function(String message, int? statusCode, String? details)? api,
    required TResult orElse(),
  }) {
    if (permission != null) {
      return permission(message, this.permission);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkError value) network,
    required TResult Function(DatabaseError value) database,
    required TResult Function(ValidationError value) validation,
    required TResult Function(PermissionError value) permission,
    required TResult Function(UnknownError value) unknown,
    required TResult Function(ApiError value) api,
  }) {
    return permission(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkError value)? network,
    TResult? Function(DatabaseError value)? database,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(PermissionError value)? permission,
    TResult? Function(UnknownError value)? unknown,
    TResult? Function(ApiError value)? api,
  }) {
    return permission?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkError value)? network,
    TResult Function(DatabaseError value)? database,
    TResult Function(ValidationError value)? validation,
    TResult Function(PermissionError value)? permission,
    TResult Function(UnknownError value)? unknown,
    TResult Function(ApiError value)? api,
    required TResult orElse(),
  }) {
    if (permission != null) {
      return permission(this);
    }
    return orElse();
  }
}

abstract class PermissionError implements AppError {
  const factory PermissionError(
      {required final String message,
      final String? permission}) = _$PermissionErrorImpl;

  @override
  String get message;
  String? get permission;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PermissionErrorImplCopyWith<_$PermissionErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnknownErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$UnknownErrorImplCopyWith(
          _$UnknownErrorImpl value, $Res Function(_$UnknownErrorImpl) then) =
      __$$UnknownErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? details});
}

/// @nodoc
class __$$UnknownErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$UnknownErrorImpl>
    implements _$$UnknownErrorImplCopyWith<$Res> {
  __$$UnknownErrorImplCopyWithImpl(
      _$UnknownErrorImpl _value, $Res Function(_$UnknownErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? details = freezed,
  }) {
    return _then(_$UnknownErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      details: freezed == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$UnknownErrorImpl implements UnknownError {
  const _$UnknownErrorImpl({required this.message, this.details});

  @override
  final String message;
  @override
  final String? details;

  @override
  String toString() {
    return 'AppError.unknown(message: $message, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnknownErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.details, details) || other.details == details));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, details);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnknownErrorImplCopyWith<_$UnknownErrorImpl> get copyWith =>
      __$$UnknownErrorImplCopyWithImpl<_$UnknownErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? details) network,
    required TResult Function(String message, String? details) database,
    required TResult Function(String message, String? field) validation,
    required TResult Function(String message, String? permission) permission,
    required TResult Function(String message, String? details) unknown,
    required TResult Function(String message, int? statusCode, String? details)
        api,
  }) {
    return unknown(message, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? details)? network,
    TResult? Function(String message, String? details)? database,
    TResult? Function(String message, String? field)? validation,
    TResult? Function(String message, String? permission)? permission,
    TResult? Function(String message, String? details)? unknown,
    TResult? Function(String message, int? statusCode, String? details)? api,
  }) {
    return unknown?.call(message, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? details)? network,
    TResult Function(String message, String? details)? database,
    TResult Function(String message, String? field)? validation,
    TResult Function(String message, String? permission)? permission,
    TResult Function(String message, String? details)? unknown,
    TResult Function(String message, int? statusCode, String? details)? api,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(message, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkError value) network,
    required TResult Function(DatabaseError value) database,
    required TResult Function(ValidationError value) validation,
    required TResult Function(PermissionError value) permission,
    required TResult Function(UnknownError value) unknown,
    required TResult Function(ApiError value) api,
  }) {
    return unknown(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkError value)? network,
    TResult? Function(DatabaseError value)? database,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(PermissionError value)? permission,
    TResult? Function(UnknownError value)? unknown,
    TResult? Function(ApiError value)? api,
  }) {
    return unknown?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkError value)? network,
    TResult Function(DatabaseError value)? database,
    TResult Function(ValidationError value)? validation,
    TResult Function(PermissionError value)? permission,
    TResult Function(UnknownError value)? unknown,
    TResult Function(ApiError value)? api,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(this);
    }
    return orElse();
  }
}

abstract class UnknownError implements AppError {
  const factory UnknownError(
      {required final String message,
      final String? details}) = _$UnknownErrorImpl;

  @override
  String get message;
  String? get details;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnknownErrorImplCopyWith<_$UnknownErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ApiErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$ApiErrorImplCopyWith(
          _$ApiErrorImpl value, $Res Function(_$ApiErrorImpl) then) =
      __$$ApiErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, int? statusCode, String? details});
}

/// @nodoc
class __$$ApiErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$ApiErrorImpl>
    implements _$$ApiErrorImplCopyWith<$Res> {
  __$$ApiErrorImplCopyWithImpl(
      _$ApiErrorImpl _value, $Res Function(_$ApiErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? statusCode = freezed,
    Object? details = freezed,
  }) {
    return _then(_$ApiErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      statusCode: freezed == statusCode
          ? _value.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int?,
      details: freezed == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ApiErrorImpl implements ApiError {
  const _$ApiErrorImpl({required this.message, this.statusCode, this.details});

  @override
  final String message;
  @override
  final int? statusCode;
  @override
  final String? details;

  @override
  String toString() {
    return 'AppError.api(message: $message, statusCode: $statusCode, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode) &&
            (identical(other.details, details) || other.details == details));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, statusCode, details);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiErrorImplCopyWith<_$ApiErrorImpl> get copyWith =>
      __$$ApiErrorImplCopyWithImpl<_$ApiErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message, String? details) network,
    required TResult Function(String message, String? details) database,
    required TResult Function(String message, String? field) validation,
    required TResult Function(String message, String? permission) permission,
    required TResult Function(String message, String? details) unknown,
    required TResult Function(String message, int? statusCode, String? details)
        api,
  }) {
    return api(message, statusCode, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, String? details)? network,
    TResult? Function(String message, String? details)? database,
    TResult? Function(String message, String? field)? validation,
    TResult? Function(String message, String? permission)? permission,
    TResult? Function(String message, String? details)? unknown,
    TResult? Function(String message, int? statusCode, String? details)? api,
  }) {
    return api?.call(message, statusCode, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, String? details)? network,
    TResult Function(String message, String? details)? database,
    TResult Function(String message, String? field)? validation,
    TResult Function(String message, String? permission)? permission,
    TResult Function(String message, String? details)? unknown,
    TResult Function(String message, int? statusCode, String? details)? api,
    required TResult orElse(),
  }) {
    if (api != null) {
      return api(message, statusCode, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkError value) network,
    required TResult Function(DatabaseError value) database,
    required TResult Function(ValidationError value) validation,
    required TResult Function(PermissionError value) permission,
    required TResult Function(UnknownError value) unknown,
    required TResult Function(ApiError value) api,
  }) {
    return api(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkError value)? network,
    TResult? Function(DatabaseError value)? database,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(PermissionError value)? permission,
    TResult? Function(UnknownError value)? unknown,
    TResult? Function(ApiError value)? api,
  }) {
    return api?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkError value)? network,
    TResult Function(DatabaseError value)? database,
    TResult Function(ValidationError value)? validation,
    TResult Function(PermissionError value)? permission,
    TResult Function(UnknownError value)? unknown,
    TResult Function(ApiError value)? api,
    required TResult orElse(),
  }) {
    if (api != null) {
      return api(this);
    }
    return orElse();
  }
}

abstract class ApiError implements AppError {
  const factory ApiError(
      {required final String message,
      final int? statusCode,
      final String? details}) = _$ApiErrorImpl;

  @override
  String get message;
  int? get statusCode;
  String? get details;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApiErrorImplCopyWith<_$ApiErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
