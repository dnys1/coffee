/// The base URL for the coffee API.
///
/// In order to use the API on web, a proxy must be used since the original API
/// does not send CORS headers. If no proxy is provided, the original URL is
/// used, but the application will not work on web.
final baseUrl = Uri.parse(
  const String.fromEnvironment(
    'PROXY_URL',
    defaultValue: 'https://coffee.alexflipnote.dev/',
  ),
);
