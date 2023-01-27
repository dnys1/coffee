import 'package:aws_common/aws_common.dart';
import 'package:riverpod/riverpod.dart';

/// The [Provider] for [AWSHttpClient].
final httpClientProvider = Provider(
  (ref) {
    final client = AWSHttpClient();
    ref.onDispose(client.close);
    return client;
  },
  name: 'httpClient',
);
