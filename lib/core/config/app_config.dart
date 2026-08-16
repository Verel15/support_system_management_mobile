enum Flavor { dev, staging, prod }

class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const bool enableNetworkLogs = bool.fromEnvironment(
    'ENABLE_NETWORK_LOGS',
    defaultValue: true,
  );

  static const String _flavorName = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  static final Flavor flavor = switch (_flavorName) {
    'staging' => Flavor.staging,
    'prod' => Flavor.prod,
    _ => Flavor.dev,
  };
}
