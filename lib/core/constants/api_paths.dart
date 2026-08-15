class ApiPaths {
  ApiPaths._();

  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  static const String tickets = '/tickets';
  static String ticketById(String id) => '/tickets/$id';
}
