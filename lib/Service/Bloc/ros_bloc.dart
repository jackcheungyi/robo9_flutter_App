import 'package:bloc/bloc.dart';
import 'package:robo9_mobile_app/Service/Bloc/ros_event.dart';
import 'package:robo9_mobile_app/Service/Bloc/ros_state.dart';
import 'package:robo9_mobile_app/Service/ros_provider.dart';

class RosBloc extends Bloc<RosEvent, RosState> {
  RosBloc(RosProvider provider) : super(const RosStateUninitialize()) {
    //initialize ros
    on<RosInitEvent>((event, emit) {
      emit(
        const RosStateDisconnected(isLoading: false),
      );
    });

    //connect ros
    on<RosConnectEvent>((event, emit) async {
      emit(
        const RosStateDisconnected(isLoading: true),
      );
      // await Future.delayed(const Duration(seconds: 3));
      final addr = event.addr;
      final port = event.port;
      try {
        await provider.connect(address: addr, port: port);
        // final ros_ = provider.ros;
        emit(const RosStateConnected());
      } on Exception catch (e) {
        //catching connection errors
        emit(RosStateConnectFailure(exception: e));
      }
    });

    //disconnect ros
    on<RosDisconnectEvent>((event, emit) async {
      // emit(
      //   const RosStateDisconnected(isLoading: true),
      // );

      try {
        await provider.disconnect();
        emit(const RosStateDisconnected(isLoading: false));
      } on Exception catch (e) {
        emit(RosStateDisconnectFailure(e));
      }
    });

    on<RosPublishEvent>((event, emit) async {
      try {
        await provider.publishToTopic(
            topicName: event.topic, dataType: event.datatype, json: event.json);
      } on Exception catch (e) {
        emit(RosStateDisconnectFailure(e));
      }
    });

    on<RosSubsribeEvent>((event, emit) async {
      try {
        // String data = '';
        await provider.subscribeToTopic(
            topicName: event.topic,
            dataType: event.datatype,
            handler: event.handler);
        await Future.delayed(const Duration(seconds: 1));
        // if (provider.msgReviced != '') {
        //   // print("emiting rosstate with new data");
        //   // print("new data :");
        //   // print(provider.msgReviced);
        //   emit(RosStateConnected(event.topicID, provider.msgReviced));
        // }
        // emit(RosStateConnected(event.topicID, data));
      } on Exception catch (e) {
        emit(RosStateDisconnectFailure(e));
      }
    });

    on<RosSetParamEvent>((event, emit) async {
      await provider.setParam(name: event.paramName, data: event.data);
    });

    on<RosGetParamEvent>((event, emit) async {
      await provider.getParam(
          paramHandler: event.handler, name: event.paramName);
    });
  }
}
