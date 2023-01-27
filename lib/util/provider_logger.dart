import 'package:aws_common/aws_common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// {@template util.provider_logger}
/// Logs [Provider] updates and disposes for debugging purposes.
/// {@endtemplate}
class ProviderLogger extends ProviderObserver {
  /// {@macro util.provider_logger}
  const ProviderLogger();

  static final _logger = AWSLogger().createChild('ProviderLogger');

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    final providerName = provider.name ?? provider.runtimeType.toString();
    final update = _ProviderUpdate(
      providerName,
      previousValue,
      newValue,
    );
    _logger.verbose('didUpdateProvider: $update');
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    final providerName = provider.name ?? provider.runtimeType.toString();
    _logger.debug('didDisposeProvider: $providerName');
  }
}

class _ProviderUpdate
    with
        AWSEquatable<_ProviderUpdate>,
        AWSSerializable<Map<String, Object?>>,
        AWSDebuggable {
  _ProviderUpdate(this.providerName, this.previousValue, this.newValue);

  final String providerName;
  final Object? previousValue;
  final Object? newValue;

  @override
  List<Object?> get props => [providerName, previousValue, newValue];

  @override
  String get runtimeTypeName => 'ProviderUpdate';

  @override
  Map<String, Object?> toJson() => {
        'name': providerName,
        if (previousValue != null) 'previousValue': '$previousValue',
        'newValue': '$newValue',
      };
}
