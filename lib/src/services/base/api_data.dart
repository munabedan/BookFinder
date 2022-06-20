

class APIData {
  static const host = 'www.googleapis.com';
  static const String scheme = 'https';
  static const apiKey = 'AIzaSyB8cf6RiyGKz_wTwxJjf4pUAJv_OjZRqTg';

  static Uri baseUri() => Uri(scheme: scheme, host: host, path: '');

  static Uri errorUri() => Uri(scheme: scheme, host: host, path: '/nopath');

  static Uri fetchBooks({String? query}) => Uri(
        scheme: scheme,
        host: host,
        path: 'books/v1/volumes',
        query: query,
      );
}
