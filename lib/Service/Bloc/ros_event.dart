// import 'package:flutter/foundation.dart' show immutable;

typedef SubscribeHandler = Future<void> Function(Map<String, dynamic> args);
typedef ParamHandler = Future<void> Function(Map<String, dynamic> args);

// @immutable
abstract class RosEvent {
  const RosEvent();
}

class RosInitEvent extends RosEvent {
  const RosInitEvent();
}

class RosConnectEvent extends RosEvent {
  final String addr;
  final String port;
  const RosConnectEvent(this.addr, this.port);
}

class RosDisconnectEvent extends RosEvent {
  const RosDisconnectEvent();
}

class RosPublishEvent extends RosEvent {
  final String topic;
  final String datatype;
  final Map<String, dynamic> json;
  const RosPublishEvent(this.topic, this.datatype, this.json);
}

class RosSubsribeEvent extends RosEvent {
  final SubscribeHandler handler;
  final String topic;
  final String datatype;
  RosSubsribeEvent(this.handler, this.topic, this.datatype);
}

class RosGetParamEvent extends RosEvent {
  final String paramName;
  final ParamHandler handler;
  const RosGetParamEvent(this.paramName, this.handler);
}

class RosSetParamEvent extends RosEvent {
  final String paramName;
  final dynamic data;
  const RosSetParamEvent(this.paramName, this.data);
}
