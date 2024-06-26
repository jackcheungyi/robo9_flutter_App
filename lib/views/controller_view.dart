// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_joystick/flutter_joystick.dart';
// import 'package:robo9_mobile_app/Service/Bloc/ros_bloc.dart';
// import 'package:robo9_mobile_app/Service/Bloc/ros_event.dart';
// import 'package:robo9_mobile_app/Service/Bloc/ros_state.dart';
// import 'package:robo9_mobile_app/Utilities/disconnect_dialog.dart';

// enum MenuAction { Disconnect }

// class ControllerPage extends StatefulWidget {
//   const ControllerPage({super.key});

//   @override
//   State<ControllerPage> createState() => _ControllerPageState();
// }

// class _ControllerPageState extends State<ControllerPage> {
//   String data = '';

//   Future<void> subscribeHandler(Map<String, dynamic> msg) async {
//     data = json.encode(msg);
//     // print("handler called in controller view : $data");
//     setState(() {});
//   }

//   @override
//   void initState() {
//     super.initState();

//     // Timer(const Duration(seconds: 1), () {
//     // print("call rossub....");
//     context.read<RosBloc>().add(
//         RosSubsribeEvent(subscribeHandler, '/client_count', 'std_msgs/Int32'));
//     // });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Timer.periodic(const Duration(seconds: 10), (Timer timer) {
//     //   print("call rossub....");
//     //   context
//     //       .read<RosBloc>()
//     //       .add(const RosSubsribeEvent(0, '/client_count', 'std_msgs/Int32'));
//     // });
//     // Timer(const Duration(seconds: 10), () {
//     //   // print("call rossub....");
//     //   context
//     //       .read<RosBloc>()
//     //       .add(const RosSubsribeEvent(0, '/client_count', 'std_msgs/Int32'));
//     // });

//     return BlocListener<RosBloc, RosState>(
//       listener: (context, state) {
//         // TODO: implement listener

//         // if (state is RosStateConnected) {
//         //   if (state.id == 0) {
//         //     // print("should have incoming data");
//         //     data = state.msg!;
//         //     // print(data);
//         //     setState(() {});
//         //   }
//         // }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'Controller',
//             style: TextStyle(color: Colors.white),
//           ),
//           backgroundColor: Colors.purple,
//           actions: [
//             PopupMenuButton<MenuAction>(
//               color: Colors.white,
//               onSelected: (value) async {
//                 switch (value) {
//                   case MenuAction.Disconnect:
//                     final disconnect = await showDisconnectDialog(context);
//                     if (disconnect) {
//                       context.read<RosBloc>().add(const RosDisconnectEvent());
//                     }
//                 }
//               },
//               itemBuilder: (context) {
//                 return const [
//                   PopupMenuItem<MenuAction>(
//                     value: MenuAction.Disconnect,
//                     child: Text('Disconnect'),
//                   ),
//                 ];
//               },
//             )
//           ],
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(30.0),
//           child: Column(
//             children: [
//               Text("Hello! Connected Count : " + data),
//               Padding(
//                 padding: const EdgeInsets.only(top: 400),
//                 child: Center(
//                   child: Joystick(
//                     stick: const MyJoystickStick(),
//                     listener: (detail) {
//                       String topic = '/cmd_vel';
//                       String datatype = 'geometry_msgs/Twist';
//                       var linear = {'x': detail.y * 0.75, 'y': 0.0, 'z': 0.0};
//                       var angular = {'x': 0.0, 'y': 0.0, 'z': -detail.x * 0.75};
//                       var twist = {'linear': linear, 'angular': angular};

//                       context
//                           .read<RosBloc>()
//                           .add(RosPublishEvent(topic, datatype, twist));
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class MyJoystickStick extends StatelessWidget {
//   final double size;

//   const MyJoystickStick({
//     this.size = 50,
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.5),
//             spreadRadius: 5,
//             blurRadius: 7,
//             offset: const Offset(0, 3),
//           )
//         ],
//         gradient: const LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Color.fromARGB(255, 47, 50, 52),
//             Color.fromARGB(255, 44, 44, 44),
//           ],
//         ),
//       ),
//     );
//   }
// }
