class ApiPaths {
  ApiPaths._();

  static const String login = '/api/v1/auth/login';
  static const String refresh = '/api/v1/auth/refresh';
  static const String logout = '/api/v1/auth/logout';
  static const String me = '/api/v1/auth/me';

  static const String tickets = '/tickets';
  static String ticketById(String id) => '/tickets/$id';
}
