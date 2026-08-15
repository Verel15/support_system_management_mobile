// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/data/datasources/auth_remote_datasource.dart'
    as _i161;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/logout_usecase.dart' as _i48;
import '../../features/auth/domain/usecases/restore_session_usecase.dart'
    as _i90;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../network/auth_session.dart' as _i195;
import '../network/dio_client.dart' as _i667;
import '../network/interceptors/auth_interceptor.dart' as _i745;
import '../network/secure_token_storage.dart' as _i547;
import '../network/token_refresher.dart' as _i1058;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt init(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final networkModule = _$NetworkModule();
  gh.lazySingleton<_i195.AuthSession>(() => _i195.AuthSession());
  gh.lazySingleton<_i547.SecureTokenStorage>(() => _i547.SecureTokenStorage());
  gh.lazySingleton<_i1058.TokenRefresher>(
    () => _i1058.TokenRefresher(
      gh<_i195.AuthSession>(),
      gh<_i547.SecureTokenStorage>(),
    ),
  );
  gh.factory<_i745.AuthInterceptor>(
    () => _i745.AuthInterceptor(
      gh<_i195.AuthSession>(),
      gh<_i1058.TokenRefresher>(),
      gh<_i547.SecureTokenStorage>(),
    ),
  );
  gh.lazySingleton<_i361.Dio>(
    () => networkModule.dio(gh<_i745.AuthInterceptor>()),
  );
  gh.factory<_i161.AuthRemoteDataSource>(
    () => _i161.AuthRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.factory<_i787.AuthRepository>(
    () => _i153.AuthRepositoryImpl(
      gh<_i161.AuthRemoteDataSource>(),
      gh<_i195.AuthSession>(),
      gh<_i547.SecureTokenStorage>(),
      gh<_i1058.TokenRefresher>(),
    ),
  );
  gh.factory<_i188.LoginUseCase>(
    () => _i188.LoginUseCase(gh<_i787.AuthRepository>()),
  );
  gh.factory<_i48.LogoutUseCase>(
    () => _i48.LogoutUseCase(gh<_i787.AuthRepository>()),
  );
  gh.factory<_i90.RestoreSessionUseCase>(
    () => _i90.RestoreSessionUseCase(gh<_i787.AuthRepository>()),
  );
  gh.factory<_i797.AuthBloc>(
    () => _i797.AuthBloc(
      gh<_i188.LoginUseCase>(),
      gh<_i48.LogoutUseCase>(),
      gh<_i90.RestoreSessionUseCase>(),
      gh<_i195.AuthSession>(),
    ),
  );
  return getIt;
}

class _$NetworkModule extends _i667.NetworkModule {}
