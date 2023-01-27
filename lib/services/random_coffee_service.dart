import 'dart:async';
import 'dart:convert';

import 'package:aws_common/aws_common.dart';
import 'package:coffee/environment.dart';
import 'package:coffee/services/http.dart';
import 'package:riverpod/riverpod.dart';

/// A [Provider] for [RandomCoffeeService].
final randomCoffeeService = Provider<RandomCoffeeService>(
  (ref) => _RemoteRandomCoffeeService(
    ref.watch(httpClientProvider),
  ),
  name: 'randomCoffeeService',
);

/// A service which provides random coffee images.
abstract class RandomCoffeeService {
  /// Returns a random coffee image URL.
  Future<String> getRandomCoffee();
}

class _RemoteRandomCoffeeService implements RandomCoffeeService {
  _RemoteRandomCoffeeService(this._client);

  static final _url = baseUrl.replace(path: '/random.json');
  final AWSHttpClient _client;

  @override
  Future<String> getRandomCoffee() async {
    final request = AWSHttpRequest.get(_url);
    final response = await _client.send(request).response;
    final responseBody = await response.decodeBody();
    if (response.statusCode != 200) {
      throw AWSHttpException(request, 'Failed to get coffee: $responseBody');
    }
    final responseJson = jsonDecode(responseBody) as Map<String, Object?>;
    final fileUrl = Uri.parse(responseJson['file'] as String);
    return fileUrl.replace(host: baseUrl.host).toString();
  }
}
