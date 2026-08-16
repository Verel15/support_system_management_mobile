// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cookie_jar/cookie_jar.dart' as _i557;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../data/repositories/auth_repository.dart' as _i481;
import '../../data/services/auth_service.dart' as _i117;
import '../../ui/auth/bloc/auth_bloc.dart' as _i842;
import '../network/auth_session.dart' as _i195;
import '../network/dio_client.dart' as _i667;
import '../network/interceptors/auth_interceptor.dart' as _i745;
import '../network/token_refresher.dart' as _i1058;
import '../storage/onboarding_storage.dart' as _i84;
import '../storage/shared_preferences_module.dart' as _i737;

// initializes the registration of main-scope dependencies inside of GetIt
Future<_i174.GetIt> init(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final networkModule = _$NetworkModule();
  final sharedPreferencesModule = _$SharedPreferencesModule();
  gh.lazySingleton<_i195.AuthSession>(() => _i195.AuthSession());
  await gh.lazySingletonAsync<_i557.CookieJar>(
    () => networkModule.cookieJar(),
    preResolve: true,
  );
  await gh.lazySingletonAsync<_i460.SharedPreferences>(
    () => sharedPreferencesModule.prefs,
    preResolve: true,
  );
  gh.lazySingleton<_i1058.TokenRefresher>(
    () => _i1058.TokenRefresher(gh<_i195.AuthSession>(), gh<_i557.CookieJar>()),
  );
  gh.lazySingleton<_i84.OnboardingStorage>(
    () => _i84.OnboardingStorage(gh<_i460.SharedPreferences>()),
  );
  gh.factory<_i745.AuthInterceptor>(
    () => _i745.AuthInterceptor(
      gh<_i195.AuthSession>(),
      gh<_i1058.TokenRefresher>(),
    ),
  );
  gh.lazySingleton<_i361.Dio>(
    () => networkModule.dio(gh<_i745.AuthInterceptor>(), gh<_i557.CookieJar>()),
  );
  gh.factory<_i117.AuthApiService>(
    () => _i117.AuthApiServiceImpl(gh<_i361.Dio>()),
  );
  gh.factory<_i481.AuthRepository>(
    () => _i481.AuthRepository(
      gh<_i117.AuthApiService>(),
      gh<_i195.AuthSession>(),
      gh<_i1058.TokenRefresher>(),
    ),
  );
  gh.factory<_i842.AuthBloc>(
    () => _i842.AuthBloc(gh<_i481.AuthRepository>(), gh<_i195.AuthSession>()),
  );
  return getIt;
}

class _$NetworkModule extends _i667.NetworkModule {}

class _$SharedPreferencesModule extends _i737.SharedPreferencesModule {}
