import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class RosState {
  const RosState();
}

class RosStateUninitialize extends RosState {
  const RosStateUninitialize();
}

class RosStateConnected extends RosState {
  const RosStateConnected();
}

class RosStateConnectFailure extends RosState {
  final Exception exception;
  const RosStateConnectFailure({required this.exception});
}

class RosStateDisconnected extends RosState with EquatableMixin {
  final bool isLoading;
  const RosStateDisconnected({required this.isLoading});

  @override
  List<Object?> get props => [isLoading];
}

class RosStateDisconnectFailure extends RosState {
  final Exception exception;
  const RosStateDisconnectFailure(this.exception);
}
