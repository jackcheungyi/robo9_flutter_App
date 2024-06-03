import 'dart:async';
import 'dart:convert';

// import 'dart:ffi';
import 'package:robo9_mobile_app/Service/ros_exceptions.dart';
import 'package:roslibdart/roslibdart.dart';

typedef SubscribeHandler = Future<void> Function(Map<String, dynamic> args);
typedef ParamHandler = Future<void> Function(Map<String, dynamic> args);

class RosProvider {
  Ros? _ros;
  String? _msgReviced;
  Ros? get ros => _ros;
  String? get msgReviced => _msgReviced;
  dynamic _subcription;
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  int clientCount = 0;

  Future<void> ClientCountHandler(Map<String, dynamic> msg) async {
    clientCount = msg['data'];
  }

  Future<Ros> connect({required String address, required String port}) {
    String urlLink = 'ws://$address:$port';
    Completer<Ros> completer = Completer<Ros>();
    // print("url_link : $urlLink");
    if (_isConnected == false) {
      try {
        _ros = Ros(url: urlLink);
        Status localState = Status.none;
        _subcription = _ros!.statusStream.listen((status) {
          // print("inside stream listener");
          // print(status.toString());
          localState = status;
          if (status == Status.errored) {
            _isConnected = false;
          } else if (status == Status.closed) {
            _isConnected = false;
            _ros = null;
          }
        });
        // print("Trying to connect");
        _ros!.connect();
        Timer(const Duration(seconds: 1), () async {
          // print("inside timer");
          // print(localState.toString());
          Topic chatter = Topic(
              ros: _ros!,
              name: '/client_count',
              type: 'std_msgs/Int32',
              queueLength: 1,
              queueSize: 1);
          chatter.subscribe(ClientCountHandler);
          await Future.delayed(const Duration(seconds: 2));
          if (localState == Status.errored) {
            completer.completeError(RosConnectionException());
          } else if (localState == Status.closed) {
            completer.completeError(RosConnectionException());
          } else if (localState == Status.connected) {
            _isConnected = true;
            if (clientCount == 0) {
              completer.completeError(RosConnectionException());
            } else if (clientCount > 1) {
              completer.completeError(RosConnectionException());
            } else if (clientCount == 1) {
              completer.complete(_ros!);
            } else {
              completer.completeError(RosConnectionException());
            }
          }
        });
        // completer.completeError(RosConnectionException());
        return completer.future;
      } catch (_) {
        throw RosGeneralException();
      }
    } else {
      throw RosAlreadyConnectedException();
    }
  }

  Future<void> disconnect() async {
    if (_isConnected) {
      _subcription?.cancel();
      await _ros!.close();
      _isConnected = false;
    } else {
      throw RosCloseException();
    }
  }

  Topic createTopic(
      {required Ros ros, required String topicName, required String dataType}) {
    return Topic(
        ros: ros,
        name: topicName,
        type: dataType,
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10);
  }

  Future<void> publishToTopic(
      {required String topicName,
      required String dataType,
      required Map<String, dynamic> json}) async {
    Topic chatter = Topic(
        ros: _ros!,
        name: topicName,
        type: dataType,
        queueLength: 10,
        queueSize: 1);
    await chatter.publish(json);
  }

  Future<void> subscribeToTopic(
      {required String topicName,
      required String dataType,
      required SubscribeHandler handler,
      int queueSize = 10,
      int queueLength = 10}) async {
    Topic chatter = Topic(
        ros: _ros!,
        name: topicName,
        type: dataType,
        queueLength: queueLength,
        queueSize: queueSize);

    await chatter.subscribe(handler);
  }

  // Future<void> subscribeHandler(Map<String, dynamic> msg, String data) async {
  //   data = json.encode(msg);
  // }

  Future<void> getParam(
      {required String name, required ParamHandler paramHandler}) async {
    Map<String, dynamic> param = await Param(ros: _ros!, name: name).get();
    // Map<String, dynamic> data = jsonDecode(param);
    // print("data receive in ros provider is ${param}");
    await paramHandler(param);
  }

  Future<void> setParam({required String name, required dynamic data}) async {
    String jsondata = json.encode(data);
    await Param(ros: _ros!, name: name).set(jsondata);
  }
}
