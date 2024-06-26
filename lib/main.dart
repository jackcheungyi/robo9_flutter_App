import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:robo9_mobile_app/Service/Bloc/ros_bloc.dart';
import 'package:robo9_mobile_app/Service/Bloc/ros_event.dart';
import 'package:robo9_mobile_app/Service/Bloc/ros_state.dart';
import 'package:robo9_mobile_app/Service/ros_provider.dart';
import 'package:robo9_mobile_app/views/connection_view.dart';
import 'package:robo9_mobile_app/views/dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LSCM Robo9',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 58, 137, 212)),
        useMaterial3: true,
      ),
      home: BlocProvider<RosBloc>(
        create: (context) => RosBloc(RosProvider()),
        // child: const MyHomePage(title: 'Flutter Demo Home Page'),
        child: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<RosBloc>().add(const RosInitEvent());
    return BlocBuilder<RosBloc, RosState>(builder: (context, state) {
      if (state is RosStateDisconnected || state is RosStateConnectFailure) {
        // print("returning connect page");
        return const ConnectPage();
        // return const Dashboard();
      } else if (state is RosStateConnected) {
        // print("returning controll page");
        return const Dashboard()
            .animate()
            .fade()
            .scale(curve: Curves.decelerate);
      } else {
        return const Scaffold(
          body: CircularProgressIndicator(),
        );
      }
    });
  }
}
