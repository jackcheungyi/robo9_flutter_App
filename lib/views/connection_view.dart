import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:robo9_mobile_app/Service/Bloc/ros_bloc.dart';
import 'package:robo9_mobile_app/Service/Bloc/ros_event.dart';
import 'package:robo9_mobile_app/Service/Bloc/ros_state.dart';
import 'package:robo9_mobile_app/Service/ros_exceptions.dart';
import 'package:robo9_mobile_app/Utilities/error_dialog.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});

  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  late final TextEditingController _address;
  late final TextEditingController _port;
  late bool _isLoading = false;
  bool _isConnected = false;
  var logger = Logger(level: Level.debug);
  // late Ros? _ros;

  @override
  void initState() {
    _address = TextEditingController();
    _port = TextEditingController();
    logger.d('connection view inited');
    super.initState();
  }

  @override
  void dispose() {
    _address.dispose();
    _port.dispose();
    logger.d('controller view disposed');
    super.dispose();
  }

  Widget connectBtn(bool isConnected, bool isLoading) {
    logger.d("connectBtn function called");
    Widget btn_icon;
    Widget btn_label;

    if (isLoading) {
      return const CircularProgressIndicator(
        color: Colors.blue,
      );
    }

    // if (isConnected) {
    //   btn_icon = const Icon(Icons.link_off);
    //   btn_label = const Text('disconnect');
    // } else {
    btn_icon = const Icon(Icons.settings_remote);
    btn_label = const Text('connect');
    // }

    return TextButton.icon(
        onPressed: () async {
          if (isConnected == false) {
            final ipAddr = _address.text;
            final port = _port.text;
            logger.d(
                "on pressed trigger should connect and state is :$isConnected ");

            context.read<RosBloc>().add(RosConnectEvent(ipAddr, port));
            // setState(() {});
          } else {
            logger.d(
                "on pressed trigger should disconnect and state is :$isConnected ");
            context.read<RosBloc>().add(const RosDisconnectEvent());

            // setState(() {});
          }
        },
        icon: btn_icon,
        label: btn_label);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RosBloc, RosState>(
      listener: (context, state) async {
        // TODO: implement listener
        if (state is RosStateDisconnected) {
          _isConnected = false;
          if (state.isLoading) {
            _isLoading = true;
          } else {
            _isLoading = false;
          }
          setState(() {});
        } else if (state is RosStateConnectFailure) {
          _isLoading = false;
          _isConnected = false;
          if (state.exception is RosGeneralException) {
            await showErrorDialog(context, "Invalid Input");
          } else if (state.exception is RosConnectionException) {
            await showErrorDialog(context, "Connection Error");
          }
          setState(() {});
        } else {
          _isLoading = false;
          _isConnected = true;
        }
        logger.i("isLoading : $_isLoading && isConnected : $_isConnected");
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Connection',
            style: TextStyle(color: Colors.white),
          ),
          // leading: ,
          backgroundColor: Colors.green,
        ),
        // drawer: const Drawer_Side(),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: TextField(
                controller: _address,
                enableSuggestions: false,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    hintText: 'Enter IP address',
                    labelText: 'Address ',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromRGBO(0, 100, 200, 100),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: TextField(
                controller: _port,
                enableSuggestions: false,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    hintText: 'Enter Port number',
                    labelText: 'Port ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    )),
              ),
            ),
            connectBtn(_isConnected, _isLoading),
          ]),
        ),
      ),
    );
  }
}
